# 创建模板
PUT /_template/${TemplateName}
{
    "order": 1,
    "template": "${TemplatePattern}",
    "settings": { "index": {} },
    "mappings": {
        # "${TemplateName}": {
            "properties": {
                "${FieldName}": {
                    "type": "${FieldType}"
                },
                # ...
            }
        # }
    },
    "aliases": {}
}

# 查看模板
GET /_template/${TemplateName}
# ----------------
{
    "${TemplateName}": {
        "order": 1, # 同时匹配多个模板时，使用数值较大的
        "template": "${TemplatePattern}",
        "settings": {
            "index": {
                # ...
            }
        },
        "mappings": {
            # "${TemplateName}": {
                # ...
                "properties": {
                    "${FieldName}": {
                        # keyword | text | integer | long | date
                        "type": "${FieldType}"
                    },
                    # ...
                }
            # }
        },
        "aliases": {}
    }
}

# 模板是否存在
HEAD /_template/${TemplateName}

# 删除模板
DELETE /_template/${TemplateName}
