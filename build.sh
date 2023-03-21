#!/bin/sh
src=~/gitbook-pre
dst=~/sth
cd $src
gitbook build ./ ~/buildbook/

cd $dst
git checkout gh-pages
/bin/cp -rf ~/gitbook-pre/*md  .
/bin/cp -rf ~/buildbook/*  .
if [[ $? -eq 0 ]];then
  git add .
  git commit -m "更新日志"
  git push
fi
