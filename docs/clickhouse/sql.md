
## SQL

>[Clickhouse SQL](https://clickhouse.tech/docs/zh/sql-reference/syntax/)

### 数据库

```SQL
-- 创建集群库
CREATE DATABASE IF NOT EXISTS dbname ON CLUSTER ck_cluster;

-- 删除集群库
DROP DATABASE IF EXISTS dbname ON CLUSTER ck_cluster;
```

### 表

```SQL
-- 创建本地表并同步到集群
CREATE TABLE IF NOT EXISTS
    dbname.table_local
ON CLUSTER
    ck_cluster
(
    `EventDate` Date,
    `CounterID` UInt32,
    `UserID` UInt32
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{layer}-{shard}/table_local',
    '{replica}'
)
PARTITION BY (EventDate)
ORDER BY (CounterID, intHash32(UserID))
SAMPLE BY intHash32(UserID);

-- 基于本地表创建集群表（相当于视图）
CREATE TABLE IF NOT EXISTS
    dbname.table_distributed
ON CLUSTER
    ck_cluster
AS
    dbname.table_local
ENGINE = Distributed(
    ck_cluster,
    dbname,
    table_local,
    rand()
);
-- Distributed({cluster}, {local_database}, {local_table}, rand())

-- 本地表插入删除
-- INSERT INTO dbname.table_local VALUES('2020-03-11',22,46);
-- ALTER TABLE dbname.table_local DELETE WHERE UserID=46;

-- 集群表插入删除
INSERT INTO dbname.table_distributed VALUES
    ('2020-03-11',22,54),
    ('2020-03-11',22,57),
    ('2020-03-12',22,58);
ALTER TABLE dbname.table_local ON CLUSTER ck_cluster DELETE WHERE UserID=54;

-- 【集群表注意事项】
-- 集群表 插入/清空 会有延时情况
-- GLOBAL IN 代替 IN
-- GLOBAL NOT JOIN 代替 NOT JOIN
-- GLOBAL JOIN 代替 JOIN

-- 清空本地表数据并同步到集群（清空集群表）
TRUNCATE TABLE IF EXISTS dbname.table_local ON CLUSTER ck_cluster;

-- 删除表
DROP TABLE IF EXISTS dbname.table_distributed ON CLUSTER ck_cluster;
DROP TABLE IF EXISTS dbname.table_local ON CLUSTER ck_cluster;
```

### 分区

```SQL
-- 查看本地表分区
SELECT
    `name`,
    `partition`,
    `partition_id`,
    `path`
FROM system.parts
WHERE
    `database` = 'dbname' AND
    `table` ='table_local';

-- 删除本地表分区并同步到集群
ALTER TABLE dbname.table_local ON CLUSTER ck_cluster DROP PARTITION 'partition';
```

### 日期

```SQL
SELECT  now()                                 AS t
       ,toUnixTimestamp(t)                    AS ts
       ,toString(t)                           AS s1
       ,formatDateTime(t,'%Y-%m-%d %H:%M:%S') AS s2
       -- ID
       ,toYYYYMM(t)                           AS `month_id`
       ,toYYYYMMDD(t)                         AS `day_id`
       ,toYYYYMMDDhhmmss(t)                   AS `second_id`
       -- 日期
       ,toYear(t)                             AS `年`
       ,toQuarter(t)                          AS `季度`
       ,toMonth(t)                            AS `月`
       ,toDate(t)                             AS `%Y-%m-%d`
       -- 日期
       ,toHour(t)                             AS `时`
       ,toMinute(t)                           AS `分`
       ,toSecond(t)                           AS `秒`
       ,toTime(t)                             AS `%H:%M:%S`
       -- 排名
       ,toDayOfYear(t)                        AS `年中天`
       ,toDayOfMonth(t)                       AS `月中天`
       ,toDayOfWeek(t)                        AS `周中天`
       -- 时区
       ,toDate(t,'Asia/Shanghai')             AS `上海日期`
       ,toDateTime(t,'Asia/Shanghai')         AS `上海时间`
       -- 起始
       ,toStartOfYear(t)                      AS `始年`
       ,toStartOfMonth(t)                     AS `始月`
       ,toStartOfQuarter(t)                   AS `始季`
       ,toStartOfDay(t)                       AS `始天`
       ,toStartOfHour(t)                      AS `始时`
       ,toStartOfMinute(t)                    AS `始分`
       -- 之后
       ,addYears(t,1)
       ,addQuarters(t,1)
       ,addMonths(t,1)
       ,addWeeks(t,1)
       ,addDays(t,1)
       ,addHours(t,1)
       ,addMinutes(t,1)
       ,addSeconds(t,1)
       -- 之前
       ,subtractYears(t,1)
       ,subtractQuarters(t,1)
       ,subtractMonths(t,1)
       ,subtractWeeks(t,1)
       ,subtractDays(t,1)
       ,subtractHours(t,1)
       ,subtractMinutes(t,1)
       ,subtractSeconds(t,1)
       -- 时间差
       ,DATEDIFF('year',t,addYears(t,1))      AS diff_years
       ,DATEDIFF('month',t,addMonths(t,2))    AS diff_months
       ,DATEDIFF('week',t,addWeeks(t,3))      AS diff_week
       ,DATEDIFF('day',t,addDays(t,4))        AS diff_days
       ,DATEDIFF('hour',t,addHours(t,5))      AS diff_hours
       ,DATEDIFF('minute',t,addMinutes(t,6))  AS diff_minutes
       ,DATEDIFF('second',t,addSeconds(t,7))  AS diff_seconds ;
```

### 正则

```SQL
-- 正则匹配
SELECT DISTINCT(region) FROM dbname.table_distributed
WHERE NOT match(region , '^[0-9]+$');
```

### 聚合函数

>[aggregate-functions](https://clickhouse.tech/docs/zh/sql-reference/aggregate-functions/reference/)
>[aggregate-combinators](https://clickhouse.tech/docs/zh/sql-reference/aggregate-functions/combinators/)

#### groupArray

```SQL
SELECT
    `name`,
    groupArray(`identity`) AS `identity`,
    arrayEnumerate(`identity`) AS `index`
FROM (
    SELECT 'Ann' AS `name`, 'Student' AS `identity`
    UNION ALL
    SELECT 'Ann' AS `name`, 'American' AS `identity`
)
GROUP BY `name`
```

#### ARRAY JOIN

```SQL
SELECT * FROM (
    SELECT
        'Ann' AS `name`,
        ['Student', 'American'] AS `identity`
)
ARRAY JOIN `identity`;
```

#### 分组筛选

1. 分组查询
2. 按组过滤数据
3. 提取组内数据
4. 还原分组

```SQL
-- 还原分组
SELECT `id`, `name`, `class`
FROM (
    -- 筛选班级内成员人数超过2人的班级
    SELECT
        `class`,
        groupArray(`id`) AS `id`,
        groupArray(`name`) AS `name`
    FROM (
        -- 模拟数据
        SELECT 1 AS `id`, '张三' AS `name`, 101 AS `class` UNION ALL
        SELECT 2 AS `id`, '李四' AS `name`, 101 AS `class` UNION ALL
        SELECT 3 AS `id`, '王五' AS `name`, 102 AS `class` UNION ALL
        SELECT 4 AS `id`, '赵六' AS `name`, 102 AS `class` UNION ALL
        SELECT 5 AS `id`, '钱七' AS `name`, 102 AS `class`
    )
    GROUP BY `class`
    HAVING COUNT(*) > 2
) ARRAY JOIN `id`, `name`;
```
