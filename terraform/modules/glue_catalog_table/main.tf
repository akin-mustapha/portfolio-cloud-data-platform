locals {
  schema = jsondecode(var.schema)

  columns = [
    for column in local.schema : {
      name = column.Name
      type = column.Type
    }
    if !contains(keys(column), "PartitionKey")
  ]

  partition_keys = [
    for column in local.schema : {
      name = column.Name
      type = column.Type
    }
    if contains(keys(column), "PartitionKey")
  ]
}

resource "aws_glue_catalog_table" "this" {
  name          = var.name
  database_name = var.database_name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = var.location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = var.name
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    dynamic "columns" {
      for_each = local.columns

      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }

  dynamic "partition_keys" {
    for_each = local.partition_keys

    content {
      name = partition_keys.value.name
      type = partition_keys.value.type
    }
  }
}