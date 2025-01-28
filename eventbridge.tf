resource "aws_cloudwatch_event_connection" "this" {
  name               = "${var.name}-${random_uuid.id.result}"
  description        = "Event Connection to call Teams webhook endpoint"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      // we do not need thos for authentication on teams webhook, but this is a required property
      // and this way we can identify the calling client by id
      key   = "x-client-id"
      value = random_uuid.id.result
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "this" {
  name                             = "${var.name}-${random_uuid.id.result}"
  description                      = "API Destination to call Teams webhool endpoint"
  invocation_endpoint              = var.webhook_url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 10
  connection_arn                   = aws_cloudwatch_event_connection.this.arn
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "${var.name}-${random_uuid.id.result}"
  description = "EventBridge rule to send teams notifications for alarm state changes for defined alarms"
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    resources   = var.alarm_arns
  })
}

resource "aws_cloudwatch_event_target" "this" {
  arn      = aws_cloudwatch_event_api_destination.this.arn
  rule     = aws_cloudwatch_event_rule.this.name
  role_arn = aws_iam_role.this.arn

  input_transformer {
    input_paths = {
      previousState : "$.detail.previousState.value",
      previousTimestamp : "$.detail.previousState.timestamp",
      state : "$.detail.state.value",
      timestamp : "$.detail.state.timestamp",
      alarmName : "$.detail.alarmName",
      description : "$.detail.configuration.description",
      region : "$.region",
      account : "$.account"
    }
    input_template = file("${path.module}/res/webhook_template.json")
  }
}