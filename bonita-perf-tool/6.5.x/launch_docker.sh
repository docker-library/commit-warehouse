sudo docker run -p 61616:61616 --env-file ./perf_docker.env --link bonita65x:BONITA -v ${PWD}/results:/opt/results bonita_perf_beta
