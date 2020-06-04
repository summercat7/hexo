---
title: docker入门
date: 2020-06-04 17:33:35
categories: 其他
tags: 其他
---

## Docker使用入门 

### 1. Docker安装

```shell
sudo yum update

#安装需要的软件包，yum-util提供yum-config-manager，另外两个是devicemapper驱动依赖
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

#设置yum源为阿里云
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#安装docker
sudo yum install docker-ce

#查看docker版本
docker -v

#设置ustc的镜像
vi /etc/docker/daemon.json
{
"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}

#启动docker
systemctl start docker
#启动状态
systemctl status docker
#停止docker
systemctl stop docker
#重启docker
systemctl start docker
#开机自启动
systemctl enable docker
#docker概要
docker info
#在线帮助文档
docker --help
```

#### 2.Docker镜像命令

```shell
#查看镜像
docker images

#搜索镜像
docker search xxx

#拉取镜像
docker pull xxx:x.x

#删除镜像
docker rmi 镜像ID

#删除所有镜像
docker rmi `docker images -q`

#查看运行的容器
docker ps
#查看所有容器
docker ps -a
#查看最后一次运行的容器
docker ps -l
#查看停止的容器
docker ps -f status=exited

#交互方式启动容器（exit后关闭）
docker run -it --name=mycentos centos:7 /bin/bash
#守护方式启动容器（后台运行）
docker run -id --name=mycentos2 centos:7
#进入守护式容器
docker exec -it mycentos2 /bin/bash

#容器停止
docker stop 容器ID/容器NAME
#启动停止的容器
docker start 容器ID/容器NAME

#文件拷贝
docker cp 文件名 mycentos2:/usr/local
docker cp mycentos2:/usr/local/文件名 拷出后文件名

#目录挂载
docker run -id --name=mycentos3 -v /usr/local/myhtml(宿主机目录):/usr/local/myhtml(容器目录) centos:7

#查看容器信息
docker inspect mycentos3
#查看容器ip
docker inspect --format='{{.NetworkSettings.IPAddress}}' mycentos3

#删除容器(先停止容器)
docker rm mycentos3
```

#### 3. Docker应用部署

##### 3.1 MySQL部署

```shell
1.拉取mysql镜像
docker pull centos/mysql-57-centos7
2.创建容器
-p 33306(宿主机端口):3306(容器端口)
docker run -id --name=tensquare_mysql -p 33306:3306 -e MYSQL_ROOT_PASSWORD=root centos/mysql-57-centos7
3.进入MySQL容器
docker exec -it tensquare_mysql /bin/bash
4.登陆MySQL
mysql -u root -p
5.远程登录mysql
连接宿主机的IP，指定端口为33306
```

##### 3.2 tomcat部署

```shell
1.拉取镜像
docker pull tomcat:7-jre7
2.创建容器
docker run -di --name=mytomcat -p 9000:8080 -v /usr/local/webapps:/usr/local/tomcat/webapps tomcat:7-jre7

上传文件（sftp连接）
put d:\..\cas.war
转移到指定目录
mv cas.war /usr/local/webapps
```

##### 3.3 Nginx部署

```shell
1.拉取镜像
docker pull nginx
2.创建Nginx容器
docker run -di --name=mynginx -p 80:80 nginx

docker exec -it mynginx /bin/bash
cd etc
cd nginx
cat nginx.conf
cd conf.d
cat default.conf
exit
docker cp html mynginx:/usr/share/nginx/
```

##### 3.4 Redis部署

```shell
1.拉取镜像
docker pull redis
2.创建容器
docker run -di --name=myredis -p 6379:6379 redis

远程连接测试
redis-cli -h 192.168.159.100
```

#### 4. docker迁移与备份

```shell
#容器保存为镜像
docker commit mynginx mynginx_i
#镜像备份(将镜像保存为tar文件)
docker save -o mynginx.tar mynginx_i
#镜像恢复与迁移
docker load -i mynginx.tar


Dockerfile

#私有仓库
docker run -di --name=registry -p 5000:5000 registry
#修改daemon.json
vi /etc/docker/daemon.json
#添加
{"insecure-registries":["192.168.184.141:5000"]}
#重启docker服务
systemctl restart docker

#镜像上传至私有仓库
1.标志镜像
docker tag jdk1.8 192.168.184.141:5000/jdk1.8
2.上传标志的镜像
docker push 192.168.184.141:5000/jdk1.8
```

