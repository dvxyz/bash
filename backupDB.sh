#!/bin/bash

export RELEASE=$1

if [ ${RELEASE} == "X0" ]; then
 export BCKUSER=l2001
else
 export BCKUSER=l2001$RELEASE
fi

if [ $USER != $BCKUSER ]; then
 echo "Error 1"
 echo "Execution as user "$BCKUSER "is required!"
 exit -1
fi

export RELEASE=`echo $RELEASE | tr [:lower:] [:upper:]`

export FECHA=`date -u +'%F_%s'`
export DATABASE=LOGA${RELEASE:-"X0"}
export BCKDIR="/backup/QDB/${RELEASE}"
export DBOXDIR="/backup/nube/QDB/${RELEASE}"
export BCKFILE="${DATABASE}_${FECHA}.dmp"
export LOGFILE="${DATABASE}_${FECHA}.txt"
export TGZFILE="${DATABASE}_${FECHA}.tgz"

export ORADIR=/opt/oracle/ora10/bin

cd $BCKDIR

export EXPCMD="${ORADIR}/exp l2001/${BCKUSER}@${DATABASE} file=${BCKFILE} log=${LOGFILE}"
export TGZCMD="tar cfz ${TGZFILE} ${BCKFILE}"
export UPLCMD="mv ${TGZFILE} ${LOGFILE} ${DBOXDIR}"
export RMFCMD="rm -f *.log *.dmp"
export CLNCMD="find ${DBOXDIR} -mtime +30 -exec rm  {} "

if [ $2 == "TEST" ]; then
 echo $LOGFILE
 echo $BCKFILE
 export EXPCMD="touch ${LOGFILE} ${BCKFILE}"
 export CLNCMD="find ${DBOXDIR} -mtime +30 -exec ls {} "
 unset UPLCMD
fi

export WRKDIR=`pwd`

echo "Source  DB         : "$DATABASE  > /tmp/crontab.${USER}.log
echo "Backup Dir         : "$BCKDIR   >> /tmp/crontab.${USER}.log
echo "Working Dir        : "$WRKDIR   >> /tmp/crontab.${USER}.log
echo "Exporting          : "$EXPCMD   >> /tmp/crontab.${USER}.log
echo "Archiving          : "$TGZCMD   >> /tmp/crontab.${USER}.log
echo "Uploading          : "$UPLCMD   >> /tmp/crontab.${USER}.log
echo "Removing temp-files: "$RMFCMD   >> /tmp/crontab.${USER}.log
echo "Cleaning           : "$CLNCMD   >> /tmp/crontab.${USER}.log

$EXPCMD
$TGZCMD

export RESULTS_SIZE="`stat -c %s $TGZFILE`"
if [ "$RESULTS_SIZE" -lt 32768 ]; then
 ( cat /tmp/crontab.${USER}.log ) | mailx -n -r arealoga@savia.net -s "LOGA ${RELEASE}: Error en Backup ${FECHA}" -a $LOGFILE -S smtp=172.23.0.23 -S smtp-auth-user=demologahcm@savia.net -S smtp-auth-password=demologa00 dvelez@savia.net
 exit -1
fi


$UPLCMD
$RMFCMD
$CLNCMD\;
