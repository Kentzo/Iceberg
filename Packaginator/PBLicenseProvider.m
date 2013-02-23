/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBLicenseProvider.h"
#import "NSString+Karelia.h"

@implementation PBLicenseProvider

+ (PBLicenseProvider *) defaultProvider
{
    static PBLicenseProvider * sLicenseProvider=nil;
    
    if (sLicenseProvider==nil)
    {
        sLicenseProvider=[[PBLicenseProvider alloc] init];
    }
    
    return sLicenseProvider;
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        NSFileManager * tFileManager;
        NSString * tFolderPath;
        NSArray * tTemplateTypes;
        NSString * tSubPath=nil;
        int i,tTypeCount;
        NSArray * tLibraryArray;
        NSEnumerator * tEnumerator;
        NSString * tLibraryPath;
        
        // Find the Template licenses folder
        
        tLibraryArray=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSLocalDomainMask,NO);
        
        tEnumerator=[tLibraryArray objectEnumerator];
        
        while (tLibraryPath=[tEnumerator nextObject])
        {
            tFolderPath=[tLibraryPath stringByAppendingPathComponent:@"Application Support/Iceberg/Licenses Templates"];
            
            tFileManager=[NSFileManager defaultManager];
            
            tTemplateTypes=[tFileManager directoryContentsAtPath:tFolderPath];
            
            tTypeCount=[tTemplateTypes count];
            
            licensesArray_=[[NSMutableArray alloc] initWithCapacity:tTypeCount];
            
            for(i=0;i<tTypeCount;i++)
            {
                NSString * tTypePath;
                
                BOOL isDirectory;
                
                tSubPath=[tTemplateTypes objectAtIndex:i];
                
                tTypePath=[tFolderPath stringByAppendingPathComponent:tSubPath];
                
                if ([tFileManager fileExistsAtPath:tTypePath isDirectory:&isDirectory]==YES && isDirectory==YES)
                {
                    NSArray * tLanguages;
                    int j,tLanguagesCount;
                    NSString * tLanguageName;
                    NSMutableDictionary * tLicenseAvailableLanguages;
                    NSDictionary * tLicenseObject;
                    
                    tLanguages=[tFileManager directoryContentsAtPath:tTypePath];
                    
                    tLanguagesCount=[tLanguages count];
                    
                    tLicenseAvailableLanguages=[NSMutableDictionary dictionaryWithCapacity:tLanguagesCount];
                    
                    for(j=0;j<tLanguagesCount;j++)
                    {
                        NSString * tLanguagePath;
                        
                        tLanguageName=[tLanguages objectAtIndex:j];
                        
                        tLanguagePath=[tTypePath stringByAppendingPathComponent:tLanguageName];
                        
                        if ([tFileManager fileExistsAtPath:tLanguagePath isDirectory:&isDirectory]==YES && isDirectory==YES)
                        {
                            NSDictionary * tDictionary;
                            
                            // Check the coherence of the Folder before creating it
                            
                            if ([tFileManager fileExistsAtPath:[tLanguagePath stringByAppendingPathComponent:@"License.rtf"] isDirectory:&isDirectory]==NO || isDirectory==YES)
                            {
                                continue;
                            }
                            
                            tDictionary=[NSDictionary dictionaryWithContentsOfFile:[tLanguagePath stringByAppendingPathComponent:@"Keywords.plist"]];
                            
                            if (tDictionary!=nil)
                            {
                                [tLicenseAvailableLanguages setObject:tDictionary forKey:[tLanguageName stringByDeletingPathExtension]];
                            }
                            else
                            {
                                [tLicenseAvailableLanguages setObject:[NSNull null] forKey:[tLanguageName stringByDeletingPathExtension]];
                            }
                        }
                    }
                    
                    tLicenseObject=[NSDictionary dictionaryWithObjectsAndKeys:tSubPath,@"Name",
                                                                            tLicenseAvailableLanguages,@"Languages",
                                                                            tTypePath,@"Path",
                                                                            nil];
                                                                            
                    
                    [licensesArray_ addObject:tLicenseObject];
                }
            }
        }
    }
    
    return self;
}

