---
title: ElasticSearch的使用
date: 2020-06-06 17:26:09
categories: 其他
tags: 其他
---

## ElasticSearch的使用

#### 1、[下载]( https://www.elastic.co/cn/downloads/elasticsearch )与配置

* 解压后在bin里运行elasticSearch脚本启动
* 默认9200端口为http协议，9300端口为Tcp协议

#### 2、图形化界面[elasticsearch-head ]( https://github.com/mobz/elasticsearch-head)的安装与使用

* elasticsearch-head是试用nodejs开发的，在使用之前先安装nodejs

* 安装grunt

  ```shell
  npm install -g grunt-cli
  npm install
  ```

* 启动服务

  ```
  grunt server
  ```

* 修改elasticSearch/conf/elasticsearch.yml允许跨域

  ```yaml
  http.cors.enabled: true
  http.cors.allow-origin: "*"
  ```

#### 3、使用Http请求操作

##### 3.1 创建index

```http
PUT http://127.0.0.1:9200/{{index}}
```

```json
{
    "mappings":{
        "type":{
            "properties":{
                "id":{
                    "store":true,
                    "type":"long"
                },
                "title":{
                    "analyzer":"standard",
                    "store":true,
                    "type":"text",
                    "index":true
                },
                "content":{
                    "analyzer":"standard",
                    "store":true,
                    "type":"text",
                    "index":true
                }
            }
        }
    }
}
```

给已创建的index设置mapping信息

```http
POST http://127.0.0.1:9200/{{index}}/{{type}}/_mapping
```

```
{
    "properties":{
        "id":{
            "store":true,
            "type":"long"
        },
        "title":{
            "analyzer":"standard",
            "store":true,
            "type":"text",
            "index":true
        },
        "content":{
            "analyzer":"standard",
            "store":true,
            "type":"text",
            "index":true
        }
    }
}

```

#### 3.2 删除index

```http
DELETE http://127.0.0.1:9200/{{index}}
```

#### 3.3 创建Document

```http
POST http://127.0.0.1:9200/{{index}}/{{type}}/{{id}}
```

```json
{
    "id":1,
    "title":"新添加的标题",
    "content":"新添加的内容"
}
```

#### 3.4 删除Document

```http
DELETE http://127.0.0.1:9200/{{index}}/{{type}}/{{id}}
```

#### 3.5 修改Document

* 与添加的操作一样，底层在检测到有相同id存在时会先删除后添加

#### 3.6 根据id查询

```http
GET http://127.0.0.1:9200/{{index}}/{{type}}/{{id}}
```

#### 3.7 根据关键字查询

```http
POST http://127.0.0.1:9200/{{index}}/{{type}}/_search
```

```json
{
    "query":{
        "term":{
            "title":"新"
        }
    }
}
```

#### 3.7 根据字符串查询（分词后查询）

```http
POST http://127.0.0.1:9200/{{index}}/{{type}}/_search
```

```json
{
    "query":{
        "query_string":{
            "default_field":"title",
            "query":"的标题"
        }
    }
}
```

#### 3.8 查看分词结果

```http
POST http://127.0.0.1:9200/_analyze
```

```json
{
    "text":"测试分词器，后边是测试内容：spring cloud实战",
    "analyzer":"ik_max_word"
}
```

