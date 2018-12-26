variable "db_instance_id" {
  description = "The instance ID of the RDS database instance that you want to monitor."
  type        = "string"
}

variable "topic_arn" {
  description = "Optional topic arn for the existing topic"
  type        = "string"
}

variable "burst_balance_threshold" {
  description = "The minimum percent of General Purpose SSD (gp2) burst-bucket I/O credits available."
  type        = "string"
  default     = 20
}

variable "cpu_utilization_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = "string"
  default     = 80
}

variable "cpu_credit_balance_threshold" {
  description = "The minimum number of CPU credits (t2 instances only) available."
  type        = "string"
  default     = 20
}

variable "disk_queue_depth_threshold" {
  description = "The maximum number of outstanding IOs (read/write requests) waiting to access the disk."
  type        = "string"
  default     = 64
}

variable "freeable_memory_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = "string"
  default     = 64000000

  # 64 Megabyte in Byte
}

variable "free_storage_space_threshold" {
  description = "The minimum amount of available storage space in Byte."
  type        = "string"
  default     = 2000000000

  # 2 Gigabyte in Byte
}

variable "swap_usage_threshold" {
  description = "The maximum amount of swap space used on the DB instance in Byte."
  type        = "string"
  default     = 256000000

  # 256 Megabyte in Byte
}

variable "connection_threshold" {
  description = "The maximum usage of DB connection"
  type        = "string"
  default     = 50
}

variable "db_events" {
  description = "List of db events that will be published to the SNS topic"
  type        = "list"

  default = [
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "recovery",
  ]
}
