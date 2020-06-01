---
title: SpringBoot入门2：配置文件
date: 2019-10-09 15:49:53
categories: java
tags: 框架
---
# 配置文件
## 自定义属性
* 如果你需要读取配置文件的值只需要加@Value(“${属性名}”)

## 将配置文件的属性赋给实体类
```yml
my:
 name: forezp
 age: 12
 number:  ${random.int}
 uuid : ${random.uuid}
 max: ${random.int(10)}
 value: ${random.value}
 greeting: hi,i'm  ${my.name}
```
### javabean
```java
@ConfigurationProperties(prefix = "my")
@Component
public class ConfigBean {

    private String name;
    private int age;
    private int number;
    private String uuid;
    private int max;
    private String value;
    private String greeting;
}
```
### spring-boot-configuration-processor依赖
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-configuration-processor</artifactId>
	<optional>true</optional>
</dependency>
```
### 应用类
```java
@RestController
@EnableConfigurationProperties({ConfigBean.class})
public class LucyController {
    @Autowired
    ConfigBean configBean;

    @RequestMapping("/lucy")
    public String miya() {
        return configBean.getGreeting()+" >>>>"+configBean.getName()+" >>>>"+ configBean.getUuid()+" >>>>"+configBean.getMax();
    }
}
```
## 自定义配置文件
### test.properties
```properties
com.wang.name=wang
com.wang.age=12
```
### javaBean
* 在最新版本的springboot，需要加这三个注解。@Configuration @PropertySource(value = “classpath:test.properties”) @ConfigurationProperties(prefix = “com.forezp”);在1.4版本需要 PropertySource加上location。
```java
@Configuration
@PropertySource("test.properties")
@ConfigurationProperties("com.wang")
public class User {
    private String name;
    private int age;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}
```
### 应用类
```java
@RestController
@EnableConfigurationProperties({ConfigBean.class,User.class})
public class LucyController {
    @Autowired
    ConfigBean configBean;

    @RequestMapping("/lucy")
    public String miya() {
        return configBean.getGreeting()+" >>>>"+configBean.getName()+" >>>>"+ configBean.getUuid()+" >>>>"+configBean.getMax();
    }

    @Autowired
    User user;
    @RequestMapping("/user")
    public String user() {
        return user.getName()+">>>>"+user.getAge();
    }
}
```

## 多个环境配置文件
* application-test.properties：测试环境
* application-dev.properties：开发环境
* application-prod.properties：生产环境
### 使用方法
* application.yml
```yml
spring:
  profiles:
    active: dev
```
* application-dev.yml
```yml
server:
  port: 8082
```