PERF_REFPATH=${PERF_REFPATH:-/home/guillaume/perf/docker/PerfLauncher}
PERF_MODE=${PERF_MODE:-loadrunner}
PERF_BROKER_ADDRESS=${PERF_BROKER_ADDRESS:-localhost:61616}
PERF_TESTS=${PERF_TESTS:-standardProcess;messageStartProcess;messageSynchronizationProcess}
PERF_BONITAURL=${PERF_BONITA_URL:-http://localhost:8080}
PERF_NB_LAUNCH=${PERF_NB_LAUNCH:-10}
PERF_NB_PARALLEL_LAUNCH=${PERF_NB_PARALLEL_LAUNCH:-10}
PERF_RESULTS_DIRECTORY=${PERF_RESULTS_DIRECTORY:-../results}
PERF_TIMEOUT_INSTANCE=${PERF_TIMEOUT_INSTANCE:-60000}
PERF_TIMEOUT_ACTIVITY=${PERF_TIMEOUT_ACTIVITY:-10000}
mkdir -p ${PERF_REFPATH}/home_save/client/conf/

#prepare tests list
TESTS=
for i in $(echo $PERF_TESTS | tr ";" "\n")
do
#  TESTS=${TESTS}`echo -e "<ref bean=\""$i"\"/>"`'\n'
  TESTS=${TESTS}`echo -e "<ref bean=\""$i"\"/>"`''

done
echo -e "tests :"$TESTS
PERF_TESTS=$TESTS
echo -e "mode :"$PERF_MODE
export PERF_REFPATH PERF_MODE PERF_BROKER_ADDRESS PERF_TESTS PERF_BONITAURL PERF_NB_LAUNCH PERF_NB_PARALLEL_LAUNCH PERF_TIMEOUT_INSTANCE PERF_TIMEOUT_ACTIVITY

pushd template 
TEMPLATES=`find . -type f -exec echo {} \;`
echo $TEMPLATES
popd
for tpl in ${TEMPLATES}
do
 echo ${tpl} - ${PERF_REFPATH}/${tpl}
 envsubst "`cat var`" < template/${tpl} >${PERF_REFPATH}/${tpl}
done



