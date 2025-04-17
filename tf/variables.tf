# Datadog API and Application Keys
variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true # Mark as sensitive to prevent it from showing in logs
}

variable "datadog_app_key" {
  description = "Datadog Application Key"
  type        = string
  sensitive   = true # Mark as sensitive to prevent it from showing in logs
}

# Alert Variables
variable "cpu_threshold" {
  description = "CPU usage threshold percentage that triggers the alert"
  type        = number
  default     = 80
}

variable "evaluation_period" {
  description = "Time period (in minutes) over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "environment" {
  description = "Environment (development, testing, production)"
  type        = string
  default     = "development"
}

# Notification Variables
variable "notification_emails" {
  description = "List of email addresses to notify"
  type        = list(string)
  default     = []
}

variable "slack_channel" {
  description = "Slack channel for notifications (without the # symbol)"
  type        = string
  default     = ""
}

# Enhanced Notification Variables
variable "enable_slack_notifications" {
  description = "Enable Slack notifications"
  type        = bool
  default     = true
}

variable "enable_email_notifications" {
  description = "Enable email notifications"
  type        = bool
  default     = true
}

variable "enable_pagerduty_notifications" {
  description = "Enable PagerDuty notifications"
  type        = bool
  default     = false
}

variable "pagerduty_service_key" {
  description = "PagerDuty service integration key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "notification_message_prefix" {
  description = "Prefix for alert notification messages"
  type        = string
  default     = "[MONITORING]"
}

variable "escalation_message" {
  description = "Message sent when alert is escalated after not being resolved"
  type        = string
  default     = "This alert is still not resolved and requires attention!"
}

variable "include_tags_in_title" {
  description = "Include tags in the monitor title"
  type        = bool
  default     = true
}
