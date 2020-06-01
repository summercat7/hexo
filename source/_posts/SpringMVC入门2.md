---
title: SpringMVC入门2
date: 2019-09-12 21:35:02
categories: java
tags: 框架
---
常用的注解
## RequestParam
* 1. 作用：把请求中的指定名称的参数传递给控制器中的形参赋值
* 2. 属性
	* 1. value：请求参数中的名称
	* 2. required：请求参数中是否必须提供此参数，默认值是true，必须提供
* 3. 代码如下
```java
/**
* 接收请求
* @return
*/
@RequestMapping(path="/hello")
public String sayHello(@RequestParam(value="username",required=false)String name) {
	System.out.println("aaaa");
	System.out.println(name);
	return "success";
}
```
## RequestBody
* 1. 作用：用于获取请求体的内容（注意：get方法不可以）
* 2. 属性
	* 1. required：是否必须有请求体，默认值是true
* 3. 代码如下
```java
/**
* 接收请求
* @return
*/
@RequestMapping(path="/hello")
public String sayHello(@RequestBody String body) {
	System.out.println("aaaa");
	System.out.println(body);
	return "success";
}
```
## PathVariable
* 1. 作用：拥有绑定url中的占位符的。例如：url中有/delete/{id}，{id}就是占位符
* 2. 属性
	1. value：指定url中的占位符名称
* 3. Restful风格的URL
	* 1. 请求路径一样，可以根据不同的请求方式去执行后台的不同方法
	* 2. restful风格的URL优点
		* 1. 结构清晰
		* 2. 符合标准
		* 3. 易于理解
		* 4. 扩展方便
* 4. 代码如下
```html
<a href="user/hello/1">入门案例</a>
``````java
/**
* 接收请求
* @return
*/
@RequestMapping(path="/hello/{id}")
public String sayHello(@PathVariable(value="id") String id) {
	System.out.println(id);
	return "success";
}
```
## RequestHeader
* 1. 作用：获取指定请求头的值
* 2. 属性
	* 1. value：请求头的名称
* 3. 代码如下
```java
@RequestMapping(path="/hello")
public String sayHello(@RequestHeader(value="Accept") String header) {
	System.out.println(header);
	return "success";
}
```
## CookieValue
* 1. 作用：用于获取指定cookie的名称的值
* 2. 属性
	* 1. value：cookie的名称
* 3. 代码
```java
@RequestMapping(path="/hello")
public String sayHello(@CookieValue(value="JSESSIONID") String cookieValue) {
	System.out.println(cookieValue);
	return "success";
}
```
## ModelAttribute
* 1. 作用
	* 1. 出现在方法上：表示当前方法会在控制器方法执行前线执行。
	* 2. 出现在参数上：获取指定的数据给参数赋值。
* 2. 应用场景
	* 1. 当提交表单数据不是完整的实体数据时，保证没有提交的字段使用数据库原来的数据。
3. 具体的代码
	* 1. 修饰的方法有返回值
	```java
	/**
	* 作用在方法，先执行
	* @param name
	* @return
	*/
	@ModelAttribute
	public User showUser(String name) {
		System.out.println("showUser执行了...");
		// 模拟从数据库中查询对象
		User user = new User();
		user.setName("哈哈");
		user.setPassword("123");
		user.setMoney(100d);
		return user;
	}
	/**
	* 修改用户的方法
	* @param cookieValue
	* @return
	*/
	@RequestMapping(path="/updateUser")
	public String updateUser(User user) {
		System.out.println(user);
		return "success";
	}
	```
	* 2. 修饰的方法没有返回值
	```java
	/**
	* 作用在方法，先执行
	* @param name
	* @return
	*/
	@ModelAttribute
	public void showUser(String name,Map<String, User> map) {
		System.out.println("showUser执行了...");
		// 模拟从数据库中查询对象
		User user = new User();
		user.setName("哈哈");
		user.setPassword("123");
		user.setMoney(100d);
		map.put("abc", user);
	}
	/**
	* 修改用户的方法
	* @param cookieValue
	* @return
	*/
	@RequestMapping(path="/updateUser")
		public String updateUser(@ModelAttribute(value="abc") User user) {
		System.out.println(user);
		return "success";
	}
	```
## SessionAttributes
* 1. 作用：用于多次执行控制器方法间的参数共享
* 2. 属性
	* 1. value：指定存入属性的名称
* 3. 代码如下
```java
@Controller
@RequestMapping(path="/user")
@SessionAttributes(value= {"username","password","age"},types={String.class,Integer.class}) // 把数据存入到session域对象中
public class HelloController {
/**
* 向session中存入值
* @return
*/
@RequestMapping(path="/save")
public String save(Model model) {
	System.out.println("向session域中保存数据");
	model.addAttribute("username", "root");
	model.addAttribute("password", "123");
	model.addAttribute("age", 20);
	return "success";
}
/**
* 从session中获取值
* @return
*/
@RequestMapping(path="/find")
public String find(ModelMap modelMap) {
	String username = (String) modelMap.get("username");
	String password = (String) modelMap.get("password");
	Integer age = (Integer) modelMap.get("age");
	System.out.println(username + " : "+password +" : "+age);
	return "success";
}
/**
* 清除值
* @return
*/
@RequestMapping(path="/delete")
public String delete(SessionStatus status) {
		status.setComplete();
		return "success";
	}
}
```