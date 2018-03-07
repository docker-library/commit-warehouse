#!/bin/bash
set -x
# Path to deploy the Tomcat Bundle
BONITA_PATH=${BONITA_PATH:-/opt/bonita}
# Templates directory
BONITA_TPL=${BONITA_TPL:-/opt/templates}
# Files directory
BONITA_FILES=${BONITA_FILES:-/opt/files}
# Flag to allow or not the SQL queries to automatically check and create the databases
ENSURE_DB_CHECK_AND_CREATION=${ENSURE_DB_CHECK_AND_CREATION:-true}
# Java OPTS
JAVA_OPTS=${JAVA_OPTS:--Xms1024m -Xmx1024m -XX:MaxPermSize=256m}
# Flag to enable or not dynamic authorization checking on Bonita REST API
REST_API_DYN_AUTH_CHECKS=${REST_API_DYN_AUTH_CHECKS:-true}
# Flag to enable or not Bonita HTTP API
HTTP_API=${HTTP_API:-false}
# Clustering mode 
CLUSTER_MODE=${CLUSTER_MODE:-false}
BONITA_HOME_COMMON_PATH=${BONITA_HOME_COMMON_PATH:-/opt/bonita_home}

# In order to keep consistency between nodes, the Hibernate cache must be disabled
if [ "${CLUSTER_MODE}" = 'true' ]
then
	USE_SECOND_LEVEL_CACHE='false'
else
	USE_SECOND_LEVEL_CACHE='true'
fi

# retrieve the db parameters from the container linked
if [ -n "$POSTGRES_PORT_5432_TCP_PORT" ]
then
	DB_VENDOR='postgres'
	DB_HOST=$POSTGRES_PORT_5432_TCP_ADDR
	DB_PORT=$POSTGRES_PORT_5432_TCP_PORT
	JDBC_DRIVER=$POSTGRES_JDBC_DRIVER
elif [ -n "$MYSQL_PORT_3306_TCP_PORT" ]
then
	DB_VENDOR='mysql'
	DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
	DB_PORT=$MYSQL_PORT_3306_TCP_PORT
	JDBC_DRIVER=${MYSQL_JDBC_DRIVER}-bin.jar
elif [ -n "$ORACLE_PORT_1521_TCP_PORT" ]
then
	DB_VENDOR='oracle'
	DB_HOST=$ORACLE_PORT_1521_TCP_ADDR
	DB_PORT=$ORACLE_PORT_1521_TCP_PORT
	JDBC_DRIVER=$ORACLE_JDBC_DRIVER
else
	DB_VENDOR=${DB_VENDOR:-h2}
fi

case $DB_VENDOR in
	"postgres")
		JDBC_DRIVER=$POSTGRES_JDBC_DRIVER
		DB_PORT=${DB_PORT:-5432}
		;;
	"mysql")
		JDBC_DRIVER=${MYSQL_JDBC_DRIVER}-bin.jar
		DB_PORT=${DB_PORT:-3306}
		;;
	"oracle")
		JDBC_DRIVER=$ORACLE_JDBC_DRIVER
		DB_PORT=${DB_PORT:-1521}
		# pay attention that for Oracle, DB_NAME is used to store INSTANCE NAME (SID)
		DB_NAME=${DB_NAME:-orcl}
		;;
	*)
		;;
esac
if [ -z "$BIZ_DB_VENDOR" ]
then
	BIZ_DB_VENDOR=${DB_VENDOR}	
fi

# if not enforced, set the default values to configure the databases
DB_NAME=${DB_NAME:-bonitadb}
DB_USER=${DB_USER:-bonitauser}
DB_PASS=${DB_PASS:-bonitapass}
BIZ_DB_NAME=${BIZ_DB_NAME:-businessdb}
BIZ_DB_USER=${BIZ_DB_USER:-businessuser}
BIZ_DB_PASS=${BIZ_DB_PASS:-businesspass}

