/*
Copyright (c) 2004, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "PBProjectBuilder.h"

#include <unistd.h>
#include <sys/types.h>

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    /*int i;
    
    for(i=0;i<argc;i++)
    {
        [[NSString stringWithUTF8String:argv[i]] writeToFile:[NSString stringWithFormat:@"/tmp/t%d",i] atomically:YES];
    }*/
    
    if (argc>=6)
    {
        PBProjectBuilder * tProjectBuilder;
        int tUserID;
        int tGroupID;
        int tProcessID=0;
        NSString * tScratchPath=nil;
        NSString * tSplitForksToolName=nil;
		
        tUserID=[[NSString stringWithUTF8String:argv[2]] intValue];
        tGroupID=[[NSString stringWithUTF8String:argv[3]] intValue];
        
        tProcessID=[[NSString stringWithUTF8String:argv[4]] intValue];
        
        tProjectBuilder=[PBProjectBuilder new];
        
        if (argc>=7)
        {
            if (argv[6][0]!='/')
			{
				tSplitForksToolName=[NSString stringWithUTF8String:argv[6]];
				
				if (argc>=8)
				{
					tScratchPath=[NSString stringWithUTF8String:argv[7]];
				}
			}
			else
			{
				tScratchPath=[NSString stringWithUTF8String:argv[6]];
			}
        }
        
        [tProjectBuilder buildProjectAtPath:[NSString stringWithUTF8String:argv[1]]
                            forProcessID:tProcessID
                                withUserID:tUserID
                                    groupID:tGroupID
                           notificationPath:[NSString stringWithUTF8String:argv[5]]
						 splitForksToolName:tSplitForksToolName
								scratchPath:tScratchPath
								];
        
        [tProjectBuilder release];
    }
    else
    {
        return 1;
    }
    
    [pool release];
    
    return 0;
}
