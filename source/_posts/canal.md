---
title: canal的使用
date: 2020-06-02 12:04:32
tags: 其他
categories: 其他
---
## CentOS7安装Canal

内容参考链接：https://blog.csdn.net/qrjqrjqrj/article/details/102979410

#### canal的工作原理

canal 模拟 MySQL slave 的交互协议，伪装自己为 MySQL slave ，向 MySQL master 发送dump 协议
MySQL master 收到 dump 请求，开始推送 binary log 给 slave (即 canal )
canal 解析 binary log 对象(原始为 byte 流)

#### 安装

1 下载[Canal]( https://github.com/alibaba/canal/releases )( [canal.deployer-1.1.4.tar.gz](https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.deployer-1.1.4.tar.gz) )

2 解压到安装目录

```shell
tar -zxvf canal.deployer-1.1.4.tar.gz -C /opt/myapp/canal
```

3 配置

3.1 mysql开启binlog

```shell
vim /etc/my.cnf
```

**  在[mysqld]中添加下列语句

```
log-bin=mysql-bin

binlog-format=ROW

server_id=1
```

** 保存退出后重启mysql，执行systemctl restart mysql

```sql
show variables like 'log_%';

show variables like 'binlog_format';
```

3.2 创建有slave权限的账号

```sql
--通过以下语句创建用户canal：
create user canal@'%' identified by 'canal';
--通过以下语句给用户授权：
grant select, replication slave, replication client on *.* to canal@'%';
```



3.3 修改Canal Server配置

```shell
vim conf/example/instance.properties
```

```
canal.instance.mysql.slaveId=1234

canal.instance.master.address=127.0.0.1:3306

canal.instance.dbUsername=root
canal.instance.dbPassword=123456
```





4 代码测试(mysql->redis)

4.1 pow.xml

```xml
    <dependencies>
        <dependency>
            <groupId>javax.validation</groupId>
            <artifactId>validation-api</artifactId>
            <version>2.0.1.Final</version>
        </dependency>
        <dependency>
            <groupId>com.alibaba.otter</groupId>
            <artifactId>canal.client</artifactId>
            <version>1.1.3</version>
        </dependency>
        <dependency>
            <groupId>redis.clients</groupId>
            <artifactId>jedis</artifactId>
            <version>2.9.0</version>
        </dependency>
    </dependencies>
```



4.2 CanalClient

```java
import com.alibaba.fastjson.JSONObject;
import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.client.CanalConnectors;
import com.alibaba.otter.canal.protocol.CanalEntry.*;
import com.alibaba.otter.canal.protocol.Message;

import java.net.InetSocketAddress;
import java.util.List;

public class CanalClient {

    public static void main(String args[]) {
        CanalConnector connector = CanalConnectors.newSingleConnector(new InetSocketAddress("192.168.159.100",
                11111), "example", "", "");
        int batchSize = 100;
        int emptyCount = 0;
        try {
            connector.connect();
            connector.subscribe(".*\\..*");
            connector.rollback();
            int i=0;
            while (true) {
                // 获取指定数量的数据
                Message message = connector.getWithoutAck(batchSize);
                long batchId = message.getId();
                int size = message.getEntries().size();
//                System.out.println("batchId = " + batchId);
//                System.out.println("size = " + size);
                if (batchId == -1 || size == 0) {
                    emptyCount++;
//                    System.out.println("empty count : " + emptyCount);
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                } else {
                    emptyCount = 0;
                    printEntry(message.getEntries());
                }
                // 提交确认
                connector.ack(batchId);
                // connector.rollback(batchId); // 处理失败, 回滚数据
            }
        } finally {
            connector.disconnect();
        }
    }

    private static void printEntry(List<Entry> entrys) {
        for (Entry entry : entrys) {
            if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN || entry.getEntryType() == EntryType.TRANSACTIONEND) {
                continue;
            }
            RowChange rowChage = null;
            try {
                rowChage = RowChange.parseFrom(entry.getStoreValue());
            } catch (Exception e) {
                throw new RuntimeException("ERROR ## parser of eromanga-event has an error , data:" + entry.toString(),
                        e);
            }
            EventType eventType = rowChage.getEventType();
            System.out.println(String.format("================> binlog[%s:%s] , name[%s,%s] , eventType : %s",
                    entry.getHeader().getLogfileName(), entry.getHeader().getLogfileOffset(),
                    entry.getHeader().getSchemaName(), entry.getHeader().getTableName(),
                    eventType));

            for (RowData rowData : rowChage.getRowDatasList()) {
                if (eventType == EventType.DELETE) {
                    redisDelete(rowData.getBeforeColumnsList());
                } else if (eventType == EventType.INSERT) {
                    redisInsert(rowData.getAfterColumnsList());
                } else {
                    System.out.println("-------> before");
                    printColumn(rowData.getBeforeColumnsList());
                    System.out.println("-------> after");
                    printColumn(rowData.getAfterColumnsList());
                    redisUpdate(rowData.getAfterColumnsList());
                }
            }
        }
    }

    private static void printColumn(List<Column> columns) {
        for (Column column : columns) {
            System.out.println(column.getName() + " : " + column.getValue() + "    update=" + column.getUpdated());
        }
    }

    private static void redisInsert(List<Column> columns) {
        JSONObject json = new JSONObject();
        for (Column column : columns) {
            json.put(column.getName(), column.getValue());
        }
        if (columns.size() > 0) {
            RedisUtil.stringSet("user:" + columns.get(0).getValue(), json.toJSONString());
        }
    }

    private static void redisUpdate(List<Column> columns) {
        JSONObject json = new JSONObject();
        for (Column column : columns) {
            json.put(column.getName(), column.getValue());
        }
        if (columns.size() > 0) {
            RedisUtil.stringSet("user:" + columns.get(0).getValue(), json.toJSONString());
        }
    }

    private static void redisDelete(List<Column> columns) {
        JSONObject json = new JSONObject();
        for (Column column : columns) {
            json.put(column.getName(), column.getValue());
        }
        if (columns.size() > 0) {
            RedisUtil.delKey("user:" + columns.get(0).getValue());
        }
    }
}
```



4. 3RedisUtil

```java
import redis.clients.jedis.Jedis;


public class RedisUtil {

    private static Jedis jedis = null;

    public static synchronized Jedis getJedis() {
        if (jedis == null) {
            jedis = new Jedis("127.0.0.1", 6379);
//            jedis.auth("password");
        }
        return jedis;
    }

    public static boolean existKey(String key) {
        return getJedis().exists(key);
    }

    public static void delKey(String key) {
        getJedis().del(key);
    }

    public static String stringGet(String key) {
        return getJedis().get(key);
    }

    public static String stringSet(String key, String value) {
        return getJedis().set(key, value);
    }

    public static void hashSet(String key, String field, String value) {
        getJedis().hset(key, field, value);
    }
}

```

