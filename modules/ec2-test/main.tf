# =============================================================================
# EC2 Test Instance Module - AWS Best Practices Implementation
# =============================================================================
# This module creates test EC2 instances for connectivity verification with:
# - Latest Amazon Linux 2023 AMI
# - SSM Session Manager access (no SSH key required)
# - Proper security groups
# - User data for testing tools
# =============================================================================

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_region" "current" {}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Module      = "ec2-test"
    Region      = data.aws_region.current.name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# IAM Role for SSM Session Manager
# AWS Best Practice: Use Session Manager instead of SSH for secure access
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ssm" {
  name = "${var.project_name}-ssm-role-${var.region_name}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ssm-role-${var.region_name}-${var.environment}"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project_name}-ssm-profile-${var.region_name}-${var.environment}"
  role = aws_iam_role.ssm.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ssm-profile-${var.region_name}-${var.environment}"
  })
}

# -----------------------------------------------------------------------------
# Security Group
# AWS Best Practice: Least privilege access
# -----------------------------------------------------------------------------

resource "aws_security_group" "test_instance" {
  name        = "${var.project_name}-test-sg-${var.region_name}-${var.environment}"
  description = "Security group for test instances"
  vpc_id      = var.vpc_id

  # Allow ICMP (ping) from VPC and peer VPC
  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "ICMP from peer VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.peer_vpc_cidr]
  }

  # Allow SSH from VPC (for internal access)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-test-sg-${var.region_name}-${var.environment}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# EC2 Test Instance
# -----------------------------------------------------------------------------

resource "aws_instance" "test" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.test_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  key_name               = var.key_name

  # Enable detailed monitoring for production
  monitoring = var.environment == "prod" ? true : false

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-test-root-${var.region_name}-${var.environment}"
    })
  }

  # User data for installing testing tools
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Update system
    dnf update -y

    # Install network testing tools
    dnf install -y \
      traceroute \
      mtr \
      nmap-ncat \
      bind-utils \
      tcpdump \
      iperf3 \
      jq

    # Create test script
    cat > /home/ec2-user/test-connectivity.sh << 'SCRIPT'
    #!/bin/bash
    echo "=== Connectivity Test Script ==="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
    echo ""
    
    if [ -n "$1" ]; then
      echo "Testing connectivity to: $1"
      echo ""
      echo "--- Ping Test ---"
      ping -c 4 $1
      echo ""
      echo "--- Traceroute ---"
      traceroute $1
    else
      echo "Usage: ./test-connectivity.sh <target-ip>"
    fi
    SCRIPT
    chmod +x /home/ec2-user/test-connectivity.sh
    chown ec2-user:ec2-user /home/ec2-user/test-connectivity.sh

    # Log completion
    echo "Test instance setup completed at $(date)" >> /var/log/user-data.log
  EOF
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 required (AWS best practice)
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-test-instance-${var.region_name}-${var.environment}"
  })

  lifecycle {
    ignore_changes = [ami]  # Don't recreate on AMI updates
  }
}

# -----------------------------------------------------------------------------
# VPC Endpoint for SSM (if in private subnet)
# Required for Session Manager access without internet
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ssm" {
  count = var.create_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ssm-endpoint-${var.region_name}-${var.environment}"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.create_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ssmmessages-endpoint-${var.region_name}-${var.environment}"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = var.create_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2messages-endpoint-${var.region_name}-${var.environment}"
  })
}

resource "aws_security_group" "vpc_endpoints" {
  count = var.create_ssm_endpoints ? 1 : 0

  name        = "${var.project_name}-vpce-sg-${var.region_name}-${var.environment}"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpce-sg-${var.region_name}-${var.environment}"
  })
}
