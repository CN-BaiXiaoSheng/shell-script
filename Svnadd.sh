#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Add Virtual Host for SVN "
echo "========================================================================="
echo "This script is a tool to add virtual host for SVN"
echo ""
echo "========================================================================="

if [ "$1" != "--help" ]; then

        domain=""
        read -p "Please input domain:" domain
        if [ "$domain" = "" ]; then
                echo "Error: Domain Name Can't be empty!!"
                exit 1
        fi

	svnpwd=""
        read -p "Please input svnpwd:" svnpwd
        if [ "$svnpwd" = "" ]; then
                echo "Error: Svnpasswd Can't be empty!!"
                exit 1
        fi

        svnwww=""
        read -p "Please input svnwww:" svnwww
        if [ "$svnwww" = "" ]; then
                echo "Error: Svnwww Can't be empty!!"
                exit 1
        fi

	domainA=`echo $domain | awk -F . '{print  $1}'`
	domainB=`echo $domain | awk -F . '{print  $2}'`
	domainC=`echo $domain | awk -F . '{print  $3}'`


	svndir=/svnroot/$domainB.$domainC/$domainA

        if [ ! -d "$svndir" ]; then
        echo "==========================="
        echo "domain=$domain"
        echo "===========================" 
        else
        echo "==========================="
        echo "$domain is exist!"
        echo "==========================="
	exit      
        fi

	get_char()
        {
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
        }
        echo ""
        echo "Press any key to start create svn host..."
        char=`get_char`


        if [ ! -d "$svndir" ]; then
	mkdir -p $svndir && svnadmin create $svndir
	fi

cat > $svndir/conf/authz<<eof
### This file is an example authorization file for svnserve.
### Its format is identical to that of mod_authz_svn authorization
### files.
### As shown below each section defines authorizations for the path and
### (optional) repository specified by the section name.
### The authorizations follow. An authorization line can refer to:
###  - a single user,
###  - a group of users defined in a special [groups] section,
###  - an alias defined in a special [aliases] section,
###  - all authenticated users, using the '$authenticated' token,
###  - only anonymous users, using the '$anonymous' token,
###  - anyone, using the '*' wildcard.
###
### A match can be inverted by prefixing the rule with '~'. Rules can
### grant read ('r') access, read-write ('rw') access, or no access
### ('').

[aliases]
# joe = /C=XZ/ST=Dessert/L=Snake City/O=Snake Oil, Ltd./OU=Research Institute/CN=Joe Average

[groups]
# harry_and_sally = harry,sally
# harry_sally_and_joe = harry,sally,&joe
$domainB.$domainC = $domainB

# [/foo/bar]
# harry = rw
# &joe = r
# * =
[/]
$domainB = rw
* =

# [repository:/baz/fuz]
# @harry_and_sally = rw
# * = r
[$domainA.$domainB.$domainC:$svndir]
$domainB = rw
* =
eof

cat > $svndir/conf/passwd<<eof
### This file is an example password file for svnserve.
### Its format is similar to that of svnserve.conf. As shown in the
### example below it contains one section labelled [users].
### The name and password for each user follow, one account per line.

[users]
# harry = harryssecret
# sally = sallyssecret
$domainB = $svnpwd
eof

cat > $svndir/conf/svnserve.conf<<eof
### This file controls the configuration of the svnserve daemon, if you
### use it to allow access to this repository.  (If you only allow
### access through http: and/or file: URLs, then this file is
### irrelevant.)

### Visit http://subversion.apache.org/ for more information.

[general]
### These options control access to the repository for unauthenticated
### and authenticated users.  Valid values are "write", "read",
### and "none".  The sample settings below are the defaults.
anon-access = none
auth-access = write
### The password-db option controls the location of the password
### database file.  Unless you specify a path starting with a /,
### the file's location is relative to the directory containing
### this configuration file.
### If SASL is enabled (see below), this file will NOT be used.
### Uncomment the line below to use the default password file.
password-db = passwd
### The authz-db option controls the location of the authorization
### rules for path-based access control.  Unless you specify a path
### starting with a /, the file's location is relative to the the
### directory containing this file.  If you don't specify an
### authz-db, no path-based access control is done.
### Uncomment the line below to use the default authorization file.
authz-db = authz
### This option specifies the authentication realm of the repository.
### If two repositories have the same authentication realm, they should
### have the same password database, and vice versa.  The default realm
### is repository's uuid.
realm = $domainA.$domainB.$domainC

