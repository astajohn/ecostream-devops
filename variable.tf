variable "region" {
    description = "region-used"
    default = "us-east-1"
    type = string
  
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}
