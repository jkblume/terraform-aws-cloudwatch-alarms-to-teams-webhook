provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
}

module "simple_example" {
    // source  = "jkblume/cloudwatch-alarms-to-teams-webhook/aws"
    source = "../../"
    name = "my-name" // for identifying created resources by a descriptive name
    alarm_arns = [
        ""
    ]
    webhook_url = "" // checkout this: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook
}