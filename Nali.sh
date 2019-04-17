#!/bin/bash

cd /tmp
wget -c https://raw.githubusercontent.com/jinchengjiang/shell-script/master/nali/nali.zip
unzip nali.zip
cd nali
./configure
make
make install

nali-update
