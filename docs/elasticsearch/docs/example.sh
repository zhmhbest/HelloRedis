# 查看所有模板
GET /_cat/templates?v&h=name
# 创建模板
PUT /_template/student
{
  "order": 1,
  "template": "student*",
  "index_patterns": "student*",
  "settings": {
    "index": {}
  },
  "mappings": {
    "properties": {
      "name": {
        "type": "keyword"
      },
      "comment": {
        "type": "text",
        "fielddata": true
      },
      "gender": {
        "type": "boolean"
      },
      "birth": {
        "type": "date"
      },
      "weight": {
        "type": "float"
      },
      "class": {
        "type": "integer"
      }
    }
  },
  "aliases": {}
}
HEAD /_template/student
# 查看模板
GET /_template/student
# DELETE /_template/student

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# 查看所有索引
GET /_cat/indices?v&h=index
# 匹配模板创建索引
PUT /student1
# 查看索引
GET /student1
HEAD /student1
# DELETE /student1

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# 创建文档
PUT /student1/_doc/1
{"name":"张三","comment":"一位帅哥","gender":true,"birth":"1999-10-10","weight":120.6,"class":101}
PUT /student1/_doc/2
{"name":"李四","comment":"一位靓女","gender":false,"birth":"1995-03-13","weight":99.2,"class":101}
PUT /student1/_doc/3
{"name":"__","comment":"???","gender":false,"birth":"2000-01-01","weight":100,"class":100}
POST /student1/_doc/
{"name":"王五","comment":"一位辣妹","gender":false,"birth":"2002-02-02","weight":87.5,"class":102}
POST /student1/_doc/
{"name":"赵六","comment":"一位绅士","gender":true,"birth":"1997-10-23","weight":160.2,"class":102}
# 查看所有文档
GET /student1/_search
# 修改文档
POST /student1/_update/2
{"doc": {"name": "李四四"}}
# 查看所有文档
GET /student1/_search

# 查看、删除
GET /student1/_doc/3
DELETE /student1/_doc/3

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# 分词匹配
GET /student1/_search
{"query": {"match": {"comment": "一位绅士"}}}

# 精确匹配（keyword）
GET /student1/_search
{"query":{"term":{"name":"李四四"}}}

# 范围匹配
GET /student1/_search
{"query":{"bool":{"filter":[{"range":{"birth":{"gt":"1995-01-01","lt":"2000-01-01"}}}]}}}

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# 字段过滤
GET /student1/_search
{"_source": ["name", "gender"]}

# 排序
GET /student1/_search
{"sort":[{"birth":{"order":"desc"}}]}

GET /student1/_search
{"sort":[{"birth":{"order":"asc"}}]}

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# 分页查询
GET /student1/_search
{"from": 0,"size": 2}

GET /student1/_search
{"from": 2,"size": 2}

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

### 高亮匹配的内容
GET /student1/_search
{"query":{"match":{"comment":"一位绅士"}},"highlight":{"pre_tags":["<a>"],"post_tags":["</a>"],"fields":{"comment":{"pre_tags":["<b>"],"post_tags":["</b>"]}}}}

GET /student1/_search
{"query":{"match":{"comment":"一位绅士"}},"highlight":{"pre_tags":["<a>"],"post_tags":["</a>"],"fields":{"comment":{}}}}

GET /student1/_search
{"query":{"match":{"comment":"一位绅士"}},"highlight":{"fields":{"comment":{}}}}

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

GET /student1/_search
{"size":0,"aggs":{"maxWeight":{"max":{"field":"weight"}},"minWeight":{"min":{"field":"weight"}},"avgWeight":{"avg":{"field":"weight"}},"sumWeight":{"sum":{"field":"weight"}},"countGender":{"terms":{"field":"gender"},"aggs":{"maxGenderWeight":{"max":{"field":"weight"}},"minGenderWeight":{"min":{"field":"weight"}}}}}}

GET /student1/_search
{"size":0,"aggs":{"showWeight":{"terms":{"field":"comment"},"aggs":{"maxGenderWeight":{"max":{"field":"weight"}},"minGenderWeight":{"min":{"field":"weight"}}}}}}
