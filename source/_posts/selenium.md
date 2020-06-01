---
title: selenium
date: 2019-06-10 21:33:38
tags: python
categories: python
---
###selenium基础使用
```python
from selenium import webdriver
from selenium.webdriver.support.select import Select
import time

driver = webdriver.Chrome(executable_path="E:\\Code\\python\\scrapy\\chromedriver.exe")
driver.fullscreen_window()  # 最大化
'''
driver.get("http://www.baidu.com")
driver.find_element_by_id("kw").send_keys("python")  # 输入值
driver.find_element_by_id("su").click()  # 点击
# driver.minimize_window()
# driver.maximize_window()
title = driver.title  # 标题
print(title)
url = driver.current_url  # 网址
print(url)
driver.back()  # 上一页
page = driver.page_source  # 网页源代码
print(page)
driver.forward()  # 下一页
driver.close()  # 关闭当前标签页
# driver.quit()#关闭浏览器
'''

'''
#选择器
driver.get("https://wannianrili.51240.com/")
year = driver.find_element_by_id("wnrl_xuanze_nian")
year = Select(year)
year.select_by_visible_text("1997")
'''

#截图
driver.get("https://www.baidu.com")
driver.save_screenshot(r"C:\Users\Administrator\Desktop\截图.png")
driver.close()
```