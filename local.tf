locals {
  environment = terraform.workspace

  common_tags = {
    Environment = local.environment
    managed_by  = "terraform"
  }
}
