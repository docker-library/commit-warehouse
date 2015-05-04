docker run --name mydbpostgres -e POSTGRES_PASSWORD=mysecretpassword -d ci-01.rd.lan:5000/bonitacloud/postgres_9.3_custom
sleep 30
docker run --name=bonita-performance_psql -h cloud -v ${PWD}/bonita:/opt/bonita/ -v ${PWD}/home:/opt/bonita_home/ -e "BENCH_MODE=true" -d -p 8081:8080  --link mydbpostgres:postgres bonita_65x_test
#sleep 60
#docker run --name=bonita-performance_psql2 -h cloud -v /home/guillaume/svn/cloud/docker/trunk/bonita-performance/6.5.x/sample/home:/opt/bonita_home/ -d -p 8082:8080  --link mydbpostgres:postgres bonita_65x_test
#sleep 5
#docker run --name=bonita-performance_psql3 -h cloud -v /home/guillaume/svn/cloud/docker/trunk/bonita-performance/6.5.x/sample/home:/opt/bonita_home/ -d -p 8083:8080  --link mydbpostgres:postgres bonita_65x_test

