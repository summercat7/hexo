---
title: SpringCloud_ribbon
date: 2019-10-11 20:04:34
categories: java
tags: 框架
---
# ribbon
## 用途
* 在微服务架构中，业务都会被拆分成一个独立的服务，服务与服务的通讯是基于http restful的。Spring cloud有两种服务调用方式，一种是ribbon+restTemplate，另一种是feign。

## 简介
* ribbon是一个负载均衡客户端，可以很好的控制htt和tcp的一些行为。Feign默认集成了ribbon。

* ribbon 已经默认实现了这些配置bean：
	* IClientConfig ribbonClientConfig: DefaultClientConfigImpl
 	* IRule ribbonRule: ZoneAvoidanceRule
 	* IPing ribbonPing: NoOpPing
 	* ServerList ribbonServerList: ConfigurationBasedServerList
 	* ServerListFilter ribbonServerListFilter: ZonePreferenceServerListFilter
	* ILoadBalancer ribbonLoadBalancer: ZoneAwareLoadBalancer

## 准备工作
* 基于上一篇文章的工程，启动eureka-server 工程；启动service-hi工程，它的端口为8762；将service-hi的配置文件的端口改为8763,并启动，这时：service-hi在eureka-server注册了2个实例，这就相当于一个小的集群。

## 建一个服务消费者
* 引入依赖
```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-ribbon</artifactId>
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
* 配置
```yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8764
spring:
  application:
    name: service-ribbon
```

* 在工程的启动类中,通过@EnableDiscoveryClient向服务中心注册；
* 向程序的ioc注入一个bean: restTemplate;
* 通过@LoadBalanced注解表明这个restRemplate开启负载均衡的功能。
```java
@SpringBootApplication
@EnableDiscoveryClient
public class ServiceRibbonApplication {

	public static void main(String[] args) {
		SpringApplication.run(ServiceRibbonApplication.class, args);
	}

	@Bean
	@LoadBalanced
	RestTemplate restTemplate() {
		return new RestTemplate();
	}

}
```

* 写一个测试类HelloService，通过之前注入ioc容器的restTemplate来消费service-hi服务的“/hi”接口，在这里我们直接用的程序名替代了具体的url地址，在ribbon中它会根据服务名来选择具体的服务实例，根据服务实例在请求的时候会用具体的url替换掉服务名，代码如下：
```java
@Service
public class HelloService {

    @Autowired
    RestTemplate restTemplate;

    public String hiService(String name) {
        return restTemplate.getForObject("http://SERVICE-HI/hi?name="+name,String.class);
    }

}
```

* 写一个controller，在controller中用调用HelloService 的方法，代码如下：
```java
@RestController
public class HelloControler {

    @Autowired
    HelloService helloService;
    @RequestMapping(value = "/hi")
    public String hi(@RequestParam String name){
        return helloService.hiService(name);
    }
}
```

* 在浏览器上多次访问http://localhost:8764/hi?name=wang，浏览器交替显示：
	* hi wang,i am from port:8762
	* hi wang,i am from port:8763