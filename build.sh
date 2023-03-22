#!/bin/sh
src=~/gitbook-pre
dst=~/sth
cd $src
gitbook build ./ ~/buildbook/

cd $dst
git checkout gh-pages
if [[ $? -eq 0 ]];then
  /bin/cp -rf ~/gitbook-pre/*md  .
  /bin/cp -rf ~/buildbook/*  .
  git add .
  git commit -m "更新日志"
  git push
fi
