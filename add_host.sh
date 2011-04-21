#!/bin/bash

# v1.0 stuart.moore@monitisegroup.com
#	+ Just adds the host, including ssh and / filesystem checking.
# v1.1 stuart.moore@monitisegroup.com
#	- Removed everything except the ssh check, everything else
#		is now in a seperate script.
#	+ Now installs NRPE (the nagios agent) on the remote host
# v1.2 stuart.moore@monitisegroup.com
#	+ NRPE stuff moved to a seperate update_nrpe script

# TO DO LIST:
# - Convert the echo spam to a function
# - Make all of the host and service variables actual variables in this script
# - Have a disable flag for the agent installation.


usage()
{
        cat << EOF
Usage: $0 options

This script adds a host into Nagios.

OPTIONS:
	-c Contact Groups (comma delimited)
	-g Hostgroup			
	-h Show this message
	-H FQDN of the host to be added
EOF
}

define_host()
{
	echo -e "define host {"	>> $HOSTS_FILE
	echo -e "\tuse generic-host" >> $HOSTS_FILE
	echo -e "\thost_name $HOST" >> $HOSTS_FILE
	echo -e "\talias $FQDN" >> $HOSTS_FILE
	echo -e "\taddress $IPADDR" >> $HOSTS_FILE
	echo -e "\tcheck_command check_ssh" >> $HOSTS_FILE
	echo -e "\tmax_check_attempts 10" >> $HOSTS_FILE
	echo -e "\tactive_checks_enabled 1" >> $HOSTS_FILE
	echo -e "\tflap_detection_enabled 1" >> $HOSTS_FILE
	echo -e "\tnotification_interval 10" >> $HOSTS_FILE
	echo -e "\tnotification_period 24x7" >> $HOSTS_FILE
	echo -e "\tnotification_options d,u,r" >> $HOSTS_FILE
	echo -e "\thostgroups $HOSTGROUP" >> $HOSTS_FILE
	echo -e "\tcontact_groups $CONTACTGROUPS" >> $HOSTS_FILE
	echo -e "}" >> $HOSTS_FILE
}

while getopts "hH:g:c:" OPTION
do
	case $OPTION in
		c)
			CONTACTGROUPS=$OPTARG
			;;
		g)
			HOSTGROUP=$OPTARG
			;;
		h)
			usage
			exit 0
			;;
		H)
			FQDN=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $FQDN ] || [ -z $HOSTGROUP ] || [ -z $CONTACTGROUPS ]; then
	usage
	exit 1
else
	HOST=`echo $FQDN | cut -f1 -d "."`
	IPADDR=`host $FQDN | cut -f 4 -d " "`
	HOSTS_DIR="/usr/local/nagios/etc/hosts"
	HOSTS_FILE="$HOSTS_DIR"/"$HOST".cfg
	if [ -e "$HOSTS_FILE" ]; then
		echo Server already exists at $HOSTS_FILE! Aborting ...
		exit 1
	else
		define_host
		chown nagios:apache $HOSTS_FILE
#		HOST_OS=`ssh -l root $FQDN uname`
#		HOST_PLATFORM=`ssh -l root $FQDN uname -i`
#		scp /usr/local/nagios/scripts/nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz root@$FQDN:/opt
#		ssh root@$FQDN "cd /opt ; gunzip nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz; tar xf nrpe.$HOST_OS.$HOST_PLATFORM.tar ; cd nrpe ; ./nrpe.install ; cd .. ; rm nrpe.$HOST_OS.$HOST_PLATFORM.tar"
		/etc/init.d/nagios reload
	fi
fi

# EOF
