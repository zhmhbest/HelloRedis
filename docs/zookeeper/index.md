<link rel="stylesheet" href="https://zhmhbest.gitee.io/hellomathematics/style/index.css">
<script src="https://zhmhbest.gitee.io/hellomathematics/style/index.js"></script>

# [Zookeeper](../index.html)

[TOC]

## 系统配置

### 添加域名

```bash
# 对所有主机统一修改
vim /etc/hosts
# G
# o
# ...
# wq
more /etc/hosts
```

```txt
192.168.1.101 zookeeper1
192.168.1.102 zookeeper2
192.168.1.103 zookeeper3
```

### 设置主机名称

```bash
# 对每台主机定制修改
hostnamectl set-hostname 'zookeeper1'
hostname -f
```

## 安装

### 安装Java

```bash
yum -y install java
JAVA_HOME=$(echo /usr/lib/jvm/java-*-openjdk-*)
grep '^export JAVA_HOME' /etc/profile ||\
    echo "export JAVA_HOME=${JAVA_HOME}">>/etc/profile
tail -n 2 /etc/profile
```

### 安装Zookeeper

```bash
# 下载Zookeeper
ZOOKEEPER_LOCATION='/zookeeper' # 安装位置
ZOOKEEPER_VERSION='3.5.9'       # 安装版本
ZOOKEEPER_REPOSITORY='http://archive.apache.org/dist/zookeeper'
ZOOKEEPER_ARCHIVE="${ZOOKEEPER_REPOSITORY}/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
echo $ZOOKEEPER_ARCHIVE
wget $ZOOKEEPER_ARCHIVE
tar -xvf "./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
pushd "./apache-zookeeper-${ZOOKEEPER_VERSION}-bin"
mkdir data log
cp -f ./conf/zoo_sample.cfg ./conf/zoo.cfg
cp -rf ./* $ZOOKEEPER_LOCATION
popd

# 修改基本配置
pushd $ZOOKEEPER_LOCATION/conf
ZOOKEEPER_DAT=$ZOOKEEPER_LOCATION/data
ZOOKEEPER_LOG=$ZOOKEEPER_LOCATION/log
grep -q '^dataDir=' ./zoo.cfg &&\
    sed -ri "/^dataDir=/s/=.+$/=`echo ${ZOOKEEPER_DAT//\//\\\/}`/"    ./zoo.cfg ||\
    echo "dataDir=${ZOOKEEPER_DAT}">>./zoo.cfg
grep -q '^dataLogDir=' ./zoo.cfg &&\
    sed -ri "/^dataLogDir=/s/=.+$/=`echo ${ZOOKEEPER_LOG//\//\\\/}`/" ./zoo.cfg ||\
    echo "dataLogDir=${ZOOKEEPER_LOG}">>./zoo.cfg
grep '^data' ./zoo.cfg
popd

# 加入环境变量
grep -q '^export ZOOKEEPER_HOME' /etc/profile ||\
    echo "export ZOOKEEPER_HOME=${ZOOKEEPER_LOCATION}">>/etc/profile && \
    echo 'export PATH=$ZOOKEEPER_HOME/bin:$PATH'>>/etc/profile
grep '^export ' /etc/profile
source /etc/profile
```

#### 集群配置

```bash
# myid
hostname=`hostname -f`
hostid=${hostname:0-1}
echo $hostid>$ZOOKEEPER_HOME/data/myid
head -n 1 $ZOOKEEPER_HOME/data/myid

# Server.Index
echo "server.1=zookeeper1:2888:3888">>$ZOOKEEPER_HOME/conf/zoo.cfg
echo "server.2=zookeeper2:2888:3888">>$ZOOKEEPER_HOME/conf/zoo.cfg
echo "server.3=zookeeper3:2888:3888">>$ZOOKEEPER_HOME/conf/zoo.cfg
tail -n 5 $ZOOKEEPER_HOME/conf/zoo.cfg
```

### 服务管理

```bash
# start | stop | restart | status
zkServer.sh start
zkServer.sh status | grep 'Mode:'
```
