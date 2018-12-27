output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = "${var.topic_arn == "" ? aws_sns_topic.default.*.arn[0] : var.topic_arn}"
}
