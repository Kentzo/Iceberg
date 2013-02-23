#import "PBSystemUtilities.h"
#include <Carbon/Carbon.h>

@implementation PBSystemUtilities

+ (PBOSVersion) systemMajorVersion
{
    OSErr tError;
    SInt32 tSystemVersion;
    
    tError=Gestalt(gestaltSystemVersion,&tSystemVersion);
    
    if (tError==noErr)
    {
        return (PBOSVersion) (tSystemVersion & 0x0000FFF0);
    }
    
    return PBOSVersionError;
}

@end
