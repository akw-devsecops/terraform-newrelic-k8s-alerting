variable "cluster_name" {
  type        = string
  description = "The name of the kubernetes cluster."
}

variable "cluster_policy" {
  type        = bool
  description = "Set this to `false` if you don't want to create the cluster policy."
  default     = true
}

variable "channel_name" {
  type        = string
  default     = null
  description = "Name of the alert channel"
}

variable "email_alert_recipient" {
  type        = string
  default     = null
  description = "The email alert address."
}

variable "google_chat_alert_url" {
  type        = string
  default     = null
  description = "The Google Chat alert channel webhook URL."
}

variable "namespaces" {
  type        = list(string)
  default     = []
  description = "List of namespaces to be monitored."
}

variable "enable_job_alerting" {
  type        = bool
  default     = true
  description = "Determines whether to alert on job errors."
}