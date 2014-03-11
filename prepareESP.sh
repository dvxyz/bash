#!/bin/bash

export WHOAMI=`whoami`
# export CVSROOT=:pserver:$WHOAMI:@195.124.89.18:/var/cvs

export ROOTDIR=/opt/LOGA/EServicePacks
export BASEDIR=ESP_
export OUTDIR=$BASEDIR
export RELEASE=`echo $1 | cut -d"-" -f1`
export SEPARATOR=`echo $1 | grep "-"`
export VERSION=`echo $1 | cut -d"-" -f2`
export GLOBAL_BRANCH=branch
export FECHA=`date -u +'%Y-%m-%d'`
export FICHERO=esp_
export ARCHIVFILE=esp_"${RELEASE}"-"${VERSION}"_"${FECHA}".csv
export TMPFILE=$$.esp_$RELEASE-$VERSION.csv
export SMTPSRV=mail.savia.net

if [ "$SEPARATOR" = "" ]; then
 echo "El parametro "$1" es incorrecto. El formato correcto es RELEASE-VERSION. Por ejemplo, 13-0."
 exit
fi

if [ ! -f $HOME/.cvspass ]; then
 cvs login
fi

if [ $? != 0 ]; then
 echo "No ha sido posible iniciar sesion en CVS"
 exit
fi
cd $ROOTDIR

export GLOBAL_BRANCH=${2:-$GLOBAL_BRANCH-$RELEASE-$VERSION}
OUTDIR=$OUTDIR$RELEASE-$VERSION/$FECHA/src

rm -fR $OUTDIR
rm -f ERRORS.err
rm -f cvslog.log

mkdir -p $OUTDIR

# Limpia el fichero de Caracteres no interpretables
# Comprueba existencia correcta del fichero
#
if [ -r esp_$RELEASE-$VERSION.csv ]; then
 cp esp_"${RELEASE}"-"${VERSION}".csv $TMPFILE

 if [ "$DRYRUN" = "" ]; then
  mv esp_"${RELEASE}"-"${VERSION}".csv archiv/$ARCHIVFILE
 fi

 sed 's/
//' < $TMPFILE > esp_"${RELEASE}"-"${VERSION}".csv

 rm $TMPFILE
 echo "Fine. File exists!"
else
 echo ":( Fichero esp_$RELEASE-$VERSION.csv no localizado. Se corta el programa."
 exit
fi

# Recorre las lineas del CSV para hacer el checkout del cpp/h/hpp
# Formato: fuente;batch/forsrv;1.40
#
IFS=";"
grep \$ esp_$RELEASE-$VERSION.csv | while read CPP FIND_SUFFIX CVS_VERSION ; do
 echo CPP: $CPP
 echo FIND_SUFFIX: $FIND_SUFFIX
 echo CVS_VERSION: $CVS_VERSION

 CPP_PATH=`find -L /opt/LOGA/src."${RELEASE}${VERSION}"/$FIND_SUFFIX -name $CPP -print | grep -v Linux.oracle.10.1`
 CPP_PATH=${CPP_PATH/\/opt\/LOGA\/src.$RELEASE$VERSION\//}
 CPP_PATH=${CPP_PATH/\/$CPP/}

 echo FICHERO: $CPP
 echo RUTA: $CPP_PATH

 if [ -f /opt/LOGA/src.$RELEASE$VERSION/$CPP_PATH/$CPP ]; then

  echo Checkout... $l2001/src/$CPP_PATH/$CPP

  if [ "$CVS_VERSION" != "" ]; then
   BRANCH=$CVS_VERSION
  else
   BRANCH=$GLOBAL_BRANCH
  fi

  cvs -d $CVSROOT checkout -P -r $BRANCH -d $OUTDIR/$CPP_PATH -- l2001/src/$CPP_PATH/$CPP

  if [ $? != 0 ]; then
   echo "Problemas al obtener el fichero: "$CPP
   echo /opt/LOGA/src.$RELEASE$VERSION/$CPP_PATH/$CPP >> ERRORS.err
  fi
 fi

 # Obtiene la version del CVS
 # Si el fichero no lo contempla solo muestra el nombre del fichero
 #
 export CVSID=`grep "^static char \*cvsid" $OUTDIR/$CPP_PATH/$CPP | cut -d: -f2,3`
 if [ "$CVSID" = "" ]; then
  export CVSID=$CPP
 fi

 echo "src."${RELEASE}${VERSION}"/"$CPP_PATH"/"${CVSID} >> cvslog.log

done

if [ -e ERRORS.err ]; then
 echo "Se han producido errores!"
 echo "========================="
 cat ERRORS.err
 exit
fi

cd $BASEDIR$RELEASE-$VERSION/$FECHA

find . -name CVS -print0 | xargs -0 /bin/rm -fR

# Borra ficheros de anteriores ejecuciones del dia actual
#
TARFILE=ESP_"${RELEASE}"-"${VERSION}"_"${FECHA}".tar.gz
rm -f $TARFILE

# Creamos un paquete con los nuevos fuentes
#
echo tar cvfz ESP_"${RELEASE}"-"${VERSION}"_"${FECHA}".tar.gz src."${RELEASE}${VERSION}"

mv src src."${RELEASE}${VERSION}"
tar cfz $TARFILE src."${RELEASE}${VERSION}"

# Valores para conexion FTP
#
HOST='ftp2.savia.net'
USER=
PASSWD=

ftp -n -v $HOST << EOT
ascii
user $USER $PASSWD
prompt
mkdir rel"${RELEASE}${VERSION}"
put $TARFILE ./rel"${RELEASE}${VERSION}"/$TARFILE
bye
bye
EOT

cd /tmp
wget ftp://$USER:$PASSWD@$HOST/rel"${RELEASE}${VERSION}"/$TARFILE -O $TARFILE.$$

if [ $? != 0 ]; then
 echo "No ha sido posible obtener el fichero del FTP."
 exit
else
 rm -f $TARFILE.$$
 cd -
fi

(
 echo "Preparacion de Envio para Release: "$RELEASE-$VERSION
 echo "Fecha de preparacion: "`date`
 echo "Responsable: " `cat /etc/passwd | grep $WHOAMI | cut -d: -f5 | cut -d, -f1`
 echo ""
 echo ""
 echo "TAR Package:"
 echo "==========="
 # tar vftz $TARFILE | cut -c49-100 | grep -v "/$"
 cat  $ROOTDIR/cvslog.log
 echo ""
 echo ""
 echo "Links:"
 echo http://privada.savia.net/clientes/descarga/loga/rel"${RELEASE}${VERSION}"/$TARFILE
) | mailx -n -r arealoga@savia.net -s "EService Pack $RELEASE-$VERSION" -a $TARFILE \
     -S smtp=$SMTPSRV -S smtp-auth-user= -S smtp-auth-password= $WHOAMI@savia.net

rm $ROOTDIR/esp_"${RELEASE}"-"${VERSION}".csv 
