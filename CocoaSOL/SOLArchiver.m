#import "SOLArchiver.h"
#import "CocoaAMF.h"

@implementation SOLArchiver

+ (BOOL)writeDictionary:(NSDictionary *)dict toFile:(NSString *)path SOLName:(NSString *)solName encoding:(amf_version_t)amf_version {
	NSLog(@"name: %@, %lu, %hu", solName, (unsigned long)[solName length], CFSwapInt16HostToBig([solName length]));
	
	NSMutableData *data = [NSMutableData new];
	
	sol_header_t sol_header;
	
	memcpy(sol_header.magic1, sol_magic_1, sizeof(sol_magic_1));
	memcpy(sol_header.magic2, sol_magic_2, sizeof(sol_magic_2));
	
	sol_header.sol_name_length = CFSwapInt16HostToBig([solName length]);
	
	[data appendBytes:&sol_header length:sizeof(sol_header)];
	[data appendBytes:[solName UTF8String] length:[solName length]];
	
	amf_version_t big_amf_version = CFSwapInt32HostToBig(amf_version);
	[data appendBytes:&big_amf_version length:sizeof(big_amf_version)];
	
	NSLog(@"data1: %@", data);
	
	NSMutableArray *m_stringTable = [NSMutableArray new];
	
	for(NSString *key in dict) {
		id obj = dict[key];
		
		uint8_t name_length = [key length];
		name_length = (name_length << 1) + 1;
		[data appendBytes:&name_length length:sizeof(name_length)];
		
		[data appendBytes:[key UTF8String] length:[key length]];
		
		[m_stringTable addObject:key];
		
		AMFArchiver *archiver = [[AMFArchiver alloc] initForWritingWithMutableData:[NSMutableData new] encoding:kAMF3Encoding];
		
		_object_setInstanceVariable_id(archiver, "m_stringTable", m_stringTable);
		
		[archiver encodeObject:obj];
		
		_object_getInstanceVariable_id(archiver, "m_stringTable", &m_stringTable);
		
		NSData *objData = [archiver data];
		
		NSMutableArray *m_objectTable;
		_object_getInstanceVariable_id(archiver, "m_objectTable", &m_objectTable);
		
		if([m_objectTable count] >= 1) {
			id firstObject = m_objectTable[0];
			if([firstObject isKindOfClass:[ASObject class]]) {
				NSString *m_type;
				_object_getInstanceVariable_id(firstObject, "m_type", &m_type);
				NSRange match = [objData rangeOfData:[m_type dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, [objData length])];
				if(match.location != NSNotFound) {
					NSUInteger start = match.location + match.length;
					objData = [objData subdataWithRange:NSMakeRange(start, [objData length] - start)];
				}
			}
		}
		
		[data appendData:objData];
		
		uint8_t padding = 0x00;
		[data appendBytes:&padding length:sizeof(padding)];
	}
	
	NSLog(@"data2: %@", data);
	
	uint32_t body_length = CFSwapInt32HostToBig((uint32_t)[data length] - offsetof(sol_header_t, magic2));
	[data replaceBytesInRange:NSMakeRange(offsetof(sol_header_t, body_length), sizeof(body_length)) withBytes:&body_length];
	
	NSLog(@"data3: %@", data);
	
	return [data writeToFile:path atomically:YES];
}

@end