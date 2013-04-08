#!/bin/bash

# v1.0 stuart.moore@gmail.com
#	+ Filesystem checking.
# v1.1 stuart.moore@gmail.com
#	+ added zpools checking.

# TO DO LIST:
# - Convert the echo spam to a function
# - Make all of the host and service variables actual variables in this script
# - Have a disable flag for the agent installation.


usage()
{
        cat << EOF
Usage: $0 options

This script adds a filesystem check into Nagios.

OPTIONS:
	-c Contact Groups (comma delimited)
	-h Show this message
	-H HOST of the host to be added
	-1 ARG1 (filesystem, TCP Port, etc) 
	-t Service Type (Options: filesystem, matml_core, http, ssh, tcp, zpools)
EOF
}

define_service()
{
	echo -e "\ndefine service {" >> $HOSTS_FILE
	echo -e "\tuse generic-service" >> $HOSTS_FILE
	echo -e "\tis_volatile 0" >> $HOSTS_FILE
	if [ "$1" == "filesystem" ]; then
		echo -e "\tservice_description $1: $2" >> $HOSTS_FILE
		echo -e "\tcheck_command check_$1!10%!2%!$2"  >> $HOSTS_FILE
	fi
	if [ "$1" == "zpools" ] || [ "$1" == "http" ] || [ "$1" == "https" ] || [ "$1" == "ssh" ] ; then
		echo -e "\tservice_description $1">> $HOSTS_FILE
		echo -e "\tcheck_command check_$1">> $HOSTS_FILE
	fi
	if [ "$1" == "tcp" ]; then
                echo -e "\tservice_description $1: $2" >> $HOSTS_FILE
                echo -e "\tcheck_command check_$1!$2"  >> $HOSTS_FILE
        fi
	echo -e "\tmax_check_attempts 3" >> $HOSTS_FILE
	echo -e "\tnormal_check_interval 10" >> $HOSTS_FILE
	echo -e "\tretry_check_interval 1" >> $HOSTS_FILE
	echo -e "\tcheck_period 24x7" >> $HOSTS_FILE
	echo -e "\tnotification_interval 120" >> $HOSTS_FILE
	echo -e "\tnotification_period 24x7" >> $HOSTS_FILE
	echo -e "\thost_name $HOST" >> $HOSTS_FILE
	echo -e "\tnotification_options w,u,c,r" >> $HOSTS_FILE
	echo -e "\tcontact_groups $CONTACTGROUPS" >> $HOSTS_FILE
	echo -e "}" >> $HOSTS_FILE
}

while getopts "hH:1:c:t:" OPTION
do
	case $OPTION in
		c)
			CONTACTGROUPS=$OPTARG
			;;
		h)
			usage
			exit 0
			;;
		H)
			HOST=$OPTARG
			;;
		t)
			SERVICE_TYPE=$OPTARG
			;;
		1)
			FILESYSTEM=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $HOST ] || [ -z $CONTACTGROUPS ]; then
	usage
	exit 1
else
	HOSTS_DIR="/usr/local/nagios/etc/hosts"
	HOSTS_FILE="$HOSTS_DIR"/"$HOST".cfg
	if [ ! -e "$HOSTS_FILE" ]; then
		echo Server does not exist at $HOSTS_FILE, run add_hosts.sh first
		exit 1
	else
		define_service $SERVICE_TYPE $FILESYSTEM
		/etc/init.d/nagios reload
	fi
fi

# EOF
