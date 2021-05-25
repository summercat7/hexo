## 一、基础命令：

### 1.1 目录查看 ls [-al]

命令：ls [-al]

ls         查看当前目录下的所有目录和文件
ls -a       查看当前目录下的所有目录和文件（包括隐藏的文件）
ls -l 或 ll    列表查看当前目录下的所有目录和文件（列表查看，显示更多信息） （常用）
ll -h        功能同上，可查看转换单位后的文件大小
ls /dir       查看指定目录下的所有目录和文件  如：ls /usr

命令 : pwd 查看当前所在路径


### 1.2 目录切换 cd

命令：cd 目录  (常用)

cd 目录名    切换到当前文件夹下的指定文件夹
cd /     切换到根目录
cd /usr     切换到根目录下的usr目录
cd ../     切换到上一级目录 或者  cd ..
cd ~     切换到home目录
cd -     切换到上次访问的目录

### 1.3 创建目录【增】 mkdir

命令：mkdir 目录

mkdir    aaa            在当前目录下创建一个名为aaa的目录
mkdir    /usr/aaa    在指定目录下创建一个名为aaa的目录
mkdir -p aa/bb/cc    在当前目录创建一个多级目录

### 1.4 删除目录或文件【删】rm
命令：rm [-rf] 目录

删除文件：
rm 文件        删除当前目录下的文件
rm -f 文件    删除当前目录的的文件（不询问）

删除目录：
rm -r aaa    递归删除当前目录下的aaa目录
rm -rf aaa    递归删除当前目录下的aaa目录（不询问）

