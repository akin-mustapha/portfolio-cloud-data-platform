variable "name" {
  type        = string
  description = "Glue Catalog table name"
}

variable "database_name" {
  type        = string
  description = "Glue database containing the table"
}

variable "location" {
  type        = string
  description = "S3 location of the Parquet dataset"
}

# variable "columns" {
#   type = list(object({
#     name    = string
#     type    = string
#     comment = optional(string)
#   }))
# }

# variable "partition_keys" {
#   type = list(object({
#     name = string
#     type = string
#   }))
#   default = []
# }

variable "schema" {
  description = "JSON array defining Glue columns and optional partition keys"
  type        = string
}