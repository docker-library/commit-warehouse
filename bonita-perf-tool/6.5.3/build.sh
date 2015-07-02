PERF_TOOL_ARCHIVE_FILE=PerfLauncher-bonitaBPM6-community-server-6.5.3-1.0-SNAPSHOT-postgres.zip
wget -q http://192.168.1.254/qa/releases/performance_tools/6.5.3/${PERF_TOOL_ARCHIVE_FILE} -O bin/${PERF_TOOL_ARCHIVE_FILE}
sudo docker build -t bonita_bench_6.5.3  .

