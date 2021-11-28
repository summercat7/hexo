---
title: spider
date: 2019-04-21 15:18:16
tags: python
categories: python
---
##获取拉链详情保持到本地excal
```python
from urllib.request import*
from lxml import etree
import re
import os
import time
import xlwt
from xlutils.copy import copy
import xlrd

def imgdownload(imgurl,filename,name):  #下载图片
    try:
        print("下载。。。%s"%name)
        imgurl = imgurl.replace(" ","%20")  #将空白符替换成"%20"
        urlretrieve(imgurl, ".\\%s\\%s.jpg" % (filename, name))
    except Exception as e:
        print("="*70)
        print("下载异常详情：")
        print(e)
        print("图片名：%s\t图片地址：%s"%(name,imgurl))
        print("="*70)


def excel(index,detailed_information):
    book1 = xlrd.open_workbook('ykk.xls')
    book2 = copy(book1)
    excel_sheet = book2.get_sheet(0)
    colIndex = 0
    excel_headDatas = ["商品名称", "商品类型", "商品链接", "商品简介", "商品用途", "注意事项"]
    for item in excel_headDatas:
        excel_sheet.write(index, colIndex, detailed_information[item])
        colIndex += 1
    book2.save('ykk.xls')

def new_excel():
    excel_headDatas = ["商品名称", "商品类型", "商品链接", "商品简介", "商品用途", "注意事项"]
    excle_Workbook = xlwt.Workbook()
    excel_sheet = excle_Workbook.add_sheet("拉链")
    index = 0
    for data in excel_headDatas:
        excel_sheet.write(0, index, data)
        index += 1
    excle_Workbook.save('ykk.xls')

def look_details(details_urls):
    di = 1
    line = 1
    new_excel()
    gong = len(details_urls)
    for details_url in details_urls:
        name = details_url["name"]
        stype = details_url["stype"]
        url = details_url["url"]
        try:
            print("="*100)
            print("第%d/%d个网页"%(di,gong))
            print(name)
            print(stype)
            print(url)
            html = urlopen(url).read().decode("utf-8")
            html = etree.HTML(html)
            #简介
            intro = ''
            intro_div = html.xpath('//div[@class="ProductInfo"]')
            for string in intro_div[0].xpath('.//div[@class="text"]/text()'):
                string = string.strip()
                intro += string
            print(intro)
            #用途
            use = []
            useul = html.xpath('//ul[@class="layoutItem col4 flexed"]//text()')
            print(useul)
            for i in useul:
                i = i.replace("\n",'').strip()
                if i:
                    use.append(i)
            use = '、'.join(use)
            print(use)
            #注意事项
            announcements = ''
            andiv = html.xpath('//div[@class="area clearfix"]')[0]
            andivs = etree.tostring(andiv, encoding="utf-8").decode("utf-8")
            subdiv = re.findall('<h2>注意事项((.|\s)*?)</div>', andivs)
            if len(subdiv)!=0:
                subdiv = subdiv[0][0]
                parser = etree.HTMLParser(encoding="utf-8")
                subdiv = etree.HTML(subdiv, parser=parser)
                # subdiv = etree.tostring(subdiv,encoding="utf-8").decode("utf-8")
                text = subdiv.xpath('.//div//text()')
                announcements = ''.join(text)
            print(announcements)
            dic = {"商品名称":name,"商品类型":stype,"商品链接":url,"商品简介":intro,"商品用途":use,"注意事项":announcements}
            excel(line,dic)
            line += 1
        except Exception as e:
            print("="*50)
            print("访问异常详情：")
            print(e)
            print("异常网址：%s"%url)
            print("="*50)
        finally:
            di += 1
            print("="*100)
        time.sleep(10)

def open_dict_url(urls):
    details_urls = []
    for i in urls:
        filename = i["name"]
        if not os.path.exists(".\\%s"%filename):
            os.mkdir(".\\%s"%filename)
        for index in range(1,3):
            url = i["url"] + str(index)
            print(url)
            html = urlopen(url).read().decode("utf-8")
            html = etree.HTML(html)
            result = html.xpath('//div[@class="ProductItems"]')
            for div in result:
                imgurl = "https://www.ykkfastening.com" + div.xpath('.//img/@src')[0]
                url = "https://www.ykkfastening.com" + div.xpath('.//a/@href')[0]
                name = div.xpath('.//a/text()')[0].replace(' ','')
                name = re.sub('/|\\|\||\?|\*|"|<|>','_',name)  #文件名不能出现符号
                details_urls.append({"name":name,"stype":filename,"url":url})
                imgdownload(imgurl,filename,name)
    look_details(details_urls)

if __name__ == "__main__":
    headers = ("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36")
    opener = build_opener()
    opener.addheaders = [headers]
    install_opener(opener)
    urls = [{"name": "金属拉链", "url": "https://www.ykkfastening.com/cn/products/zipper/metal_zipper/?pno_941="},
            {"name": "尼龙拉链", "url": "https://www.ykkfastening.com/cn/products/zipper/coil_zipper/?pno_956="},
            {"name": "树脂拉链", "url": "https://www.ykkfastening.com/cn/products/zipper/vislon_zipper/?pno_957="}]
    open_dict_url(urls)
```