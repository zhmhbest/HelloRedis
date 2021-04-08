<link rel="stylesheet" href="https://zhmhbest.gitee.io/hellomathematics/style/index.css">
<script src="https://zhmhbest.gitee.io/hellomathematics/style/index.js"></script>

# [Kafka](../index.html)

>Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理消费者在网站中的所有动作流数据。

## 环境准备

- [Download Kafka from apache](https://archive.apache.org/dist/kafka/)
- [Download Kafka from tsinghua](https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/)
- [Download Kafka from aliyun](https://mirrors.aliyun.com/apache/kafka/)

## 启动

```batch
@START "Zookeeper" bin\windows\zookeeper-server-start.bat config\zookeeper.properties
@START "Kafka" bin\windows\kafka-server-start.bat config\server.properties
```
