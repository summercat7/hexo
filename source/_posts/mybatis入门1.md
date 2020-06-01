---
title: mybatis入门1
date: 2019-08-06 21:55:42
categories: java
tags: 框架
---
## mybatis框架概述:
	是一个优秀的基于 java 的持久层框架，它内部封装了 jdbc，使开发者只需要关注 sql 语句本身，
	而不需要花费精力去处理加载驱动、创建连接、创建 statement 等繁杂的过程。
	mybatis 通过 xml 或注解的方式将要执行的各种 statement 配置起来，并通过 java 对象和 statement 中
	sql 的动态参数进行映射生成最终执行的 sql 语句，最后由 mybatis 框架执行 sql 并将结果映射为 java 对象并
	返回。
	采用 ORM 思想解决了实体和数据库映射的问题，对 jdbc 进行了封装，屏蔽了 jdbc api 底层访问细节，使我
	们不用与 jdbc api 打交道，就可以完成对数据库的持久化操作。
	为了我们能够更好掌握框架运行的内部过程，并且有更好的体验，下面我们将从自定义 Mybatis 框架开始来
	学习框架。此时我们将会体验框架从无到有的过程体验，也能够很好的综合前面阶段所学的基础。

### SqlMapConfig.xml 配置文件
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <properties resource="jdbcConfig.properties"></properties>
	
	<!--配置参数-->
    <settings>
        <!--开启Mybatis支持延迟加载-->
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false"></setting>
    </settings>

    <!--使用typeAliases配置别名，它只能配置domain中类的别名 -->
    <typeAliases>
        <!--typeAlias用于配置别名。type属性指定的是实体类全限定类名。alias属性指定别名，当指定了别名就再区分大小写
        <typeAlias type="com.itheima.domain.User" alias="user"></typeAlias>-->

        <!-- 用于指定要配置别名的包，当指定之后，该包下的实体类都会注册别名，并且类名就是别名，不再区分大小写-->
        <package name="cn.wang.domain"></package>
    </typeAliases>

    <!--配置文件 -->
    <environments default="mysql">
    <!--配置mysql的环境-->
        <environment id="mysql">
            <!-- 配置事务 -->
            <transactionManager type="JDBC"></transactionManager>
            <!-- 配置连接池 -->
            <dataSource type="POOLED">
                <property name="driver" value="${jdbc.driver}"/>
                <property name="url" value="jdbc:mysql://localhost:3306/mybatis"/>
                <property name="username" value="root"/>
                <property name="password" value="root"/>
            </dataSource>
        </environment>
    </environments>
    <!-- 配置映射文件路径-->
    <mappers>
<!--        <mapper resource="cn/wang/dao/UserDao.xml"></mapper>-->

        <!-- package标签是用于指定dao接口所在的包,当指定了之后就不需要在写mapper以及resource或者class了 -->
        <package name="cn.wang.dao"></package>
    </mappers>
</configuration>
```

### 持久层接口的映射文件 UserDao.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.wang.dao.UserDao">

    <sql id="default">
        select *from user
    </sql>

    <select id="findAll" resultType="cn.wang.domain.User">
        <include refid="default"></include>
    </select>

    <insert id="saveUser" parameterType="cn.wang.domain.User">
        <selectKey keyProperty="id" keyColumn="id" resultType="int" order="AFTER">
            select last_insert_id();
        </selectKey>
        insert into user(username,address,sex,birthday) value(#{username},#{address},#{sex},#{birthday});
    </insert>

    <update id="updateUser" parameterType="cn.wang.domain.User">
        update user set address=#{address} where username=#{username};
    </update>

    <delete id="deleteUser" parameterType="java.lang.Integer">
        delete from user where id=#{uid};
    </delete>

    <select id="findOne" parameterType="java.lang.Integer" resultType="cn.wang.domain.User">
        select * from user where id=#{uid};
    </select>

    <select id="findByCondition" resultType="cn.wang.domain.User" parameterType="cn.wang.domain.User">
        <!--select * from user where 1=1
        <if test="username != null">
            and username = #{username}
        </if>-->
        select * from user
        <where>
            <if test="username != null">
                and username = #{username}
            </if>
        </where>
    </select>

    <select id="findUserInIds" resultType="cn.wang.domain.User" parameterType="cn.wang.domain.QueryVo">
        <include refid="default"></include>
        <where>
            <if test="ids !=null and ids.size()>0">
                <foreach collection="ids" open="and id in(" close=")" item="id" separator=",">
                    #{id}
                </foreach>
            </if>
        </where>
    </select>
</mapper>
```
### 一对多 xml配置
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.itheima.dao.IUserDao">

    <!-- 定义User的resultMap-->
    <resultMap id="userAccountMap" type="user">
        <id property="id" column="id"></id>
        <result property="username" column="username"></result>
        <result property="address" column="address"></result>
        <result property="sex" column="sex"></result>
        <result property="birthday" column="birthday"></result>
        <!-- 配置user对象中accounts集合的映射 -->
        <collection property="accounts" ofType="account">
            <id column="aid" property="id"></id>
            <result column="uid" property="uid"></result>
            <result column="money" property="money"></result>
        </collection>
    </resultMap>

    <!-- 查询所有 -->
    <select id="findAll" resultMap="userAccountMap">
        select * from user u left outer join account a on u.id = a.uid
    </select>

    <!-- 根据id查询用户 -->
    <select id="findById" parameterType="INT" resultType="user">
        select * from user where id = #{uid}
    </select>

</mapper>
```
### 多对多 xml配置
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.itheima.dao.IUserDao">

    <!-- 定义User的resultMap-->
    <resultMap id="userMap" type="user">
        <id property="id" column="id"></id>
        <result property="username" column="username"></result>
        <result property="address" column="address"></result>
        <result property="sex" column="sex"></result>
        <result property="birthday" column="birthday"></result>
        <!-- 配置角色集合的映射 -->
        <collection property="roles" ofType="role">
            <id property="roleId" column="rid"></id>
            <result property="roleName" column="role_name"></result>
            <result property="roleDesc" column="role_desc"></result>
        </collection>
    </resultMap>

    <!-- 查询所有 -->
    <select id="findAll" resultMap="userMap">
        select u.*,r.id as rid,r.role_name,r.role_desc from user u
         left outer join user_role ur  on u.id = ur.uid
         left outer join role r on r.id = ur.rid
    </select>

    <!-- 根据id查询用户 -->
    <select id="findById" parameterType="INT" resultType="user">
        select * from user where id = #{uid}
    </select>

</mapper>
```

### 编写测试类
```java
public class UserTest {
    private InputStream in;
    private SqlSession sqlSession;
    private IUserDao userDao;
    @Before//用于在测试方法执行之前执行
    public void init()throws Exception{
        //1.读取配置文件，生成字节输入流
        in = Resources.getResourceAsStream("SqlMapConfig.xml");
        //2.获取SqlSessionFactory
        SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(in);
        //3.获取SqlSession对象
        sqlSession = factory.openSession(true);
        //4.获取dao的代理对象
        userDao = sqlSession.getMapper(IUserDao.class);
    }
    @After//用于在测试方法执行之后执行
    public void destroy()throws Exception{
        //提交事务
        // sqlSession.commit();
        //6.释放资源
        sqlSession.close();
        in.close();
    }
    /**
     * 测试查询所有
     */
    @Test
    public void testFindAll(){
        List<User> users = userDao.findAll();
        for(User user : users){
            System.out.println("-----每个用户的信息------");
            System.out.println(user);
            System.out.println(user.getRoles());
        }
    }
}

```