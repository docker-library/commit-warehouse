#### OrientDB image for Kubernetes

Project to produce an OrientDB Docker image for Kubertnetes/GKE.

This project uses hazelcast-kubernetes artifact:

https://github.com/hazelcast/hazelcast-kubernetes

and provides a basic config file that uses the Kube service discovery

#### Create the image

mvn clean dependency:copy-dependencies docker:build

the image is tagged as orientdb/orientdb-k8

#### Create cluster

gcloud container clusters create "test-cluster"

#### Creaate the custom image

The docker folder contains the Dockerfile to build a custom image.
There are two folders, one for additional jars and one for configuration.
Check the hazelcast (hazelcast.xml) configuration in config folder if you want/need to change some parameter.

Build the image, tag it and push to the gcr registry:
_NOTE_: use right vales for cluster name and version

```shell

>docker tag orientdb/orientdb-k8 gcr.io/orientdb-test-170714/orientdb-kube:2.2.25
>gcloud docker -- push  gcr.io/orientdb-test-170714/orientdb-kube:2.2.25

```

The "orientdb-test-170714" is the projects's id, tag the image using your own id.

#### Deploy the stateful set

The stateful set contains the definition of containers and volumes as well.
Before staring it, modify the image name using the tag given before.

kubectl create -f orientdb-stateful.yaml

It will start two replica of OrientDB, each with persistence storage, and a service.
OrientDB's studio is accessible pointing your web browser to the service's external ip

```shell
kubectl get svc
NAME               CLUSTER-IP     EXTERNAL-IP     PORT(S)                         AGE
kubernetes         10.7.240.1     <none>          443/TCP                         3m
orientdb-service   10.7.240.175   35.189.82.146   2424:30766/TCP,2480:31677/TCP   46s
```

#### Stop the set

kubectl delete -f orientdb-stateful.yaml

#### Delete the cluster (loose your data)

All data will be lost:

gcloud container clusters delete "test-cluster"

