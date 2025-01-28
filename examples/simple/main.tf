provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
}

module "simple_example" {
    source = "../../"
    name = "your-name" // for identifying created resources
    alarm_arns = [
        // insert alarm arns you want to monitor
    ]
    webhook_url = "https://insert.your.webhook.url" // checkout this: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook
}