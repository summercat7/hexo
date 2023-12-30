cd -- "$(dirname "$BASH_SOURCE")"
pwd
hexo clean&&hexo g&&hexo d
echo 部署完成