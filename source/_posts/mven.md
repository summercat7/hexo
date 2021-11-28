---
title: Centos下安装maven
date: 2019-06-01 12:04:32
tags: 其他
categories: 其他
---
## Centos下安装maven

1、maven下载地址：https://maven.apache.org/download.cgi

下载 apache-maven-3.6.1-bin.tar.gz



2、在linux环境中创建maven目录，/opt/myjava/maven，将maven安装包上传至此目录中解压

```shell
tar -zxvf apache-maven-3.6.1-bin.tar.gz
```

3、配置环境变量

```shell
vim /etc/profile
```

 将下面这两行代码拷贝到文件末尾并保存 

```shell
export MAVEN_HOME=/opt/myjava/maven/apache-maven-3.6.1
export PATH=${MAVEN_HOME}/bin:${PATH}
```

 重载环境变量 

```shell
source /etc/profile
```

 4、查看结果 

```shell
mvn -v
```



5、替换maven源，阿里云的源

打开maven配置文件，比如：

```shell
vim /opt/myjava/maven/apache-maven-3.6.1/conf/settings.xml
```

 找到<mirrors></mirrors>标签对，添加一下代码： 

```xml
<mirror>
     <id>alimaven</id>
     <name>aliyun maven</name>
     <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
     <mirrorOf>central</mirrorOf>
</mirror> 
```

 6、指定下载资源位置 

```xml
<localRepository>/opt/myjava/maven_repository</localRepository>
```

 7、指定JDK版本 

```xml
<profile>    
     <id>jdk-1.8</id>    
     <activation>    
       <activeByDefault>true</activeByDefault>    
       <jdk>1.8</jdk>    
     </activation>    
       <properties>    
         <maven.compiler.source>1.8</maven.compiler.source>    
         <maven.compiler.target>1.8</maven.compiler.target>    
         <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>    
       </properties>    
</profile>
```

