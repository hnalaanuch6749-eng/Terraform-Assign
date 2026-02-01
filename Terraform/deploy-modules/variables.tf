################################################ VPC Variables ##################################################
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "Map of private subnets"
  type        = string
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


########################################################## Lookup variables #####################################
locals {
  common = {
    product    = var.product
    accountenv = var.accountenv
    sdlcenv    = var.sdlcenv
  }
}

variable "accountenv" {
  default = ""
}

variable "product" {
  default = ""
}

variable "sdlcenv" {
  default = ""
}

###################################################### Lambda IAM Role variables ##########################
variable "lambda_functionrole" {
  type = string
}

variable "cw_eventrulename" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "schedule_description" {
  type = string
}

variable "enabled" {
  type = bool
}


#################################################### SNAPSHOT Cleanup variable ##################################
variable "lambda_functionname" {
  description = "Lambda function name"
  type        = string
}
variable "days_old" {
  description = "Delete snapshots older than N days"
  type        = number
  default     = 365
}

variable "timeout" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 60
}

variable "enable_schedule" {
  description = "Enable EventBridge schedule"
  type        = bool
  default     = true
}

variable "schedule_expressionsnapshot" {
  description = "EventBridge schedule expression"
  type        = string
}
