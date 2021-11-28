---
title: CentOS防火墙设置
date: 2020-06-02 12:00:32
tags: 其他
categories: 其他
---
## CentOS 6、CentOS7 防火墙端口设置

#### 虚拟机上CentOS使用nat联网

```shell
vim /etc/sysconfig/network-scripts/ifcfg-eth0 或者是 ifcfg-ens33(centos7) 打开此文件
```

修改配置文件

```shell
TYPE=Ethernet　　　　　　　　
BOOTPROTO=static　　　　　  #静态链接
DEVICE=ens33
ONBOOT=yes
NM_CONTROLLED=yes
IPADDR=192.168.211.100　　　　 #自己要用的地址（设置在虚拟网卡网关一个ip段）
NETMASK=255.255.255.0　　　　#子网掩码
GATEWAY=192.168.211.2　　　　#网关
DNS1=114.114.114.114　　　　　#DNS
```

重启network (root用户)

```shell
service network restart
```



#### CentOS 6.5

1.开放指定端口
/sbin/iptables -I INPUT -p tcp --dport 端口号 -j ACCEPT   //写入修改
/etc/init.d/iptables save                                       //保存修改
service iptables restart                                               //重启防火墙，修改生效
2.关闭指定端口
/sbin/iptables -I INPUT -p tcp --dport 端口号 -j DROP       //写入修改
/etc/init.d/iptables save                                        //保存修改
service iptables restart                                             //重启防火墙，修改生效
3.查看端口状态
/etc/init.d/iptables status

#### CentOS 7

1.防火墙操作
启动： systemctl start firewalld
查看状态： systemctl status firewalld 
停止： systemctl disable firewalld
禁用： systemctl stop firewalld
2.开放指定端口
firewall-cmd --zone=public --add-port=80/tcp --permanent   //开放端口
firewall-cmd --reload                                                                   //重新载入，使其生效
3.关闭指定端口
firewall-cmd --zone=public --remove-port=80/tcp --permanent            //关闭端口
firewall-cmd --reload                                                                   //重新载入，使其生效
4.查看端口状态
firewall-cmd --zone=public --query-port=80/tcp                            //查看端口状态