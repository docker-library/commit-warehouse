#!/bin/bash
if [ "$#" -ne 2 ]; 
then
	echo "Usage : `basename "$0"` x.y.z [community|performance]"
	exit 1
fi
NEW_RELEASE=$1
EDITION=$2
LAST_RELEASE=`grep "^ENV BONITA_VERSION" bonita/7.2/Dockerfile | awk '{ print $3 }'`
BASE_URL="http://192.168.1.254/qa/releases/7.2.x/${NEW_RELEASE}"
TOMCAT_VERSION="7.0.67"

echo "updating $ed"
case $EDITION in
"community")
        BUNDLE="BonitaBPMCommunity-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
	DIR="bonita"
	LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/7.2/Dockerfile | awk '{ print $3 }'`
	echo "Last release is : $LAST_RELEASE"
	echo "We will update to : $NEW_RELEASE"
	wget ${BASE_URL}/BonitaBPMCommunity-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
	SHA256SUM=`sha256sum /tmp/${BUNDLE}.zip | awk '{ print $1 }'`
	unzip -q /tmp/${BUNDLE}.zip -d /tmp
	if [ -d "${DIR}/7.2.bck" ]
	then
		echo "${DIR}/7.2.bck dir already present, last update seems not terminated, exit"
		exit 1
	fi
	echo "backup current version"
	cp -r ${DIR}/7.2 ${DIR}/7.2.bck
	sed -i "s/^ENV BONITA_VERSION.*/ENV BONITA_VERSION ${NEW_RELEASE}/" ${DIR}/7.2/Dockerfile
	sed -i "s/^ENV BONITA_SHA256.*/ENV BONITA_SHA256 ${SHA256SUM}/" ${DIR}/7.2/Dockerfile
        cp /tmp/${BUNDLE}/bonita/engine-server/conf/platform/bonita-platform-community-custom.properties ${DIR}/7.2/templates/bonita-platform-community-custom.properties
        cp /tmp/${BUNDLE}/bonita/engine-server/conf/tenants/template/bonita-tenant-community-custom.properties ${DIR}/7.2/templates/bonita-tenant-community-custom.properties
        cp /tmp/${BUNDLE}/bonita/client/platform/conf/platform-tenant-config.properties ${DIR}/7.2/templates/platform-tenant-config.properties
        unzip -q -c /tmp/${BUNDLE}/webapps/bonita.war WEB-INF/web.xml > ${DIR}/7.2/files/WEB-INF/web.xml
	rm /tmp/${BUNDLE}.zip
	rm -rf /tmp/${BUNDLE}
	meld ${DIR}/7.2.bck ${DIR}/7.2
	echo "if merge is finished, please remove ${DIR}/7.2.bck directory"
	;;
"performance")
        BUNDLE="BonitaBPMSubscription-${NEW_RELEASE}-Tomcat-${TOMCAT_VERSION}"
        DIR="bonita-performance"
        LAST_RELEASE=`grep "^ENV BONITA_VERSION" ${DIR}/7.2/Dockerfile | awk '{ print $3 }'`
	echo "Last release is : $LAST_RELEASE"
	echo "We will update to : $NEW_RELEASE"
        wget ${BASE_URL}/BonitaBPMSubscription-${NEW_RELEASE}/${BUNDLE}.zip -O /tmp/${BUNDLE}.zip
        SHA256SUM=`sha256sum /tmp/${BUNDLE}.zip | awk '{ print $1 }'`
        unzip -q /tmp/${BUNDLE}.zip -d /tmp
        if [ -d "${DIR}/7.2.bck" ]
        then
                echo "${DIR}/7.2.bck dir already present, last update seems not terminated, exit"
                exit 1
        fi
        echo "backup current version"
        cp -r ${DIR}/7.2 ${DIR}/7.2.bck
        sed -i "s/^ENV BONITA_VERSION.*/ENV BONITA_VERSION ${NEW_RELEASE}/" ${DIR}/7.2/Dockerfile
        sed -i "s/^ENV BONITA_SHA256.*/ENV BONITA_SHA256 ${SHA256SUM}/" ${DIR}/7.2/Dockerfile
        cp /tmp/${BUNDLE}/bonita/engine-server/conf/platform/bonita-platform-community-custom.properties ${DIR}/7.2/templates/bonita-platform-community-custom.properties
        cp /tmp/${BUNDLE}/bonita/engine-server/conf/tenants/template/bonita-tenant-community-custom.properties ${DIR}/7.2/templates/bonita-tenant-community-custom.properties
        cp /tmp/${BUNDLE}/bonita/client/platform/conf/platform-tenant-config.properties ${DIR}/7.2/templates/platform-tenant-config.properties
	cp /tmp/${BUNDLE}/bonita/engine-server/conf/platform/bonita-platform-sp-custom.properties ${DIR}/7.2/templates/bonita-platform-sp-custom.properties
        unzip -q -c /tmp/${BUNDLE}/webapps/bonita.war WEB-INF/web.xml > ${DIR}/7.2/files/WEB-INF/web.xml
        rm /tmp/${BUNDLE}.zip
        rm -rf /tmp/${BUNDLE}
        meld ${DIR}/7.2.bck ${DIR}/7.2
        echo "if merge is finished, please remove ${DIR}/7.2.bck directory"
	;;
esac
