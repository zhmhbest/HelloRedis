
GET /${IndexName}/_search
{
  "aggs": {
    "${MaxResultName}": {
      "max": {
        "field": "${FieldName}"
      }
    },
    "${MinResultName}": {
      "min": {
        "field": "${FieldName}"
      }
    },
    "${SumResultName}": {
      "sum": {
        "field": "${FieldName}"
      }
    },
    "${AvgResultName}": {
      "avg": {
        "field": "${FieldName}"
      }
    }
  }
}