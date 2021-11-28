---
title: SpringBoot入门1：创建工程
date: 2019-10-09 14:30:43
categories: java
tags: 框架
---
# 构建springboot工程
## 创建项目
* 打开Idea-> new Project ->Spring Initializr ->填写group、artifact ->钩上web(开启web功能）->点下一步就行了。
## 目录结构
* pom文件为基本的依赖管理文件
* resouces 资源文件
	* statics 静态资源
	* templates 模板资源
	* application.yml 配置文件
* SpringbootApplication程序的入口。
## 启动springboot 方式
* cd到项目主目录:
	* mvn clean  
	* mvn package  编译项目的jar
* mvn spring-boot: run 启动
* cd 到target目录，java -jar 项目.jar
## 单元测试
* 通过@RunWith() @SpringBootTest开启注解
```java
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HelloControllerIT {

    @LocalServerPort
    private int port;

    private URL base;

    @Autowired
    private TestRestTemplate template;

    @Before
    public void setUp() throws Exception {
        this.base = new URL("http://localhost:" + port + "/");
    }

    @Test
    public void getHello() throws Exception {
        ResponseEntity<String> response = template.getForEntity(base.toString(),
                String.class);
        assertThat(response.getBody(), equalTo("Greetings from Spring Boot!"));
    }
}
```