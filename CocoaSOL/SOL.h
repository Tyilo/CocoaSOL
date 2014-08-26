#include <objc/runtime.h>

static const unsigned char sol_magic_1[] = {0x00, 0xBF};
static const unsigned char sol_magic_2[] = {0x54, 0x43, 0x53, 0x4F, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00};

typedef struct __attribute__((packed)) {
	unsigned char magic1[sizeof(sol_magic_1)];
	uint32_t body_length;
	unsigned char magic2[sizeof(sol_magic_2)];
	uint16_t sol_name_length;
} sol_header_t;

typedef uint32_t amf_version_t;

Ivar _object_getInstanceVariable(id obj, const char *name, void **outValue);
Ivar _object_getInstanceVariable_id(id obj, const char *name, id *outValue);
Ivar _object_setInstanceVariable_id(id obj, const char *name, id value);