[sasl]
### This option specifies whether you want to use the Cyrus SASL
### library for authentication. Default is false.
### This section will be ignored if svnserve is not built with Cyrus
### SASL support; to check, run 'svnserve --version' and look for a line
### reading 'Cyrus SASL authentication is available.'
# use-sasl = true
### These options specify the desired strength of the security layer
### that you want SASL to provide. 0 means no encryption, 1 means
### integrity-checking only, values larger than 1 are correlated
### to the effective key length for encryption (e.g. 128 means 128-bit
### encryption). The values below are the defaults.
# min-encryption = 0
# max-encryption = 256
eof

cat > $svndir/hooks/post-commit<<eof
#!/bin/sh

# POST-COMMIT HOOK
#
# The post-commit hook is invoked after a commit.  Subversion runs
# this hook by invoking a program (script, executable, binary, etc.)
# named 'post-commit' (for which this file is a template) with the 
# following ordered arguments:
#
#   [1] REPOS-PATH   (the path to this repository)
#   [2] REV          (the number of the revision just committed)
#
# The default working directory for the invocation is undefined, so
# the program should set one explicitly if it cares.
#
# Because the commit has already completed and cannot be undone,
# the exit code of the hook program is ignored.  The hook program
# can use the 'svnlook' utility to help it examine the
# newly-committed tree.
#
# On a Unix system, the normal procedure is to have 'post-commit'
# invoke other programs to do the real work, though it may do the
# work itself too.
#
# Note that 'post-commit' must be executable by the user(s) who will
# invoke it (typically the user httpd runs as), and that user must
# have filesystem-level permission to access the repository.
#
# On a Windows system, you should name the hook program
# 'post-commit.bat' or 'post-commit.exe',
# but the basic idea is the same.
# 
# The hook program typically does not inherit the environment of
# its parent process.  For example, a common problem is for the
# PATH environment variable to not be set to its usual value, so
# that subprograms fail to launch unless invoked via absolute path.
# If you're having unexpected problems with a hook program, the
# culprit may be unusual (or missing) environment variables.
# 
# Here is an example hook script, for a Unix /bin/sh interpreter.
# For more examples and pre-written hooks, see those in
# the Subversion repository at
# http://svn.apache.org/repos/asf/subversion/trunk/tools/hook-scripts/ and
# http://svn.apache.org/repos/asf/subversion/trunk/contrib/hook-scripts/


REPOS="$1"
REV="$2"
export LANG=en_US.UTF-8
/usr/local/svnserve/bin/svn log -vr 'HEAD' svn://localhost/$domainB.$domainC/$domainA | grep ' D ' | cut -d ' ' -f5 |xargs -i rm -rf $svnwww/{}
/usr/local/svnserve/bin/svn log -vr 'HEAD' svn://localhost/$domainB.$domainC/$domainA | grep ' A ' | cut -d ' ' -f5 |xargs -i rm -rf $svnwww/{}
/usr/local/svnserve/bin/svn log -vr 'HEAD' svn://localhost/$domainB.$domainC/$domainA | grep ' M ' | cut -d ' ' -f5 |xargs -i rm -rf $svnwww/{}
 
/usr/local/svnserve/bin/svn log -vr 'HEAD' svn://localhost/$domainB.$domainC/$domainA | grep ' M ' | cut -d ' ' -f5 |xargs -i /usr/local/svnserve/bin/svn export --force svn://localhost/$domainB.$domainC/$domainA/{} $svnwww/{}

/usr/local/svnserve/bin/svn log -vr 'HEAD' svn://localhost/$domainB.$domainC/$domainA | grep ' A ' | cut -d ' ' -f5 |xargs -i /usr/local/svnserve/bin/svn export --force svn://localhost/$domainB.$domainC/$domainA/{} $svnwww/{}

chown -R www:www $svnwww
chmod -R 755 $svnwww
eof

chmod +x $svndir/hooks/post-commit

/usr/local/svnserve/bin/svn export --force svn://localhost/$domainB.$domainC/$domainA $svnwww

echo "========================================================================="
echo "Add Virtual Host for SVN"
echo "========================================================================="
echo "Your SVN: svn://$domain/$domainB.$domainC/$domainA"
echo "Your SVNUSRE: $domainB"
echo "Your SVNPWD: $svnpwd"
echo "========================================================================="
	
fi
