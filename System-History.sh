#!/bin/bash

cat >>/etc/profile<<eof
#History-Environment
history
USER_IP=\`who -u am i 2>/dev/null | awk '{print \$NF}'|sed -e 's/[()]//g'\`
DT=\`date "+%Y-%m-%d_%H-%M-%S"\`
HF=/var/.history
if [ "\$USER_IP" = "" ]
  then
    USER_IP=\`hostname\`
fi
if [ ! -d \$HF ]
  then
    mkdir \$HF
    chmod 777 "\$HF"
fi
export HISTTIMEFORMAT="%F %T \`whoami\` "
export HISTSIZE=65536
export HISTFILE="/var/.history/\$DT-\${LOGNAME}@\${USER_IP}.log"
chmod 600 "\$HF/*" 2>/dev/null
eof
source /etc/profile
