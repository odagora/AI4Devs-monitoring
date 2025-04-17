# EC2 CPU Usage Monitor
resource "datadog_monitor" "ec2_cpu_alert" {
  name               = var.include_tags_in_title ? "EC2 High CPU Usage - ${var.environment} [CPU]" : "EC2 High CPU Usage - ${var.environment}"
  type               = "metric alert"
  message            = <<EOT
${var.notification_message_prefix} EC2 CPU usage is above ${var.cpu_threshold}% for ${var.evaluation_period} minutes.

This could indicate:
- High application load
- A process using excessive resources
- Insufficient instance size for the workload

Recommended actions:
1. Check running processes on the instance
2. Review application logs for errors
3. Consider scaling up or out if this is a persistent issue

{{#is_alert}}
Alert details:
* Instance: {{host.name}}
* CPU: {{value}}%
* Threshold: ${var.cpu_threshold}%
* Environment: ${var.environment}
* Alert triggered at: {{last_triggered_at}}
{{/is_alert}}

{{#is_recovery}}
EC2 CPU usage has returned to normal levels.
* Environment: ${var.environment}
* Recovery time: {{last_triggered_at}}
* Duration: {{state.elapsed}} seconds
{{/is_recovery}}

${var.enable_slack_notifications && var.slack_channel != "" ? "@slack-${var.slack_channel}" : ""}
${var.enable_email_notifications && length(var.notification_emails) > 0 ? join(" ", formatlist("@%s", var.notification_emails)) : ""}
${var.enable_pagerduty_notifications && var.pagerduty_service_key != "" ? "@pagerduty-${var.pagerduty_service_key}" : ""}
EOT

  escalation_message = var.escalation_message

  query = "avg(last_${var.evaluation_period}m):avg:aws.ec2.cpuutilization{environment:${var.environment}} by {instance_id} > ${var.cpu_threshold}"

  monitor_thresholds {
    critical = var.cpu_threshold
    warning  = var.cpu_threshold * 0.8  # Warning at 80% of critical threshold
  }

  notify_no_data    = false
  renotify_interval = var.environment == "production" ? 30 : 60  # Renotify more frequently in production

  # For production environment, we want to know if there's no data being reported
  no_data_timeframe = var.environment == "production" ? 20 : 60

  # Different settings based on environment
  priority = var.environment == "production" ? 1 : 3

  # Tags help with organizing and filtering monitors
  tags = [
    "service:ec2",
    "env:${var.environment}",
    "team:devops",
    "managed-by:terraform",
    "metric:cpu"
  ]

  # Automatically resolve after the condition is no longer met
  include_tags = true
  evaluation_delay = 60  # Wait 60 seconds after the time period to evaluate

  # For development/testing: Only evaluate during business hours
  # For production: Evaluate 24/7
  new_host_delay = var.environment == "production" ? 300 : 600
  require_full_window = var.environment == "production" ? true : false

  # Notify on re-notification
  notification_preset_name = "hide_handles"
}

# Note: For Slack and PagerDuty integrations, you should first enable them in the Datadog UI
# and then reference them in the notification messages above.
# The provider might not support direct creation of these integration channels via Terraform.

# Create another monitor for disk usage (as an example of multiple monitors)
resource "datadog_monitor" "ec2_disk_alert" {
  name               = "EC2 High Disk Usage - ${var.environment}"
  type               = "metric alert"
  message            = <<EOT
${var.notification_message_prefix} EC2 disk usage is above 85% for ${var.evaluation_period} minutes.

This could indicate:
- Low disk space that could impact application performance
- Log files growing too large
- Temporary files not being cleaned up

Recommended actions:
1. Check for large log files that can be archived
2. Remove temporary files or unused data
3. Consider increasing disk size if needed

{{#is_alert}}
Alert details:
* Instance: {{host.name}}
* Disk Usage: {{value}}%
* Threshold: 85%
* Environment: ${var.environment}
{{/is_alert}}

${var.enable_slack_notifications && var.slack_channel != "" ? "@slack-${var.slack_channel}" : ""}
${var.enable_email_notifications && length(var.notification_emails) > 0 ? join(" ", formatlist("@%s", var.notification_emails)) : ""}
${var.enable_pagerduty_notifications && var.pagerduty_service_key != "" ? "@pagerduty-${var.pagerduty_service_key}" : ""}
EOT

  query = "avg(last_${var.evaluation_period}m):avg:aws.ec2.disk_used_percent{environment:${var.environment}} by {instance_id} > 85"

  monitor_thresholds {
    critical = 85
    warning  = 75
  }

  notify_no_data    = false
  renotify_interval = var.environment == "production" ? 30 : 60
  priority          = var.environment == "production" ? 1 : 3

  tags = [
    "service:ec2",
    "env:${var.environment}",
    "team:devops",
    "managed-by:terraform",
    "metric:disk"
  ]

  include_tags = true
}
