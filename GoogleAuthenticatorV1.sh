#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


function GoogleAuthenticator()
{
echo "============================Install GoogleAuthenticator============================"
cd /tmp
yum -y install pam-devel make gcc-c++ wget
rm -rf libpam-google-authenticator-1.0
if [ -s libpam-google-authenticator-1.0-source.tar.bz2 ]; then
	echo " libpam-google-authenticator-1.0-source.tar.bz2 [found]"
else
	echo "Error: libpam-google-authenticator-1.0-source.tar.bz2 not found!!!download now......"
	wget -c https://github.com/jinchengjiang/shell-script/blob/master/google-authenticator/libpam-google-authenticator-1.0-source.tar.bz2
fi
tar -xvf libpam-google-authenticator-1.0-source.tar.bz2
cd libpam-google-authenticator-1.0
make
make install

echo "============================Config GoogleAuthenticator============================"
cat >sshdpam<<EOF
auth       required     pam_google_authenticator.so
EOF
sed -i '/#%PAM-1.0/ {
r sshdpam
}' /etc/pam.d/sshd
rm -rf sshdpam
if grep -v "\#" /etc/ssh/sshd_config | grep -q "ChallengeResponseAuthentication" ; then echo do nothing ; else sed -i '/#ChallengeResponseAuthentication/a\ChallengeResponseAuthentication yes' /etc/ssh/sshd_config; fi

google-authenticator<< EOF
y
y
y
y
y
y
EOF

/etc/init.d/sshd restart
echo "============================Config_GoogleAuthenticator========================="
}

if [ -s /tmp/.GoogleAuthenticator.lock ]; then
echo "This shell script has run! Bye!!"
else
GoogleAuthenticator 2>&1 | tee GoogleAuthenticator.log
echo > /tmp/.GoogleAuthenticator.lock
fi