全部删除：
rm -rf *     将当前目录下的所有目录和文件全部删除
rm -rf /*    【自杀命令！慎用！慎用！慎用！】将根目录下的所有文件全部删除

### 1.5 目录修改【改】mv 和 cp
一、重命名目录
    命令：mv 当前目录  新目录
    例如：mv aaa bbb    将目录aaa改为bbb

二、剪切目录
    命令：mv 目录名称 目录的新位置
    示例：将/usr/tmp目录下的aaa目录剪切到 /usr目录下面     mv /usr/tmp/aaa /usr

三、拷贝目录
    命令：cp -r 目录名称 目录拷贝的目标位置   -r代表递归
    示例：将/usr/tmp目录下的aaa目录复制到 /usr目录下面     cp /usr/tmp/aaa  /usr


## 二、文件操作

### 2.1 新建文件 touch

命令：touch 文件名
示例：在当前目录创建一个名为aa.txt的文件        touch  aa.txt

### 2.2 修改文件内容  vi 或 vim

#### 打开文件

命令：vi 文件名
示例：打开当前目录下的aa.txt文件     vi aa.txt 或者 vim aa.txt

注意：使用vi编辑器打开文件后，并不能编辑，因为此时处于命令模式，点击键盘i/a/o进入编辑模式。

#### 保存或者取消编辑

保存文件：

第一步：ESC  进入命令行模式
第二步：:     进入底行模式
第三步：wq     保存并退出编辑

取消编辑：

第一步：ESC  进入命令行模式
第二步：:     进入底行模式
第三步：q!     撤销本次修改并退出编辑

### 2.3 文件的查看

文件的查看命令：cat/more/less/tail

tail：指定行数或者动态查看

示例：使用tail -n 10 查看sudo.conf文件的后10行，Ctrl+C结束  
tail -n 10 sudo.conf

示例：使用tail -f 动态查看sudo.conf文件的最新状态（可用于查看日志），Ctrl+C结束  
tail -f sudo.conf

## 三、压缩文件操作

### 3.1 打包和压缩

命令：tar -zcvf 打包压缩后的文件名 要打包的文件
其中：z：调用gzip压缩命令进行压缩
  c：打包文件
  v：显示运行过程
  f：指定文件名

示例：打包并压缩/usr/tmp 下的所有文件 压缩后的压缩包指定名称为xxx.tar
tar -zcvf ab.tar aa.txt bb.txt 
或：tar -zcvf ab.tar  *


### 3.2 解压

命令：tar [-zxvf] 压缩文件    
其中：x：代表解压
示例：将/usr/tmp 下的ab.tar 解压到当前目录下
tar -zxvf ab.tar

示例：将/usr/tmp 下的ab.tar解压到根目录/usr下
tar -zxvf ab.tar -C /usr   -C代表指定解压的位置


## 四、查找命令

### 4.1 grep

查看服务进程 (常用，在服务重启时，用于查询服务的pid，再使用 kill 停止服务)
命令 : ps - ef | grep 进程名称

结束进程：kill
命令：kill pid 或者 kill -9 pid(强制杀死进程)           pid:进程号


### 4.2 find

find命令在目录结构中搜索文件，并对搜索结果执行指定的操作。 

find 默认搜索当前目录及其子目录，并且不过滤任何结果（也就是返回所有文件），将它们全都显示在屏幕上。

使用实例：

``` sh
find . -name "*.log" -ls  在当前目录查找以.log结尾的文件，并显示详细信息。 
find /root/ -perm 600   查找/root/目录下权限为600的文件 
find . -type f -name "*.log"  查找当目录，以.log结尾的普通文件 
find . -type d | sort   查找当前所有目录并排序 
find . -size +100M  查找当前目录大于100M的文件
```

### 4.3 whereis

whereis命令是定位可执行文件、源代码文件、帮助文件在文件系统中的位置。这些文件的属性应属于原始代码，二进制文件，或是帮助文件。

使用实例：
``` sh 
whereis ls    将和ls文件相关的文件都查找出来
```

## 五、时间设置

### 5.1 安装npt
```sh
yum -y install ntp ntpdate
```
### 5.2 自动同步时间
npt配置文件
```sh
vim /etc/ntp.conf
```
```conf
# 新增-内网的时间服务器地址
server 192.168.31.223 prefer

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
```

NTP同步服务
```sh
systemctl start ntpd   ## 启动服务 
systemctl stop ntpd    ## 关闭服务 
systemctl status ntpd  ## 查看crontab服务状态
```

查看时间同步结果：ntpstat
```sh
[root@wang01 ~]# ntpstat
unsynchronised
   polling server every 64 s
```
同步失败,同步也需要时间嘛，需等待一段再次查询

### 5.3 手动时间同步
```sh
ntpdate 0.centos.pool.ntp.org ## 时间服务器地址
```

## 六、防火墙

### 6.1 防火墙操作
启动： systemctl start firewalld
查看状态： systemctl status firewalld
停止： systemctl disable firewalld
禁用： systemctl stop firewalld

### 6.2 开放指定端口
firewall-cmd --zone=public --add-port=80/tcp --permanent //开放端口
firewall-cmd --reload //重新载入，使其生效

### 6.3 关闭指定端口
firewall-cmd --zone=public --remove-port=80/tcp --permanent //关闭端口
firewall-cmd --reload //重新载入，使其生效

### 6.4 查看端口状态
firewall-cmd --zone=public --query-port=80/tcp //查看端口状态

## 七、系统操作

### 7.1 域名映射 (Hosts)
/etc/hosts文件用于在通过主机名进行访问时做ip地址解析之用。所以，你想访问一个什么样的主机名，就需要把这个主机名和它对应的ip地址。
```sh
[root@wang01 /]# vi /etc/hosts
#### 将ip与指定域名对应
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
52.201.142.14 registry-1.docker.io
192.168.159.100 wang01
```

### 7.2 挂盘查看

磁盘信息

命令 :  fdisk -l

```sh
[root@wang01 jdk1.8.0_221]# fdisk -l

磁盘 /dev/sda：53.7 GB, 53687091200 字节，104857600 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000df63b

   设备 Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048      411647      204800   83  Linux
/dev/sda2          411648    25593855    12591104   8e  Linux LVM
/dev/sda3        25593856   104857599    39631872   8e  Linux LVM

磁盘 /dev/mapper/centos-root：51.3 GB, 51321503744 字节，100237312 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节


磁盘 /dev/mapper/centos-swap：2147 MB, 2147483648 字节，4194304 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
```



存储信息

命令 : df -h
``` sh
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                 1.4G     0  1.4G    0% /dev
tmpfs                    1.4G     0  1.4G    0% /dev/shm
tmpfs                    1.4G   11M  1.4G    1% /run
tmpfs                    1.4G     0  1.4G    0% /sys/fs/cgroup
/dev/mapper/centos-root   48G   32G   17G   66% /
/dev/sda1                197M  167M   31M   85% /boot
tmpfs                    283M   40K  283M    1% /run/user/0
```

### 7.3 yum 下载源修改
当计算机没连接到外网，使用yum下载资源，需要将下载源改为局域网内才可以下载

命令 : vim /etc/yum.repos.d/xxx.repo   文件名称必须以repo结尾,打开此目录，编辑xxx.repo文件，xxx名字任意，但是最好起规范一点

配置详情：
```sh
[rhel7.2]                                       #仓库名称
name=rhel7.2 source                             #对软件源的描述
baseurl=http:172.25.254.250/rhel7.2/x86_64/dvd  #网络安装源
gpgcheck=0                                      #不检测gpgkey
enable=1                                        #此安装源语句块生效
```

清空系统原有的yum缓存
``` sh
yum clean all 
```
更新yum配置
``` sh
yum repolist
```

### 7.4 定时任务 (crontab)

#### crontab 安装
```sh
yum install crontabs
```
#### 服务操作说明
```sh
systemctl start crond   ## 启动服务 
systemctl stop crond    ## 关闭服务 
systemctl restart crond ## 重启服务 
systemctl enable crond  ## 开机自启动
systemctl status crond  ## 查看crontab服务状态
```

#### crontab命令

##### 编辑定时任务的两种方法： 
1)、在命令行输入: crontab -e 然后添加相应的任务，wq存盘退出。 
2)、直接编辑/etc/crontab 文件，即vi /etc/crontab，添加相应的任务。 
crontab -e配置是针对某个用户的，而编辑/etc/crontab是针对系统的任务 

3)、进入编辑状态后的配置说明
命令： *   *    *   *   *  command  
解释：分  时  日  月  周  命令
```
第1列表示分钟1～59 每分钟用*或者 */1表示    

