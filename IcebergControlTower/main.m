/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
    +----------+-------------+---------------------------------------------------------+
    |   Date   |    Author   | Comments                                                |
    +----------+-------------+---------------------------------------------------------+
    | 03/15/01 |   S.Sudre   | Creation                                                |
    +----------+-------------+---------------------------------------------------------+
    | 03/24/04 |   S.Sudre   | New: Support for the "Scratch Path" option              |
	+----------+-------------+---------------------------------------------------------+
    | 06/02/06 |   S.Sudre   | New: Support for the "SplitForks Tool" option           |
    +----------+-------------+---------------------------------------------------------+
    |          |             |                                                         |
    +----------+-------------+---------------------------------------------------------+
*/

#import <Foundation/Foundation.h>

static NSString * sProcessPath;

CFDataRef CallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info);

CFDataRef CallBack(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (data)
    {
        NSTask * tBuildTask;
        NSMutableArray *args = [NSMutableArray array];
        NSDictionary * tDictionary;
        CFStringRef tErrorString;
        
        tDictionary=(NSDictionary *) CFPropertyListCreateFromXMLData(kCFAllocatorDefault,data,kCFPropertyListImmutable,&tErrorString);
        
        if (tDictionary!=nil)
        {
            NSString * tScratchPath;
            NSString * tToolName;
			
            tBuildTask=[NSTask new];
            
            [args addObject:[tDictionary objectForKey:@"Project Path"]];		// Project Path
            
            [args addObject:[[tDictionary objectForKey:@"User ID"] stringValue]];	// User ID
            
            [args addObject:[[tDictionary objectForKey:@"Group ID"] stringValue]];	// Group ID
            
            [args addObject:[[tDictionary objectForKey:@"Process ID"] stringValue]];	// Process ID
            
            [args addObject:[tDictionary objectForKey:@"Notification Path"]];		// Notification Path
			
			tToolName=[tDictionary objectForKey:@"SplitForks Tool"];
			
			if (tToolName!=nil)
			{
				[args addObject:tToolName];		// Tool to use to split forks
            }
			
            tScratchPath=[tDictionary objectForKey:@"Scratch Path"];
            
            if (tScratchPath!=nil)
            {
                [args addObject:tScratchPath];						// Scratch Path
            }
            
            [tBuildTask setLaunchPath:[sProcessPath stringByAppendingPathComponent:@"IcebergBuilder"]];
            [tBuildTask setArguments:args];
            
            [tBuildTask launch];
            
            [tDictionary release];
        }
        else
        {
            // Release Memory
            
            CFRelease(tErrorString);
        }
    }
    
    [pool release];
    
    return NULL;
}

int main (int argc, const char * argv[])
{
    NSRunLoop * mainRunLoop;
    CFMessagePortRef myLocalMessagePort;
    CFRunLoopSourceRef myRunLoopSource;
    Boolean shouldFreeInfo=FALSE;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    
    sProcessPath=[[[NSString stringWithCString:argv[0]] stringByDeletingLastPathComponent] retain];
    
    mainRunLoop=[NSRunLoop currentRunLoop];
    
    // Add the MessagePort Listener
    
    myLocalMessagePort =CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR("ICEBERGCONTROLTOWER"),CallBack, NULL, &shouldFreeInfo);
    
    if (myLocalMessagePort!=NULL)
    {
        myRunLoopSource =CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, myLocalMessagePort,0);
        
        if (myRunLoopSource!=NULL)
        {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), myRunLoopSource,kCFRunLoopDefaultMode);
        }
    }
    
    [mainRunLoop run];
    
    [pool release];
    
    return 0;
}
