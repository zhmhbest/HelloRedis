
## 故障修复

```log
... <Debug> Application: Shut down storages.
... <Debug> Application: Destroyed global context.
... <Error> Application: Coordination::Exception: No node, path: /...
```

```bash
mv '/var/lib/clickhouse/metadata' '/var/lib/clickhouse/metadata_bk'
mv '/var/lib/clickhouse/data' '/var/lib/clickhouse/data_bk'
```

<!--
1. 将/var/lib/clickhouse/metadata/ 下的SQL备份之后删除
2. 将/var/lib/clickhouse/data/ 下的备份之后删除
3. 启动数据库
4. 创建同数据结构的MergeTree表
5. 将之前分布式表的数据文件夹复制到新表(MergeTree)的数据目录中。
6. 重启数据库
7. 重新创建原结构本地表
8. 重新创建原结构分布式表
9. insert into [分布式表] select * from [MergeTree表]
-->