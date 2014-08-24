#import "SOL.h"

@interface SOLUnarchiver : NSObject {
	NSData *data;
	NSUInteger dataRead;
}

+ (NSDictionary *)dictionaryFromFile:(NSString *)path SOLName:(NSString **)solName;

@end