- (void) dealloc
{
    [licensesArray_ release];
    
    [super dealloc];
}

- (NSArray *) licensesForLanguage:(NSString *) inLanguage
{
    NSMutableArray * tMutableArray;
    int i,tCount;
    
    tCount=[licensesArray_ count];
    
    
    tMutableArray=[NSMutableArray arrayWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tDictionary;
        
        tDictionary=[[licensesArray_ objectAtIndex:i] objectForKey:@"Languages"];
        
        if ([tDictionary objectForKey:inLanguage]!=nil)
        {
            [tMutableArray addObject:[[licensesArray_ objectAtIndex:i] objectForKey:@"Name"]];
        }
    }
    
    return tMutableArray;
    
}

- (NSDictionary *) licenseKeywordsWithName:(NSString *) inName language:(NSString *) inLanguage
{
    int i,tCount;
    NSDictionary * tDictionary=nil;
    
    tCount=[licensesArray_ count];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tLicenseDictionary;
        
        tLicenseDictionary=[licensesArray_ objectAtIndex:i];
        
        if ([[tLicenseDictionary objectForKey:@"Name"] isEqualToString:inName]==YES)
        {
            NSDictionary * tLanguageDictionary;
            
            tLanguageDictionary=[tLicenseDictionary objectForKey:@"Languages"];
            
            if (tLanguageDictionary!=nil)
            {
                tDictionary=[tLanguageDictionary objectForKey:inLanguage];
            }
            
            break;
        }
    }
    
    return tDictionary;
}

- (NSString *) pathForLicenseWithName:(NSString *) inName language:(NSString *) inLanguage
{
    int i,tCount;
    
    tCount=[licensesArray_ count];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tLicenseDictionary;
        
        tLicenseDictionary=[licensesArray_ objectAtIndex:i];
        
        if ([[tLicenseDictionary objectForKey:@"Name"] isEqualToString:inName]==YES)
        {
            NSString * tPath;
            
            tPath=[[tLicenseDictionary objectForKey:@"Path"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj/License.rtf",inLanguage]];
            
            return tPath;
        }
    }
    
    return nil;
}

+ (void) replaceKeywords:(NSDictionary *) inDictionary inAttributedString:(NSMutableAttributedString *) inMutableAttributedString
{
    NSString * tString;
    BOOL keepOn=YES;
    
    tString=[inMutableAttributedString string];
    
    do
    {
        NSRange foundRange = [tString rangeFromString:@"%%" toString:@"%%" options:0 range:NSMakeRange(0,[tString length])];
        
        if (foundRange.location == NSNotFound)
        {
            keepOn=NO;
        }
        else
        {
            NSString * tKey;
            NSString * tValue;
            
            tKey=[tString substringWithRange:NSMakeRange(foundRange.location+2,foundRange.length-4)];
            
            tValue=[inDictionary objectForKey:tKey];
            
            if (tValue!=nil)
            {
                [inMutableAttributedString replaceCharactersInRange:foundRange
                                                         withString:tValue];
            
                tString=[inMutableAttributedString string];
            }
            else
            {
                break;
            }
        }
        
        
    }
    while (YES==keepOn);
}

+ (void) replaceKeywords:(NSDictionary *) inDictionary inString:(NSMutableString *) inMutableString
{
    BOOL keepOn=YES;
    
    do
    {
        NSRange foundRange = [inMutableString rangeFromString:@"%%" toString:@"%%" options:0 range:NSMakeRange(0,[inMutableString length])];
        
        if (foundRange.location == NSNotFound)
        {
            keepOn=NO;
        }
        else
        {
            NSString * tKey;
            NSString * tValue;
            
            tKey=[inMutableString substringWithRange:NSMakeRange(foundRange.location+2,foundRange.length-4)];
            
            tValue=[inDictionary objectForKey:tKey];
            
            if (tValue!=nil)
            {
                [inMutableString replaceCharactersInRange:foundRange
                                                         withString:tValue];
            }
            else
            {
                break;
            }
        }
        
        
    }
    while (YES==keepOn);
}

@end
