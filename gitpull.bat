set /p type=input git type(1:push or 2:pull):
if "%type%"=="1" (
	hexo clean && git add --all && git commit -m "1.0" && git push -u origin master
) else if "%type%"=="2" (
	hexo clean && git pull origin master
) else (
	echo error
)
pause