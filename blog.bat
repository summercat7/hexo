:: @echo off
:: e:
:: cd E:\Code\nodejs\hexo
hexo clean&& rd /s/q .deploy_git && git add -f --all && git commit -m "1.0" && git push -u origin master &&hexo g&&hexo d
