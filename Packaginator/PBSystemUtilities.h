#import <Foundation/Foundation.h>

typedef enum _PBOSVersion
{
    PBOSVersionError=-1,
    PBJaguar=0x1020,
    PBPanther=0x1030,
    PBTiger=0x1040,
	PBLeopard=0x1050,
} PBOSVersion;

@interface PBSystemUtilities : NSObject
{

}

+ (PBOSVersion) systemMajorVersion;

@end
