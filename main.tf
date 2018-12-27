# resource "aws_cloudwatch_event_target" "sns" {
#   rule       = "${aws_cloudwatch_event_rule.default.name}"
#   target_id  = "SendToSNS"
#   arn        = "${var.sns_topic_arn}"
#   depends_on = ["aws_cloudwatch_event_rule.default"]
#   input      = "${var.sns_message_override}"
# }
data "aws_caller_identity" "default" {}

locals {
  default_topic_arn = "${element(concat(aws_sns_topic.default.*.arn, list("")), 0)}"
  topic_arn = "${var.topic_arn == "" ? local.default_topic_arn : var.topic_arn}"
}

# Make a topic
resource "aws_sns_topic" "default" {
  name_prefix = "rds-threshold-alerts"
  count = "${var.topic_arn == "" ? 1 : 0}"
}

resource "aws_db_event_subscription" "default" {
  name_prefix = "rds-event-sub"
  sns_topic   = "${local.topic_arn}"

  source_type = "db-instance"
  source_ids  = ["${var.db_instance_id}"]

  event_categories = "${var.db_events}"
}

resource "aws_sns_topic_policy" "default" {
  arn    = "${local.topic_arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = ["${local.topic_arn}"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${data.aws_caller_identity.default.account_id}",
      ]
    }
  }

  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = ["${local.topic_arn}"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }

  statement {
    sid       = "Allow RDS Event Notification"
    actions   = ["sns:Publish"]
    resources = ["${local.topic_arn}"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}
