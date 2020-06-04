@echo off
set /p name=input pages name:

echo name:%name%

hexo n "%name%" && start /d "D:\Typora"  Typora.exe  "E:\code\hexo\source\_posts\%name%.md"