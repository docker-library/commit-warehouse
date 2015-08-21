FROM jpetazzo/dind 

MAINTAINER Truc Nguyen <truc.nguyen@bonitasoft.com>

#-- as root --#
# Upgrade
RUN apt-get update && apt-get -y upgrade

# Install Jenkins
RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | apt-key add - \
    && echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list \
    && apt-get update \
    && apt-get install -y curl supervisor jenkins

ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_UC https://updates.jenkins-ci.org
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

VOLUME /var/lib/jenkins

EXPOSE 8080

# Upgrade docker
RUN apt-get install -y apt-transport-https \
    && apt-get purge -y lxc-docker \
    && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-engine \
    && usermod -aG docker jenkins

# Clean APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]

# Configure Github SSH
COPY id_rsa /id_rsa
RUN chown jenkins:jenkins /id_rsa
RUN mkdir -p /usr/share/jenkins/ref/.ssh \
    && cp /id_rsa /usr/share/jenkins/ref/.ssh/id_rsa \
    && ssh-keyscan github.com > usr/share/jenkins/ref/.ssh/known_hosts

# Extend Jenkins with plugins
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY plugins.sh /usr/local/bin/plugins.sh
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

