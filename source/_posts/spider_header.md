---
title: spider_header
date: 2019-05-15 08:04:37
tags: python
categories: python
---
###请求头设置
```python
import requests
import time
from lxml import etree

base_url = 'http://yuanjian.cnki.net/Search/ListResult'
headers={
    'Host':'yuanjian.cnki.net',
    'Referer':'http://yuanjian.cnki.net/Search/ListResult',
    'User_Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.108 Safari/537.36'
}
Listkey=[]
Listhref=[]
param = {
    'searchType': 'MulityTermsSearch',
    'Order': 2,
    'KeyWord' : "",
    'Page': 1
}

def post_page(key):
   param["KeyWord"]=key
   index=1
   while True:
       param["Page"]=index
       request=requests.post(base_url,data=param,headers=headers)
       html = etree.HTML(request.text)
       href = html.xpath('//p[@class="tit clearfix"]/a[@class="left"]/@href')
       for i in href:
           if i not in Listhref:
               Listhref.append(i)
           else:
               return None
       index=index+1
       time.sleep(5)

if __name__ == "__main__":
    str=post_page("MXD6")
    print(len(Listhref))
    html = Listhref[0]
    html = requests.get(Listhref[0]).text
    print(html)


```