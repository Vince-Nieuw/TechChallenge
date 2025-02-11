variable "mongodb_admin_user" {
  description = "MongoDB admin username"
  type        = string
  default     = "admin"  # Hardcoded default (easy to remove later)
}

variable "mongodb_admin_password" {
  description = "MongoDB admin password"
  type        = string
  default     = "SuperSecretPass123"  # Hardcoded default (easy to remove later)
}
