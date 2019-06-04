#!/bin/bash
# ensure to set the proper owner of data volume
if [ `stat -c %U /opt/bonita/` != 'bonita' ]
then
	chown -R bonita:bonita /opt/bonita/
fi
# ensure to set the proper owner of data volume
if [ `stat -c %U /opt/bonita_lic/` != 'bonita' ]
then
  chown -R bonita:bonita /opt/bonita_lic/
fi
# ensure to apply the proper configuration
if [ ! -f /opt/${BONITA_VERSION}-configured ]
then
	gosu bonita /opt/files/config.sh \
      && touch /opt/${BONITA_VERSION}-configured || exit 1
fi
if [ -d /opt/custom-init.d/ ]
then
	for f in $(ls -v /opt/custom-init.d/*.sh)
	do
		[ -f "$f" ] && . "$f"
	done
fi
# start cron
cron
# launch tomcat
export LOGGING_CONFIG="-Djava.util.logging.config.file=${BONITA_SERVER_LOGGING_FILE:-/opt/bonita/BonitaSubscription-${BONITA_VERSION}-tomcat/server/conf/logging.properties}"
exec gosu bonita /opt/bonita/BonitaSubscription-${BONITA_VERSION}-tomcat/server/bin/catalina.sh run
