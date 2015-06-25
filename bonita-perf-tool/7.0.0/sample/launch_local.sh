sudo docker run -p 61616:61616 --env-file ./perf_local.env -v ${PWD}/results:/opt/results bonita_perf_beta
