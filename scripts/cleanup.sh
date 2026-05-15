#!/bin/bash
# =============================================================================
# Cleanup Script for TGW Multi-Region Infrastructure
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

# Destroy infrastructure
destroy_infrastructure() {
    print_header "Destroying Infrastructure"
    cd "$ENV_DIR"
    
    print_warning "This will destroy ALL resources in the dev environment!"
    print_warning "Resources to be destroyed:"
    echo "  - VPCs in eu-west-3 (Paris) and eu-central-1 (Frankfurt)"
    echo "  - Transit Gateways and peering"
    echo "  - EC2 test instances"
    echo "  - NAT Gateways, Internet Gateways"
    echo "  - All associated route tables and security groups"
    echo ""
    
    read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    print_info "Running terraform destroy..."
    terraform destroy -auto-approve
    
    print_success "All resources destroyed"
}

# Clean local files
clean_local() {
    print_header "Cleaning Local Files"
    cd "$ENV_DIR"
    
    # Remove Terraform files
    rm -rf .terraform
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f tfplan
    rm -f crash.log
    
    print_success "Local Terraform files cleaned"
}

# Main
main() {
    print_header "TGW Multi-Region Infrastructure Cleanup"
    echo "Date: $(date)"
    echo "Environment: dev"
    
    case "${1:-destroy}" in
        destroy)
            destroy_infrastructure
            ;;
        local)
            clean_local
            ;;
        all)
            destroy_infrastructure
            clean_local
            ;;
        *)
            echo "Usage: $0 {destroy|local|all}"
            echo ""
            echo "  destroy - Destroy AWS infrastructure"
            echo "  local   - Clean local Terraform files"
            echo "  all     - Destroy infrastructure and clean local files"
            exit 1
            ;;
    esac
}

main "$@"
