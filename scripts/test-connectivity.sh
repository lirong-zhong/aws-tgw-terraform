#!/bin/bash
# =============================================================================
# TGW Inter-Region Connectivity Test Script
# =============================================================================
# This script tests connectivity between Paris and Frankfurt regions
# via Transit Gateway peering
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    print_success "AWS CLI is installed"
}

# Check if Terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    print_success "Terraform is installed"
}

# Get Terraform outputs
get_terraform_outputs() {
    print_info "Getting Terraform outputs..."
    
    cd "$(dirname "$0")/../environments/dev"
    
    PARIS_INSTANCE_ID=$(terraform output -raw paris_test_instance_id 2>/dev/null || echo "")
    FRANKFURT_INSTANCE_ID=$(terraform output -raw frankfurt_test_instance_id 2>/dev/null || echo "")
    PARIS_PRIVATE_IP=$(terraform output -raw paris_test_instance_private_ip 2>/dev/null || echo "")
    FRANKFURT_PRIVATE_IP=$(terraform output -raw frankfurt_test_instance_private_ip 2>/dev/null || echo "")
    
    if [ -z "$PARIS_INSTANCE_ID" ] || [ -z "$FRANKFURT_INSTANCE_ID" ]; then
        print_error "Could not get instance IDs from Terraform outputs"
        print_warning "Make sure you have run 'terraform apply' and test instances are created"
        exit 1
    fi
    
    print_success "Got Terraform outputs"
    echo ""
    print_info "Paris Instance ID: $PARIS_INSTANCE_ID"
    print_info "Paris Private IP: $PARIS_PRIVATE_IP"
    print_info "Frankfurt Instance ID: $FRANKFURT_INSTANCE_ID"
    print_info "Frankfurt Private IP: $FRANKFURT_PRIVATE_IP"
}

# Check instance status
check_instance_status() {
    local instance_id=$1
    local region=$2
    local name=$3
    
    print_info "Checking $name instance status..."
    
    status=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --region "$region" \
        --query 'Reservations[0].Instances[0].State.Name' \
        --output text 2>/dev/null || echo "error")
    
    if [ "$status" == "running" ]; then
        print_success "$name instance is running"
        return 0
    else
        print_error "$name instance is not running (status: $status)"
        return 1
    fi
}

# Check SSM agent status
check_ssm_status() {
    local instance_id=$1
    local region=$2
    local name=$3
    
    print_info "Checking SSM agent status for $name..."
    
    ssm_status=$(aws ssm describe-instance-information \
        --filters "Key=InstanceIds,Values=$instance_id" \
        --region "$region" \
        --query 'InstanceInformationList[0].PingStatus' \
        --output text 2>/dev/null || echo "error")
    
    if [ "$ssm_status" == "Online" ]; then
        print_success "$name SSM agent is online"
        return 0
    else
        print_warning "$name SSM agent is not online (status: $ssm_status)"
        print_info "Wait a few minutes for the SSM agent to come online"
        return 1
    fi
}

# Run ping test via SSM
run_ping_test() {
    local source_instance=$1
    local source_region=$2
    local target_ip=$3
    local source_name=$4
    local target_name=$5
    
    print_info "Running ping test from $source_name to $target_name ($target_ip)..."
    
    result=$(aws ssm send-command \
        --instance-ids "$source_instance" \
        --region "$source_region" \
        --document-name "AWS-RunShellScript" \
        --parameters "commands=['ping -c 4 $target_ip']" \
        --output json 2>/dev/null)
    
    command_id=$(echo "$result" | grep -o '"CommandId": "[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$command_id" ]; then
        print_error "Failed to send ping command"
        return 1
    fi
    
    print_info "Waiting for command to complete..."
    sleep 10
    
    output=$(aws ssm get-command-invocation \
        --command-id "$command_id" \
        --instance-id "$source_instance" \
        --region "$source_region" \
        --query 'StandardOutputContent' \
        --output text 2>/dev/null || echo "")
    
    if echo "$output" | grep -q "0% packet loss"; then
        print_success "Ping test successful!"
        echo "$output"
        return 0
    else
        print_error "Ping test failed"
        echo "$output"
        return 1
    fi
}

# Main function
main() {
    print_header "TGW Inter-Region Connectivity Test"
    
    echo "Date: $(date)"
    echo ""
    
    # Prerequisites check
    print_header "Checking Prerequisites"
    check_aws_cli
    check_terraform
    
    # Get Terraform outputs
    print_header "Getting Infrastructure Information"
    get_terraform_outputs
    
    # Check instance status
    print_header "Checking Instance Status"
    check_instance_status "$PARIS_INSTANCE_ID" "eu-west-3" "Paris"
    check_instance_status "$FRANKFURT_INSTANCE_ID" "eu-central-1" "Frankfurt"
    
    # Check SSM status
    print_header "Checking SSM Agent Status"
    paris_ssm_ok=true
    frankfurt_ssm_ok=true
    check_ssm_status "$PARIS_INSTANCE_ID" "eu-west-3" "Paris" || paris_ssm_ok=false
    check_ssm_status "$FRANKFURT_INSTANCE_ID" "eu-central-1" "Frankfurt" || frankfurt_ssm_ok=false
    
    if [ "$paris_ssm_ok" = false ] || [ "$frankfurt_ssm_ok" = false ]; then
        print_warning "SSM agents are not ready. Please wait and try again."
        print_info "You can manually connect using:"
        echo ""
        echo "  aws ssm start-session --target $PARIS_INSTANCE_ID --region eu-west-3"
        echo "  aws ssm start-session --target $FRANKFURT_INSTANCE_ID --region eu-central-1"
        echo ""
        exit 1
    fi
    
    # Run connectivity tests
    print_header "Running Connectivity Tests"
    
    print_info "Test 1: Paris → Frankfurt"
    run_ping_test "$PARIS_INSTANCE_ID" "eu-west-3" "$FRANKFURT_PRIVATE_IP" "Paris" "Frankfurt"
    
    echo ""
    
    print_info "Test 2: Frankfurt → Paris"
    run_ping_test "$FRANKFURT_INSTANCE_ID" "eu-central-1" "$PARIS_PRIVATE_IP" "Frankfurt" "Paris"
    
    # Summary
    print_header "Test Summary"
    print_success "All connectivity tests completed!"
    echo ""
    print_info "To manually test, connect to instances using:"
    echo ""
    echo "  Paris:     aws ssm start-session --target $PARIS_INSTANCE_ID --region eu-west-3"
    echo "  Frankfurt: aws ssm start-session --target $FRANKFURT_INSTANCE_ID --region eu-central-1"
    echo ""
    print_info "Then run: ./test-connectivity.sh <target-ip>"
}

# Run main function
main "$@"
