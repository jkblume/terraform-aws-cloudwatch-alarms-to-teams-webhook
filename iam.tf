data "aws_iam_policy_document" "events_this" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-${random_uuid.id.result}"
  assume_role_policy = data.aws_iam_policy_document.events_this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "events:InvokeApiDestination"
    ]
    resources = [
        // sadly one can not use aws_cloudwatch_event_api_destination.this.arn, because it contains additional but unwanted id in path
        "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:api-destination/${aws_cloudwatch_event_api_destination.this.name}/*",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "grant_required_permissions" {
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}