output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = "${local.topic_arn}"
}
