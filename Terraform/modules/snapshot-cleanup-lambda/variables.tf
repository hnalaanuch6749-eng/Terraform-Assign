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

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  type        = string
}

variable "common" {
  description = "defines the common map variables"
  type        = map(any)
  default     = {}
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
