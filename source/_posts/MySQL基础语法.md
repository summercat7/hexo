---
title: MySQL基础语法
date: 2019-07-15 19:08:26
tags: MySQL
categories: SQL
---

## DDL:操作数据库、表

	1. 操作数据库：CRUD
		1. C(Create):创建
			* 创建数据库：
				* create database 数据库名称;
			* 创建数据库，判断不存在，再创建：
				* create database if not exists 数据库名称;
			* 创建数据库，并指定字符集
				* create database 数据库名称 character set 字符集名;

			* 练习： 创建db4数据库，判断是否存在，并制定字符集为gbk
				* create database if not exists db4 character set gbk;
		2. R(Retrieve)：查询
			* 查询所有数据库的名称:
				* show databases;
			* 查询某个数据库的字符集:查询某个数据库的创建语句
				* show create database 数据库名称;
		3. U(Update):修改
			* 修改数据库的字符集
				* alter database 数据库名称 character set 字符集名称;
		4. D(Delete):删除
			* 删除数据库
				* drop database 数据库名称;
			* 判断数据库存在，存在再删除
				* drop database if exists 数据库名称;
		5. 使用数据库
			* 查询当前正在使用的数据库名称
				* select database();
			* 使用数据库
				* use 数据库名称;


	2. 操作表
		1. C(Create):创建
			1. 语法：
				create table 表名(
					列名1 数据类型1,
					列名2 数据类型2,
					....
					列名n 数据类型n
				);
				* 注意：最后一列，不需要加逗号（,）
				* 数据库类型：
					1. int：整数类型
						* age int,
					2. double:小数类型
						* score double(5,2)
					3. date:日期，只包含年月日，yyyy-MM-dd
					4. datetime:日期，包含年月日时分秒	 yyyy-MM-dd HH:mm:ss
					5. timestamp:时间错类型	包含年月日时分秒	 yyyy-MM-dd HH:mm:ss	
						* 如果将来不给这个字段赋值，或赋值为null，则默认使用当前的系统时间，来自动赋值

					6. varchar：字符串
						* name varchar(20):姓名最大20个字符
						* zhangsan 8个字符  张三 2个字符
				

			* 创建表
				create table student(
					id int,
					name varchar(32),
					age int ,
					score double(4,1),
					birthday date,
					insert_time timestamp
				);
			* 复制表：
				* create table 表名 like 被复制的表名;	  	
		2. R(Retrieve)：查询
			* 查询某个数据库中所有的表名称
				* show tables;
			* 查询表结构
				* desc 表名;
		3. U(Update):修改
			1. 修改表名
				alter table 表名 rename to 新的表名;
			2. 修改表的字符集
				alter table 表名 character set 字符集名称;
			3. 添加一列
				alter table 表名 add 列名 数据类型;
			4. 修改列名称 类型
				alter table 表名 change 列名 新列别 新数据类型;
				alter table 表名 modify 列名 新数据类型;
			5. 删除列
				alter table 表名 drop 列名;
		4. D(Delete):删除
			* drop table 表名;
			* drop table  if exists 表名 ;

## 数据库的备份和还原

	* 语法：
		* 备份： mysqldump -u用户名 -p密码 数据库名称 > 保存的路径
		* 还原：
			1. 登录数据库
			2. 创建数据库
			3. 使用数据库
			4. 执行文件。source 文件路径

