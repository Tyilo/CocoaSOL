#import "SOLUnarchiver.h"
#import "CocoaAMF.h"

@implementation SOLUnarchiver

- (id)init {
	if(self = [super init]) {
		self->data = nil;
		self->dataRead = 0;
	}
	
	return self;
}

+ (NSDictionary *)dictionaryFromFile:(NSString *)path SOLName:(NSString **)solName {
	SOLUnarchiver *instance = [[self alloc] init];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	instance->data = data;
	
	if(!data) {
		return nil;
	}
	
	sol_header_t sol_header;
	if(![instance readBytes:&sol_header length:sizeof(sol_header)]) {
		NSLog(@"File too small to be a SOL file!");
		return nil;
	}
	
	if(memcmp(sol_header.magic1, sol_magic_1, sizeof(sol_magic_1)) != 0) {
		NSLog(@"First SOL magic doesn't match!");
		return nil;
	}
	
	if(memcmp(sol_header.magic2, sol_magic_2, sizeof(sol_magic_2)) != 0) {
		NSLog(@"Second SOL magic doesn't match!");
		return nil;
	}
	
	if([data length] != CFSwapInt32BigToHost(sol_header.body_length) + offsetof(sol_header_t, magic2)) {
		NSLog(@"File size doesn't match body length in header!");
		return nil;
	}
	
	uint16_t sol_name_length = CFSwapInt16BigToHost(sol_header.sol_name_length);
	
	char *bytes = malloc(sol_name_length + 1);
	bytes[sol_name_length] = '\0';
	
	if(![instance readBytes:bytes length:sol_name_length]) {
		NSLog(@"File size too small to fit file name!");
		
		free(bytes);
		return nil;
	}
	
	NSString *_solName = [NSString stringWithUTF8String:bytes];
	
	if(solName) {
		*solName = _solName;
	}
	
	free(bytes);
	
	amf_version_t big_amf_version;
	if(![instance readBytes:&big_amf_version length:sizeof(big_amf_version)]) {
		NSLog(@"File size too small to fit amf version!");
		return nil;
	}
	
	amf_version_t amf_version = CFSwapInt32BigToHost(big_amf_version);
	
	if(amf_version != kAMF0Encoding && amf_version != kAMF3Encoding) {
		NSLog(@"Unknown AMF version!");
		return nil;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary new];
	
	NSMutableArray *m_stringTable = [NSMutableArray new];
	if(amf_version == kAMF3Encoding) {
		[m_stringTable addObject:_solName];
	}
	
	while(instance->dataRead < [data length]) {
		uint8_t name_length;
		if(![instance readBytes:&name_length length:sizeof(name_length)]) {
			NSLog(@"Failed to read name length!");
			return nil;
		}
		
		name_length >>= 1;
		
		char *name = malloc(name_length + 1);
		name[name_length] = '\0';
		
		if(![instance readBytes:name length:name_length]) {
			NSLog(@"Failed to read name!");
			
			free(name);
			return nil;
		}
		
		NSString *key = [NSString stringWithUTF8String:name];
		free(name);
		
		NSData *remainingData = [data subdataWithRange:NSMakeRange(instance->dataRead, [data length] - instance->dataRead)];
		
		AMFUnarchiver *unarchiver = [[AMFUnarchiver alloc] initForReadingWithData:remainingData encoding:amf_version];
		
		_object_setInstanceVariable_id(unarchiver, "m_stringTable", m_stringTable);
		
		id obj = [unarchiver decodeObject];
		
		dict[key] = obj;
		
		_object_getInstanceVariable_id(unarchiver, "m_stringTable", &m_stringTable);
		
		uint32_t m_position;
		_object_getInstanceVariable(unarchiver, "m_position", (void **)&m_position);
		instance->dataRead += m_position;
		
		uint8_t padding;
		[instance readBytes:&padding length:sizeof(padding)];
	}
	
	return dict;
}

- (BOOL)readBytes:(void *)buffer length:(NSUInteger)length {
	if(!self->data) {
		return NO;
	}
	
	if([data length] < self->dataRead + length) {
		return NO;
	}
	
	[data getBytes:buffer range:NSMakeRange(self->dataRead, length)];
	self->dataRead += length;
	
	return YES;
}

@end