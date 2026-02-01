variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "Map of private subnets"
  type = string
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet (required if NAT enabled)"
  type        = string
  default     = null
}


variable "tags" {
  description = "value"
  type        = map(string)
  default     = {}
}

variable "common" {
  description = "defines the common map variables"
  type        = map(any)
  default     = {}
}

variable "vpc_function" {
  type = string
}

variable "vpc_cidrblock" {
  type = string
}
