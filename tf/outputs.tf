# Datadog Monitor Outputs
output "monitor_id" {
  description = "ID of the created Datadog monitor"
  value       = datadog_monitor.ec2_cpu_alert.id
}

output "monitor_url" {
  description = "URL to the created Datadog monitor"
  value       = "https://app.datadoghq.com/monitors/${datadog_monitor.ec2_cpu_alert.id}"
}

output "dashboard_url" {
  description = "URL to the created Datadog dashboard"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.ec2_monitoring.id}"
}

output "aws_account_id" {
  description = "AWS Account ID where monitoring is set up"
  value       = data.aws_caller_identity.current.account_id
}

output "datadog_role_arn" {
  description = "ARN of the IAM role for Datadog integration"
  value       = aws_iam_role.datadog_role.arn
}

output "environment" {
  description = "Current environment being monitored"
  value       = var.environment
}

output "alert_threshold" {
  description = "CPU threshold that triggers the alert"
  value       = "${var.cpu_threshold}%"
}

output "evaluation_period" {
  description = "Time period over which the metric is evaluated"
  value       = "${var.evaluation_period} minutes"
}

# Notification Outputs
output "notification_channels" {
  description = "Notification channels configured"
  value = {
    slack_enabled = var.enable_slack_notifications
    slack_channel = var.enable_slack_notifications ? var.slack_channel : "Not configured"
    email_enabled = var.enable_email_notifications
    email_recipients = var.enable_email_notifications ? var.notification_emails : ["None configured"]
    pagerduty_enabled = var.enable_pagerduty_notifications
  }
}

output "monitors_created" {
  description = "List of monitors created"
  value = [
    {
      name = datadog_monitor.ec2_cpu_alert.name
      type = "CPU Usage"
      threshold = "${var.cpu_threshold}%"
    },
    {
      name = datadog_monitor.ec2_disk_alert.name
      type = "Disk Usage"
      threshold = "85%"
    }
  ]
}
