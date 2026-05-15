#!/bin/bash
# =============================================================================
# Deployment Script for TGW Multi-Region Infrastructure
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/dev"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}! $1${NC}"; }
print_info() { echo -e "${BLUE}→ $1${NC}"; }

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi
    print_success "Terraform $(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4) is installed"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    print_success "AWS CLI is installed"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured"
        print_info "Run 'aws configure' or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    print_success "AWS credentials are configured"
    
    # Check terraform.tfvars
    if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found"
        print_info "Copying from terraform.tfvars.example..."
        cp "$ENV_DIR/terraform.tfvars.example" "$ENV_DIR/terraform.tfvars"
        print_warning "Please edit $ENV_DIR/terraform.tfvars with your values"
        exit 1
    fi
    print_success "terraform.tfvars exists"
}

# Initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"
    cd "$ENV_DIR"
    terraform init -upgrade
    print_success "Terraform initialized"
}

# Validate configuration
validate_terraform() {
    print_header "Validating Configuration"
    cd "$ENV_DIR"
    terraform validate
    print_success "Configuration is valid"
}

# Plan deployment
plan_deployment() {
    print_header "Planning Deployment"
    cd "$ENV_DIR"
    terraform plan -out=tfplan
    print_success "Plan created: tfplan"
}

# Apply deployment
apply_deployment() {
    print_header "Applying Deployment"
    cd "$ENV_DIR"
    
    if [ ! -f "tfplan" ]; then
        print_error "No plan file found. Run with --plan first"
        exit 1
    fi
    
    terraform apply tfplan
    rm -f tfplan
    print_success "Deployment completed"
}

# Show outputs
show_outputs() {
    print_header "Deployment Outputs"
    cd "$ENV_DIR"
    terraform output
}

# Main
main() {
    print_header "TGW Multi-Region Infrastructure Deployment"
    echo "Date: $(date)"
    echo "Environment: dev"
    
    case "${1:-all}" in
        init)
            check_prerequisites
            init_terraform
            ;;
        plan)
            check_prerequisites
            init_terraform
            validate_terraform
            plan_deployment
            ;;
        apply)
            apply_deployment
            show_outputs
            ;;
        all)
            check_prerequisites
            init_terraform
            validate_terraform
            plan_deployment
            echo ""
            read -p "Do you want to apply this plan? (yes/no): " confirm
            if [ "$confirm" == "yes" ]; then
                apply_deployment
                show_outputs
            else
                print_warning "Deployment cancelled"
            fi
            ;;
        outputs)
            show_outputs
            ;;
        *)
            echo "Usage: $0 {init|plan|apply|all|outputs}"
            exit 1
            ;;
    esac
}

main "$@"
