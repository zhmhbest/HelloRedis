
GET /${IndexName}/_search
{
  "size": 0,
  "aggs": {
    "${ResultName}": {
      # min | max | sum | avg
      "${FunctionName}": {
        "field": "${FieldName}"
      },
      # terms = group by
      "terms": {
        "field": "${FieldName}",
        "aggs": {
          # 聚合组内数据
        }
      }
    },
    # ...
  }
}