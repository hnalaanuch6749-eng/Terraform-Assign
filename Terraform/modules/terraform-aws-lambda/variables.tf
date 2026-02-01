variable "lambda_functionrole" {
    type = string
}

variable "schedule_description" {
   type = string
}

variable "schedule_expression" {
   type = string
}

variable "enabled" {
    type = bool
}

variable "common" {
  description = "defines the common map variables"
  type        = map(any)
  default     = {}
}

variable "cw_eventrulename" {
    type = string
}
