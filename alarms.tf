locals {
  thresholds = {
    BurstBalanceThreshold     = "${min(max(var.burst_balance_threshold, 0), 100)}"
    CPUUtilizationThreshold   = "${min(max(var.cpu_utilization_threshold, 0), 100)}"
    CPUCreditBalanceThreshold = "${max(var.cpu_credit_balance_threshold, 0)}"
    DiskQueueDepthThreshold   = "${max(var.disk_queue_depth_threshold, 0)}"
    FreeableMemoryThreshold   = "${max(var.freeable_memory_threshold, 0)}"
    FreeStorageSpaceThreshold = "${max(var.free_storage_space_threshold, 0)}"
    SwapUsageThreshold        = "${max(var.swap_usage_threshold, 0)}"
    ConnectionThreshold       = "${min(max(var.connection_threshold, 0), 100)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "burst_balance_too_low" {
  alarm_name          = "burst_balance_too_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["BurstBalanceThreshold"]}"
  alarm_description   = "Average database storage burst balance over last 10 minutes too low, expect a significant performance drop soon"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  alarm_name          = "cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUUtilizationThreshold"]}"
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  alarm_name          = "cpu_credit_balance_too_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUCreditBalanceThreshold"]}"
  alarm_description   = "Average database CPU credit balance over last 10 minutes too low, expect a significant performance drop soon"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_too_high" {
  alarm_name          = "disk_queue_depth_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["DiskQueueDepthThreshold"]}"
  alarm_description   = "Average database disk queue depth over last 10 minutes too high, performance may suffer"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_too_low" {
  alarm_name          = "freeable_memory_too_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["FreeableMemoryThreshold"]}"
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  alarm_name          = "free_storage_space_threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["FreeStorageSpaceThreshold"]}"
  alarm_description   = "Average database free storage space over last 10 minutes too low"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "swap_usage_too_high" {
  alarm_name          = "swap_usage_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${local.thresholds["SwapUsageThreshold"]}"
  alarm_description   = "Average database swap usage over last 10 minutes too high, performance may suffer"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}

data "aws_db_instance" "db_instance" {
  db_instance_identifier = "${var.db_instance_id}"
}

locals {
  memory_mapping = {
    "db.t2.micro"     = 1
    "db.t1.micro"     = 0.613
    "db.t2.small"     = 2
    "db.m1.small"     = 1.7
    "db.t2.medium"    = 4
    "db.m3.medium"    = 3.75
    "db.m1.medium"    = 3.75
    "db.t2.large"     = 8
    "db.m5.large"     = 8
    "db.m3.large"     = 7.5
    "db.m4.large"     = 8
    "db.m1.large"     = 7.5
    "db.r4.large"     = 15.25
    "db.r3.large"     = 15.25
    "db.t2.xlarge"    = 16
    "db.m2.xlarge"    = 17.1
    "db.m5.xlarge"    = 16
    "db.m3.xlarge"    = 15
    "db.m4.xlarge"    = 16
    "db.m1.xlarge"    = 15
    "db.r3.xlarge"    = 30.5
    "db.r4.xlarge"    = 30.5
    "db.t2.2xlarge"   = 32
    "db.m2.2xlarge"   = 34.2
    "db.m5.2xlarge"   = 32
    "db.m3.2xlarge"   = 30
    "db.m4.2xlarge"   = 32
    "db.r3.2xlarge"   = 61
    "db.r4.2xlarge"   = 61
    "db.m2.4xlarge"   = 68.4
    "db.m5.4xlarge"   = 64
    "db.m4.4xlarge"   = 64
    "db.r3.4xlarge"   = 122
    "db.r4.4xlarge"   = 122
    "db.m4.10xlarge"  = 160
    "db.r3.8xlarge"   = 244
    "db.r4.8xlarge"   = 244
    "db.m5.12xlarge"  = 192
    "db.m4.16xlarge"  = 256
    "db.r4.16xlarge"  = 488
    "db.m5.24xlarge"  = 384
    "db.x1.32xlarge"  = 1952
    "db.r5.xlarge"    = 32
    "db.t3.large"     = 8
    "db.x1e.8xlarge"  = 976
    "db.x1e.xlarge"   = 122
    "db.r5.24xlarge"  = 768
    "db.r5.12xlarge"  = 384
    "db.t3.2xlarge"   = 32
    "db.t3.medium"    = 4
    "db.r5.4xlarge"   = 192
    "db.x1e.4xlarge"  = 488
    "db.x1e.32xlarge" = 3904
    "db.t3.small"     = 2
    "db.x1e.16xlarge" = 1952
    "db.r5.large"     = 16
    "db.x1e.2xlarge"  = 244
    "db.t3.xlarge"    = 16
    "db.t3.micro"     = 1
    "db.x1.16xlarge"  = 976
    "db.r5.2xlarge"   = 64
  }

  memory_gb = "${lookup(local.memory_mapping, data.aws_db_instance.db_instance.db_instance_class)}"

  # for postgres
  connection_per_gb = 112
  max_connection    = "${local.memory_gb * local.connection_per_gb}"
}

#TODO setup alarm for connection count

resource "aws_cloudwatch_metric_alarm" "connection_usage_too_high" {
  alarm_name          = "connection_usage_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${floor(local.thresholds["ConnectionThreshold"] * local.max_connection * 0.01)}"
  alarm_description   = "Average database connection usage over last 10 minutes too high, performance may suffer"
  alarm_actions       = ["${aws_sns_topic.default.arn}"]
  ok_actions          = ["${aws_sns_topic.default.arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.db_instance_id}"
  }
}
