
import os

ls = input("")

def f(name):
	mylist = os.listdir(name)
	for var in mylist:
		var = os.path.join(name,var)
		if(os.path.isdir(var)):
			f(var)
		else:
			with open(var,"rb") as fp:
				a = fp.readlines()
				for w in a:
					#if "网站地图".encode("utf-8") in w:
					if "footer_rss".encode("utf-8") in w:
						print(var)

if not ls:
	ls = 'BlueLake'

f(ls)
#print("网站地图".encode("gbk"))