# if not enforced, set the default credentials
PLATFORM_LOGIN=${PLATFORM_LOGIN:-platformAdmin}
PLATFORM_PASSWORD=${PLATFORM_PASSWORD:-platform}
TENANT_LOGIN=${TENANT_LOGIN:-install}
TENANT_PASSWORD=${TENANT_PASSWORD:-install}
if [ -d ${BONITA_HOME_COMMON_PATH}/engine-server ]; then
	echo "BONITA_HOME directory already exists."
	BONITA_HOME_EXISTS='true'
else
	echo "BONITA_HOME directory is not here. Using the one from Bonita directory."
	BONITA_HOME_EXISTS='false'
fi

if [ ! -d ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION} ]
then
	mkdir -p ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}
fi

if [ ! -d ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bin ]
then
    unzip -q ${BONITA_FILES}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}.zip -d ${BONITA_PATH}
fi

if [ ! -d ${BONITA_PATH}/${BONITA_DBTOOL} ]
then
		unzip -q ${BONITA_FILES}/${BONITA_DBTOOL}.zip -d ${BONITA_PATH}
fi

if [ "${ENSURE_DB_CHECK_AND_CREATION}" = 'true' ]
then
	# load SQL functions
	. ${BONITA_FILES}/functions.sh
	case "${DB_VENDOR}" in
		"postgres")
			DB_ADMIN_USER=${DB_ADMIN_USER:-postgres}
			if [ -z "$DB_ADMIN_PASS" ]
			then
				DB_ADMIN_PASS=$POSTGRES_ENV_POSTGRES_PASSWORD
			fi
			;;
		"mysql")
			DB_ADMIN_USER=${DB_ADMIN_USER:-root}
			if [ -z "$DB_ADMIN_PASS" ]
			then
				DB_ADMIN_PASS=$MYSQL_ENV_MYSQL_ROOT_PASSWORD
			fi
			;;
		"oracle")
			DB_ADMIN_USER=${DB_ADMIN_USER:-sys}
			if [ -z "$DB_ADMIN_PASS" ]
			then
				DB_ADMIN_PASS=$ORACLE_ENV_ORACLE_PASSWORD
			fi
			;;
	esac
	if [ "${DB_VENDOR}" != 'h2' ]
	then
		# ensure to create bonita db and user
		create_user_if_not_exists $DB_VENDOR $DB_HOST $DB_PORT $DB_ADMIN_USER $DB_ADMIN_PASS $DB_USER $DB_PASS
		create_database_if_not_exists $DB_VENDOR $DB_HOST $DB_PORT $DB_ADMIN_USER $DB_ADMIN_PASS $DB_NAME $DB_USER
		# ensure to create business db and user if needed
		create_user_if_not_exists $DB_VENDOR $DB_HOST $DB_PORT $DB_ADMIN_USER $DB_ADMIN_PASS $BIZ_DB_USER $BIZ_DB_PASS
		create_database_if_not_exists $DB_VENDOR $DB_HOST $DB_PORT $DB_ADMIN_USER $DB_ADMIN_PASS $BIZ_DB_NAME $BIZ_DB_USER
	fi
fi

