#!/bin/bash

cat >>/etc/profile<<eof
#PS1-Environment
PS1="\[\e[35;1m\][\[\e[32;1m\]\u\[\e[37;1m\]@\[\e[35;40m\]\H \[\e[34;40m\]\d \t\[\e[35;1m\]] \[\e[36;40m\][\\\$PWD] \[\e[37;40m\][CMD:\#] \\\\n\[\e[31;40m\][Bash:\v] \[\e[32;40m\]<\\\\$> \[\e[1m\]"
eof

source /etc/profile
