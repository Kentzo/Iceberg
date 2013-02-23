#import "PBProjectRemoverErrorHandler.h"
#include <sys/stat.h>
#include <unistd.h>

@implementation PBProjectRemoverErrorHandler

+ (id) sharedRemoverErrorHandler
{
    static PBProjectRemoverErrorHandler * sRemoverErrorHandler=nil;
    
    if (sRemoverErrorHandler==nil)
    {
        sRemoverErrorHandler=[PBProjectRemoverErrorHandler new];
    }
    
    return sRemoverErrorHandler;
}

- (BOOL) fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
    const char * tFilePath;
    struct stat tStat;
    int tError;
    
    tFilePath=[[errorInfo objectForKey:@"Path"] fileSystemRepresentation];
    
    tError=lstat(tFilePath, &tStat);
    
    if (tError==0 && tStat.st_flags!=0)
    {
        if (chflags(tFilePath,0)==0)
        {
            if (unlink(tFilePath)==0)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