第2列表示小时0～23（0表示0点）

第3列表示日期1～31  

第4列表示月份1～12  

第5列标识号星期0～6（0表示星期天）  

第6列要运行的命令
```
4)、配置实例：
```sh 
# 进入编辑状态
crontab -e
```
```sh
#每分钟执行一次date命令 
*/1 * * * * date >> /root/date.txt
 
#每晚的21:30重启apache。 
30 21 * * * service httpd restart
 
#每月1、10、22日的4 : 45重启apache。  
45 4 1,10,22 * * service httpd restart
 
#每周六、周日的1 : 10重启apache。 
10 1 * * 6,0 service httpd restart
 
#每天18 : 00至23 : 00之间每隔30分钟重启apache。
0,30   18-23    *   *   *   service httpd restart

#晚上11点到早上7点之间，每隔一小时重启apache
*  23-7/1    *   *   *   service httpd restart
```


##### 查看调度任务 
crontab -l //列出当前的所有调度任务 
crontab -l -u jp //列出用户jp的所有调度任务 
##### 删除任务调度工作 
crontab -r //删除所有任务调度工作 


### 7.5 系统版本查看
本文指令基于 centos 7.x 版本，如有命令问题，可先排除版本是否不一致
命令 :  cat  /etc/redhat-release
``` sh
CentOS Linux release 7.8.2003 (Core)
```

### 7.6 cpu使用情况

命令 : top
```sh
[root@wang01 yum.repos.d]# top
top - 14:45:07 up 1 day,  4:27,  3 users,  load average: 0.01, 0.04, 0.05
Tasks: 205 total,   1 running, 202 sleeping,   2 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.3 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  2895252 total,   530652 free,  1280236 used,  1084364 buff/cache
KiB Swap:  2097148 total,  2097148 free,        0 used.  1386784 avail Mem

   PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
  1838 mysql     20   0 1336196 384924  14712 S  0.3 13.3   7:02.93 mysqld
 19444 root      20   0  162124   2348   1588 R  0.3  0.1   0:00.39 top
     1 root      20   0  125856   4352   2628 S  0.0  0.2   0:01.94 systemd
     2 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kthreadd
     4 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kworker/0:0H
     5 root      20   0       0      0      0 S  0.0  0.0   0:01.53 kworker/u256:0
     6 root      20   0       0      0      0 S  0.0  0.0   0:00.68 ksoftirqd/0
     7 root      rt   0       0      0      0 S  0.0  0.0   0:00.00 migration/0
