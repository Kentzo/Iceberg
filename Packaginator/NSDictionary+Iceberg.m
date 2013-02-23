/*
Copyright (c) 2004-2008, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "NSDictionary+Iceberg.h"

@implementation NSDictionary (Iceberg)

+ (NSDictionary *) dictionaryWithContentsOfInfoFile:(NSString *) inFilePath
{
    NSString * tString;
    NSMutableDictionary * nDictionary=nil;
    
    tString=[NSString stringWithContentsOfFile:inFilePath];
    
    if (tString!=nil)
    {
        NSArray * tLines;
        
        tLines=[tString componentsSeparatedByString:@"\n"];
        
        if (tLines!=nil)
        {
            int i,tCount;
            
            tCount=[tLines count];
            
            nDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
            
            for(i=0;i<tCount;i++)
            {
                NSString * tStringLine;
                unsigned int tLength;
                
                tStringLine=[tLines objectAtIndex:i];
                
                tLength=[tStringLine length];
                
                if (tLength>0)
                {
                    unsigned int tIndex;
                    unichar tChar;
                    
                    tChar=[tStringLine characterAtIndex:0];
                    
                    switch (tChar)
                    {
                        case '#':
                        case ' ':
                        case '\n':
                        case '\t':
                            break;
                        default:
                            for(tIndex=1;tIndex<tLength;tIndex++)
                            {
                                tChar=[tStringLine characterAtIndex:tIndex];
                                
                                if (tChar==' ' || tChar=='\t')
                                {
                                    if (tIndex>1)
                                    {
                                        NSString * tKey;
                                        NSString * tValue;
                                        
                                        tKey=[tStringLine substringToIndex:tIndex];
                                        
                                        tIndex++;
                                            
                                        for(;tIndex<tLength;tIndex++)
                                        {
                                            tChar=[tStringLine characterAtIndex:tIndex];
                                
                                            if (tChar!=' ' && tChar!='\t')
                                            {
                                                tValue=[tStringLine substringFromIndex:tIndex];
                                                
                                                [nDictionary setObject:tValue forKey:tKey];
                                                
                                                break;
                                            } 
                                        }
                                    }
                                    
                                    break;
                                }
                            }
                            break;
                    }
                }
                
            }
        }
    }
    
    return nDictionary;
}

@end

@implementation NSMutableDictionary (Iceberg)

+ (NSMutableDictionary *) mutableDictionaryWithContentsOfFile:(NSString *) inPath
{
    // Use CoreFoundation to have a completely mutable dictionary
    
    NSData * tData;
    NSMutableDictionary * tMutableDictionary=nil;
    
    tData=[NSData dataWithContentsOfFile:inPath];
    
    if (tData!=nil)
    {
        NSString * tErrorString;
        NSPropertyListFormat tFormat;
        
        tMutableDictionary=[NSPropertyListSerialization propertyListFromData:tData
                                                            mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                    format:&tFormat
                                                            errorDescription:&tErrorString];
        
        if (tMutableDictionary==nil)
        {
            NSLog(@"%@",tErrorString);
        }
    
    }
    
    return tMutableDictionary;
}

@end