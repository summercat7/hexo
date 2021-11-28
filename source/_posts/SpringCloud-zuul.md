---
title: SpringCloud_zuul
date: 2019-10-11 20:12:09
categories: java
tags: 框架
---
# Zuul
## 简介
* Zuul的主要功能是路由转发和过滤器。路由功能是微服务的一部分，比如／api/user转发到到user服务，/api/shop转发到到shop服务。zuul默认和Ribbon结合实现了负载均衡的功能。
* zuul有以下功能：
	* Authentication
	* Insights
	* Stress Testing
	* Canary Testing
	* Dynamic Routing
	* Service Migration
	* Load Shedding
	* Security
	* Static Response handling
	* Active/Active traffic management

## 准备工作
* 在原有的工程上，创建一个新的工程。

## 创建service-zuul工程
* 引入依赖
```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-zuul</artifactId>
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
* 在其入口applicaton类加上注解@EnableZuulProxy，开启zuul的功能
```java
@EnableZuulProxy
@EnableEurekaClient
@SpringBootApplication
public class ServiceZuulApplication {
	public static void main(String[] args) {
		SpringApplication.run(ServiceZuulApplication.class, args);
	}
}
```
* 加上配置文件application.yml加上以下的配置代码
```yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8769
spring:
  application:
    name: service-zuul
zuul:
  routes:
    api-a:
      path: /api-a/**
      serviceId: service-ribbon
    api-b:
      path: /api-b/**
      serviceId: service-feign
```
* 首先指定服务注册中心的地址为http://localhost:8761/eureka/，服务的端口为8769，服务名为service-zuul；以/api-a/ 开头的请求都转发给service-ribbon服务；以/api-b/开头的请求都转发给service-feign服务；
* 依次运行这五个工程;打开浏览器访问：http://localhost:8769/api-a/hi?name=wang ;浏览器显示：
	* hi wang,i am from port:8762
* 打开浏览器访问：http://localhost:8769/api-b/hi?name=wang ;浏览器显示：
	* hi wang,i am from port:8762
* 这说明zuul起到了路由的作用

## 服务过滤
* zuul不仅只是路由，并且还能过滤，做一些安全验证。继续改造工程:
```java
@Component
public class MyFilter extends ZuulFilter{

    private static Logger log = LoggerFactory.getLogger(MyFilter.class);
    @Override
    public String filterType() {
        return "pre";
    }

    @Override
    public int filterOrder() {
        return 0;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    @Override
    public Object run() {
        RequestContext ctx = RequestContext.getCurrentContext();
        HttpServletRequest request = ctx.getRequest();
        log.info(String.format("%s >>> %s", request.getMethod(), request.getRequestURL().toString()));
        Object accessToken = request.getParameter("token");
        if(accessToken == null) {
            log.warn("token is empty");
            ctx.setSendZuulResponse(false);
            ctx.setResponseStatusCode(401);
            try {
                ctx.getResponse().getWriter().write("token is empty");
            }catch (Exception e){}

            return null;
        }
        log.info("ok");
        return null;
    }
}
```

* filterType：返回一个字符串代表过滤器的类型，在zuul中定义了四种不同生命周期的过滤器类型，具体如下：
	* pre：路由之前
	* routing：路由之时
	* post： 路由之后
	* error：发送错误调用
* filterOrder：过滤的顺序
* shouldFilter：这里可以写逻辑判断，是否要过滤，本文true,永远过滤。
* run：过滤器的具体逻辑。可用很复杂，包括查sql，nosql去判断该请求到底有没有权限访问。

```
这时访问：http://localhost:8769/api-a/hi?name=wang ；网页显示：
	token is empty
访问 http://localhost:8769/api-a/hi?name=wang&token=22 ； 网页显示：
	hi wang,i am from port:8762
```