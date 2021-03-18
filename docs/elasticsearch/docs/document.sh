# 创建文档（指定ID）
# PUT /${IndexName}/_doc/${ID}/_create
PUT /${IndexName}/_doc/${ID}/
{
    "${FieldName}": "${FieldValue}",
    # ...
}

# 创建文档（随机ID）
POST /${IndexName}/_doc
{
    "${FieldName}": "${FieldValue}",
    # ...
}

# 查看所有文档
GET /${IndexName}/_search

# 查看指定ID文档
GET /${IndexName}/_doc/${ID}

# 删除指定ID文档
DELETE /${IndexName}/_doc/${ID}

# 修改文档
# POST /${IndexName}/${Type}/${ID}/_update
POST /${IndexName}/_update/${ID}
{
    "doc": {
        "${FieldName}": "${FieldValue}",
        # ...
    }
}