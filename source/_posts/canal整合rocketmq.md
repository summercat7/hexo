---
title: canal整合rocketmq
date: 2020-06-04 14:52:08
categories: 其他
tags: 其他
---

## canal整合rocketmq

#### 1. 数据库设置

 修改需要被同步的数据库 /etc/my.cfg配置，有则修改无则添加 

```shell
[mysqld]
log-bin=mysql-bin # 开启 binlog
binlog-format=ROW # 选择 ROW 模式
server_id=1 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
binlog-rows-query-log-events  = 1  #查看完整的sql语句
```

 canal的原理是模拟自己为mysql slave，创建有mysql slave的相关权限的用户

``` sql
CREATE USER canal IDENTIFIED BY 'canal';  

GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON . TO 'canal'@'%';

GRANT ALL PRIVILEGES ON . TO 'canal'@'%' ;

FLUSH PRIVILEGES;
```

#### 2. Canal配置

##### 修改instance 配置文件 `vi conf/example/instance.properties`

```properties
# 数据库实例地址，主数据库
canal.instance.master.address=192.168.1.48:3306
canal.instance.master.journal.name=
canal.instance.master.position=
canal.instance.master.timestamp=
canal.instance.master.gtid=

# rds oss binlog
canal.instance.rds.accesskey=
canal.instance.rds.secretkey=
canal.instance.rds.instanceId=

# table meta tsdb info
canal.instance.tsdb.enable=true
#canal.instance.tsdb.url=jdbc:mysql://127.0.0.1:3306/canal_tsdb
#canal.instance.tsdb.dbUsername=canal
#canal.instance.tsdb.dbPassword=canal

#canal.instance.standby.address =
#canal.instance.standby.journal.name =
#canal.instance.standby.position =
#canal.instance.standby.timestamp =
#canal.instance.standby.gtid=

# username/password 数据库帐号密码
canal.instance.dbUsername=tradesrv
canal.instance.dbPassword=Qt!S!U3wkmuu97_I
canal.instance.connectionCharset = UTF-8
# enable druid Decrypt database password
canal.instance.enableDruid=false

# table regex 白名单过滤
canal.instance.filter.regex=trade\\..*
# table black regex 黑名单过滤
canal.instance.filter.black.regex=mysql\\..*

# mq config
#定义主题
canal.mq.topic=example
# dynamic topic route by schema or table regex
# 根据正则表达式做动态topic
#canal.mq.dynamicTopic=example:.*\\..*
#消息分区
canal.mq.partition=0
# hash partition config
#canal.mq.partitionsNum=3
#canal.mq.partitionHash=test.table:id^name,.*\\..*
#################################################

```

##### 修改canal 配置文件`vi conf/canal.properties`

