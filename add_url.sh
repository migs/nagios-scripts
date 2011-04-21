#!/bin/bash

# v1.0 stuart.moore@monitisegroup.com
#	+ Adds the URL. Simples.

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
	-s service to be checked (http, matml_core, console_nigeria etc)
EOF
}

define_host()
{
	echo -e "define host {"	>> $HOSTS_FILE
	echo -e "\tuse generic-host" >> $HOSTS_FILE
	echo -e "\thost_name $FQDN" >> $HOSTS_FILE
	echo -e "\talias $FQDN ($SERVICE)" >> $HOSTS_FILE
	echo -e "\taddress $IPADDR" >> $HOSTS_FILE
	echo -e "\tcheck_command check_$SERVICE" >> $HOSTS_FILE
	echo -e "\tmax_check_attempts 10" >> $HOSTS_FILE
	echo -e "\tactive_checks_enabled 1" >> $HOSTS_FILE
	echo -e "\tflap_detection_enabled 1" >> $HOSTS_FILE
	echo -e "\tnotification_interval 10" >> $HOSTS_FILE
	echo -e "\tnotification_period 24x7" >> $HOSTS_FILE
	echo -e "\tnotification_options d,u,r" >> $HOSTS_FILE
	echo -e "\thostgroups $HOSTGROUP" >> $HOSTS_FILE
	echo -e "\tcontact_groups $CONTACTGROUPS" >> $HOSTS_FILE
	echo -e "}" >> $HOSTS_FILE
        echo -e "\ndefine service {" >> $HOSTS_FILE
        echo -e "\tuse generic-service" >> $HOSTS_FILE
        echo -e "\tis_volatile 0" >> $HOSTS_FILE
        echo -e "\tservice_description $FQDN ($SERVICE)">> $HOSTS_FILE
        echo -e "\tcheck_command check_$SERVICE">> $HOSTS_FILE
        echo -e "\tmax_check_attempts 3" >> $HOSTS_FILE
        echo -e "\tnormal_check_interval 10" >> $HOSTS_FILE
        echo -e "\tretry_check_interval 1" >> $HOSTS_FILE
        echo -e "\tcheck_period 24x7" >> $HOSTS_FILE
        echo -e "\tnotification_interval 120" >> $HOSTS_FILE
        echo -e "\tnotification_period 24x7" >> $HOSTS_FILE
        echo -e "\thost_name $FQDN" >> $HOSTS_FILE
        echo -e "\tnotification_options w,u,c,r" >> $HOSTS_FILE
        echo -e "\tcontact_groups $CONTACTGROUPS" >> $HOSTS_FILE
        echo -e "}" >> $HOSTS_FILE
}

while getopts "hH:g:c:s:" OPTION
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
		s)
			SERVICE=$OPTARG
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

if [ -z $FQDN ] || [ -z $HOSTGROUP ] || [ -z $CONTACTGROUPS ] || [ -z $SERVICE ]; then
	usage
	exit 1
else
	IPADDR=`host $FQDN | cut -f 4 -d " "`
	HOSTS_DIR="/usr/local/nagios/etc/hosts"
	HOSTS_FILE="$HOSTS_DIR"/"$FQDN".cfg
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
