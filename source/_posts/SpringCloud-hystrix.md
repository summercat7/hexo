---
title: SpringCloud_hystrix
date: 2019-10-11 20:09:48
categories: java
tags: 框架
---
# hystrix

## ribbon中使用断路器
### 概述
* 在微服务架构中，根据业务来拆分成一个个的服务，服务与服务之间可以相互调用（RPC），在Spring Cloud可以用RestTemplate+Ribbon和Feign来调用。为了保证其高可用，单个服务通常会集群部署。由于网络原因或者自身的原因，服务并不能保证100%可用，如果单个服务出现问题，调用这个服务就会出现线程阻塞，此时若有大量的请求涌入，Servlet容器的线程资源会被消耗完毕，导致服务瘫痪。服务与服务之间的依赖性，故障会传播，会对整个微服务系统造成灾难性的严重后果，这就是服务故障的“雪崩”效应。
* 为了解决这个问题，业界提出了断路器模型。

### 准备工作
* 启动eureka-server 工程；启动service-hi工程，它的端口为8762。

### 在ribbon使用断路器
* 改造serice-ribbon 工程的代码，首先在pox.xml文件中加入spring-cloud-starter-hystrix的起步依赖
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
```
* 在程序的启动类ServiceRibbonApplication 加@EnableHystrix注解开启Hystrix
```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableHystrix
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
* 改造HelloService类，在hiService方法上加上@HystrixCommand注解。该注解对该方法创建了熔断器的功能，并指定了fallbackMethod熔断方法，熔断方法直接返回了一个字符串
```java
@Service
public class HelloService {

    @Autowired
    RestTemplate restTemplate;

    @HystrixCommand(fallbackMethod = "hiError")
    public String hiService(String name) {
        return restTemplate.getForObject("http://SERVICE-HI/hi?name="+name,String.class);
    }

    public String hiError(String name) {
        return "hi,"+name+",sorry,error!";
    }
}
```
* 启动：service-ribbon 工程，当我们访问http://localhost:8764/hi?name=wang,浏览器显示：
	* hi wang,i am from port:8762
* 此时关闭 service-hi 工程，当我们再访问http://localhost:8764/hi?name=wang，浏览器会显示：
	* hi ,wang,orry,error!

## Feign中使用断路器
* Feign是自带断路器的，在D版本的Spring Cloud中，它没有默认打开。需要在配置文件中配置打开它
```properties
feign.hystrix.enabled=true
```
* 基于service-feign工程进行改造，只需要在FeignClient的SchedualServiceHi接口的注解中加上fallback的指定类
```java
@FeignClient(value = "service-hi",fallback = SchedualServiceHiHystric.class)
public interface SchedualServiceHi {
    @RequestMapping(value = "/hi",method = RequestMethod.GET)
    String sayHiFromClientOne(@RequestParam(value = "name") String name);
}
```
* SchedualServiceHiHystric需要实现SchedualServiceHi 接口，并注入到Ioc容器中
```java
@Component
public class SchedualServiceHiHystric implements SchedualServiceHi {
    @Override
    public String sayHiFromClientOne(String name) {
        return "sorry "+name;
    }
}
```
* 运行效果同上

## Hystrix Dashboard (断路器：Hystrix 仪表盘)
* 基于service-ribbon 改造，Feign的改造和这一样。

* 首选在pom.xml引入spring-cloud-starter-hystrix-dashboard的起步依赖
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-hystrix-dashboard</artifactId>
</dependency>
```
* 在主程序启动类中加入@EnableHystrixDashboard注解，开启hystrixDashboard
```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableHystrix
@EnableHystrixDashboard
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
* 打开浏览器：访问http://localhost:8764/hystrix
* 点击monitor stream，进入下一个界面，访问：http://localhost:8764/hi?name=forezp
	* 此时会出现监控界面