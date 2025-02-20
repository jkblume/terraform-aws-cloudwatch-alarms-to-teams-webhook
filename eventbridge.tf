resource "aws_cloudwatch_event_connection" "this" {
  name               = local.name_with_id
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
  name                             = local.name_with_id
  description                      = "API Destination to call teams webhook endpoint"
  invocation_endpoint              = var.webhook_url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 10
  connection_arn                   = aws_cloudwatch_event_connection.this.arn
}

resource "aws_cloudwatch_event_rule" "this_ok" {
  name        = "${local.name_with_id}-ok"
  description = "EventBridge rule to send teams notifications for OK state changes for defined alarms"
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    resources   = var.alarm_arns
    detail = {
      state = {
        value = ["OK"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "this_ok" {
  arn      = aws_cloudwatch_event_api_destination.this.arn
  rule     = aws_cloudwatch_event_rule.this_ok.name
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
    input_template = templatefile(
      "${path.module}/res/webhook_template.json",
      {
        imageData = filebase64("${path.module}/res/ok.png")
      }
    )
  }
}

resource "aws_cloudwatch_event_rule" "this_alarm" {
  name        = "${local.name_with_id}-alarm"
  description = "EventBridge rule to send teams notifications for ALARM state changes for defined alarms"
  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    resources   = var.alarm_arns
    detail = {
      state = {
        value = ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "this_alarm" {
  arn      = aws_cloudwatch_event_api_destination.this.arn
  rule     = aws_cloudwatch_event_rule.this_alarm.name
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
    input_template = templatefile(
      "${path.module}/res/webhook_template.json",
      {
        imageData = filebase64("${path.module}/res/alarm.png")
      }
    )
  }
}