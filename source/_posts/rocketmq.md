---
title: Centos7部署RocketMQ
date: 2020-06-03 15:00:20
tags: 其他
categories: 其他
---
## Centos7部署RocketMQ

### 1. 环境准备

系统环境：Centos7 x64

JDK：jdk-8u171-linux-x64

Maven：3.2.x以上的版本均可

### 2. 下载RocketMQ

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/apache/rocketmq/4.7.0/rocketmq-all-4.7.0-source-release.zip
```

### 3. 解压

```shell
unzip -d /opt/myapp/ rocketmq-all-4.7.0-source-release.zip
```

### 4. 使用MAVEN进行打包

 执行mvn打包会下好多的依赖包 ，时间较长

```shell
cd /opt/myapp/rocketmq-all-4.7.0/

mvn -Prelease-all -DskipTests clean install -U

cd distribution/target/apache-rocketmq
```

### 5. 修改配置

 一般到这里按照官方文档是可以启动的，但是最关键的一点，除了上面环境的要求外，还有个硬性要求，就是内存不能低于4G 

```shell
cd bin

vim runserver.sh 

# 找到如下配置
JAVA_OPT="${JAVA_OPT} -server -Xms8g -Xmx8g -Xmn4g"

# 修改成你可以接受的范围
JAVA_OPT="${JAVA_OPT} -server -Xms512m -Xmx521m -Xmn256m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"

vim runbroker.sh

# 找到如下配置
JAVA_OPT="${JAVA_OPT} -server -Xms4g -Xmx4g -Xmn2g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
# 修改成你可以接受的范围
JAVA_OPT="${JAVA_OPT} -server -Xms512m -Xmx512m -Xmn256m"
```



### 6. 配置环境变量

```shell
vim /etc/profile

export ROCKETMQ_HOME=/opt/myapp/rocketmq/rocketmq-all-4.7.0-source-release/distribution/target/rocketmq-4.7.0/rocketmq-4.7.0
export PATH=${ROCKETMQ_HOME}/bin:${PATH}

# 使配置生效
source /etc/profile
```



### 7. 启动Name Server

```shell
nohup sh mqnamesrv &

tail -f ~/logs/rocketmqlogs/namesrv.log
```



### 8. 启动Broker

```shell
nohup sh mqbroker -n localhost:9876 &

tail -f ~/logs/rocketmqlogs/broker.log
```



### 9. 执行测试

添加环境变量：

```shell
export NAMESRV_ADDR=localhost:9876
```

建议分别于不同两个窗口执行以下两个脚本

```shell
# 生产者生产消息
sh tools.sh org.apache.rocketmq.example.quickstart.Producer
```

```shell
# 消费者消费消息
sh tools.sh org.apache.rocketmq.example.quickstart.Consumer
```



### 10. 关闭服务

```shell
sh mqshutdown broker
sh mqshutdown namesrv
```

### 11. 可视化服务配置

#### 11.1 下载

```shell
cd /opt/myjava/rocketmq

git clone https://github.com/apache/rocketmq-externals
```

#### 11.2 修改配置文件

```shell
cd /opt/myjava/rocketmq/rocketmq-externals/rocketmq-console/src/main/resources
vim application.properties

# 修改如下配置
server.port=8081 // 服务端口号
rocketmq.config.namesrvAddr=127.0.0.1:9876 // 配置服务地址

rocketmq.config.dataPath=/tmp/rocketmq-console/data // mq数据路径，可以自己修改
```

#### 11.3 使用maven打包

```shell
cd /opt/myjava/rocketmq/rocketmq-externals/rocketmq-console
mvn clean package -Dmaven.test.skip=true
```

#### 11.4 运行

运行后访问对应的端口，如：http://192.168.159.100.8081

```shell
cd /opt/myjava/rocketmq/rocketmq-externals/rocketmq-console/target

java -jar rocketmq-console-ng-1.0.1.jar
```

指定端口运行和rocketmq地址运行

```shell
java -jar rocketmq-console-ng-1.0.0.jar --server.port=8081 --rocketmq.config.namesrvAddr=127.0.0.1:9876
```





### 12. 自定义测试

自动创建Topic

```shell
nohup sh mqbroker -n localhost:9876 autoCreateTopicEnable=true > ~/logs/rocketmqlogs/broker.log 2>&1 &
```

RocketMQ常用命令

```shell
#查看所有消费组group:
sh mqadmin consumerProgress -n 127.0.0.1:9876

#查看所有topic:
sh mqadmin topicList -n 127.0.0.1:9876

#新增topic:
sh mqadmin updateTopic -n localhost:9876  -b localhost:10911  -t mytopic

#删除topic
sh mqadmin deleteTopic –n 127.0.0.1:9876 –c DefaultCluster –t mytopic

#查询集群消息
sh mqadmin  clusterList -n 127.0.0.1:9876
```



生产者:

```java
import com.alibaba.rocketmq.client.producer.DefaultMQProducer;
import com.alibaba.rocketmq.client.producer.SendResult;
import com.alibaba.rocketmq.common.message.Message;

public class ProducerTest {
    public static void main(String[] args) throws Exception {
        DefaultMQProducer producer = new DefaultMQProducer("producerGroup1");
        producer.setNamesrvAddr("192.168.159.100:9876");
        producer.setInstanceName("instance1");
        //为避免程序启动的时候报错，添加此代码，可以让rocketMq自动创建topickey
        producer.setCreateTopicKey("AUTO_CREATE_TOPIC_KEY");
        producer.start();
        System.out.println("开始发送数据");
        try {
            for (int i = 0; i < 3; i++) {
                Message msg = new Message("mytopic", "mytag", ("hello world " + i).getBytes());
                SendResult sendResult = producer.send(msg);
                System.out.println("发送成功 " + new String(msg.getBody()));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        producer.shutdown();
    }
}

```

消费者:

```java
import com.alibaba.rocketmq.client.consumer.DefaultMQPushConsumer;
import com.alibaba.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import com.alibaba.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import com.alibaba.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import com.alibaba.rocketmq.common.consumer.ConsumeFromWhere;
import com.alibaba.rocketmq.common.message.Message;
import com.alibaba.rocketmq.common.message.MessageExt;
import java.util.List;

public class ConsumerTest {
    public static void main(String[] args) {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("producerGroup1");
        consumer.setNamesrvAddr("192.168.159.100:9876");
        System.out.println("开始接收数据");
        try {
            // 设置topic和标签
            consumer.subscribe("mytopic", "mytag");
            // 程序第一次启动从消息队列头取数据
            consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);
            consumer.registerMessageListener(new MessageListenerConcurrently() {
                public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list,
                                                                ConsumeConcurrentlyContext Context) {
                    Message msg = list.get(0);
                    System.out.println("收到数据：" + new String(msg.getBody()));
                    return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
                }
            });
            consumer.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

```



