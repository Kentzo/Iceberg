/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBLanguageConverter.h"

@implementation PBLanguageConverter

+ (PBLanguageConverter *) defaultConverter
{
    static PBLanguageConverter * sLanguageConverter=nil;
    
    if (sLanguageConverter==nil)
    {
        sLanguageConverter=[[PBLanguageConverter alloc] init];
    }
    
    return sLanguageConverter;
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        NSBundle * tBundle;
        NSString * tPath;
        
        tPath=[NSString stringWithString:@"/System/Library/PrivateFrameworks/IntlPreferences.framework"];
        
        tBundle=[NSBundle bundleWithPath:tPath];
        
        if (tBundle!=nil)
        {
             NSDictionary * tEnglishIso;
             
             tEnglishIso=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EnglishToISO" ofType:@"strings"]];
             
             if (tEnglishIso!=nil)
             {
                NSArray * tEnglishArray;
                NSArray * tISOArray;
                
                tEnglishArray=[tEnglishIso objectForKey:@"EnglishNames"];
                
                tISOArray=[tEnglishIso objectForKey:@"ISOLanguageNames"];
                
                if (tEnglishArray!=nil && tISOArray!=nil)
                {
                    int i,tCount;
                
                    tCount=[tEnglishArray count];
                
                    conversionDictionary_=[[NSMutableDictionary alloc] initWithCapacity:tCount];
                    
                    ISOToEnglishDictionary_=[[NSMutableDictionary alloc] initWithCapacity:tCount];
                    
                    englishToISODictionary_=[[NSMutableDictionary alloc] initWithCapacity:tCount];
                    
                    kenobiDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[tBundle pathForResource:@"Language" ofType:@"strings"]];
                    
                    for(i=0;i<tCount;i++)
                    {	
                        NSString * tNativeName;
                        NSString * tKey;
                        
                        tKey=[tEnglishArray objectAtIndex:i];
                        
                        tNativeName=[kenobiDictionary_ objectForKey:[tISOArray objectAtIndex:i]];
                    
                        if (tNativeName!=nil)
                        {
                            [conversionDictionary_ setObject:tNativeName forKey:tKey];
                        }
                        
                        [ISOToEnglishDictionary_ setObject:[tEnglishArray objectAtIndex:i] forKey:[tISOArray objectAtIndex:i]];
                        
                        [englishToISODictionary_ setObject:[tISOArray objectAtIndex:i] forKey:[tEnglishArray objectAtIndex:i]];
                    }
                }
             }
        }
    }
    
    return self;
}

- (NSString *) nativeForEnglish:(NSString *) inEnglishName
{
    NSString * tNative=nil;
    
    if (conversionDictionary_==nil && kenobiDictionary_==nil)
    {
        return inEnglishName;
    }
    
    if (conversionDictionary_!=nil)
    {
        tNative=[conversionDictionary_ objectForKey:inEnglishName];
    }
    
    if (tNative==nil)
    {
        if (kenobiDictionary_!=nil)
        {
            // You are our only hope
            
            tNative=[kenobiDictionary_ objectForKey:inEnglishName];
        }
    }

    if (tNative==nil)
    {
        tNative=inEnglishName;
    }
    
    return tNative;
}

- (NSString *) englishFromISO:(NSString *) inISOName
{
    if (ISOToEnglishDictionary_==nil)
    {
        return inISOName;
    }
    
    return [ISOToEnglishDictionary_ objectForKey:inISOName];
}

- (NSString *) ISOFromEnglish:(NSString *) inEnglishName
{
    if (englishToISODictionary_==nil)
    {
        return inEnglishName;
    }
    
    return [englishToISODictionary_ objectForKey:inEnglishName];
}

@end
