#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mosquitto.h>

/* mosquitto_connect_async() test, with mosquitto_loop_start() called before mosquitto_connect_async(). */

static int run = -1;
static bool should_run = true;

void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
	if(rc){
		exit(1);
	}else{
		mosquitto_subscribe(mosq, NULL, "qos1/test", 1);
	}
}

void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
	run = rc;
}

void on_subscribe(struct mosquitto *mosq, void *obj, int mid, int qos_count, const int *granted_qos)
{
	//mosquitto_disconnect(mosq);
	should_run = false;
}

int main(int argc, char *argv[])
{
	int rc;
	struct mosquitto *mosq;

	int port = atoi(argv[1]);

	mosquitto_lib_init();

	mosq = mosquitto_new("subscribe-qos1-test", true, NULL);
	mosquitto_connect_callback_set(mosq, on_connect);
	mosquitto_disconnect_callback_set(mosq, on_disconnect);
	mosquitto_subscribe_callback_set(mosq, on_subscribe);
	printf("ok, about to call connect_async\n");

	// this only works if loop_start is first.  with loop_start second,
	// it fails on both 1.6.4 _and_ 1.6.5
	// in this order, 1.6.4 works and 1.6.5 fails.
	rc = mosquitto_loop_start(mosq);
	printf("loop_start returned rc: %d\n", rc);
	if (rc) {
		printf("which is: %s\n", mosquitto_strerror(rc));
	}
	
	// not sure which rc you want to be returned....
	rc = mosquitto_connect_async(mosq, "localhost", port, 60);
	printf("connect async returned rc: %d\n", rc);
	if (rc) {
		printf("which is: %s\n", mosquitto_strerror(rc));
	}

	printf("ok, so we can start just waiting now, loop_start will run in it's thread\n");
	/* 10 millis to be system polite */
	//struct timespec tv = { 0, 10e6 };
	struct timespec tv = { 1, 0 };
	while(should_run){
		nanosleep(&tv, NULL);
		printf("...waiting...\n");
	}
	printf("Already exited should_run....\n");

	mosquitto_disconnect(mosq);
	mosquitto_loop_stop(mosq, false);

	mosquitto_lib_cleanup();
	return run;
}
