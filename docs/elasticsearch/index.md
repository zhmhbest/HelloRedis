<link rel="stylesheet" href="https://zhmhbest.gitee.io/hellomathematics/style/index.css">
<script src="https://zhmhbest.gitee.io/hellomathematics/style/index.js"></script>

# [ElasticSearch](../index.html)

[toc]

## 基本概念

每台服务器可以运行多个 Elastic 实例。单个 Elastic 实例称为一个 **Node** 。一组节点构成一个 **Cluster** 。

ElasticSearch 会索引所有字段，经过处理后写入一个反向索引（Inverted Index）。所以，Elastic 数据管理的顶层单位就叫做 Index（索引）。每个 Index 的名字必须是小写。

## 运行环境

学习环境下减少ElasticSearch内存占用。

`vim ./config/jvm.options`

```bash
# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space

-Xms256m
-Xmx256m
```

修改Kibana语言

`vim ./config/kibana.yml`

```conf
18n.locale: "zh-CN"
```

### es-head

```bash
# 下载
wget 'https://github.com/mobz/elasticsearch-head/archive/master.zip' -O 'es-head.zip'
unzip './es-head.zip'
mv './elasticsearch-head-master/crx/es-head.crx' './'
rm -rf './elasticsearch-head-master'
```

### 启动

```bash
# 启动ES
elasticsearch-${VERSION}/bin/elasticsearch
# 默认HTTP协议端口9200
# 默认TCP 协议端口9300

# 启动Kibana
kibana-${VERSION}/bin/kibana
# 默认HTTP协议端口5601
```

- <http://localhost:5601>
- <http://localhost:5601/app/dev_tools#/console>

## REST API

### Cat

@import "docs/cat.sh"

### Template

@import "docs/template.sh"

### Index

@import "docs/index.sh"

### Document

@import "docs/document.sh"

### Search

@import "docs/search.sh"

### Group

@import "docs/group.sh"

### Example

@import "docs/example.sh"

## IK分词器

@import "docs/analysis_ik.md"

## ES Clients

- [Clients](https://www.elastic.co/guide/en/elasticsearch/client/index.html)

### JavaScript

```bash
mkdir HelloJSElasticSearch
cd HelloJSElasticSearch
npm init -f
npm -S i @elastic/elasticsearch
```

`index.js`

```js
const { Client } = require('@elastic/elasticsearch');
const client = new Client({
    node: 'http://localhost:9200',
    // auth: {
    //     username: 'elastic',
    //     password: 'changeme'
    // },
    // ssl: {
    //     ca: fs.readFileSync('./cacert.pem'),
    //     rejectUnauthorized: false
    // }
});

client.search({
    index: `${IndexName}`,
    body: {
        query: {
            match: {
                `${FieldName}`: `${FieldValue}`
            }
        }
    }
}).then(res => {
    console.log(res.body);
}).catch(err => {
    console.log(`${err}`);
});
```

### Java

```bash
mvn archetype:generate "-DgroupId=org.example.es" "-DartifactId=HelloJavaElasticSearch" "-DarchetypeArtifactId=maven-archetype-quickstart" "-DinteractiveMode=false"
cd HelloJavaElasticSearch
vim pom.xml
```

`pom.xml`

@import "pom.xml"

#### Transport

@import "src\main\java\org\example\es\AppTransport.java"

#### Low-level

@import "src\main\java\org\example\es\AppLowLevel.java"

#### High-level

@import "src\main\java\org\example\es\AppHighLevel.java"
