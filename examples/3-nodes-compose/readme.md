# Purpose

This folder contains a Docker compose file that runs three OrientDB nodes in an HA configuration.
Configuration of each node is stored inside the *var* directory.
The cluster is configured with a write quorum of 1 and a read quorum of 1.

It would be quite easy to extend it to more nodes and to modify the clustering configuration.

# Usage

Take a look at the compose file and at the var folder.

Use *docker-compose*  to run the three node cluster

```shell
docker-compose -f ./compose.yml up
```

Point a browser to localhost:2480, the OrientDB studio webapp of the first node is exposed.
From the web console you can create a new database using server credentials (root/root) or import one.

## Create a new database

After the new database is created, it will be replicated to the other nodes.

```shell
docker-compose -f ./compose.yml stop
docker-compose -f ./compose.yml start
```


