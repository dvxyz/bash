#!/bin/bash

Resolution=`xdpyinfo | grep dimension | cut -d ":" -f 2 | cut -d "p" -f 1 | tr -d ' '`
Xaxis=`echo $Resolution | cut -d "x" -f 1`
Yaxis=`echo $Resolution | cut -d "x" -f 2`
MaxXRes=$Xaxis
MaxYRes="`expr $Yaxis - 65`"

OSVERSION=`cat /etc/SuSE-release | grep VERSION | cut -d" " -f 3`

if [ $OSVERSION == "12.3" ]; then
 MaxYRes="`expr $Yaxis - 60`"
fi

export SERVER=$1
export RDP_DOMAIN=${2:-SAVIA}
export RDP_USER=${3:-$USER}
export RDP_PASS=${4:-}
export XRESOLUTION=${5:-$MaxXRes}
export YRESOLUTION=${6:-$MaxYRes}
export TITLE="${SERVER}"@"${RDP_DOMAIN}"

if [[  "$RDP_PASS" != "" ]]; then
 nohup xfreerdp --plugin rdpdr --data disk:TEMP:/tmp -- --plugin cliprdr -g ${XRESOLUTION}x${YRESOLUTION} -d ${RDP_DOMAIN} -u ${RDP_USER} -p ${RDP_PASS} -T ${TITLE} --ignore-certificate --no-nla -z ${SERVER} &
else
 nohup xfreerdp --plugin rdpdr --data disk:TEMP:/tmp -- --plugin cliprdr -g ${XRESOLUTION}x${YRESOLUTION} -d ${RDP_DOMAIN} -u ${RDP_USER} -T ${TITLE} --ignore-certificate --no-nla -z ${SERVER} &
fi
