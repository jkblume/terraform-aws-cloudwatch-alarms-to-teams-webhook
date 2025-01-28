variable "name" {
    type = string
    description = "Give your notification a name (to identify created resources afterwards)"
}

variable "webhook_url" {
    type = string
    description = "The Teams Webhook URL you want to send alarm notifications to."
}

variable "alarm_arns" {
    type = list(string)
    description = "The list of alarm arns you want to send teams notifications for"
}
