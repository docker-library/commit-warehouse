docker run --name mydbpostgres -e POSTGRES_PASSWORD=mysecretpassword -d ci-01.rd.lan:5000/bonitacloud/postgres_9.3_custom
sleep 30
docker run --name=bonita-performance_psql -h cloud -v ${PWD}/bonita:/opt/bonita/ -v ${PWD}/home:/opt/bonita_home/ -e "BENCH_MODE=true" -d -p 8081:8080  --link mydbpostgres:postgres bonita_65x_test

