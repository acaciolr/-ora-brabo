#!/bin/sh

#this script will be in the root oeda directory
ME=`basename "$0"`
# default to not allow run as root
ROOT=0
MYID=`id -g`
OEDAHOME=`pwd`
echo "oeda home: $OEDAHOME"

if [[ $OEDAHOME == *" "* ]]; then
  echo "Detected space in the oeda home directory path. The compressed file must be extracted into a directory with no spaces in its path."
  exit 1;
fi

#http port
HTTP_PORT="7072"
#enable remote connection to server. Disabled by default, set to -g to enable
# remote access
LISTENADDRESSFLAG==""

## did they request  a different port ?
while getopts ":p:rgh" opt; do
  case $opt in
    p)
      HTTP_PORT=$OPTARG
      ;;
    r)
      ROOT=1
      ;;
    g)
      LISTENADDRESSFLAG="-g"
      ;;
    h)
      echo "usage installOedaServer [-p port number] [-r] [-g]"
      echo "-p port number : default is 7072"
      echo "-g : enable remote server access"
      echo "-r : run with root privileges"
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
echo  using HTTP PORT : $HTTP_PORT
echo allow root :  $ROOT
if [ $MYID -eq 0 ] && [ $ROOT -eq 0 ];  then
   echo  "It is not recommended to install as root. Please re-run $ME, passing -r if you insist on installing as root"
   exit 2
fi

#kill existing server instances
kill -9 `ps -ef | grep OedaWebMain | awk '{print $2}'` 2>/dev/null

thisdir=`dirname $0`
pushd $thisdir >> /dev/null
. ./jre
$JRE_PATH/java ${JAVA_OPTIONS} -cp .:Lib/*:out/*:WebLib/*: oracle.onecommand.webservice.OedaWebMain  -p $HTTP_PORT  $LISTENADDRESSFLAG
popd >> /dev/null