## 基础语法
```SQL
CREATE TABLE student (
 id INT, -- 编号
 NAME VARCHAR(20), -- 姓名
 age INT, -- 年龄
 sex VARCHAR(5), -- 性别
 address VARCHAR(100), -- 地址
 math INT, -- 数学
 english INT -- 英语
);
INSERT INTO student(id,NAME,age,sex,address,math,english) VALUES (1,'马云',55,'男','杭州',66,78),
(2,'马化腾',45,'女','深圳',98,87),(3,'马景涛',55,'男','香港',56,77),
(4,'柳岩',20,'女','湖南',76,65),(5,'柳青',20,'男','湖南',86,NULL),(6,'刘德华',57,'男','香港',99,99),
(7,'马德',22,'女','香港',99,99),(8,'德玛西亚',18,'男','南京',56,65);

UPDATE student SET id = 003 WHERE id = 1;
DELETE FROM student WHERE id=1;
DROP TABLE student;
TRUNCATE TABLE student;


-- 查询姓名和年龄
SELECT NAME,age FROM student;
-- 去除重复的结果集
SELECT DISTINCT address FROM student;
-- 计算 math 和 English 的和
SELECT NAME,math,english,math+english FROM student;
-- 如果有null 参与运算，结果都为null
SELECT NAME,math,english,math+IFNULL(english,0) FROM student;
-- 起别名
SELECT NAME,math,english,math+IFNULL(english,0) AS 总分 FROM student;
SELECT NAME,math 数学,english 英语,math+IFNULL(english,0) 总分 FROM student;


-- 查询年龄大于20
SELECT * FROM student WHERE age >= 20;
-- 查询年龄大于20
SELECT * FROM student WHERE age != 20;
SELECT * FROM student WHERE age <> 20;
-- 查询年龄再20和30之间
SELECT * FROM student WHERE age >= 20 && age <=30;
SELECT * FROM student WHERE age >= 20 AND age <= 30;
SELECT * FROM student WHERE age BETWEEN 20 AND 30;
-- 查询年龄为18,22,25
SELECT * FROM student WHERE age = 18 OR age = 22 OR age = 25;
SELECT * FROM student WHERE age IN (18,22,25);
-- 查询是否为null， 不能使用=(!=)
SELECT * FROM student WHERE english IS NULL;
SELECT * FROM student WHERE english IS NOT NULL;

-- 查询姓名第二个字是“化”
SELECT * FROM student WHERE NAME LIKE "_化%";
-- 查询姓名是三个字的
SELECT * FROM student WHERE NAME LIKE '___';
-- 查询姓名含有“德”的
SELECT * FROM student WHERE NAME LIKE "%德%";

-- 排序
SELECT * FROM student ORDER BY math DESC , english ASC;
-- 聚合函数（纵向计算）
SELECT COUNT(IFNULL(english,0)) FROM student;
SELECT MAX(english) FROM student;
SELECT MIN(english) FROM student;
SELECT SUM(english) FROM student;
SELECT AVG(english) FROM student;
-- 分组查询
SELECT sex,AVG(english),COUNT(id) FROM student GROUP BY sex;
SELECT sex,AVG(english),COUNT(id) FROM student WHERE english > 70 GROUP BY sex;
SELECT sex,AVG(english),COUNT(id) FROM student WHERE english > 70 GROUP BY sex HAVING COUNT(id) > 2;
-- 分页
SELECT * FROM student LIMIT 3,3;
```
## 约束条件
```SQL
CREATE TABLE obj(
	id INT PRIMARY KEY,
	NAME VARCHAR(10) DEFAULT "数学"
);

CREATE TABLE st(
	id INT PRIMARY KEY,
	NAME VARCHAR(20) NOT NULL,
	number VARCHAR(20),
	uid INT,
	CONSTRAINT uk FOREIGN KEY (uid) REFERENCES obj(id)
);
-- 删除非空
ALTER TABLE st MODIFY NAME VARCHAR(10);
ALTER TABLE st MODIFY NAME VARCHAR(20) NOT NULL;
-- 唯一约束
ALTER TABLE st MODIFY number INT UNIQUE;
-- 删除唯一约束
ALTER TABLE st DROP INDEX number ;  
-- 删除主键
ALTER TABLE st DROP PRIMARY KEY;
-- 添加主键
ALTER TABLE st MODIFY id INT PRIMARY KEY;
-- 添加自动增长
ALTER TABLE st MODIFY id INT AUTO_INCREMENT;
-- 删除自动增长
ALTER TABLE st MODIFY id INT;

-- 删除外键
ALTER TABLE st DROP FOREIGN KEY uk;
-- 添加外键,设置级联更新
ALTER TABLE st ADD CONSTRAINT uk FOREIGN KEY (uid) REFERENCES obj(id) ON UPDATE CASCADE; -- ON DELETE CASCADE

```
## 多表查询：
* 多表查询的分类：
	1. 内连接查询：
		1. 隐式内连接：使用where条件消除无用数据
			* 例子：
			SELECT 
				t1.name, -- 员工表的姓名
				t1.gender,-- 员工表的性别
				t2.name -- 部门表的名称
			FROM
				emp t1,
				dept t2
			WHERE 
				t1.`dept_id` = t2.`id`;


		2. 显式内连接：
			* 语法： select 字段列表 from 表名1 [inner] join 表名2 on 条件
			* 例如：
				* SELECT * FROM emp INNER JOIN dept ON emp.`dept_id` = dept.`id`;	
				* SELECT * FROM emp JOIN dept ON emp.`dept_id` = dept.`id`;	

		3. 内连接查询：
			1. 从哪些表中查询数据
			2. 条件是什么
			3. 查询哪些字段
	2. 外链接查询：
		1. 左外连接：
			* 语法：select 字段列表 from 表1 left [outer] join 表2 on 条件；
			* 查询的是左表所有数据以及其交集部分。
			* 例子：
				-- 查询所有员工信息，如果员工有部门，则查询部门名称，没有部门，则不显示部门名称
				SELECT 	t1.*,t2.`name` FROM emp t1 LEFT JOIN dept t2 ON t1.`dept_id` = t2.`id`;
		2. 右外连接：
			* 语法：select 字段列表 from 表1 right [outer] join 表2 on 条件；
			* 查询的是右表所有数据以及其交集部分。
			* 例子：
				SELECT 	* FROM dept t2 RIGHT JOIN emp t1 ON t1.`dept_id` = t2.`id`;
		3. 子查询：
			* 概念：查询中嵌套查询，称嵌套查询为子查询。
				-- 查询工资最高的员工信息
				-- 1 查询最高的工资是多少 9000
				SELECT MAX(salary) FROM emp;
				
				-- 2 查询员工信息，并且工资等于9000的
				SELECT * FROM emp WHERE emp.`salary` = 9000;
				
				-- 一条sql就完成这个操作。子查询
				SELECT * FROM emp WHERE emp.`salary` = (SELECT MAX(salary) FROM emp);

			* 子查询不同情况
				1. 子查询的结果是单行单列的：
					* 子查询可以作为条件，使用运算符去判断。 运算符： > >= < <= =
					* 
					-- 查询员工工资小于平均工资的人
					SELECT * FROM emp WHERE emp.salary < (SELECT AVG(salary) FROM emp);
				2. 子查询的结果是多行单列的：
					* 子查询可以作为条件，使用运算符in来判断
					-- 查询'财务部'和'市场部'所有的员工信息
					SELECT id FROM dept WHERE NAME = '财务部' OR NAME = '市场部';
					SELECT * FROM emp WHERE dept_id = 3 OR dept_id = 2;
					-- 子查询
					SELECT * FROM emp WHERE dept_id IN (SELECT id FROM dept WHERE NAME = '财务部' OR NAME = '市场部');

				3. 子查询的结果是多行多列的：
					* 子查询可以作为一张虚拟表参与查询
					-- 查询员工入职日期是2011-11-11日之后的员工信息和部门信息
					-- 子查询
					SELECT * FROM dept t1 ,(SELECT * FROM emp WHERE emp.`join_date` > '2011-11-11') t2
					WHERE t1.id = t2.dept_id;
					
					-- 普通内连接
					SELECT * FROM emp t1,dept t2 WHERE t1.`dept_id` = t2.`id` AND t1.`join_date` >  '2011-11-11'
					
