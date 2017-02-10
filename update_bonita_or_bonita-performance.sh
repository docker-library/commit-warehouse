#!/bin/bash
if [ "$#" -ne 2 ]; 
then
	echo "Usage : `basename "$0"` x.y.z [community|performance]"
	exit 1
fi
NEW_RELEASE=$1
MINOR=7.4
EDITION=$2
LAST_RELEASE=`grep "^ENV BONITA_VERSION" bonita/${MINOR}/Dockerfile | awk '{ print $3 }'`
BASE_URL="http://repositories.rd.lan/nas/releases/7.x/${MINOR}.x/${NEW_RELEASE}"
TOMCAT_VERSION="7.0.67"

echo "updating $ed"
case $EDITION in
"community")
        BUNDLE="BonitaBPMCommunity-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
	DIR="bonita"
        LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/${MINOR}/Dockerfile | awk '{ print $3 }'`
        wget ${BASE_URL}/BonitaBPMCommunity-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
	;;
"performance")
        BUNDLE="BonitaBPMSubscription-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
        DIR="bonita-performance"
        LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/${MINOR}/Dockerfile | awk '{ print $3 }'`
        wget ${BASE_URL}/BonitaBPMSubscription-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
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
	sed -i "s/^ENV BONITA_VERSION.*/ENV BONITA_VERSION ${NEW_RELEASE}/" ${DIR}/${MINOR}/Dockerfile
	sed -i "s/^ENV BONITA_SHA256.*/ENV BONITA_SHA256 ${SHA256SUM}/" ${DIR}/${MINOR}/Dockerfile
        cp /tmp/${BUNDLE}/setup/database.properties ${DIR}/${MINOR}/templates/database.properties
        cp /tmp/${BUNDLE}/setup/tomcat-templates/setenv.sh ${DIR}/${MINOR}/templates/setenv.sh
        unzip -q -c /tmp/${BUNDLE}/server/webapps/bonita.war WEB-INF/web.xml > ${DIR}/${MINOR}/files/WEB-INF/web.xml
	rm /tmp/${BUNDLE}.zip
	rm -rf /tmp/${BUNDLE}
	meld ${DIR}/${MINOR}.bck ${DIR}/${MINOR}
	echo "if merge is finished, please remove ${DIR}/${MINOR}.bck directory"
