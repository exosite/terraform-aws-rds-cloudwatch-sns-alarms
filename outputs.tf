output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  type        = "string"
  value       = "${local.topic_arn}"
}