## 事务

	1. 事务的基本介绍
		1. 概念：
			*  如果一个包含多个步骤的业务操作，被事务管理，那么这些操作要么同时成功，要么同时失败。
			
		2. 操作：
			1. 开启事务： start transaction;
			2. 回滚：rollback;
			3. 提交：commit;
		3. 例子：
			CREATE TABLE account (
				id INT PRIMARY KEY AUTO_INCREMENT,
				NAME VARCHAR(10),
				balance DOUBLE
			);
			-- 添加数据
			INSERT INTO account (NAME, balance) VALUES ('zhangsan', 1000), ('lisi', 1000);
			
			
			SELECT * FROM account;
			UPDATE account SET balance = 1000;
			-- 张三给李四转账 500 元
			
			-- 0. 开启事务
			START TRANSACTION;
			-- 1. 张三账户 -500
			
			UPDATE account SET balance = balance - 500 WHERE NAME = 'zhangsan';
			-- 2. 李四账户 +500
			-- 出错了...
			UPDATE account SET balance = balance + 500 WHERE NAME = 'lisi';
			
			-- 发现执行没有问题，提交事务
			COMMIT;
			
			-- 发现出问题了，回滚事务
			ROLLBACK;
		4. MySQL数据库中事务默认自动提交
			
			* 事务提交的两种方式：
				* 自动提交：
					* mysql就是自动提交的
					* 一条DML(增删改)语句会自动提交一次事务。
				* 手动提交：
					* Oracle 数据库默认是手动提交事务
					* 需要先开启事务，再提交
			* 修改事务的默认提交方式：
				* 查看事务的默认提交方式：SELECT @@autocommit; -- 1 代表自动提交  0 代表手动提交
				* 修改默认提交方式： set @@autocommit = 0;


	2. 事务的四大特征：
		1. 原子性：是不可分割的最小操作单位，要么同时成功，要么同时失败。
		2. 持久性：当事务提交或回滚后，数据库会持久化的保存数据。
		3. 隔离性：多个事务之间。相互独立。
		4. 一致性：事务操作前后，数据总量不变
	3. 事务的隔离级别（了解）
		* 概念：多个事务之间隔离的，相互独立的。但是如果多个事务操作同一批数据，则会引发一些问题，设置不同的隔离级别就可以解决这些问题。
		* 存在问题：
			1. 脏读：一个事务，读取到另一个事务中没有提交的数据
			2. 不可重复读(虚读)：在同一个事务中，两次读取到的数据不一样。
			3. 幻读：一个事务操作(DML)数据表中所有记录，另一个事务添加了一条数据，则第一个事务查询不到自己的修改。
		* 隔离级别：
			1. read uncommitted：读未提交
				* 产生的问题：脏读、不可重复读、幻读
			2. read committed：读已提交 （Oracle）
				* 产生的问题：不可重复读、幻读
			3. repeatable read：可重复读 （MySQL默认）
				* 产生的问题：幻读
			4. serializable：串行化
				* 可以解决所有的问题

			* 注意：隔离级别从小到大安全性越来越高，但是效率越来越低
			* 数据库查询隔离级别：
				* select @@tx_isolation;
			* 数据库设置隔离级别：
				* set global transaction isolation level  级别字符串;

		* 演示：
			set global transaction isolation level read uncommitted;
			start transaction;
			-- 转账操作
			update account set balance = balance - 500 where id = 1;
			update account set balance = balance + 500 where id = 2;



