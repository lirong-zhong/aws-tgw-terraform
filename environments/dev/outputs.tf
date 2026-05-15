# =============================================================================
# Outputs - Dev Environment
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs - Paris
# -----------------------------------------------------------------------------

output "paris_vpc_id" {
  description = "VPC ID in Paris region"
  value       = module.vpc_paris.vpc_id
}

output "paris_vpc_cidr" {
  description = "VPC CIDR in Paris region"
  value       = module.vpc_paris.vpc_cidr
}

output "paris_public_subnet_ids" {
  description = "Public subnet IDs in Paris region"
  value       = module.vpc_paris.public_subnet_ids
}

output "paris_private_subnet_ids" {
  description = "Private subnet IDs in Paris region"
  value       = module.vpc_paris.private_subnet_ids
}

output "paris_tgw_subnet_ids" {
  description = "TGW subnet IDs in Paris region"
  value       = module.vpc_paris.tgw_subnet_ids
}

# -----------------------------------------------------------------------------
# VPC Outputs - Frankfurt
# -----------------------------------------------------------------------------

output "frankfurt_vpc_id" {
  description = "VPC ID in Frankfurt region"
  value       = module.vpc_frankfurt.vpc_id
}

output "frankfurt_vpc_cidr" {
  description = "VPC CIDR in Frankfurt region"
  value       = module.vpc_frankfurt.vpc_cidr
}

output "frankfurt_public_subnet_ids" {
  description = "Public subnet IDs in Frankfurt region"
  value       = module.vpc_frankfurt.public_subnet_ids
}

output "frankfurt_private_subnet_ids" {
  description = "Private subnet IDs in Frankfurt region"
  value       = module.vpc_frankfurt.private_subnet_ids
}

output "frankfurt_tgw_subnet_ids" {
  description = "TGW subnet IDs in Frankfurt region"
  value       = module.vpc_frankfurt.tgw_subnet_ids
}

# -----------------------------------------------------------------------------
# Transit Gateway Outputs - Paris
# -----------------------------------------------------------------------------

output "paris_tgw_id" {
  description = "Transit Gateway ID in Paris region"
  value       = module.tgw_paris.tgw_id
}

output "paris_tgw_route_table_id" {
  description = "Transit Gateway route table ID in Paris region"
  value       = module.tgw_paris.tgw_route_table_id
}

# -----------------------------------------------------------------------------
# Transit Gateway Outputs - Frankfurt
# -----------------------------------------------------------------------------

output "frankfurt_tgw_id" {
  description = "Transit Gateway ID in Frankfurt region"
  value       = module.tgw_frankfurt.tgw_id
}

output "frankfurt_tgw_route_table_id" {
  description = "Transit Gateway route table ID in Frankfurt region"
  value       = module.tgw_frankfurt.tgw_route_table_id
}

# -----------------------------------------------------------------------------
# TGW Peering Outputs
# -----------------------------------------------------------------------------

output "tgw_peering_attachment_id" {
  description = "TGW peering attachment ID"
  value       = module.tgw_peering.peering_attachment_id
}

output "tgw_peering_summary" {
  description = "Summary of TGW peering configuration"
  value       = module.tgw_peering.peering_summary
}

# -----------------------------------------------------------------------------
# Test Instance Outputs - Paris
# -----------------------------------------------------------------------------

output "paris_test_instance_id" {
  description = "Test instance ID in Paris region"
  value       = var.create_test_instances ? module.test_instance_paris[0].instance_id : null
}

output "paris_test_instance_private_ip" {
  description = "Private IP of Paris test instance"
  value       = var.create_test_instances ? module.test_instance_paris[0].private_ip : null
}

output "paris_test_instance_public_ip" {
  description = "Public IP of Paris test instance"
  value       = var.create_test_instances ? module.test_instance_paris[0].public_ip : null
}

output "paris_ssm_session_command" {
  description = "AWS CLI command to start SSM session to Paris test instance"
  value       = var.create_test_instances ? module.test_instance_paris[0].ssm_start_session_command : null
}

# -----------------------------------------------------------------------------
# Test Instance Outputs - Frankfurt
# -----------------------------------------------------------------------------

output "frankfurt_test_instance_id" {
  description = "Test instance ID in Frankfurt region"
  value       = var.create_test_instances ? module.test_instance_frankfurt[0].instance_id : null
}

output "frankfurt_test_instance_private_ip" {
  description = "Test instance private IP in Frankfurt region"
  value       = var.create_test_instances ? module.test_instance_frankfurt[0].private_ip : null
}

output "frankfurt_test_instance_public_ip" {
  description = "Public IP of Frankfurt test instance"
  value       = var.create_test_instances ? module.test_instance_frankfurt[0].public_ip : null
}

output "frankfurt_ssm_session_command" {
  description = "AWS CLI command to start SSM session to Frankfurt test instance"
  value       = var.create_test_instances ? module.test_instance_frankfurt[0].ssm_start_session_command : null
}

# -----------------------------------------------------------------------------
# Connectivity Test Instructions
# -----------------------------------------------------------------------------

output "connectivity_test_instructions" {
  description = "Instructions for testing connectivity between regions"
  value = var.create_test_instances ? join("\n", [
    "",
    "============================================================",
    "CONNECTIVITY TEST INSTRUCTIONS",
    "============================================================",
    "",
    "1. Connect to Paris test instance:",
    "   ${module.test_instance_paris[0].ssm_start_session_command}",
    "",
    "2. From Paris instance, ping Frankfurt instance:",
    "   ping ${module.test_instance_frankfurt[0].private_ip}",
    "",
    "3. Run the connectivity test script:",
    "   ./test-connectivity.sh ${module.test_instance_frankfurt[0].private_ip}",
    "",
    "4. Connect to Frankfurt test instance:",
    "   ${module.test_instance_frankfurt[0].ssm_start_session_command}",
    "",
    "5. From Frankfurt instance, ping Paris instance:",
    "   ping ${module.test_instance_paris[0].private_ip}",
    "",
    "============================================================",
    ""
  ]) : "Test instances not created. Set create_test_instances = true to enable."
}
