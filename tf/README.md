# AWS and Datadog Monitoring Setup Guide

This guide will walk you through setting up monitoring for your AWS EC2 instances using Datadog and Terraform. By the end of this guide, you will have deployed infrastructure as code that creates monitoring alerts for CPU and disk usage.

## Table of Contents

- [AWS and Datadog Monitoring Setup Guide](#aws-and-datadog-monitoring-setup-guide)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation Steps](#installation-steps)
    - [1. Install Terraform](#1-install-terraform)
      - [For Windows:](#for-windows)
      - [For macOS (using Homebrew):](#for-macos-using-homebrew)
      - [For Linux (Ubuntu/Debian):](#for-linux-ubuntudebian)
    - [2. Install AWS CLI](#2-install-aws-cli)
      - [For Windows:](#for-windows-1)
      - [For macOS:](#for-macos)
      - [For Linux (Ubuntu/Debian):](#for-linux-ubuntudebian-1)
    - [3. Set Up Datadog Account](#3-set-up-datadog-account)
    - [4. Configure AWS Credentials](#4-configure-aws-credentials)
    - [5. Set Up Terraform Variables](#5-set-up-terraform-variables)
    - [6. Initialize Terraform](#6-initialize-terraform)
    - [7. Deploy the Infrastructure](#7-deploy-the-infrastructure)
  - [Understanding the Configuration](#understanding-the-configuration)
    - [File Structure](#file-structure)
    - [Provider Configuration](#provider-configuration)
    - [Monitors and Alerts](#monitors-and-alerts)
    - [Dashboard](#dashboard)
    - [AWS Integration](#aws-integration)
  - [Customizing the Configuration](#customizing-the-configuration)
    - [Changing Alert Thresholds](#changing-alert-thresholds)
    - [Adding New Alerts](#adding-new-alerts)
    - [Configuring Notifications](#configuring-notifications)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
    - [Debugging Terraform](#debugging-terraform)
  - [Maintenance](#maintenance)
    - [Updating the Configuration](#updating-the-configuration)
    - [Destroying the Infrastructure](#destroying-the-infrastructure)
    - [Backing Up the State](#backing-up-the-state)

## Prerequisites

Before you begin, ensure you have the following:

- A computer with internet access
- Administrative privileges on your computer
- An AWS account with appropriate permissions
- A Datadog account (you can sign up for a free trial if you don't have one)
- Basic familiarity with the command line

## Installation Steps

### 1. Install Terraform

Terraform is the infrastructure as code tool we'll use to deploy our monitoring setup.

#### For Windows:

1. Download the Terraform binary from the [official website](https://www.terraform.io/downloads.html)
2. Extract the downloaded zip file to a directory, e.g., `C:\terraform`
3. Add this directory to your system's PATH environment variable:
   - Right-click on 'This PC' or 'My Computer' and select 'Properties'
   - Click on 'Advanced system settings'
   - Click on 'Environment Variables'
   - Under 'System variables', find the 'Path' variable, select it and click 'Edit'
   - Click 'New' and add the path to your Terraform directory
   - Click 'OK' to close all dialogs
4. Open a new Command Prompt window and verify the installation by typing:
   ```
   terraform version
   ```

#### For macOS (using Homebrew):

1. If you don't have Homebrew installed, install it by running:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Install Terraform using Homebrew:
   ```
   brew install terraform
   ```
3. Verify the installation:
   ```
   terraform version
   ```

#### For Linux (Ubuntu/Debian):

1. Update your package list:
   ```
   sudo apt-get update && sudo apt-get upgrade -y
   ```
2. Install required packages:
   ```
   sudo apt-get install -y gnupg software-properties-common curl
   ```
3. Add the HashiCorp GPG key:
   ```
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   ```
4. Add the HashiCorp repository:
   ```
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   ```
5. Install Terraform:
   ```
   sudo apt-get update && sudo apt-get install terraform
   ```
6. Verify the installation:
   ```
   terraform version
   ```

### 2. Install AWS CLI

The AWS Command Line Interface (CLI) is a tool that enables you to interact with AWS services using commands in your command-line shell.

#### For Windows:

1. Download the AWS CLI MSI installer for Windows (64-bit) from the [official AWS website](https://aws.amazon.com/cli/)
2. Run the downloaded MSI installer and follow the on-screen instructions
3. Open a new Command Prompt window and verify the installation:
   ```
   aws --version
   ```

#### For macOS:

1. Install AWS CLI using Homebrew:
   ```
   brew install awscli
   ```
2. Verify the installation:
   ```
   aws --version
   ```

#### For Linux (Ubuntu/Debian):

1. Install AWS CLI using pip:
   ```
   sudo apt-get install -y python3-pip
   pip3 install awscli --upgrade --user
   ```
2. Add the AWS CLI executable to your PATH:
   ```
   echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```
3. Verify the installation:
   ```
   aws --version
   ```

### 3. Set Up Datadog Account

1. Sign up for a Datadog account at [https://www.datadoghq.com/](https://www.datadoghq.com/) if you don't have one already.
2. Once logged in, navigate to "Organization Settings" → "API Keys".
3. Create a new API key and make note of it.
4. Navigate to "Organization Settings" → "Application Keys".
5. Create a new Application key and make note of it.

You'll need both these keys in the next steps.

### 4. Configure AWS Credentials

You need to configure your AWS credentials so that Terraform can deploy resources to your AWS account.

1. Open a terminal or command prompt.
2. Run the AWS configure command:
   ```
   aws configure
   ```
3. Enter your AWS Access Key ID and Secret Access Key when prompted.
4. Enter your default region (e.g., us-east-1) and default output format (json is recommended).

Your credentials will be stored in `~/.aws/credentials` on Linux/macOS or `C:\Users\USERNAME\.aws\credentials` on Windows.

### 5. Set Up Terraform Variables

1. Navigate to the `tf` directory in this project.
2. Create a new file named `terraform.tfvars` based on the provided example:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Open the `terraform.tfvars` file in a text editor and update the values:
   - Replace `"your_datadog_api_key_here"` with the API key you obtained from Datadog.
   - Replace `"your_datadog_app_key_here"` with the Application key you obtained from Datadog.
   - Update the notification email addresses.
   - Configure the Slack channel if you want Slack notifications.
   - Update other variables as needed.

### 6. Initialize Terraform

1. Open a terminal or command prompt.
2. Navigate to the `tf` directory in this project.
3. Run the following command to initialize Terraform:
   ```
   terraform init
   ```
   This command initializes the Terraform working directory, downloading any necessary providers.

### 7. Deploy the Infrastructure

1. Still in the `tf` directory, generate a Terraform plan to see what changes will be made:
   ```
   terraform plan -out=tfplan
   ```
   This command shows a preview of the resources that will be created, modified, or destroyed.

2. Review the plan carefully. The output will show:
   - The IAM role and policy that will be created for Datadog to access AWS metrics.
   - The Datadog monitors that will be set up for CPU and disk usage.
   - The Datadog dashboard that will be created.

3. If the plan looks good, apply it:
   ```
   terraform apply tfplan
   ```

4. Terraform will create all the resources. This process may take a few minutes.

5. Once completed, Terraform will output several values including URLs to your Datadog monitors and dashboard. Save these for future reference.

## Understanding the Configuration

### File Structure

Our Terraform configuration consists of several files:

- `main.tf`: Contains the core AWS and Datadog integration setup.
- `variables.tf`: Defines all the variables used in the configuration.
- `provider.tf`: Configures the AWS and Datadog providers.
- `datadog.tf`: Contains the Datadog monitor configurations.
- `dashboard.tf`: Defines the Datadog dashboard.
- `outputs.tf`: Defines the outputs that are displayed after applying the configuration.
- `terraform.tfvars`: Contains the actual values for the variables (you created this file based on the example).

### Provider Configuration

The provider configuration in `provider.tf` sets up the AWS and Datadog providers. It specifies:

- The AWS region where resources will be deployed.
- The Datadog API and Application keys for authentication.
- The Datadog API URL endpoint.

### Monitors and Alerts

The `datadog.tf` file contains the definitions for the monitoring alerts:

- **CPU Usage Monitor**: Alerts when CPU usage exceeds the defined threshold (default 80%).
- **Disk Usage Monitor**: Alerts when disk usage exceeds 85%.

Each monitor includes:
- A query that defines what metric to monitor and what threshold triggers an alert.
- A message template that provides information about the alert, causes, and recommended actions.
- Configuration for notification channels (email, Slack, PagerDuty).
- Different behavior for development and production environments.

### Dashboard

The `dashboard.tf` file defines a dashboard in Datadog that visualizes:

- CPU utilization across EC2 instances.
- Memory usage.
- Network traffic.
- Disk usage.
- Alert status.

The dashboard includes markers for warning and critical thresholds and a text widget with information about the environment and thresholds.

### AWS Integration

The AWS integration is set up in `main.tf` and includes:

- An IAM role for Datadog to assume.
- An IAM policy that grants Datadog permissions to access CloudWatch metrics and logs.
- A Datadog AWS integration that connects the AWS account with Datadog.

## Customizing the Configuration

### Changing Alert Thresholds

To change the threshold for the CPU alert:

1. Edit the `terraform.tfvars` file.
2. Change the value of `cpu_threshold` to your desired threshold percentage.
3. Run `terraform plan` and `terraform apply` to apply the changes.

### Adding New Alerts

To add a new alert:

1. Edit the `datadog.tf` file.
2. Add a new `datadog_monitor` resource block.
3. Configure the alert with a name, type, query, message, and thresholds.
4. Run `terraform plan` and `terraform apply` to apply the changes.

Example of adding a memory usage alert:

```hcl
resource "datadog_monitor" "ec2_memory_alert" {
  name               = "EC2 High Memory Usage - ${var.environment}"
  type               = "metric alert"
  message            = <<EOT
${var.notification_message_prefix} EC2 memory usage is above 90% for ${var.evaluation_period} minutes.

This could indicate:
- Memory leaks in applications
- Insufficient memory for the workload
- Too many processes running simultaneously

Recommended actions:
1. Check application memory usage
2. Restart memory-intensive processes
3. Consider scaling up instance memory

{{#is_alert}}
Alert details:
* Instance: {{host.name}}
* Memory Usage: {{value}}%
* Threshold: 90%
* Environment: ${var.environment}
{{/is_alert}}

${var.enable_slack_notifications && var.slack_channel != "" ? "@slack-${var.slack_channel}" : ""}
${var.enable_email_notifications && length(var.notification_emails) > 0 ? join(" ", formatlist("@%s", var.notification_emails)) : ""}
EOT

  query = "avg(last_${var.evaluation_period}m):avg:aws.ec2.memory_utilization{environment:${var.environment}} by {instance_id} > 90"

  monitor_thresholds {
    critical = 90
    warning  = 80
  }

  notify_no_data    = false
  renotify_interval = var.environment == "production" ? 30 : 60
  priority          = var.environment == "production" ? 1 : 3

  tags = [
    "service:ec2",
    "env:${var.environment}",
    "team:devops",
    "managed-by:terraform",
    "metric:memory"
  ]

  include_tags = true
}
```

### Configuring Notifications

To configure notifications:

1. Edit the `terraform.tfvars` file.
2. Update the following variables as needed:
   - `notification_emails`: List of email addresses to notify.
   - `enable_slack_notifications`: Set to `true` or `false`.
   - `slack_channel`: Name of the Slack channel (without the # symbol).
   - `enable_pagerduty_notifications`: Set to `true` or `false`.
   - `pagerduty_service_key`: Your PagerDuty service integration key.

For Slack and PagerDuty notifications to work, you need to first set up these integrations in the Datadog UI:

1. **Slack Integration**:
   - Log in to your Datadog account.
   - Go to Integrations → Slack.
   - Follow the instructions to authorize Datadog for your Slack workspace.
   - Add the channels you want to use for notifications.

2. **PagerDuty Integration**:
   - Log in to your Datadog account.
   - Go to Integrations → PagerDuty.
   - Follow the instructions to connect your PagerDuty account.
   - Create a service in PagerDuty and get the service integration key.

## Troubleshooting

### Common Issues

1. **Terraform initialization fails**:
   - Ensure you have internet connectivity.
   - Check if you have the correct permissions to download providers.
   - Run `terraform init -upgrade` to force re-downloading providers.

2. **AWS authentication issues**:
   - Ensure your AWS credentials are correctly configured.
   - Run `aws sts get-caller-identity` to verify your AWS credentials are working.

3. **Datadog authentication issues**:
   - Double-check your API and Application keys in `terraform.tfvars`.
   - Ensure the keys have the necessary permissions in Datadog.

4. **Alert notifications not working**:
   - Verify that you've set up the integrations in the Datadog UI.
   - Check that the channel names or email addresses are correctly specified.
   - Ensure your email isn't blocking notifications from Datadog.

### Debugging Terraform

To get more detailed output from Terraform, set the `TF_LOG` environment variable:

```
# For Windows Command Prompt
set TF_LOG=DEBUG

# For PowerShell
$env:TF_LOG="DEBUG"

# For Linux/macOS
export TF_LOG=DEBUG
```

Then run your Terraform commands as usual. The output will be much more verbose, which can help identify issues.

## Maintenance

### Updating the Configuration

To update the configuration after making changes:

1. Edit the relevant Terraform files.
2. Run `terraform plan` to see the changes that will be made.
3. Run `terraform apply` to apply the changes.

### Destroying the Infrastructure

If you want to remove all the resources created by this configuration:

1. Navigate to the `tf` directory in a terminal or command prompt.
2. Run:
   ```
   terraform destroy
   ```
3. Type `yes` when prompted to confirm.

This will remove all the resources created by Terraform, including IAM roles, policies, and Datadog monitors and dashboards.

### Backing Up the State

Terraform keeps track of the infrastructure it manages in a state file. By default, this is stored locally as `terraform.tfstate`. It's a good practice to back up this file or configure a remote backend.

To back up the state file:

1. Simply copy the `terraform.tfstate` file to a secure location.

To configure a remote backend (recommended for team environments):

1. Edit the `main.tf` file and add a backend configuration:
   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket"
       key    = "monitoring/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```
2. Run `terraform init` to initialize the backend.

This ensures that the state is stored in S3, allowing team members to collaborate and preventing loss of state if your local machine fails.

---

By following this guide, you've successfully set up monitoring for your AWS EC2 instances using Datadog and Terraform. Your monitoring setup includes alerts for CPU and disk usage, a comprehensive dashboard, and notifications through multiple channels.

If you have any questions or encounter issues, please refer to the troubleshooting section or consult the official [Terraform documentation](https://www.terraform.io/docs) and [Datadog documentation](https://docs.datadoghq.com/).