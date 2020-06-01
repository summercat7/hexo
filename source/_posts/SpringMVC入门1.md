---
title: SpringMVC入门1
date: 2019-09-11 15:28:20
categories: java
tags: 框架
---
SpringMVC创建
## maven.xml
```xml
  <properties>
    <spring.version>5.0.2.RELEASE</spring.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-context</artifactId>
      <version>${spring.version}</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-web</artifactId>
      <version>${spring.version}</version>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-webmvc</artifactId>
      <version>${spring.version}</version>
    </dependency>
    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>servlet-api</artifactId>
      <version>2.5</version>
      <scope>provided</scope>
    </dependency>
    <dependency>
      <groupId>javax.servlet.jsp</groupId>
      <artifactId>jsp-api</artifactId>
      <version>2.0</version>
      <scope>provided</scope>
    </dependency>
  </dependencies>
```
## web.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="2.4"
         xmlns="http://java.sun.com/xml/ns/j2ee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

<!--  配置前端控制器-->
  <servlet>
    <servlet-name>dispatcherServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:SpringMVC.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
  </servlet>
  <servlet-mapping>
    <servlet-name>dispatcherServlet</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>
<!--  配置中文过滤器-->
  <filter>
    <filter-name>characterEncodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
      <param-name>encoding</param-name>
      <param-value>UTF-8</param-value>
    </init-param>
  </filter>
  <filter-mapping>
    <filter-name>characterEncodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>
</web-app>
        
```
## SpringMVC.xml(配置)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/mvc
        http://www.springframework.org/schema/mvc/spring-mvc.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">

	<!-- 开启注解扫描 -->
    <context:component-scan base-package="cn.wang"></context:component-scan>

	<!-- 视图解析器对象 -->
    <bean id="internalResourceViewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/pages/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
	
    <!-- 配置自定义类型转换器 -->
    <bean id="conversionService" class="org.springframework.context.support.ConversionServiceFactoryBean">
        <property name="converters">
            <set>
                <bean class="cn.wang.utils.StringToDateConverter"/>
            </set>
        </property>
    </bean>
	<!-- 设置静态资源不过滤 -->
	<mvc:resources location="/css/" mapping="/css/**"/> <!-- 样式 -->
	<mvc:resources location="/images/" mapping="/images/**"/> <!-- 图片 -->
	<mvc:resources location="/js/" mapping="/js/**"/> <!-- javascript -->

<!--    开启SpringMVC框架注解的支持-->
    <mvc:annotation-driven  conversion-service="conversionService"/>
</beans>
```
## Controller
```java
@Controller
public class HelloController {
    @RequestMapping(path = "/hello",params = {},headers = {})
    public String sayHello(){
        System.out.println("Hello");
        return "success";
    }
	
    /**
	 * 原生的API
	 * @return
	 */
	@RequestMapping("/testServlet")
	public String testServlet(HttpServletRequest request, HttpServletResponse response){
	    System.out.println("执行了...");
	    System.out.println(request);
	
	    HttpSession session = request.getSession();
	    System.out.println(session);
	
	    ServletContext servletContext = session.getServletContext();
	    System.out.println(servletContext);
	
	    System.out.println(response);
	    return "success";
	}
}
```
## 类型转换器
```java
/**
 * 把字符串转换日期
 */
public class StringToDateConverter implements Converter<String,Date>{

    /**
     * String source    传入进来字符串
     * @param source
     * @return
     */
    public Date convert(String source) {
        // 判断
        if(source == null){
            throw new RuntimeException("请您传入数据");
        }
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");

        try {
            // 把字符串转换日期
            return df.parse(source);
        } catch (Exception e) {
            throw new RuntimeException("数据类型转换出现错误");
        }
    }
}
```
json
```xml
<dependency>
	<groupId>com.fasterxml.jackson.core</groupId>
	<artifactId>jackson-databind</artifactId>
	<version>2.9.0</version>
</dependency>
<dependency>
	<groupId>com.fasterxml.jackson.core</groupId>
	<artifactId>jackson-core</artifactId>
	<version>2.9.0</version>
</dependency>
<dependency>
	<groupId>com.fasterxml.jackson.core</groupId>
	<artifactId>jackson-annotations</artifactId>
	<version>2.9.0</version>
</dependency>
```