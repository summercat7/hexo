cd -- "$(dirname "$BASH_SOURCE")"
hexo clean && git add --all && git commit -m "1.0" && git push -u origin master
