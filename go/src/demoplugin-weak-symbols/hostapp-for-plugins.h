//This symbol should be weak only in the shared library which serves
//as plugin. So we need a different header file (or some macros or stuff)
//to ensure, only the plugin sees the __attribute__((weak)) and not
//the host app.
//
//If the host app would mark that symbol as weak, some malicious plugin
//could overwrite the function in the entire host app, just by declaring
//it a strong symbol and providing a definition. It could get different
//plugins to execute its version of the function.
//
//Maybe that point is moot, as all the plugins will share a single
//address space. Dunno if there is a effective protection from
//a malicious plugin/shared library.
void func_for_go_plugin_to_find_at_dlopen_time(void) __attribute__((weak));
