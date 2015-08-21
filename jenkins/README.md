Jenkins and Docker-in-Docker
--

This Docker image provides Jenkins CI with Docker in Docker.

It should be used to create CI jobs to build Bonita Docker images.

Quickstart
---

Build the image:

<pre>
$ docker build -t bonitasoft/docker-jenkins:stable .
</pre>

Run the image as a daemon mapping port 8080 and JENKINS_HOME volume:

<pre>
$ docker run --name docker-jenkins --privileged -d -p 8085:8080 -v /path/to/jenkins_home:/var/lib/jenkins bonitasoft/docker-jenkins:stable
</pre>
