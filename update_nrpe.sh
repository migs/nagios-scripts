#!/bin/bash

# v1.0 stuart.moore@monitisegroup.com
#	+ Pushes NRPE to the defined host.

usage()
{
        cat << EOF
Usage: $0 options

This script adds a host into Nagios.

OPTIONS:
	-h Show this message
	-H FQDN of the host to be added
EOF
}

while getopts "hH:g:c:" OPTION
do
	case $OPTION in
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

if [ -z $FQDN ]; then
	usage
	exit 1
else
	HOST_OS=`ssh -l root $FQDN uname`
	HOST_PLATFORM=`ssh -l root $FQDN uname -i`
	ZONENAME='ssh -l root $FQDN zonename'
	scp /usr/local/nagios/scripts/nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz root@$FQDN:/opt
	ssh root@$FQDN "rm /etc/init.d/nrpe"
	ssh root@$FQDN "cd /opt ; gunzip nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz; tar xf nrpe.$HOST_OS.$HOST_PLATFORM.tar ; cd nrpe ; ./nrpe.install ; cd .. ; rm nrpe.$HOST_OS.$HOST_PLATFORM.tar"
	ssh root@$FQDN "pkill -z $ZONENAME nrpe"
	ssh root@$FQDN "/etc/init.d/nrpe start"
	/etc/init.d/nagios reload
fi

# EOF

