#!/bin/bash

export WHOAMI=`whoami`
export REFRREL=$2
export SYNCREL=$1

clear

if [ "$REFRREL" == "x0" ]; then
 unset REFRREL
fi

if [ "$SYNCREL" == "" ]; then
 echo "Sintaxis: "$0" targetDB {x0 | x3 | x6 | x9} [referDB {x0 | x3 | x6 | x9}]"
 exit -1
else
 if [ "$SYNCREL" == x0 ]; then
  export DSTNTDB=LOGAX0
  unset SYNCREL
 fi
 if [ "$SYNCREL" == devel ]; then
  export DSTNTDB=DEVEL
  export SYNCREL=devel
  export PASSWD=l2001dev
 fi
fi

echo "Current user: "$WHOAMI". Requested user: l2001"$SYNCREL

if [ $WHOAMI != l2001$SYNCREL ]; then
 echo "Error 1"
 echo "Execution as user l2001"$SYNCREL "is required!"
 exit -1
fi

export REFERDB=LOGA${REFRREL:-"x0"}
export DSTNTDB=${DSTNTDB:-"LOGA"$SYNCREL}
export PASSWD=${PASSWD:-"l2001"$SYNCREL}
export BCKDIR=/backup/sync
export LOGDIR=/backup/sync
export BCKFILE="${BCKDIR}/${REFERDB}_`date -u +'%Y-%m-%d'`.dmp"
export LOGFILE="${REFERDB}_`date -u +'%Y-%m-%d'`.log"
 export LOGFIL1="${LOGDIR}/${REFERDB}_`date -u +'%Y-%m-%d'`.log"
 export LOGFIL2="${LOGDIR}/${DSTNTDB}_`date -u +'%Y-%m-%d'`.log"
export LOGFILE="${LOGDIR}/${LOGFILE}"
export ORADIR=/opt/oracle/ora10/bin

export RSTCMD="${ORADIR}/sqlplus sys/$DSTNTDB@$DSTNTDB as sysdba @$HOME/createL2001.sql ${ORACLE_PWD}"
export EXPCMD="${ORADIR}/exp l2001/l2001${REFRREL}@${REFERDB} file=${BCKFILE} log=${LOGFIL1}"
export IMPCMD="${ORADIR}/imp l2001/${PASSWD}@$DSTNTDB file=$BCKFILE fromuser=L2001 touser=L2001 log=${LOGFIL2}"

echo "Source  DB: "$REFERDB >  $LOGFILE
echo "Target  DB: "$DSTNTDB >> $LOGFILE
echo "Backup Dir: "$BCKDIR  >> $LOGFILE
echo "Reset  Cmd: "$RSTCMD  >> $LOGFILE
echo "Export Cmd: "$EXPCMD  >> $LOGFILE
echo "Import Cmd: "$IMPCMD  >> $LOGFILE
echo >> $LOGFILE
echo Starting... >> $LOGFILE

## Steps
#
# 01. Export RefDB
# 02. Drop / Create User syncDB
# 03. Import syncDB

echo $EXPCMD >> $LOGFILE
echo $RSTCMD >> $LOGFILE
echo $IMPCMD >> $LOGFILE

cat $LOGFILE

read -n 1 -p "Continuar [y/n]: "
[ "$REPLY" == "y" ] || exit 0

$EXPCMD

if [ -f $HOME/createL2001.sql ]; then
 echo Reseting ...
 $RSTCMD
 $IMPCMD 
fi
