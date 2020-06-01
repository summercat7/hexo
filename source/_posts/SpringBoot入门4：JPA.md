---
title: SpringBoot入门4：JPA
date: 2019-10-09 19:32:04
categories: java
tags: 框架
---
# JPA
## 概述
* JPA全称Java Persistence API.JPA通过JDK 5.0注解或XML描述对象－关系表的映射关系，并将运行期的实体对象持久化到数据库中。
* JPA 的目标之一是制定一个可以由很多供应商实现的API，并且开发人员可以编码来实现该API，而不是使用私有供应商特有的API。
* JPA是需要Provider来实现其功能的，Hibernate就是JPA Provider中很强的一个，应该说无人能出其右。从功能上来说，JPA就是Hibernate功能的一个子集。
## 实现
### 添加相关依赖
* 添加spring-boot-starter-jdbc依赖：
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-jpa
	</artifactId>
</dependency>
```
* 添加mysql连接类和连接池类：
```xml
<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<scope>runtime</scope>
</dependency>
```
## 配置数据源，在application.properties文件配置：
```properties
spring:
  datasource:
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/springboot?useUnicode=true&characterEncoding=utf8&characterSetResults=utf8
    username: root
    password: 123456

  jpa:
    hibernate:
      ddl-auto: update  # 第一次简表create  后面用update
    show-sql: true
```
* 注意，如果通过jpa在数据库中建表，将jpa.hibernate,ddl-auto改为create，建完表之后，要改为update,要不然每次重启工程会删除表并新建。
## 实体类
* 通过@Entity 表明是一个映射的实体类， @Id表明id， @GeneratedValue 字段自动生成
```java
@Entity
public class Account {
    @Id
    @GeneratedValue
    private int id ;
    private String name ;
    private double money;
}
```
## DAO层
* 数据访问层，通过编写一个继承自 JpaRepository 的接口就能完成数据访问,其中包含了几本的单表查询的方法，非常的方便。值得注意的是，这个Account 对象名，而不是具体的表名，另外Interger是主键的类型，一般为Integer或者Long
```java
public interface AccountDao  extends JpaRepository<Account,Integer> {
}
```