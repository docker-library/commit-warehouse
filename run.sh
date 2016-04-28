#!/usr/bin/env bash
set -e

#
# Initialization script that wraps the installation, starting and stopping
# of Silverpeas
#

pre_install() {
  dbtype=${DB_SERVERTYPE:-POSTGRESQL}
  dbserver=${DB_SERVER:-localhost}
  dbport=${DB_PORT}
  dbname=${DB_NAME:-Silverpeas}
  dbuser=${DB_USER:-silverpeas}
  dbpassword=${DB_PASSWORD}

  if [ ! "Z${dbpassword}" = "Z" ]; then
    echo "Generate ${SILVERPEAS_HOME}/configuration/config.properties..."
    cat > ${SILVERPEAS_HOME}/configuration/config.properties <<-EOF
DB_SERVERTYPE = $dbtype
DB_SERVER = $dbserver
DB_NAME = $dbname
DB_USER = $dbuser
DB_PASSWORD = $dbpassword
EOF
    test "Z${dbport}" = "Z" || echo "DB_PORT_$dbtype = $dbport" >> ${SILVERPEAS_HOME}/configuration/config.properties
  fi

  #local ip=`ip route show | grep eth0 | grep src  | awk '{print $9}'`
  #sed -ie "s/openoffice.host =/openoffice.host = $ip/g" ${SILVERPEAS_HOME}/properties/org/silverpeas/converter/openoffice.properties
}

start_silverpeas() {
  echo "Start Silverpeas..."
  /opt/ooserver start
  ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -c standalone-full.xml &
  local pids=`jobs -p`
  wait $pids
}

stop_silverpeas() {
  echo "Stop Silverpeas..."
  ./silverpeas stop
  /opt/ooserver stop
  local pids=`jobs -p`
  if [ "Z$pids" != "Z" ]; then
    kill $pids &> /dev/null
  fi
}

trap 'stop_silverpeas' SIGTERM

if [ -f ${SILVERPEAS_HOME}/bin/.install ]; then
  pre_install
  if [ -f ${SILVERPEAS_HOME}/configuration/config.properties ]; then
    echo "First start: set up Silverpeas ..."
    ./silverpeas install && rm ${SILVERPEAS_HOME}/bin/.install
  fi
fi

if [ -f ${SILVERPEAS_HOME}/configuration/config.properties ] && [ ! -e ${SILVERPEAS_HOME}/bin/.install ]; then
  start_silverpeas
else
  echo "No ${SILVERPEAS_HOME}/configuration/config.properties found! No start!"
  exit 1
fi

