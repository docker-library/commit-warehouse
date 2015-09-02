PERF_TOOL_ARCHIVE_FILE=PerfLauncher-bonitaBPM6-community-server-7.0.0-1.0-SNAPSHOT-postgres.zip
wget -q http://192.168.1.254/qa/releases/performance_tools/7.0.0/${PERF_TOOL_ARCHIVE_FILE} -O bin/${PERF_TOOL_ARCHIVE_FILE}
docker build -t bonitasoft/perf-tool:7.0.0 .

