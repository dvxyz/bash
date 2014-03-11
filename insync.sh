#!/bin/bash
#
export LOGPATH=/tmp
export LOGFILE=$LOGPATH/insync.log
export EXCLUDE_FILE=/media/DATA/Dropbox/exclude.txt

# Recursive
# export OPTS="-avzA --no-l --delete --exclude-from $EXCLUDE_FILE --log-file $LOGFILE"
export OPTS="-avzA --no-l --delete --exclude zip_archiv/* --log-file $LOGFILE"

# No Recursion
# export OPTS="-lptgoDvA --no-l --log-file $LOGFILE"

# Simulacion
# export OPTS="$OPTS --dry-run"

export SRCPATH="${1}"
export BASPATH=/media/DATA/Dropbox
export DSTPATH=/mnt/filemon

export SRCFILE="${2}"

echo `date -u +"%Y-%m-%d %T"` "${SRCFILE}" ${3} > /tmp/incron.log

export RELPATH=`echo "${SRCPATH}" | sed -e "s/\/media\/DATA//"`
export DSTPATH=`dirname "${DSTPATH}""${RELPATH}"`

echo SRCPATH: "$SRCPATH"
echo RELPATH: "$RELPATH"
echo DSTPATH: "$DSTPATH"

echo rsync $OPTS "${SRCPATH}" "${DSTPATH}" >> $LOGFILE
# ls -l "${SRCPATH}"
# ( cd "${SRCPATH}" && pwd )
time rsync $OPTS "${SRCPATH}" "${DSTPATH}"
