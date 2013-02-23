/*
Copyright (c) 2004-2007, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NSString+Iceberg.h"

@implementation NSString (Iceberg)

- (NSString *) stringByRelativizingToPath:(NSString *) inReferencePath
{
    NSArray * tComponents;
    NSString * tRelativePath=self;
    
    if ([self length]>0)
    {
        if ([self characterAtIndex:0]=='/' && [inReferencePath characterAtIndex:0]=='/')
        {
            tComponents=[self componentsSeparatedByString:@"/"];
            
            if (tComponents!=nil)
            {
                NSArray * tReferencePathComponents;
                
                tReferencePathComponents=[inReferencePath componentsSeparatedByString:@"/"];
            
                if (tReferencePathComponents!=nil)
                {
                    int i,tCount;
                    int tReferenceCount;
                    
                    tCount=[tComponents count];
                    
                    tReferenceCount=[tReferencePathComponents count];
                    
                    for(i=1;i<tCount && i<tReferenceCount;i++)
                    {
                        if ([[tComponents objectAtIndex:i] isEqualToString:[tReferencePathComponents objectAtIndex:i]]==NO)
                        {
                            break;
                        }
                    }
                    
                    tRelativePath=nil;
                    
                    if (i<tReferenceCount)
                    {
                        int savedI=i;
                        
                        for(;i<tReferenceCount;i++)
                        {
                            if (tRelativePath==nil)
                            {
                                tRelativePath=[NSString stringWithString:@".."];
                            }
                            else
                            {
                                tRelativePath=[tRelativePath stringByAppendingPathComponent:@".."];
                            }
                        }
                        
                        i=savedI;
                    }
                    else
                    if (tCount==tReferenceCount)
                    {
                        tRelativePath=[NSString stringWithString:@"."];
                        
                    }
                    
                    for(;i<tCount;i++)
                    {
                        if (tRelativePath==nil)
                        {
                            tRelativePath=[NSString stringWithString:[tComponents objectAtIndex:i]];
                        }
                        else
                        {
                            tRelativePath=[tRelativePath stringByAppendingPathComponent:[tComponents objectAtIndex:i]];
                        }
                    }
                }
            }
        }
    }
    
    return tRelativePath;
}

- (NSString *) stringByAbsolutingWithPath:(NSString *) inReferencePath
{
    NSArray * tComponents;
    NSString * tAbsolutePath=self;

    if ([self length]>0)
    {
        if ([self characterAtIndex:0]!='/' && [inReferencePath characterAtIndex:0]=='/')
        {
            tAbsolutePath=[[inReferencePath retain] autorelease];
        
            if ([self isEqualToString:@"."])
            {
                return tAbsolutePath;
            }
            
            tComponents=[self componentsSeparatedByString:@"/"];
            
            if (tComponents!=nil)
            {
                int i,tCount;
                
                tCount=[tComponents count];
                
                for(i=0;i<tCount;i++)
                {
                    if ([[tComponents objectAtIndex:i] isEqualToString:@".."]==YES)
                    {
                        tAbsolutePath=[tAbsolutePath stringByDeletingLastPathComponent];
                    }
                    else
                    {
                        for(;i<tCount;i++)
                        {
                            tAbsolutePath=[tAbsolutePath stringByAppendingPathComponent:[tComponents objectAtIndex:i]];
                        }
                    }
                }
                
                
            }
        }
    }
    
    return tAbsolutePath;
}

@end
