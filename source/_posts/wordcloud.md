---
title: wordcloud
date: 2019-06-24 08:36:08
tags: python
categories: python
---
##wordcloud常用操作
``` python
from wordcloud import WordCloud, ImageColorGenerator
import jieba
import imageio
from matplotlib import pyplot as plt

img = imageio.imread('1.png')
imgcolor = ImageColorGenerator(img)
w = WordCloud(width=500,
              height=500,
              background_color="white",
              font_path="msyh.ttc",
              mask=img,
              scale=15,
              stopwords={'不想展示的词'},
              contour_width=1,
              contour_color='blue')

text = "计算机科学与技术"
text = jieba.lcut(text)
text = " ".join(text)
w.generate(text)

fig, axes = plt.subplots(1,3)
axes[0].imshow(w)
axes[1].imshow(w.recolor(color_func=imgcolor),interpolation="bilinear")
axes[2].imshow(img,cmap=plt.cm.gray)
for ax in axes:
    ax.set_axis_off()
plt.show()


w1 = w.recolor(color_func=imgcolor)
w.to_file("2.png")
```