# =============================================================================
# Terraform Backend Configuration
# =============================================================================
# Uncomment and configure the S3 backend for remote state management
# This is recommended for team collaboration and state locking
# =============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "tgw-multi-region/dev/terraform.tfstate"
#     region         = "eu-west-3"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#     
#     # Optional: Use a specific AWS profile
#     # profile = "your-aws-profile"
#   }
# }

# =============================================================================
# Instructions for Setting Up Remote State
# =============================================================================
#
# 1. Create an S3 bucket for state storage:
#    aws s3api create-bucket \
#      --bucket your-terraform-state-bucket \
#      --region eu-west-3 \
#      --create-bucket-configuration LocationConstraint=eu-west-3
#
# 2. Enable versioning on the bucket:
#    aws s3api put-bucket-versioning \
#      --bucket your-terraform-state-bucket \
#      --versioning-configuration Status=Enabled
#
# 3. Enable encryption on the bucket:
#    aws s3api put-bucket-encryption \
#      --bucket your-terraform-state-bucket \
#      --server-side-encryption-configuration '{
#        "Rules": [{
#          "ApplyServerSideEncryptionByDefault": {
#            "SSEAlgorithm": "aws:kms"
#          }
#        }]
#      }'
#
# 4. Create a DynamoDB table for state locking:
#    aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST \
#      --region eu-west-3
#
# 5. Uncomment the backend configuration above and run:
#    terraform init -migrate-state
#
# =============================================================================
