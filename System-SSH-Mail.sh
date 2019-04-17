#!/bin/bash

cat >>/etc/profile<<eof
#LoginMail
echo -e ""[\$HOSTNAME] SystemLoginLog \$(whoami) login at: \$(date) ip address: \$(w|sed -n '3p'|awk '{print \$3}')"" | mutt -s "'[\$HOSTNAME] SystemLogining \$(date)'" $MailToUser &>/dev/null
eof

source /etc/profile
