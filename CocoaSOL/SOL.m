#import "SOL.h"
#include <dlfcn.h>

Ivar _object_getInstanceVariable(id obj, const char *name, void **outValue) {
	static Ivar (*func)(id, const char *, void **) = NULL;
	if(!func) {
		func = dlsym(RTLD_DEFAULT, "object_getInstanceVariable");
	}
	
	return func(obj, name, outValue);
}

Ivar _object_getInstanceVariable_id(id obj, const char *name, id *outValue) {
	void *_outValue;
	Ivar ret = _object_getInstanceVariable(obj, name, &_outValue);
	
	*outValue = (__bridge id)_outValue;
	
	return ret;
}

Ivar _object_setInstanceVariable_id(id obj, const char *name, id value) {
	static Ivar (*func)(id, const char *, void *) = NULL;
	if(!func) {
		func = dlsym(RTLD_DEFAULT, "object_setInstanceVariable");
	}
	
	return func(obj, name, (__bridge_retained void *)value);
}