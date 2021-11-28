---
title: SpringCloud入门1：创建工程
date: 2019-10-11 08:37:02
categories:
tags:
---
# SpringCloud入门
## SpringCloud简介
* spring cloud 为开发人员提供了快速构建分布式系统的一些工具，包括配置管理、服务发现、断路器、路由、微代理、事件总线、全局锁、决策竞选、分布式会话等等。它运行环境简单，可以在开发人员的电脑上跑。
* spring cloud是基于springboot的。
## 项目创建
* 右键工程->创建model-> 选择spring initialir
* 下一步->选择cloud discovery->eureka server

### EurekaServer
* 只需要一个注解@EnableEurekaServer
```java
@EnableEurekaServer
@SpringBootApplication
public class EurekaserverApplication {
	public static void main(String[] args) {
		SpringApplication.run(EurekaserverApplication.class, args);
	}
}
```
* eureka是一个高可用的组件，它没有后端缓存，每一个实例注册之后需要向注册中心发送心跳（因此可以在内存中完成），在默认情况下erureka server也是一个eureka client ,必须要指定一个 server
* appication.yml
```yml
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```
### EurekaClient
* 注解@EnableEurekaClient 表明自己是一个eurekaclient
```java
@SpringBootApplication
@EnableEurekaClient
@RestController
public class ServiceHiApplication {
	public static void main(String[] args) {
		SpringApplication.run(ServiceHiApplication.class, args);
	}

	@Value("${server.port}")
	String port;
	@RequestMapping("/hi")
	public String home(@RequestParam String name) {
		return "hi "+name+",i am from port:" +port;
	}
}
```
* application.yml
```yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8762
spring:
  application:
    name: service-hi
```