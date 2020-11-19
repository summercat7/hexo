---
title: 过滤器使用与bean注入
date: 2019-07-24 21:23:34
categories: java
tags: java
---

### 1 web.xml中各元素启动顺序

在项目启动时，监听器listener最先初始化，然后是过滤器filter，最后是servlet。
Spring监听器在启动时会读取spring配置文件，进行spring容器的初始化。springMVC的dispatcherServlet初始化时会读取springMVC的配置文件，进行springMVC容器的初始化。Spring容器初始化时会实例化各个bean。（个人认为web容器初始化时其中的各元素是按上述顺序依次初始化的，其他元素全部初始化完成之后web容器才初始化完成。但目前没有看到过一个十分确切的说法，等以后有时间研究一下源码）。

### 2 过滤器的使用

网上很多资料说在过滤器中拿不到spring注入的bean，原因是过滤器初始化时spring容器还没初始化好，其实并不是。下面看一段代码：
在web.xml中定义过滤器：

```
<filter>
  <filter-name>demoFilter</filter-name>  
  <filter-class>xx.framework.filter.demoFilter</filter-class>
</filter>
<filter-mapping>  
<filter-name>demoFilter</filter-name>
   <url-pattern>/*</url-pattern>
</filter-mapping>12345678
```

然后在过滤器的初始化方法init中：

```
@Override
public void init(FilterConfig filterConfig) throws ServletException {
    ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(filterConfig.getServletContext());
    RedisTemplate demoBean = (RedisTemplate)context.getBean("redisTemplate");
    System.out.println(demoBean);
 }123456
```

经过测试，此时是可以拿到spring中的redisTemplate 这个bean的，说明spring容器确实先于过滤器初始化的。那么回到过滤器中不能注入bean的问题，原因究竟是什么呢？可以看到，这里获取bean是通过applicationContext获取的，而不是直接注入的。个人理解是：过滤器是servlet规范中定义的，并不归spring容器管理，也无法直接注入spring中的bean（会报错）。当然，要想通过spring注入的方式来使用过滤器也是有办法的,先在web.xml中定义：

```
<filter>
  <filter-name>DelegatingFilterProxy</filter-name> 
  <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
  <init-param>
    <param-name>targetBeanName</param-name>
    <param-value>demoFilter</param-value>
  </init-param>
  <init-param>
    <param-name>targetFilterLifecycle</param-name>
    <param-value>true</param-value>
  </init-param>
</filter>
<filter-mapping>
  <filter-name>DelegatingFilterProxy</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>12345678910111213141516
```

然后在spring容器中配置demoFilter这个bean：

```
<bean id="demoFilter" class="xx.framework.filter.demoFilter" />1
```

在doFilter方法中可以获取到注入的bean了：

```
@Override
public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException, ServletException {
   System.out.println(redisTemplate.getClientList());
}1234
```

其中redisTemplate是通过@Resource注解注入进来的。