```properties
#################################################
#########               common argument         ############# 
#################################################
#canal.manager.jdbc.url=jdbc:mysql://127.0.0.1:3306/canal_manager?useUnicode=true&characterEncoding=UTF-8
#canal.manager.jdbc.username=root
#canal.manager.jdbc.password=121212
#canal server的唯一标识，没有实际意义，但是我们建议同一个cluster上的不同节点，其ID尽可能唯一
canal.id =150 
#canal server因为binding的本地IP地址，建议使用内网（唯一，集群可见，consumer可见）IP地址，比如“10.0.1.21”。  
#此IP主要为canalServer提供TCP服务而使用，将会被注册到ZK中,Consumer将与此IP建立连接。
canal.ip =192.168.1.150
#cannal server的TCP端口
canal.port = 11111
canal.metrics.pull.port = 11112
#zookeeper地址，可集群
canal.zkServers =192.168.1.150:2181
# flush data to zk
canal.zookeeper.flush.period = 1000
canal.withoutNetty = false
# tcp, kafka, RocketMQ
canal.serverMode = RocketMQ
# flush meta cursor/parse position to file
#canal将parse、position数据写入的本地文件目录 
canal.file.data.dir = ${canal.conf.dir}
canal.file.flush.period = 1000
## memory store RingBuffer size, should be Math.pow(2,n)
canal.instance.memory.buffer.size = 16384
## memory store RingBuffer used memory unit size , default 1kb
canal.instance.memory.buffer.memunit = 1024 
## meory store gets mode used MEMSIZE or ITEMSIZE
canal.instance.memory.batch.mode = MEMSIZE
canal.instance.memory.rawEntry = true

#################################################
#########               destinations            ############# 
#################################################
#添加实例，用逗号隔开
canal.destinations = example,example1
# conf root dir
canal.conf.dir = ../conf
# auto scan instance dir add/remove and start/stop instance
canal.auto.scan = true
canal.auto.scan.interval = 5

canal.instance.tsdb.spring.xml = classpath:spring/tsdb/h2-tsdb.xml
#canal.instance.tsdb.spring.xml = classpath:spring/tsdb/mysql-tsdb.xml

canal.instance.global.mode = spring
canal.instance.global.lazy = false
#canal.instance.global.manager.address = 127.0.0.1:1099
#canal.instance.global.spring.xml = classpath:spring/memory-instance.xml
canal.instance.global.spring.xml = classpath:spring/file-instance.xml
#canal.instance.global.spring.xml = classpath:spring/default-instance.xml


##################################################
#########                    MQ                      #############
##################################################
# kafka/rocketmq 集群配置: 192.168.1.117:9092,192.168.1.118:9092,192.168.1.119:9092
canal.mq.servers = 192.168.1.150:9876
canal.mq.retries = 0
canal.mq.batchSize = 16384
canal.mq.maxRequestSize = 1048576
canal.mq.lingerMs = 1
canal.mq.bufferMemory = 33554432
#消息生产组名
canal.mq.producerGroup = Canal-Producer
# Canal的batch size, 默认50K, 由于kafka最大消息体限制请勿超过1M(900K以下)
canal.mq.canalBatchSize = 30
# Canal get数据的超时时间, 单位: 毫秒, 空为不限超时
canal.mq.canalGetTimeout = 100
# 是否为flat json格式对象
canal.mq.flatMessage = true
canal.mq.compressionType = none
canal.mq.acks = all
# use transaction for kafka flatMessage batch produce
canal.mq.transaction = false
#canal.mq.properties. =

```

#### 3. RocketMQ配置

 修改配置文件 

```shell
cd distribution/target/apache-rocketmq/conf
vim broker.conf
```

 在broker.conf配置文件添加以下内容 

```shell
brokerClusterName = DefaultCluster		
brokerName = broker-a					
brokerId = 0
brokerIP1=192.168.159.100  #这个IP是本地内网IP地址
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
autoCreateTopicEnable=true		#自动创建topic配置
autoCreateSubscriptionGroup=true	#自动创建注册组配置
rejectTransactionMessage=false		#默认false
transactionTimeOut=6000				#超时时间

```

#### 启动RocketMQ消费者

 修改application配置文件后启动服务 

```properties
server.port=8804

#用来作为数据仓库的数据库配置
spring.datasource.type=com.alibaba.druid.pool.DruidDataSource
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://192.168.0.118/trade?autoReconnect=true&useUnicode=true&characterEncoding=utf-8&generateSimpleParameterMetadata=true&useSSL=false&&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=2%YcIZXyFH7LsC_y

# NameServer地址
apache.rocketmq.namesrvAddr=192.168.1.150:9876
# 生产者的主题 死信队列
apache.rocketmq.producer.topic=exceptionSQL
# 生产者的组名 死信队列
apache.rocketmq.producer.producerGroup=canal_producer_client
# 消费者的主题
apache.rocketmq.consumer.topic=example
# 消费者的组名
apache.rocketmq.consumer.PushConsumer=canal_consumer_client

# 消费线程池最大线程数。默认10   
apache.rocketmq.consumer.consumeThreadMin=10
# 消费线程池最大线程数。默认20   
apache.rocketmq.consumer.consumeThreadMax=20
# 批量消费，一次消费多少条消息。默认1 
apache.rocketmq.consumer.consumeMessageBatchMaxSize=1
# 批量拉消息，一次最多拉多少条。默认32   
apache.rocketmq.consumer.pullBatchSize=32

#定时批量执行sql的间隔时间
apache.rocketmq.consumer.batchExcuteTime=0/3 * * * * ?
#过滤sql语句，不执行的语句类型
apache.rocketmq.consumer.TypeFilter=drop
#过滤表 黑白名单 格式：库名~表名，表名;      *代表所有，库之间分号隔开
apache.rocketmq.consumer.tableWhite=message~*;trade~*;
apache.rocketmq.consumer.tableBlack=
```

