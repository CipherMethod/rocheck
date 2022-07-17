#!/bin/sh

# Created 20111107 - Jamey Hopkins
# Nagios script to check base file paths for a read-only filesystem condition

USER=`whoami`
F="rocheck.safetodelete"
# sets paths to test
PATHS=`df -P -l -x tmpfs -x vmhgfs -x iso9660 | column -t | awk '{ print $6 }' | grep -v "Mounted" | xargs echo`
# define specific paths
#PATHS="/ /home /opt /tmp /usr /var"

if [ "$USER" != "root" ]
then
   echo "Run $0 command as root"
   exit
fi

for P in `echo $PATHS`
do
   [ "$P" = "/" ] && P="" # don't process a double slash
   PF="$P/$F"
   touch $PF >/dev/null 2>&1
   if [ "$?" != "0" ]
   then
      [ "$P" = "" ] && P="/" # add slash back if it was ro
      FAIL="$FAIL $P" # add P to string of failed paths
   fi
   [ -e $PF ] && rm $PF >/dev/null 2>&1
done

if [ "$FAIL" != "" ]
then
   # return an error 2 status with a list of directories that failed the touch test
   echo "Read Only:$FAIL"
   exit 2
fi

# return a good status with the list of directories that were checked
echo "Good: $PATHS"
exit 0
