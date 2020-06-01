---
title: k-means图像分割
date: 2019-03-14 19:34:37
tags: python
categories: python
---
## 实现原理：
将图片的每个像素点进行K-means聚类，然后生成新的图片。
## 参考资料：
[PIL库基础](https://blog.csdn.net/zhangziju/article/details/79123275)、[数字图像处理](https://www.cnblogs.com/denny402/p/5131004.html)、[视觉机器学习](https://blog.csdn.net/dz4543/article/details/80190177)
## 代码如下：
``` python
import numpy as np
import PIL.Image as image
from sklearn.cluster import KMeans

def load_data(file_path):
    f = open(file_path,'rb') #二进制打开
    data = []
    img = image.open(f) #以列表形式返回图片像素值
    m,n = img.size #活的图片大小
    for i in range(m):
        for j in range(n):  #将每个像素点RGB颜色处理到0-1范围内并存放data
            x,y,z = img.getpixel((i,j))
            data.append([x/256.0,y/256.0,z/256.0])
    f.close()
    return np.mat(data),m,n #以矩阵型式返回data，图片大小

img_data,row,col = load_data('img.jpg')
label = KMeans(n_clusters=2).fit_predict(img_data)  #聚类中心的个数为3
label = label.reshape([row,col])    #聚类获得每个像素所属的类别
pic_new = image.new("L",(row,col))  #创建一张新的灰度图保存聚类后的结果
for i in range(row):    #根据所属类别向图片中添加灰度值
    for j in range(col):
        pic_new.putpixel((i,j),int(256/(label[i][j]+1)))
pic_new.save('new_img.jpg')

```
[sublime 虚拟环境](https://blog.csdn.net/weixin_38256474/article/details/81289702)