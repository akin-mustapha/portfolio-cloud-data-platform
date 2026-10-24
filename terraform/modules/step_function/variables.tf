variable "name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "asl" {
  description = "Amazon States Language state machine definition as JSON."
  type        = string
}