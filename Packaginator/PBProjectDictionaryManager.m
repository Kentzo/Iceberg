/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectDictionaryManager.h"

NSString * const PB_HIERARCHY_KEY = @"Hierarchy";
NSString * const PB_ATTRIBUTES_KEY = @"Attributes";
NSString * const PB_FILES_KEY = @"Files";

@implementation PBProjectDictionaryManager

+ (NSMutableDictionary *) fileHierarchyRootForPackageProject:(NSDictionary *) inProjectDictionary
{
    NSMutableDictionary * tMutableDictionary=nil;
    NSMutableDictionary * tDictionary;
        
    tDictionary=[inProjectDictionary objectForKey:PB_HIERARCHY_KEY];
        
    if (tDictionary!=nil)
    {
        tDictionary=[tDictionary objectForKey:PB_ATTRIBUTES_KEY];
        
        if (tDictionary!=nil)
        {
            tDictionary=[tDictionary objectForKey:PB_FILES_KEY];
            
            if (tDictionary!=nil)
            {
                tMutableDictionary=[tDictionary objectForKey:PB_HIERARCHY_KEY];
            }
            else
            {
                NSLog(@"fileHierarchyRoot: No value for %@:%@:%",PB_HIERARCHY_KEY,PB_ATTRIBUTES_KEY,PB_FILES_KEY);
            }
        }
        else
        {
            NSLog(@"fileHierarchyRoot: No value for %@:%@",PB_HIERARCHY_KEY,PB_ATTRIBUTES_KEY);
        }
    }
    else
    {
        NSLog(@"fileHierarchyRoot: No value for %@",PB_HIERARCHY_KEY);
    }

    return tMutableDictionary;
}

+ (NSMutableDictionary *) fileObjectAtPath:(NSString *) inPath forPackageProject:(NSDictionary *) inProjectDictionary
{
    NSMutableDictionary * tFileHierarchy;
    NSMutableDictionary * tFileObject=nil;
    
    tFileHierarchy=[PBProjectDictionaryManager fileHierarchyRootForPackageProject:inProjectDictionary];
    
    if (tFileHierarchy!=nil)
    {
        NSArray * tPathComponents;
        int tCount,i;
        NSMutableDictionary * tDictionary;
        NSArray * tArray;
        
        tPathComponents=[inPath pathComponents];
        
        tCount=[tPathComponents count];
        
        tDictionary=tFileHierarchy;
        
        for(i=1;i<tCount;i++)
        {
            int tChildrenCount,j;
            NSString * tComponentName;
            
            tComponentName=[tPathComponents objectAtIndex:i];
            
            tArray=[tDictionary objectForKey:@"Children"];
            
            if (tArray!=nil)
            {
                NSMutableDictionary * tChildDictionary;
                
                tChildrenCount=[tArray count];
                
                for(j=0;j<tChildrenCount;j++)
                {
                    tChildDictionary=[tArray objectAtIndex:j];
                    
                    if (tChildDictionary!=nil)
                    {
                        if ([[tChildDictionary objectForKey:@"Path"] isEqualToString:tComponentName]==YES)
                        {
                            tDictionary=tChildDictionary;
                            
                            break;
                        }
                    }
                }
            }
            else
            {
                NSLog(@"%@ has no children",tComponentName);
                
                break;
            }
        }
        
        if (i==tCount)
        {
            tFileObject=tDictionary;
        }
    }
    else
    {
        NSLog(@"File Hierarchy not found");
    }
    
    return tFileObject;
}

+ (NSMutableDictionary *) branchNamed:(NSString *) inBranch forPackageProject:(NSDictionary *) inProjectDictionary
{
    NSMutableDictionary * tBranch=nil;
    
    if (inBranch!=nil)
    {
        NSMutableDictionary * tDictionary;
            
        tDictionary=[inProjectDictionary objectForKey:PB_HIERARCHY_KEY];
            
        if (tDictionary!=nil)
        {
            tDictionary=[tDictionary objectForKey:PB_ATTRIBUTES_KEY];
            
            if (tDictionary!=nil)
            {
                NSArray * tArray;
                int i,tCount;
                
                tArray=[inBranch componentsSeparatedByString:@":"];
                
                if (tArray!=nil)
                {
                    tCount=[tArray count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        tDictionary=[tDictionary objectForKey:[tArray objectAtIndex:i]];
                        
                        if (tDictionary==nil)
                        {
                            NSLog(@"branchNamed:forPackageProject: Branch \"%@\" does not exist",inBranch);
                            
                            break;
                        }
                    }
                    
                    if (i==tCount)
                    {
                        tBranch=tDictionary;
                    }
                }
                else
                {
                    NSLog(@"branchNamed:forPackageProject: No value for %@:%@",PB_HIERARCHY_KEY,PB_ATTRIBUTES_KEY);
                }
            }
            else
            {
                NSLog(@"branchNamed:forPackageProject: No value for %@:%@",PB_HIERARCHY_KEY,PB_ATTRIBUTES_KEY);
            }
        }
        else
        {
            NSLog(@"branchNamed:forPackageProject: No value for %@",PB_HIERARCHY_KEY);
        }
    }
    
    return tBranch;
}

@end
