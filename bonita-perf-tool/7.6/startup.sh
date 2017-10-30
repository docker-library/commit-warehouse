#!/bin/bash
cd /opt/config
#PERF_BROKER_ADDRESS=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'`:61616
PERF_BROKER_ADDRESS=${PERF_BROKER_ADDRESS:-`ifconfig eth0 | grep 'inet addr:'|cut -d: -f2 | awk '{ print $1}'`:61616}
JAVA_OPTS=${JAVA_OPTS:-"-Xmx2g -Xms1g -Xss256m -XX:PermSize=256m -XX:MaxPermSize=512m"}

if ! [ -z "$BONITA_PORT_8080_TCP_ADDR" ]; then
	echo "youpi"
	PERF_BONITA_URL=http://$BONITA_PORT_8080_TCP_ADDR:8080
fi
export PERF_BROKER_ADDRESS 
export PERF_BONITA_URL
echo "Local broker URL :"${PERF_BROKER_ADDRESS}
echo "Bonita URL :"${PERF_BONITA_URL}
./config.sh
cd /opt/PerfLauncher/bin

BASEDIR=/opt/PerfLauncher

CFG_FOLDER=$BASEDIR/conf

JOPTS="$JOPTS -Djava.util.logging.config.file=$BASEDIR/conf/logging.properties"
JOPTS="$JOPTS -Dlogback.configurationFile=file:$BASEDIR/conf/logback.xml"
JOPTS="$JOPTS -Dconf.folder=$CFG_FOLDER"

java $JAVA_OPTS $JOPTS -cp "$BASEDIR/lib/*" org.bonitasoft.engine.performance.PerfLauncher
