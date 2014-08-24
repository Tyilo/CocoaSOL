#import "SOL.h"

@interface SOLArchiver : NSObject

+ (BOOL)writeDictionary:(NSDictionary *)dict toFile:(NSString *)path SOLName:(NSString *)solName encoding:(amf_version_t)amf_version;

@end