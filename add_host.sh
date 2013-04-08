#!/bin/bash

# v1.0 stuart.moore@gmail.com
#	+ Just adds the host, including ssh and / filesystem checking.
# v1.1 stuart.moore@gmail.com
#	- Removed everything except the ssh check, everything else
#		is now in a seperate script.
#	+ Now installs NRPE (the nagios agent) on the remote host
# v1.2 stuart.moore@gmail.com
#	+ NRPE stuff moved to a seperate update_nrpe script
# v1.3 stuart.moore@gmail.com
#	+ DNS lookup now has error handling.
# v1.4 stuart.moore@gmail.com
#	+ Added check type, allowing for SSH, RDP and PING (RDP and PING needs testing!)

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
	-k Check type (ssh, rdp, ping)
EOF
}

define_host()
{
	echo -e "define host {"	>> $HOSTS_FILE
	echo -e "\tuse generic-host" >> $HOSTS_FILE
	echo -e "\thost_name $HOST" >> $HOSTS_FILE
	echo -e "\talias $FQDN" >> $HOSTS_FILE
	echo -e "\taddress $IPADDR" >> $HOSTS_FILE
	echo -e "\tcheck_command check_$CHECK" >> $HOSTS_FILE
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
		k)
			CHECK=$OPTARG
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
	IPADDR=`getent hosts $FQDN | cut -f 1 -d " "`
	if [ -z $IPADDR ]; then
		echo $FQDN does not exist in DNS! Aborting ...
		exit 1
	fi
	HOSTS_DIR="/usr/local/nagios/etc/hosts"
	HOSTS_FILE="$HOSTS_DIR"/"$HOST".cfg
	if [ -e "$HOSTS_FILE" ]; then
		echo Server already exists at $HOSTS_FILE! Aborting ...
		exit 1
	else
		define_host
		chown nagios:apache $HOSTS_FILE
		/etc/init.d/nagios reload
	fi
fi

# EOF
