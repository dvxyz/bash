#!/bin/bash


export RELEASE=`cat /etc/os-release | grep PRETTY_NAME | cut -d "\"" -f2 | cut -d " " -f1,2 | sed -e 's/ /_/g'`
export INSTALL_CMD="zypper in"
export QUERY_CMD="rpm -q"
export VIRTUALBOX_ASC="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc"

export DROPBOX=""
export VIRTUALBOX="VirtualBox-4.2"
export XFREERDP="freerdp"
export XFREERDP_PLUGINS="libfreerdp-1_0-plugins"
export GOOGLECHROME_RPM="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.rpm"
export GOOGLECHROME_DEB="https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"
export SHUTTER="shutter"
export REVELATION="revelation"
export APPLICATION_LNS=""
export PDFTK="pdftk"
export DIFFPDF="diffpdf"

function add_software_repos()
{
	# Packman
	zypper addrepo -f http://ftp.gwdg.de/pub/linux/packman/suse/$RELEASE Packman
	# Google (Chrome)
	zypper addrepo -f http://dl.google.com/linux/chrome/rpm/stable/i386 Google
	# Revelation
	zypper addrepo -f http://download.opensuse.org/repositories/security:/passwordmanagement/$RELEASE passwordmanagement
	# VirtualBox
	zypper addrepo -f http://download.opensuse.org/repositories/Virtualization:/VirtualBox_backports/$RELEASE VirtualBox
}

function install_diffpdf()
{
	$QUERY_CMD $DIFFPDF
	if [ $? != 0 ]; then
		$INSTALL_CMD $DIFFPDF libpoppler-qt4-4
	fi
}

function install_google_chrome()
{
	$QUERY_CMD google-chrome-stable
	if [ $? != 0 ]; then
		# wget $GOOGLECHROME
		# rpm -i `basename $GOOGLECHROME`
		$INSTALL_CMD $GOOGLECHROME
	fi
}

function install_pdftk()
{
	$QUERY_CMD $PDFTK
	if [ $? != 0 ]; then
		$INSTALL_CMD $PDFTK
	fi
}

function install_revelation()
{
	$QUERY_CMD $REVELATION
	if [ $? != 0 ]; then
		$INSTALL_CMD $REVELATION python-cracklib python-gconf python-pycrypto
	fi

	$INSTALL_CMD python-cracklib python-gconf python-pycrypto
}

function install_shutter()
{
	$QUERY_CMD $SHUTTER
	if [ $? != 0 ]; then
		$INSTALL_CMD $SHUTTER
	fi
}

function install_virtualbox()
{
	$QUERY_CMD $VIRTUALBOX
	if [ $? != 0 ]; then
		wget -q $VIRTUALBOX_ASC
		rpm --import `basename $VIRTUALBOX_ASC`
		zypper search virtualbox
		$INSTALL_CMD  libpng12.so.0 dkms $VIRTUALBOX
	fi
}

function install_xfreerdp()
{
	$QUERY_CMD $XFREERDP
	if [ $? != 0 ]; then
		$INSTALL_CMD $XFREERDP $XFREERDP_PLUGINS
	fi
}

function system_utils()
{
	$INSTALL_CMD python-pyinotify libyaml-0-2 python-yaml vinagre
}

function install_dependencies()
{
	echo "Installing dependencies..."
}

function grant_permissions()
{
	# Other actions required
	#
	# mount privileges
	sudo chmod u+s /sbin/mount.cifs
	sudo chmod u+s /sbin/ifconfig
}

add_software_repos
install_dependencies
install_google_chrome
install_virtualbox
install_xfreerdp
install_shutter
install_pdftk
install_revelation
install_diffpdf
system_utils
grant_permissions

