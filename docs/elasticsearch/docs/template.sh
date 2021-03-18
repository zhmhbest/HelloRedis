# 查看所有模板
GET /_cat/templates?v

# 创建/修改模板
PUT /_template/${TemplateName}
{
    "order": 1,
    # "template": "${TemplatePattern}",         # 5.6
    "index_patterns": "${TemplatePattern}",     # 7.x
    "settings": { "index": {} },
    "mappings": {
        # "${Type}": {                          # 5.6
            "properties": {
                # keyword | text
                # byte | short | integer | long
                # half_float | scaled_float | float | double
                # date | date_nanos
                # boolean
                # binary
                # integer_range | long_range | float_range | double_range | date_range
                "${FieldName}": {
                    "type": "${FieldType}",

                    # 在text字段上默认禁用了fielddata，这将导致不能进行聚合操作
                    # "fielddata": true
                },
                # ...
            }
        # }
    },
    "aliases": {}
}

# 查看模板信息
GET /_template/${TemplateName}

# 模板是否存在
HEAD /_template/${TemplateName}

# 删除模板
DELETE /_template/${TemplateName}