data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "random_uuid" "id" {}

locals {
  name_with_id = "${var.name}-${random_uuid.id.result}"
}