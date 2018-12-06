#!/bin/bash

set -euxo pipefail

if [ "$#" -ne 2 ]; 
then
	echo "Usage : `basename "$0"` x.y.z [community|subscription]"
	exit 1
fi
NEW_RELEASE=$1
MINOR=$(echo $NEW_RELEASE | cut -d"." -f1-2)
EDITION=$2
LAST_RELEASE=`grep "^ENV BONITA_VERSION" bonita/${MINOR}/Dockerfile | awk '{ print $3 }'`
BASE_URL="http://repositories.rd.lan/nas/releases/bonita_platform/7.x/${MINOR}.x/${NEW_RELEASE}"
TOMCAT_VERSION="8.5.34"

echo "updating $EDITION"
case $EDITION in
"community")
        BUNDLE="BonitaCommunity-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
	DIR="bonita"
        LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/${MINOR}/Dockerfile | awk '{ print $3 }'`
        wget ${BASE_URL}/BonitaCommunity-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
	;;
"subscription")
        BUNDLE="BonitaSubscription-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
        DIR="bonita-subscription"
        LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/${MINOR}/Dockerfile | awk '{ print $3 }'`
        wget ${BASE_URL}/BonitaSubscription-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
        ;;
esac

	echo "Last release is : $LAST_RELEASE"
	echo "We will update to : $NEW_RELEASE"
	SHA256SUM=`sha256sum /tmp/${BUNDLE}.zip | awk '{ print $1 }'`
	unzip -q /tmp/${BUNDLE}.zip -d /tmp
	if [ -d "${DIR}/${MINOR}.bck" ]
	then
		echo "${DIR}/${MINOR}.bck dir already present, last update seems not terminated, exit"
		exit 1
	fi
	echo "backup current version"
	cp -r ${DIR}/${MINOR} ${DIR}/${MINOR}.bck
	sed -i "s/^ENV BONITA_VERSION \${BONITA_VERSION:-.*/ENV BONITA_VERSION \${BONITA_VERSION:-${NEW_RELEASE}}/" ${DIR}/${MINOR}/Dockerfile
	sed -i "s/^ENV BONITA_SHA256  \${BONITA_SHA256:-.*/ENV BONITA_SHA256  \${BONITA_SHA256:-${SHA256SUM}}/" ${DIR}/${MINOR}/Dockerfile
        cp /tmp/${BUNDLE}/setup/database.properties ${DIR}/${MINOR}/templates/database.properties
        cp /tmp/${BUNDLE}/setup/tomcat-templates/setenv.sh ${DIR}/${MINOR}/templates/setenv.sh
        unzip -q -c /tmp/${BUNDLE}/server/webapps/bonita.war WEB-INF/web.xml > ${DIR}/${MINOR}/files/WEB-INF/web.xml
	rm /tmp/${BUNDLE}.zip
	rm -rf /tmp/${BUNDLE}
	git difftool ${DIR}/${MINOR}.bck ${DIR}/${MINOR}
	echo "if merge is finished, please remove ${DIR}/${MINOR}.bck directory"
