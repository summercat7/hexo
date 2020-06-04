:: @echo off
:: e:
:: cd E:\Code\nodejs\hexo
hexo clean&& git add -f --update && git commit -m "1.0" && git push -u origin master &&hexo g&&hexo d
