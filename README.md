# Cloudwatch -> Teams Webhook

You can use this terraform module to send cloudwatch alarm state changes to a teams webhook. This is done by using eventbridge as conntector of both (cloudwatch -> webhook). An input transformator is converting the cloudwatch alarm json data to an adaptive card. 

## Example Usage

```terraform
module "simple_example" {
    source = "../../"
    name = "your-name" // for identifying created resources
    alarm_arns = [
        // insert alarm arns you want to monitor
    ]
    webhook_url = "https://insert.your.webhook.url" // checkout this: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook
}
```