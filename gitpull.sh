read -n 1 -p "input git type(1:push or 2:pull) > " type && printf "\n"
if [ $type == '1' ]
then
	hexo clean && git add --all && git commit -m "1.0" && git push -u origin master
elif [ $type == '2' ]
then
	hexo clean && git pull origin master
else
	echo 'input error'
fi
