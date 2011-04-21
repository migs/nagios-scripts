#!/bin/bash
# Adds a nagios contact

CONTACTS_FILE="/usr/local/nagios/etc/contacts.cfg"
BACKUP_DIR="/usr/local/nagios/etc/.old"
TIMESTAMP=`date "+%Y%m%d-%H%M"`
CONTACT_NAME=$1
CONTACT_ALIAS=$2
CONTACT_EMAIL=$3

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo Usage: $0 [Username] [Alias] [E-Mail address]
	echo -e "\nExample: $0 moores \"Stuart Moore\" stuart.moore@monitisegroup.com"
	exit 1
else
	cp $CONTACTS_FILE $BACKUP_DIR/contacts.cfg.$TIMESTAMP
	echo -e "\ndefine contact{" >> $CONTACTS_FILE
	echo -e "\tcontact_name\t$CONTACT_NAME" >> $CONTACTS_FILE
	echo -e "\talias\t$CONTACT_ALIAS" >> $CONTACTS_FILE
	echo -e "\thost_notification_period\t24x7" >> $CONTACTS_FILE
	echo -e "\tservice_notification_period\t24x7" >> $CONTACTS_FILE
	echo -e "\thost_notification_options\td,u,r" >> $CONTACTS_FILE
	echo -e "\tservice_notification_options\tw,u,c,r" >> $CONTACTS_FILE
	echo -e "\thost_notification_commands\thost-notify-by-email" >> $CONTACTS_FILE
	echo -e "\tservice_notification_commands\tnotify-by-email" >> $CONTACTS_FILE
	echo -e "\temail\t$CONTACT_EMAIL" >> $CONTACTS_FILE
	echo -e "}" >> $CONTACTS_FILE
fi
