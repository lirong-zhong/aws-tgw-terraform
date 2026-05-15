# =============================================================================
# EC2 Test Instance Module Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# Instance Outputs
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the test EC2 instance"
  value       = aws_instance.test.id
}

output "instance_arn" {
  description = "ARN of the test EC2 instance"
  value       = aws_instance.test.arn
}

output "private_ip" {
  description = "Private IP address of the test instance"
  value       = aws_instance.test.private_ip
}

output "private_dns" {
  description = "Private DNS name of the test instance"
  value       = aws_instance.test.private_dns
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "ID of the test instance security group"
  value       = aws_security_group.test_instance.id
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "iam_role_arn" {
  description = "ARN of the IAM role for SSM"
  value       = aws_iam_role.ssm.arn
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ssm.arn
}

# -----------------------------------------------------------------------------
# SSM Session Manager Connection
# -----------------------------------------------------------------------------

output "ssm_start_session_command" {
  description = "AWS CLI command to start SSM session"
  value       = "aws ssm start-session --target ${aws_instance.test.id} --region ${data.aws_region.current.name}"
}

# -----------------------------------------------------------------------------
# Test Information
# -----------------------------------------------------------------------------

output "test_instance_info" {
  description = "Summary of test instance information"
  value = {
    instance_id = aws_instance.test.id
    private_ip  = aws_instance.test.private_ip
    region      = data.aws_region.current.name
    region_name = var.region_name
    ami_id      = data.aws_ami.amazon_linux_2023.id
  }
}
