---
title: python图片爬取
date: 2019-03-10 23:06:11
tags: python
categories: python
---
## 主要功能：
爬取京东商城手机销售页面的手机图片，将其下载到本地文件夹。

## 代码如下：

``` python
import urllib.request
import re

def f(url,page):
	http = urllib.request.urlopen(url).read() #打开传入的页面
	http = str(http) #将网页内容转换为str类型
	obj = '<img width="220" height="220" data-img="1" src="//(.*?\.jpg)">' #正则表示图片所存的网址
	#img = re.compile(obj).findall(http)
	img = re.findall(obj,http) #将http中符合正则表示的保存在img列表，上行有同样效果
	index = 1
	for i in img:
		s = 'http://' + index #将图片网址加上(http://)前缀使其可以访问
		try:
			urllib.request.urlretrieve(s,"./img/pic"+str(page)+str(index)+".jpg") #(urlretrieve)可以将s下载到对应的目录
		except urllib.request.URLError as e:
			pass
		else:
			index += 1

for i in range(1,80):
	url = 'https://list.jd.com/list.html?cat=9987,653,655&page=' + str(i) #前为京东手机选购的网址，page 为该网页的所在的页数
	f(url,i)
```