docker run --name=bonita-performance_h2 -h cloud -v ${PWD}/bonita:/opt/bonita/ -v ${PWD}/home:/opt/bonita_home/ -e JAVA_OPTS="-Xms128m -Xmx128m -XX:MaxPermSize=64m" -e "BENCH_ACTIVE=true" -d -p 8081:8080   bonita_65x_test

