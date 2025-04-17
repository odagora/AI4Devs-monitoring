terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1" # Change to your AWS region
}

# Configuración del proveedor de Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  # Configura la región de Datadog
  api_url = "https://api.us5.datadoghq.com"
}

# Variables de entorno para las claves de Datadog
variable "datadog_api_key" {
  description = "API Key para Datadog"
  type        = string
}

variable "datadog_app_key" {
  description = "App Key para Datadog"
  type        = string
}

# Create an IAM role for Datadog
resource "aws_iam_role" "datadog_role" {
  name = "DatadogIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::464622532012:root" # Datadog's AWS account
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "datadog-external-id"  # You'll get this from Datadog
          }
        }
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "datadog_policy_attachment" {
  role       = aws_iam_role.datadog_role.name
  policy_arn = aws_iam_policy.datadog_policy.arn
}

# Política de IAM para permitir a Datadog acceder a CloudWatch
resource "aws_iam_policy" "datadog_policy" {
  name        = "DatadogPolicy"
  description = "Política para permitir a Datadog acceder a CloudWatch"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ],
        "Resource": "*"
      }
    ]
  })
}

# AWS Integration in Datadog
resource "datadog_integration_aws" "main" {
  account_id         = data.aws_caller_identity.current.account_id
  role_name          = aws_iam_role.datadog_role.name
  filter_tags        = ["environment:${var.environment}"]
  host_tags          = ["env:${var.environment}", "monitored:true"]
  account_specific_namespace_rules = {
    # Enable specific AWS services to monitor
    ec2              = true
    s3               = true
    cloudfront       = false
    dynamodb         = false
    lambda           = false
    rds              = false
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Obtener los nombres de las instancias EC2 automáticamente
data "aws_instances" "all" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# The dashboard resource is now moved to dashboard.tf
