# 列出_cat参数允许查看的内容
GET /_cat/

# 参数说明
GET /_cat/${State}/?${Query}
# State
#   health          所有集群健康状态
#   nodes           所有节点信息
#   master          集群的Master节点
#   nodeattrs       每个节点自定义的Attribute
#   allocation      每个节点Memory
#   fielddata       每个节点Fielddata占用的内存
#   thread_pool     每个节点Thread
#   aliases         别名
#   templates       模板
#   indices         索引
#   shards          索引的Shard
#   segments        索引的Segment
#   repositories    注册的快照仓库
#   recovery        索引分片移动到其它节点记录（恢复事件）
#   pending_tasks   当前集群被挂起的任务
#   plugins         当前集群使用的插件
# Query
#   v           显示表头
#   help        可显示的列及其说明
#   h=*         限制返回列（不指定返回默认的几列）
#   format      text | json | yaml
GET /_cat/nodes?v
GET /_cat/nodes?help
GET /_cat/nodes?h=ip,port
GET /_cat/nodes?format=json

# 查看所有集群健康状态
GET /_cat/health?v&h=cluster,status

# 查看所有节点
GET /_cat/nodes?v&h=ip,port,name,node.role,master

# 查看所有索引
GET /_cat/indices?v&h=index,status,health

# 查看所有模板
GET /_cat/templates?v
