#!/bin/bash

# v1.0 stuart.moore@monitisegroup.com
#	+ Pushes NRPE to the defined host.
# v1.1 stuart.moore@monitisegroup.com
#      + NRPE restart method changed depending upon client OS. This is only temporary until "/etc/init.d/nrpe stop" is fixed

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

while getopts "hH:" OPTION
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
#
# FIXME! - The below command runs 3 ssh commands, when one will do. Time to learn proper string parsing ...
#
	HOST_OS=`ssh -l root $FQDN uname`
	HOST_PLATFORM=`ssh -l root $FQDN uname -i`
	ZONENAME='ssh -l root $FQDN zonename'
	scp /usr/local/nagios/scripts/nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz root@$FQDN:/opt
	ssh root@$FQDN "rm /etc/init.d/nrpe"
	ssh root@$FQDN "cd /opt ; gunzip nrpe.$HOST_OS.$HOST_PLATFORM.tar.gz; tar xf nrpe.$HOST_OS.$HOST_PLATFORM.tar ; cd nrpe ; ./nrpe.install ; cd .. ; rm nrpe.$HOST_OS.$HOST_PLATFORM.tar"

case $HOST_OS in
  SunOS)
    ssh root@$FQDN "pkill -z $ZONENAME nrpe"
    ;;
  Linux)
    ssh root@$FQDN "killall nrpe"
    ;;
  *)
    echo -e "Unknown OS, unable to safely stop NRPE. Carrying on anyway ...
    ;;
esac
	/etc/init.d/nagios reload
fi

# EOF

