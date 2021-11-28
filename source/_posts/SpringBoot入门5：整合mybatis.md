---
title: SpringBoot入门5：整合mybatis
date: 2019-10-10 14:15:24
categories:
tags:
---
# SpringBoot整合mybatis
## 引入依赖
```xml
<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<scope>runtime</scope>
</dependency>
<dependency>
	<groupId>com.alibaba</groupId>
	<artifactId>druid</artifactId>
	<version>1.0.29</version>
</dependency>

<dependency>
	<groupId>org.mybatis.spring.boot</groupId>
	<artifactId>mybatis-spring-boot-starter</artifactId>
	<version>1.3.2</version>
</dependency>
```
## 配置数据源
### 使用注解
```yml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/springboot?serverTimezone=UTC
    username: root
    password: root
```
### 使用xml
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/test
spring.datasource.username=root
spring.datasource.password=123456
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
mybatis.mapper-locations=classpath*:mybatis/*Mapper.xml
mybatis.type-aliases-package=com.forezp.entity
```
## Dao层
### 使用注解
```java
@Mapper
public interface AccountDao {
    @Insert("insert into account(name,money) value(#{name},#{money})")
    public int add(@Param("name") String name, @Param("money") double money);

    @Update("update account set name = #{name}, money = #{money} where id = #{id}")
    int update(@Param("name") String name, @Param("money") double money, @Param("id") int  id);

    @Delete("delete from account where id = #{id}")
    int delete(int id);

    @Select("select id, name, money from account where id = #{id}")
    Account findAccount(@Param("id") int id);

    @Select("select id, name, money from account")
    List<Account> findAccountList();
}
```
### 使用xml
* 接口
```java
public interface AccountMapper2 {
   int update( @Param("money") double money, @Param("id") int  id);
}
```
* mapper
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.forezp.dao.AccountMapper2">


    <update id="update">
        UPDATE account set money=#{money} WHERE id=#{id}
    </update>
</mapper>
```
## service层
```java
@Service
public class AccountService2 {

    @Autowired
    AccountMapper2 accountMapper2;

    //使用声明式事务
    @Transactional
    public void transfer() throws RuntimeException{
        accountMapper2.update(90,1);//用户1减10块 用户2加10块
        int i=1/0;
        accountMapper2.update(110,2);
    }
}
```