<link rel="stylesheet" href="https://zhmhbest.gitee.io/hellomathematics/style/index.css">
<script src="https://zhmhbest.gitee.io/hellomathematics/style/index.js"></script>

# [Redis](../index.html)

[TOC]

## 环境准备

### Windows

下载[Redis](https://github.com/microsoftarchive/redis/releases)

```batch
REM 启动服务
redis-server.exe redis.windows.conf

REM 连接服务
redis-cli.exe -h localhost -p 6379
```

### Linux

下载[Redis](http://www.redis.cn/download.html)

```bash
yum -y install gcc-c++ make
redis_version='5.0.8'
wget "http://download.redis.io/releases/redis-${redis_version}.tar.gz"
tar -xvf redis-${redis_version}.tar.gz
pushd redis-${redis_version}
make distclean
make
make install
ll /usr/local/bin/redis-*
cp ./redis.conf /usr/local/etc/
popd; rm -rf ./redis-${redis_version}/

# 创建自动关联配置的启动程序
echo 'redis-server /usr/local/etc/redis.conf'>'/usr/local/bin/redis-start'
chmod 711 '/usr/local/bin/redis-start'

# 修改为后台启动
sed -i '/daemonize/s/no/yes/' '/usr/local/etc/redis.conf'
grep ^daemonize '/usr/local/etc/redis.conf'
```

```bash
# 启动服务
redis-start

# 查看服务
netstat -anp | grep redis-server

# 连接服务
redis-cli -h localhost -p 6379
```

#### 配置文件

```bash
redis_conf='/usr/local/etc/redis.conf'

# 查看登录密码
egrep '^(# )?requirepass' ${redis_conf}

# 是否后台运行
grep ^daemonize '/usr/local/etc/redis.conf'

# PID
grep ^pidfile ${redis_conf}

# 数据库数量
grep ^databases ${redis_conf}

# 日志级别 = debug | verbose | notice | warning
grep ^loglevel ${redis_conf}

# 持久化：条件 = 时间(s) 修改Key数量
grep ^save ${redis_conf}

# 持久化：错误后是否继续工作
grep ^stop-writes-on-bgsave-error ${redis_conf}

# 持久化：是否压缩
grep ^rdbcompression ${redis_conf}

# 持久化：是否校验
grep ^rdbchecksum ${redis_conf}

# 持久化：保存目录
grep ^dir ${redis_conf}
```

## 性能测试

```bash
# -c 并发连接数量
# -n 每个连接请求数量
redis-benchmark -h localhost -p 6379 -c 100 -n 100000
```

## [Redis命令](http://www.redis.cn/commands.html)

### 连接

>- `PING`：是否可以正常登录
>- `AUTH password`：若启用密码则应使用此命令登录

### 数据库

>- `SELECT index`：切换数据库
>- `DBSIZE`：查看当前数据库占用大小
>- `KEYS *`：查看当前数据库所有KEY

### Hello

```txt
SET hello "Hello Redis!"
TYPE hello
GET hello
KEYS *
DEL hello
EXISTS hello
FLUSHALL
```

### Expire

>- `EXPIRE key seconds`：设置key有效时间
>- `TTL key`：查看有效时间（-1：永久、-2：已过期 ）

### GET/SET

>- `SETEX key value`：设置Key-Value
>- `SETEX key seconds value`：设置Key-Value和过期时间
>- `SETNX key value`：如果不存在则设置
>- `MSET key value [key value ...]`：设置多个值
>- `MGET key [key ...]`：获取多个值
>- `MSETNX key value [key value ...]`：如果均不存在则设置（原子性操作）
>- `GETSET key value`：先获取再设置

#### 设置对象

```txt
MSET user:1:name "Zhang3" user:1:gender 0
MGET user:1:name user:1:gender
```

### String

>- `SET key value`：设置
>- `APPEND key value`：追加
>- `GET key`=`GETRANGE key 0 -1`：获取
>- `GETRANGE key start end`：裁剪
>- `SETRANGE key offset value`：从offset起替换为value

#### 自增减

```txt
SET count "0"
GET count

INCR count
GET count

INCRBY count 5
GET count

DECR count
GET count

DECRBY count 5
GET count

DEL count
```

### List

>- `RPUSH key value [value ...]`：创建List（右侧）
>- `LPUSH key value [value ...]`：创建List（左侧）
>- `RPOP key`：移除List尾部第一个元素
>- `LPOP key`：移除List头部第一个元素
>- `LRANGE key start stop`：裁剪List（不修改原列表）
>- `LRANGE key 0 -1`：查看列表内元素
>- `LTRIM key start stop`：裁剪List
>- `LLEN key`：List元素个数
>- `LINDEX key index`：List第index个元素的值
>- `LREM key count value`：移除List中值为value从左起前count个
>- `LSET key index value`：将List中第index个值替换为指定的值
>- `RPOPLPUSH source destination`：从一个List右侧移到另一个List左侧

### Set

>- `SADD key  member [member ...]`：创建Set
>- `SMEMBERS key`：打印Set中所有元素
>- `SISMEMBER key member`：元素是否在Set中
>- `SCARD key`：Set中元素个数
>- `SREM key member [member ...]`：移除Set中元素
>- `SMOVE source destination member`：移动source中的member到destination中
>- `SINTER key [key ...]`：交集
>- `SDIFF key [key ...]`：差集
>- `SUNION key [key ...]`：并集

### Hash

>- `HSET key field value`：创建Hash
>- `HMSET key field value [field value ...]`：创建Hash设置多个field
>- `HGET key field`：获取Hash中field对应的值
>- `HMGET key field [field ...]`：获取Hash中多个field对应的值
>- `HLEN key`：获取Hash中包含field的数量
>- `HEXISTS key field`：判断field是否存在
>- `HKEYS key`：所有field名称
>- `HVALS key`：所有field对应的值
>- `HINCRBY key field increment`：指定field自增increment
>- `HSETNX key field value`：不存在field时则创建

```txt
HSET hash1 field1 "Hello"
HGET hash1 field1
```

### ZSet（有序集合）

>- `ZADD key [NX|XX] [CH] [INCR] score member [score member ...]`：不存在field时则创建
>   - XX: 仅仅更新存在的成员，不添加新成员。
>   - NX: 不更新存在的成员。只添加新成员。
>   - CH: 修改返回值为发生变化的成员总数。
>   - INCR: 当ZADD指定这个选项时，成员的操作就等同ZINCRBY命令，对成员的分数进行递增操作。
>- `ZRANGE key start stop [WITHSCORES]`：返回指定范围的元素
>- `ZREM key member [member ...]`：删除元素
>- `ZCARD key`：元素个数
>- `ZCOUNT key min max`：指定score范围内元素的个数

```txt
ZADD zset1 1 "one"
ZADD zset1 3 "three"
ZADD zset1 2 "two"
ZRANGE zset1 0 -1
ZRANGE zset1 0 -1 WITHSCORES
```

## Clients

### NodeJS

```bash
mkdir test
pushd test
npm init -f
npm -S i redis
touch index.js
```

`index.js`

```js
const redis = require('redis');
const client = redis.createClient(6379, '127.0.0.1');
// client.auth(123456);
client.on('connect', connected);
async function connected() {
    await new Promise((resolve, reject) => {
        client.set('name', 'Zhang4', (err, data) => err ? reject(err) : resolve(data));
    }).then(res => {
        console.log('set', res)
    })
    await new Promise((resolve, reject) => {
        client.get('name', (err, data) => err ? reject(err) : resolve(data));
    }).then(res => {
        console.log('get', res)
    })
    console.log("Done!");
    process.exit(0);
}
```

## 常见问题

### Redis为什么快

1. 完全基于内存
2. 单线程
   - 避免上下文切换
   - 使用乐观锁
3. 非阻塞I/O多路复用机制：多个网络连接复用同一个线程。
4. 数据结构简单
   - 简单动态字符串：记录了自身使用和未使用的长度
   - 双端链表：无环链表
   - 字典：哈希表
   - 跳跃表
   - 整数集合
   - 压缩列表
5. 底层模型：VM机制（冷数据Value保存到磁盘上）
6. 过期策略
   - 定期删除
   - 惰性删除
7. 内存淘汰机制
   - volatile-lru：内存不足时，删除设置了过期时间的键空间中最近最少使用的key
   - allkeys-lru：内存不足时，在键空间中删除最少使用的key
   - volatile-random：内存不足时，随机删除在设置了过期时间的键空间中的key
   - allkeys-random：内存不足时，随即删除在键空间中的key
   - volatile-ttl：内存不足时，在设置了过期时间的键空间中，优先移除更早过期时间的key
   - noeviction：永不过期

### 缓存穿透/缓存击穿/缓存雪崩

#### 缓存穿透

**缓存和数据库中都没有的数据**

1. 把无效的Key存进Redis。
2. 使用布隆过滤器。

#### 缓存击穿

**缓存中没有但数据库中有的数据**

1. 热点数据永不过期
2. 互斥锁

#### 缓存雪崩

**缓存中数据大量过期，造成数据库宕机**

1. 失效时间加随机值。
2. 熔断机制，当流量到达一定的阈值时将不再提供正常访问。
3. 提高数据库容灾能力。
4. 提高Redis的容灾性。

### Redis持久化

#### AOF

将Redis执行的每次写命令记录到单独的日志文件中。

- always: 把每个写命令都立即同步到aof
- everysec: 每秒同步一次
- no: 交给OS来处理

#### RDB

将当前进程中的数据生成快照保存到硬盘（阻塞）。