shopt -s nullglob
LicenseNumber=0
for file in ${BONITA_HOME_COMMON_PATH}/*.lic;
do
  LicenseNumber=$(( $LicenseNumber + 1 ))
  echo "Copying licence file $file to Bonita license directory "
  cp $file ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/server/licenses
done

if [ $LicenseNumber -eq 0 ]; then
	echo "Error: no license found"
	exit 1
fi

# apply conf
# copy templates
cp ${BONITA_TPL}/bonita-platform-community-custom.properties ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/platform/bonita-platform-community-custom.properties
cp ${BONITA_TPL}/bonita-tenant-community-custom.properties ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/tenants/template/bonita-tenant-community-custom.properties
cp ${BONITA_TPL}/platform-tenant-config.properties ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/client/platform/conf/platform-tenant-config.properties
cp ${BONITA_TPL}/bonita-platform-sp-custom.properties ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/platform/bonita-platform-sp-custom.properties
cp ${BONITA_TPL}/setenv.sh ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bin/setenv.sh

# if required, uncomment dynamic checks on REST API
if [ "$REST_API_DYN_AUTH_CHECKS" = 'true' ]
then
    sed -i -e 's/^#GET|/GET|/' -e 's/^#POST|/POST|/' -e 's/^#PUT|/PUT|/' -e 's/^#DELETE|/DELETE|/' ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/client/platform/tenant-template/conf/dynamic-permissions-checks.properties
fi
# if required, deactivate HTTP API by updating bonita.war with proper web.xml
if [ "$HTTP_API" = 'false' ]
then
    cd ${BONITA_FILES}/
    zip ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/webapps/bonita.war WEB-INF/web.xml
fi

# replace variables
sed -e 's/{{TENANT_LOGIN}}/'"${TENANT_LOGIN}"'/' \
    -e 's/{{TENANT_PASSWORD}}/'"${TENANT_PASSWORD}"'/' \
    -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/tenants/template/bonita-tenant-community-custom.properties \
       ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/client/platform/conf/platform-tenant-config.properties
sed -e 's/{{PLATFORM_LOGIN}}/'"${PLATFORM_LOGIN}"'/' \
    -e 's/{{PLATFORM_PASSWORD}}/'"${PLATFORM_PASSWORD}"'/' \
    -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/platform/bonita-platform-community-custom.properties
sed -e 's/{{CLUSTER_MODE}}/'"${CLUSTER_MODE}"'/' \
    -e 's/{{USE_SECOND_LEVEL_CACHE}}/'"${USE_SECOND_LEVEL_CACHE}"'/' \
    -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/platform/bonita-platform-sp-custom.properties
sed 's@{{BONITA_HOME_PATH}}@'"${BONITA_HOME_COMMON_PATH}"'@' -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bin/setenv.sh
sed 's/{{DB_VENDOR}}/'"${DB_VENDOR}"'/' -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bin/setenv.sh
sed 's/{{JAVA_OPTS}}/'"${JAVA_OPTS}"'/' -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bin/setenv.sh
sed -e 's/{{BIZ_DB_VENDOR}}/'"${BIZ_DB_VENDOR}"'/' \
    -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/engine-server/conf/tenants/template/bonita-tenant-community-custom.properties
case "${DB_VENDOR}" in
	"mysql"|"postgres"|"oracle")
		cp ${BONITA_TPL}/${DB_VENDOR}/bitronix-resources.properties ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/conf/bitronix-resources.properties
		cp ${BONITA_TPL}/${DB_VENDOR}/bonita.xml ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/conf/Catalina/localhost/bonita.xml
		sed -e 's/{{DB_USER}}/'"${DB_USER}"'/' \
		    -e 's/{{DB_PASS}}/'"${DB_PASS}"'/' \
		    -e 's/{{DB_NAME}}/'"${DB_NAME}"'/' \
		    -e 's/{{DB_HOST}}/'"${DB_HOST}"'/' \
		    -e 's/{{DB_PORT}}/'"${DB_PORT}"'/' \
		    -e 's/{{BIZ_DB_USER}}/'"${BIZ_DB_USER}"'/' \
		    -e 's/{{BIZ_DB_PASS}}/'"${BIZ_DB_PASS}"'/' \
		    -e 's/{{BIZ_DB_NAME}}/'"${BIZ_DB_NAME}"'/' \
		    -i ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/conf/bitronix-resources.properties \
		       ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/conf/Catalina/localhost/bonita.xml

		# if not present, copy JDBC driver into the Bundle
		file=$(basename $JDBC_DRIVER)
		if [ ! -e ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/lib/bonita/$file ]
		then
			cp ${BONITA_FILES}/${JDBC_DRIVER} ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/lib/bonita/
		fi
		;;
esac

# move bonita_home files to configured path if it does not already exist
if [ "$BONITA_HOME_EXISTS" = 'false' ]
then
mv ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita/* ${BONITA_HOME_COMMON_PATH}/
rmdir ${BONITA_PATH}/BonitaBPMSubscription-${BONITA_VERSION}-Tomcat-${TOMCAT_VERSION}/bonita
fi

