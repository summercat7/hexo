---
title: SpringBoot入门3：JDBCTemplate
date: 2019-10-09 17:08:33
categories: java
tags: 框架
---
# JDBCTemplate
## 创建工程
### 引入依赖：
在pom文件引入spring-boot-starter-jdbc的依赖：
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
```
### 引入mysql连接类和连接池：
```xml
<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<scope>runtime</scope>
</dependency>

<dependency>
	<groupId>com.alibaba</groupId>
	<artifactId>druid</artifactId>
	<version>1.0.29</version>
</dependency>
```
### 开启web:
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>
```
### 配置相关文件
在application.properties文件配置mysql的驱动类，数据库地址，数据库账号、密码信息。
```properties
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/springboot?serverTimezone=UTC
spring.datasource.username=username
spring.datasource.password=password
```

## 具体代码
### Dao实现类
```java
@Repository
public class AccountDaoImpl implements IAccountDAO {
    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Override
    public int add(Account account) {
        String sql = "insert into account(name,money) value(?,?)";
        return jdbcTemplate.update(sql,account.getName(),account.getMoney());
    }

    @Override
    public int update(Account account) {
        String sql = "update account set name=?,money=? where id=?";
        return jdbcTemplate.update(sql,account.getName(),account.getMoney(),account.getId());
    }

    @Override
    public int delete(int id) {
        String sql = "delete from teble account where id=?";
        return jdbcTemplate.update(sql,id);
    }

    @Override
    public Account findAccountById(int id) {
        String sql = "select * from account where id=?";
        List<Account> list = jdbcTemplate.query(sql, new Object[]{id}, new BeanPropertyRowMapper<Account>(Account.class));
        if (list!=null && list.size()>0) {
            return list.get(0);
        } else {
            return null;
        }
    }

    @Override
    public List<Account> findAccountList() {
        List<Account> list = jdbcTemplate.query("select * from account", new Object[]{}, new BeanPropertyRowMapper(Account.class));
        if(list!=null && list.size()>0){
            return list;
        }else{
            return null;
        }
    }
}
```
### controller
```java
@RestController
@RequestMapping("/account")
public class AccountController {

    @Autowired
    IAccountService accountService;

    @RequestMapping(value = "/list",method = RequestMethod.GET)
    public List<Account> getAccounts(){
        return accountService.findAccountList();
    }

    @RequestMapping(value = "/{id}",method = RequestMethod.GET)
    public  Account getAccountById(@PathVariable("id") int id){
        return accountService.findAccountById(id);
    }

    @RequestMapping(value = "/{id}",method = RequestMethod.PUT)
    public  String updateAccount(@PathVariable("id")int id , @RequestParam(value = "name",required = true)String name,
                                 @RequestParam(value = "money" ,required = true)double money){
        Account account=new Account();
        account.setMoney(money);
        account.setName(name);
        account.setId(id);
        int t=accountService.update(account);
        if(t==1){
            return account.toString();
        }else {
            return "fail";
        }
    }

    @RequestMapping(value = "",method = RequestMethod.POST)
    public  String postAccount( @RequestParam(value = "name")String name,
                                @RequestParam(value = "money" )double money){
        Account account=new Account();
        account.setMoney(money);
        account.setName(name);
        int t= accountService.add(account);
        if(t==1){
            return account.toString();
        }else {
            return "fail";
        }
    }
}
```
* 可以通过postman来测试