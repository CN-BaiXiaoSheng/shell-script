#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo "====================================================================================="
echo "===========================SVNService  for  CentOS/RadHat  Linux VPS=============================="
echo "====================================================================================="


function installsvnserver()
{
echo "============================SVNService install begin============================"
cd /tmp
yum install gcc openssl-devel -y
wget -c https://raw.githubusercontent.com/jinchengjiang/shell-script/master/svn/subversion-1.6.18.tar.gz
wget -c https://raw.githubusercontent.com/jinchengjiang/shell-script/master/svn/subversion-deps-1.6.18.tar.gz
mkdir software
tar -xzvf subversion-1.6.18.tar.gz -C ./software/
tar -xzvf subversion-deps-1.6.18.tar.gz -C ./software/
cd software/subversion-1.6.18/
./configure --prefix=/usr/local/svnserve --with-apxs=no --with-ssl
make clean && make && make install

cat >svnserver<<EOF
export PATH="$PATH:/usr/local/svnserve/bin"
EOF

sed -i '/# \/etc\/profile/ {
r svnserver
}' /etc/profile
rm -rf svnserver

mkdir /svnroot
svnserve -d -r /svnroot

wget -c https://raw.githubusercontent.com/jinchengjiang/shell-script/master/conf/svnserve
mv svnserve /etc/init.d/svnserve

chmod +x /etc/init.d/svnserve         
chkconfig --add svnserve 
chkconfig svnserve on
service svnserve restart



echo "============================SVNService install completed============================"
}
installsvnserver 2>&1 | tee installsvnserver.log
