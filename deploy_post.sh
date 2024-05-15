#!/bin/bash


hexo g -d
if [ $# -eq 1 ]; then
	echo "commit"
	git add . 
    	git commit -m "$1"
    	git push
fi
