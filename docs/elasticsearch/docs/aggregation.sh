
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
        # 若聚合text类型需要开启fielddata
        "field": "${FieldName}",
        "aggs": {
          # 聚合组内数据
        }
      }
    },
    # ...
  }
}