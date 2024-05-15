#!/bin/bash


hexo g -d
#hexo new "post 文章名字"
if [ $# -eq 1 ]; then
	echo "commit"
	git add . 
    	git commit -m "$1"
    	git push
fi
