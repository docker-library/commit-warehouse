#!/bin/bash

set -x

while getopts l:h:s:j: opt
do
   case $opt in
       l) JDK_LOCATION=$OPTARG;;
       h) JT_HOME=$OPTARG;;
       j) TEST_JDK=$OPTARG;;
       s) TEST_SUITE=$OPTARG;;
   esac
done

shift $((OPTIND-1))
TEST_GROUPS=$@

if [ -z "$TEST_JDK" ]; then
    TEST_JDK=${JDK_LOCATION}/build/linux-x86_64-normal-server-release/images/jdk
fi

if [ -z "$JDK_LOCATION" ]; then
    echo "JDK Location not specified (-l)" >&2
    exit 1
fi

if [ -z "$JT_HOME" ]; then
    echo "JavaTest Home not specified (-h)" >&2
    exit 1
fi

if [ -z "$TEST_JDK" ]; then
    echo "Test JDK not specified (-j)" >&2
    exit 1
fi

if [ -z "$TEST_SUITE" ]; then
    echo "Test Suite not specified (-s)" >&2
    exit 1
fi

if [ -z "$TEST_GROUPS" ]; then
    echo "Test Groups not specified" >&2
    exit 1
fi

TEST_NATIVE_LIB=${JDK_LOCATION}/build/linux-x86_64-normal-server-release/images/test/${TEST_SUITE}/jtreg/native
NUM_CPUS=`grep -c ^processor /proc/cpuinfo`
CONCURRENCY=`expr $NUM_CPUS / 2`
MAX_RAM_PERCENTAGE=`expr 25 / $CONCURRENCY`
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

chmod +x ${JT_HOME}/bin/jtreg

if [ "${TEST_SUITE}" == "hotspot" ]; then
    patch ${JDK_LOCATION}/test/hotspot/jtreg/applications/scimark/Scimark.java < ${SCRIPT_DIR}/Scimark.java.patch

    ${JT_HOME}/bin/jtreg -dir:${JDK_LOCATION}/test/${TEST_SUITE}/jtreg -verbose:summary -nativepath:${TEST_NATIVE_LIB} \
     -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/jtreg/ProblemList.txt -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/jtreg/ProblemList-SapMachine.txt \
     -conc:${CONCURRENCY} -vmoption:-XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE} \
     -a -ignore:quiet -timeoutFactor:5 -agentvm -javaoption:-Djava.awt.headless=true "-k:(!ignore)&(!stress)" -testjdk:${TEST_JDK} ${TEST_GROUPS}
fi

if [ "${TEST_SUITE}" == "jdk" ]; then
    ${JT_HOME}/bin/jtreg -dir:${JDK_LOCATION}/test/${TEST_SUITE} -verbose:summary -nativepath:${TEST_NATIVE_LIB} \
    -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/ProblemList.txt -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/ProblemList-SapMachine.txt  \
    -conc:${CONCURRENCY} -vmoption:-XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE} \
    -a -ignore:quiet -timeoutFactor:5 -agentvm -javaoption:-Djava.awt.headless=true "-k:(!headful)&(!printer)" -testjdk:${TEST_JDK} ${TEST_GROUPS}
fi

if [ "${TEST_SUITE}" == "langtools" ]; then
    ${JT_HOME}/bin/jtreg -dir:${JDK_LOCATION}/test/${TEST_SUITE} -verbose:summary \
    -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/ProblemList.txt -exclude:${JDK_LOCATION}/test/${TEST_SUITE}/ProblemList-SapMachine.txt \
    -conc:${CONCURRENCY} -vmoption:-XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE} \
    -a -ignore:quiet -timeoutFactor:5 -agentvm -testjdk:${TEST_JDK} ${TEST_GROUPS}
fi
