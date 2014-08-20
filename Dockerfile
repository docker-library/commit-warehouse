############################################################
# Dockerfile to run an OrientDB (Graph) Container
# Based on Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
FROM ubuntu

MAINTAINER Davide Marquês (nesrait@gmail.com)

# Update the default application repository sources list
RUN apt-get update

# Install supervisord
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor

# Install OrientDB
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-orientdb-on-an-ubuntu-12-04-vps
RUN apt-get -y install openjdk-7-jdk git ant
RUN cd
RUN git clone https://github.com/orientechnologies/orientdb.git --single-branch --branch 1.7.8
RUN cd orientdb && ant clean installg
RUN mv /releases/orientdb-community-* /opt/orientdb

# open the image to configuration and storage via volumes
VOLUME /etc/orientdb/config
VOLUME /opt/orientdb/databases
VOLUME /opt/orientdb/backup

# use supervisord to start orientdb
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 2424
EXPOSE 2480

# Set the user to run OrientDB daemon
USER root

# Default command when starting the container
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
