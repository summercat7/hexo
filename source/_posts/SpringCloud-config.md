---
title: SpringCloud_config
date: 2019-10-11 20:13:03
categories: java
tags: 框架
---
# config
## 简介
* 在分布式系统中，由于服务数量巨多，为了方便服务配置文件统一管理，实时更新，所以需要分布式配置中心组件。在Spring Cloud中，有分布式配置中心组件spring cloud config ，它支持配置服务放在配置服务的内存中（即本地），也支持放在远程Git仓库中。在spring cloud config 组件中，分两个角色，一是config server，二是config client。

## 构建Config Server
* 创建一个spring-boot项目，取名为config-server
* 引入依赖
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
```
* 在程序的入口Application类加上@EnableConfigServer注解开启配置服务器的功能
```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConfigServerApplication.class, args);
	}
}
```
* 需要在程序的配置文件application.properties文件配置以下
```properties
spring.application.name=config-server
server.port=8888


spring.cloud.config.server.git.uri=https://github.com/forezp/SpringcloudConfig/
spring.cloud.config.server.git.searchPaths=respo
spring.cloud.config.label=master
spring.cloud.config.server.git.username=your username
spring.cloud.config.server.git.password=your password
```
	* spring.cloud.config.server.git.uri：配置git仓库地址
	* spring.cloud.config.server.git.searchPaths：配置仓库路径
	* spring.cloud.config.label：配置仓库的分支
	* spring.cloud.config.server.git.username：访问git仓库的用户名
	* spring.cloud.config.server.git.password：访问git仓库的用户密码

* 如果Git仓库为公开仓库，可以不填写用户名和密码，如果是私有仓库需要填写

* 启动程序：访问http://localhost:8888/foo/dev

* http请求地址和资源文件映射如下:

	* /{application}/{profile}[/{label}]
	* /{application}-{profile}.yml
	* /{label}/{application}-{profile}.yml
	* /{application}-{profile}.properties
	* /{label}/{application}-{profile}.properties


## 构建一个config client
* 重新创建一个springboot项目，取名为config-client

### 引入依赖
```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-config</artifactId>
</dependency>

<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
</dependency>
```

### 配置文件
```properties
spring.application.name=config-client
spring.cloud.config.label=master
spring.cloud.config.profile=dev
spring.cloud.config.uri= http://localhost:8888/
server.port=8881
```
* spring.cloud.config.label 指明远程仓库的分支
* spring.cloud.config.profile
	* dev开发环境配置文件
	* test测试环境
	* pro正式环境
* spring.cloud.config.uri= http://localhost:8888/ 指明配置服务中心的网址。

### 入口类
* 程序的入口类，写一个API接口“／hi”，返回从配置中心读取的foo变量的值
```java
@SpringBootApplication
@RestController
public class ConfigClientApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConfigClientApplication.class, args);
	}

	@Value("${foo}")
	String foo;
	@RequestMapping(value = "/hi")
	public String hi(){
		return foo;
	}
}
```
* 打开网址访问：http://localhost:8881/hi，网页显示：

	* foo version 3

* 这就说明，config-client从config-server获取了foo的属性，而config-server是从git仓库读取的