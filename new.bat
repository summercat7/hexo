@echo off
e:
cd E:\Code\nodejs\hexo
set /p name=input pages name:

echo name:%name%

hexo n "%name%" && start /d "D:\HBuilderX"  HBuilderX.exe  "E:\Code\nodejs\hexo\source\_posts\%name%.md"