## DCL：
	* SQL分类：
		1. DDL：操作数据库和表
		2. DML：增删改表中数据
		3. DQL：查询表中数据
		4. DCL：管理用户，授权

	* DBA：数据库管理员

	* DCL：管理用户，授权
		1. 管理用户
			1. 添加用户：
				* 语法：CREATE USER '用户名'@'主机名' IDENTIFIED BY '密码';
			2. 删除用户：
				* 语法：DROP USER '用户名'@'主机名';
			3. 修改用户密码：
				
				UPDATE USER SET PASSWORD = PASSWORD('新密码') WHERE USER = '用户名';
				UPDATE USER SET PASSWORD = PASSWORD('abc') WHERE USER = 'lisi';
				
				SET PASSWORD FOR '用户名'@'主机名' = PASSWORD('新密码');
				SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123');

				* mysql中忘记了root用户的密码？
					1. cmd -- > net stop mysql 停止mysql服务
						* 需要管理员运行该cmd

					2. 使用无验证方式启动mysql服务： mysqld --skip-grant-tables
					3. 打开新的cmd窗口,直接输入mysql命令，敲回车。就可以登录成功
					4. use mysql;
					5. update user set password = password('你的新密码') where user = 'root';
					6. 关闭两个窗口
					7. 打开任务管理器，手动结束mysqld.exe 的进程
					8. 启动mysql服务
					9. 使用新密码登录。
			4. 查询用户：
				-- 1. 切换到mysql数据库
				USE myql;
				-- 2. 查询user表
				SELECT * FROM USER;
				
				* 通配符： % 表示可以在任意主机使用用户登录数据库

		2. 权限管理：
			1. 查询权限：
				-- 查询权限
				SHOW GRANTS FOR '用户名'@'主机名';
				SHOW GRANTS FOR 'lisi'@'%';

			2. 授予权限：
				-- 授予权限
				grant 权限列表 on 数据库名.表名 to '用户名'@'主机名';
				-- 给张三用户授予所有权限，在任意数据库任意表上
				
				GRANT ALL ON *.* TO 'zhangsan'@'localhost';
			3. 撤销权限：
				-- 撤销权限：
				revoke 权限列表 on 数据库名.表名 from '用户名'@'主机名';
				REVOKE UPDATE ON db3.`account` FROM 'lisi'@'%';