# What is Bonita BPM?

Bonita BPM is an open-source business process management and workflow suite created in 2001. It was started in France National Institute for Research in Computer Science, and then had incubated several years inside of the French computer science company Groupe Bull. Since 2009, the development of Bonita is supported by a company dedicated to this activity: Bonitasoft.

> [wikipedia.org/wiki/Bonita_BPM](http://en.wikipedia.org/wiki/Bonita_BPM)

![logo](https://github.com/bonitasoft/docker/blob/master/bonita-performance/7.3/logo.png?raw=true)

# How to use this image

## Quick start

First genereate a request key into a container with a specific hostname (-h):

	docker run --rm --name=bonita -h bonita -ti bonita /bin/bash
	unzip /opt/files/BonitaBPMSubscription-7.2.0-Tomcat-7.0.67.zip
	cd BonitaBPMSubscription-7.2.0-Tomcat-7.0.67/request_key_utils/
	./generateRequestKey.sh
	exit
	
Retrieve the licence from the [customer portal](https://customer.bonitasoft.com) and place it to a directory on your host :	

    mkdir ~/Documents/Docker/Volumes/bonita-performance
    cp ~/Téléchargements/BonitaBPMSubscription-7.2-jeremy_Jacquier-roux-bonita-20160215-20161212.lic ~/Documents/Docker/Volumes/bonita-performance

Then we can launch the Bonita container with the same hostname (-h) and this host directory mounted (-v) :

	docker run --name bonita -h bonita -v ~/Documents/Docker/Volumes/bonita-performance/:/opt/bonita_home/ -d -p 8080:8080 bonita
	
This will start a container running the [Tomcat Bundle](http://documentation.bonitasoft.com/tomcat-bundle-1) with Bonita BPM Engine + Portal. As you didn't sepecify any environment variables it's almost like if you have launched the Bundle on your host using startup.{sh|bat} (with security hardening on REST and HTTP APIs, cf Security part). It means that Bonita BPM uses a H2 database here.

You can access to the portal on http://localhost:8080/bonita and login using the default credentials : install / install

## Link Bonita BPM to a database

### MySQL

	docker run --name mydbmysql -e MYSQL_ROOT_PASSWORD=mysecretpassword -d bonitasoft/mysql
	docker run --name bonita_mysql --link mydbmysql:mysql -h bonita -v ~/Documents/Docker/Volumes/bonita-performance/:/opt/bonita_home/ -d -p 8080:8080 bonita

### PostgreSQL

	docker run --name mydbpostgres -e POSTGRES_PASSWORD=mysecretpassword -d bonitasoft/postgres
	docker run --name bonita_postgres --link mydbpostgres:postgres -h bonita -v ~/Documents/Docker/Volumes/bonita-performance/:/opt/bonita_home/ -d -p 8080:8080 bonita

### Oracle

	docker run --name mydboracle -d alexeiled/docker-oracle-xe-11g
	docker run --name bonita_oracle --link mydboracle:oracle -e DB_ADMIN_PASS=oracle -e DB_NAME=xe -h bonita -v ~/Documents/Docker/Volumes/bonita-performance-7.2/:/opt/bonita_home/ -d -p 8080:8080 bonitasoft/bonita-performance:7.2.1

## Modify default credentials

	docker run --name=bonita -e "TENANT_LOGIN=tech_user" -e "TENANT_PASSWORD=secret" -e "PLATFORM_LOGIN=pfadmin" -e "PLATFORM_PASSWORD=pfsecret" -h bonita -v ~/Documents/Docker/Volumes/bonita-performance/:/opt/bonita_home/ -d -p 8080:8080 bonita

If you do so, you can access to the portal on http://localhost:8080/bonita and login using : tech_user / secret

# Security

This docker image ensures to activate by default both static and dynamic authorization checks on REST API. To be coherent it also deactivates the HTTP API.

 * REST API authorization
    * [Static authorization checking](http://documentation.bonitasoft.com/rest-api-authorization#static)
    * [Dynamic authorization checking](http://documentation.bonitasoft.com/rest-api-authorization#dynamic)
 * [HTTP API](http://documentation.bonitasoft.com/rest-api-authorization#activate)

But for specific needs you can override this behavior by setting HTTP_API to true and REST_API_DYN_AUTH_CHECKS to false :

	docker run  -e HTTP_API=true -e REST_API_DYN_AUTH_CHECKS=false --name bonita -h bonita -v ~/Documents/Docker/Volumes/bonita-performance/:/opt/bonita_home/ -d -p 8080:8080 bonita

# License
Bonita BPM image includes two parts :
 * Bonita BPM Engine under [LGPL v2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
 * Bonita BPM Portal under [GPL v2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a GitHub issue

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

