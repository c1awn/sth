#!/bin/sh
src=~/gitbook-pre
dst=~/sth
cd $src
gitbook build ./ ~/buildbook/

cd $dst
/bin/cp -rf ~/gitbook-pre/*md  .
/bin/cp -rf ~/buildbook/*  .
git checkout gh-pages
git add .
git commit -m "更新日志"
git push
