set /p name=input pages name:
read -p "请输入文件名 > " name
echo file name:$name
cd -- "$(dirname "$BASH_SOURCE")"
hexo n "$name" && open -a '/Applications/Typora.app'  ~/Data/hexo/source/_posts/$name.md