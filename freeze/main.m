/*
Copyright (c) 2004-2006, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "PBBuildObserver.h"

#include <sys/types.h>
#include <unistd.h>


void usage(void);
int buildToOrder(NSString * inPath,NSString * inScratchPath);

void usage(void)
{
    (void)fprintf(stderr, "%s\n","usage: freeze [-v] [-d <scratch folder>] "
                          " file ...");
    
    exit(1);
}

int buildToOrder(NSString * inPath,NSString * inScratchPath)
{
    CFMessagePortRef tRemote;
    
    tRemote=CFMessagePortCreateRemote(NULL,CFSTR("ICEBERGCONTROLTOWER"));

    if (tRemote!=NULL)
    {
        CFDataRef tDataRef;
        NSDictionary * tDictionary;
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:inPath,@"Project Path",
                                                               inPath,@"Notification Path",
                                                               [NSNumber numberWithInt:geteuid()],@"User ID",
                                                               [NSNumber numberWithInt:getegid()],@"Group ID",
                                                               [NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]],@"Process ID",
                                                               inScratchPath,@"Scratch Path",	// Don't forget: inScratchPath can be nil
                                                               nil];
        
        
        if (tDictionary!=nil)
        {
            tDataRef=CFPropertyListCreateXMLData(kCFAllocatorDefault,(CFPropertyListRef) tDictionary);
        
            if (tDataRef!=NULL)
            {
                if (CFMessagePortSendRequest(tRemote,0,tDataRef, 20, 10, kCFRunLoopDefaultMode, NULL)!=kCFMessagePortSuccess)
                {
                    return -1;
                }
                
                // Release Memory
                
                CFRelease(tDataRef);
            }
        }
        
        // Release memory
        
        CFRelease(tRemote);
    }
    else
    {
        (void)fprintf(stderr, "The Iceberg Control Tower is not responding. Iceberg can't build any project when this Daemon is not running.\n");
        
        return -1;
    }
    
    return 0;
}

#pragma mark -

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int ch;
    BOOL tVerbose=NO;
    char * tCScratchPath=NULL;
    
    // Check the parameters
    
    while ((ch = getopt(argc,(char **) argv,"v?d:")) != -1)
    {
        switch(ch)
        {
            case 'd':
                tCScratchPath=optarg;
                break;
            case 'v':
                tVerbose=YES;
                break;
            case '?':
            default:
                usage();
        }
    }
    
    argv+=optind;
    argc-=optind;
    
    if (argc < 1)
    {
        usage();
    }
    else
    {
        PBBuildObserver * nBuildObserver;
        NSString * tProjectPath;
        NSFileManager * tFileManager;
        NSString * tCurrentDirectory;
        NSString * tScratchPath=nil;
        
        tFileManager=[NSFileManager defaultManager];
        
        tCurrentDirectory=[tFileManager currentDirectoryPath];
        
        if (tCScratchPath!=NULL)
        {
            tScratchPath=[[NSString stringWithUTF8String:tCScratchPath] stringByStandardizingPath];
        
            if ([tScratchPath characterAtIndex:0]!='/')
            {
                tScratchPath=[tCurrentDirectory stringByAppendingPathComponent:tScratchPath];
            }
            
            if ([tFileManager fileExistsAtPath:tScratchPath]==NO)
            {
                tScratchPath=nil;
            }
        }
        
        tProjectPath=[[NSString stringWithUTF8String:argv[0]] stringByStandardizingPath];
        
        if ([tProjectPath characterAtIndex:0]!='/')
        {
            tProjectPath=[tCurrentDirectory stringByAppendingPathComponent:tProjectPath];
        }
        
        if ([tFileManager fileExistsAtPath:tProjectPath]==YES)
        {
            // Install the Notification Observer
    
            nBuildObserver=[PBBuildObserver new];
            
            [nBuildObserver setVerbose:tVerbose];
            
            [[NSDistributedNotificationCenter defaultCenter] addObserver:nBuildObserver
                                                                selector:@selector(processBuildNotification:)
                                                                    name:@"ICEBERGBUILDERNOTIFICATION"
                                                                object:nil
                                                    suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
            
            // Send the build message
            
            if (buildToOrder(tProjectPath,tScratchPath)!=0)
            {
                return 1;
            }
            
            // Run the loop
            
            [[NSRunLoop currentRunLoop] run];
        }
        else
        {
            (void)fprintf(stderr, "freeze: %s: No such file or directory\n",argv[0]);
            
            return 1;
        }
    }
    
    [pool release];
    
    return 0;
}
