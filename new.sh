set /p name=input pages name:
read -p "请输入文件名 > " name
echo file name:$name
hexo n "$name" && open -a '/Applications/Mark Text.app'  ~/data/hexo/source/_posts/$name.md