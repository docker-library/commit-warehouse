# Purpose

This folder contains a Docker compose file that runs two OrientDB nodes in HA configutation.
Configuration of each nodes is stored inside the *var* directory.
The cluster is configured with a write quorum of 1 and a read quorum of 1.

It would be quite easy to extend it to more nodes and to modify the clustering configuration.

# Usage

Take a look to the compose file and to the var folder.

Use *docker-compose*  to run the two nodes cluster

```shell
docker-compose -f ./compose.yml up
```

Point a browser to localhost:2480, the OrientDB studio webapp of the first node is exposed.
From the web console you can create a new database using server credentials (root/root) or import one.

## Create a new database

After the new database is created, it will be replicated to the second node.

## Import a databse from the web

Importing a database doesn't involve the replica system. To enable replication, restart the cluster

```shell
docker-compose -f ./compose.yml stop
docker-compose -f ./compose.yml start
```

The imported database will be replicated as wel as each operation on it.


