---
title: SpringBoot入门6：整合redis
date: 2019-10-10 14:30:38
categories:
tags:
---
# SpringBoot整合redis
## 引入依赖
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```
## 配置数据源
```yml
spring:
  redis:
    host: localhost
    port: 6379
    database: 1
    timeout: 5000
    pool:
      max-active: 8
      max-wait: -1
      max-idle: 500
      min-idle: 0
```
## Dao层
```java
@Repository
public class RedisDao {

    @Autowired
    private StringRedisTemplate template;

    public  void setKey(String key,String value){
        ValueOperations<String, String> ops = template.opsForValue();
        ops.set(key,value,1, TimeUnit.MINUTES);//1分钟过期
    }

    public String getValue(String key){
        ValueOperations<String, String> ops = this.template.opsForValue();
        return ops.get(key);
    }
}
```
## 单元测试
```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class SpringbootRedisApplicationTests {

	public static Logger logger= LoggerFactory.getLogger(SpringbootRedisApplicationTests.class);
	@Test
	public void contextLoads() {
	}

	@Autowired
	RedisDao redisDao;
	@Test
	public void testRedis(){
		redisDao.setKey("name","wang");
		redisDao.setKey("age","18");
		logger.info(redisDao.getValue("name"));
		logger.info(redisDao.getValue("age"));
	}
}
```