```
字段说明
```
%us：表示用户空间程序的cpu使用率（没有通过nice调度）
%sy：表示系统空间的cpu使用率，主要是内核程序。
%ni：表示用户空间且通过nice调度过的程序的cpu使用率。
%id：空闲cpu
%wa：cpu运行时在等待io的时间
%hi：cpu处理硬中断的数量
%si：cpu处理软中断的数量
%st：被虚拟机偷走的cpu
注：99.0 id，表示空闲CPU，即CPU未使用率，100%-99.0%=1%，即系统的cpu使用率为1%。
```
```
PID：进程标示号
USER：进程所有者
PR：进程优先级
NI：进程优先级别数值
VIRT：进程占用的虚拟内存值
RES：进程占用的物理内存值
SHR ：进程使用的共享内存值
S ：进程的状态，其中S表示休眠，R表示正在运行，Z表示僵死
%CPU ：进程占用的CPU使用率
%MEM ：进程占用的物理内存百分比
TIME+：进程启动后占用的总的CPU时间
Command：进程启动的启动命令名称
```

### 7.7 内存使用情况

命令 : free
```sh
[root@wang01 jdk1.8.0_221]# free -h
              total        used        free      shared  buff/cache   available
Mem:           2.8G        1.3G        162M         38M        1.3G        1.2G
Swap:          2.0G          0B        2.0G
```
字段说明
```
total：总计物理内存的大小
used：已使用多大
free：可用有多少
Shared：多个进程共享的内存总额
Buffers/cached：磁盘缓存的大小
```

### 7.8 磁盘文件大小情况

命令 : du
```sh
# 显示当前文件夹下的文件大小，-s : 不显示子文件夹情况;  -h : 自动转换单位;  sort : 将结果排序
[root@wang01 opt]# du -sh .[!.]* * | sort -hr
du: 无法访问".[!.]*": 没有那个文件或目录                 # .[!.]* ： 指包含隐藏文件夹
16G bigDataProject
2.7G  myjava
209M  myjavacode
193M  Python-3.7.0
31M scala-2.11.8
28M scala-2.11.8.tgz
25M application
22M Python-3.7.0.tgz
0 rh
0 fs
0 containerd
0 bigDataProject
```

## 八、JDK离线安装

### 8.1 进入要安装的目录
cd 指定目录

### 8.2 创建 jdk 文件夹
mkdir jdk

将安装包上传到该文件夹

### 8.3 解压安装包
```sh
tar -zxvf jdk-8u211-linux-x64.tar.gz
[root@wang01 myjava]# cd jdk1.8.0_221/
[root@wang01 jdk1.8.0_221]# pwd
/opt/myjava/jdk1.8.0_221
```

### 8.4 配置环境变量
vim /etc/profile

在最后面填入下面信息，文件目录与上面对应
```
export JAVA_HOME=/opt/myjava/jdk1.8.0_221
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
export PATH=.:${JAVA_HOME}/bin:$PATH
```

### 8.5 刷新环境变量文件
source /etc/profile

### 8.6 查看是否安装成功
```sh
[root@wang01 jdk1.8.0_221]# java -version
java version "1.8.0_221"
Java(TM) SE Runtime Environment (build 1.8.0_221-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.221-b11, mixed mode)
```


## 九、docker的简单实用
```sh
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
docker inspect --format='{ {.NetworkSettings.IPAddress} }' mycentos3

#删除容器(先停止容器)
docker rm mycentos3
```