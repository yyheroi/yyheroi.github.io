#!/bin/bash


hexo g -d
#hexo new "post 文章名字"
if [ $# -eq 1 ]; then
	echo "commit"
	git add . 
    	git commit -m "$1"
    	git push origin hexo -f
fi
cp source/_posts/* source/back_posts -rf
cp source/_posts/* ../_posts -rf
cp source/imgs/*   ../imgs -rf
