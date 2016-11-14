#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include "hostapp.h"

typedef void (*plugged_in_func_t)(void);

static void check_dl_error(void * value) {
	if (value == NULL) {
		fprintf(stderr, "dlopen/dlsym/dlclose error: %s\n", dlerror());
		fflush(stderr);
		exit(1);
	}
}

int main(int argc, char * argv[]) {
	const char * pluginname = "./plugin";
	if (argc > 1) {
		pluginname = argv[1];
	}
	void * plugin_handle = dlopen(pluginname, RTLD_LAZY);
	check_dl_error(plugin_handle);
	plugged_in_func_t plugged_in_func = dlsym(plugin_handle, "GoFunction");
	check_dl_error(plugin_handle);
	plugged_in_func();
	if (dlclose(plugin_handle) != 0) {
		check_dl_error(NULL);
	}
	return 0;
}

void func_for_go_plugin_to_find_at_dlopen_time(void) {
	fprintf(stdout, "Hello from C called from go through a plugin!\n");
	fflush(stdout);
}
