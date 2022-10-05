variable "role_to_assume" {
  description = "Name of role to assume (not ARN)"
  type        = string
}

variable "aws_account" {
  description = "aws account number to assume role into"
  type        = string
}

variable "security_group_ports" {
  type        = list(number)
  description = "Security group ports required"
  default     = [80,443]
}

variable "ec2_key" {
  description = "SSH Key"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet id"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "naming_prefix" {
  description = "Name for prefixing resources, should be something unique"
  type        = string
}

variable "tags" {
  description = "Additional tags to add to resources. Defaults to empty."
  type        = map(string)
  default     = {}
}
