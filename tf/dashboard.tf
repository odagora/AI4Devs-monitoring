# EC2 Monitoring Dashboard
resource "datadog_dashboard" "ec2_monitoring" {
  title       = "EC2 Monitoring - ${var.environment}"
  description = "Dashboard for monitoring EC2 instances in ${var.environment} environment"
  layout_type = "ordered"

  # CPU Usage Widget
  widget {
    timeseries_definition {
      title = "CPU Utilization by Instance"
      request {
        q = "avg:aws.ec2.cpuutilization{environment:${var.environment}} by {instance_id}"
        display_type = "line"
      }

      marker {
        display_type = "error dashed"
        value = "y = ${var.cpu_threshold}"
        label = "Critical Threshold"
      }

      marker {
        display_type = "warning dashed"
        value = "y = ${var.cpu_threshold * 0.8}"
        label = "Warning Threshold"
      }

      custom_link {
        label = "View CPU Metrics in AWS Console"
        link  = "https://console.aws.amazon.com/cloudwatch/home"
      }
    }
  }

  # Memory Usage Widget
  widget {
    timeseries_definition {
      title = "Memory Usage by Instance"
      request {
        q = "avg:aws.ec2.memory_utilization{environment:${var.environment}} by {instance_id}"
        display_type = "line"
      }
    }
  }

  # Network Traffic Widget
  widget {
    timeseries_definition {
      title = "Network Traffic by Instance"
      request {
        q = "avg:aws.ec2.network_in{environment:${var.environment}} by {instance_id}"
        display_type = "line"
      }
      request {
        q = "avg:aws.ec2.network_out{environment:${var.environment}} by {instance_id}"
        display_type = "line"
      }
    }
  }

  # Disk Usage Widget
  widget {
    timeseries_definition {
      title = "Disk Usage by Instance"
      request {
        q = "avg:aws.ec2.disk_used_percent{environment:${var.environment}} by {instance_id}"
        display_type = "line"
      }
    }
  }

  # Alert Status Widget
  widget {
    alert_graph_definition {
      title = "CPU Alert Status"
      alert_id = datadog_monitor.ec2_cpu_alert.id
      viz_type = "timeseries"
    }
  }

  # Text Widget with Information
  widget {
    note_definition {
      content = <<EOT
## EC2 Monitoring Dashboard

This dashboard provides real-time metrics for your EC2 instances in the ${var.environment} environment.

**Critical Thresholds:**
- CPU: ${var.cpu_threshold}%
- Warning: ${var.cpu_threshold * 0.8}%

**Alerts will trigger when:**
- CPU usage exceeds threshold for ${var.evaluation_period} minutes

**Environment: ${var.environment}**
EOT
      background_color = "gray"
      font_size = "14"
      text_align = "left"
      show_tick = true
      tick_pos = "bottom"
      tick_edge = "right"
    }
  }
}
