/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSimulatorLocalizer.h"
#import "PBInstallerLocator.h"

@implementation PBSimulatorLocalizer

+ (PBSimulatorLocalizer *) defaultLocalizer
{
    static PBSimulatorLocalizer * sSimulatorLocalizer=nil;
    
    if (sSimulatorLocalizer==nil)
    {
        sSimulatorLocalizer=[[PBSimulatorLocalizer alloc] init];
    }
    
    return sSimulatorLocalizer;
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        NSString * tPath;
        
        tPath=[PBInstallerLocator pathForInstaller];
        
        if (tPath!=nil)
        {
            mainBundle_=[[NSBundle bundleWithPath:tPath] retain];
            
            // Get the Splash and Document bundle
            
            tPath=nil;
            
            if (mainBundle_!=nil)
            {
                tPath=[[mainBundle_ resourcePath] stringByAppendingPathComponent:@"Splash.bundle"];
                
                if (tPath!=nil)
                {
                    splashBundle_=[[NSBundle bundleWithPath:tPath] retain];
                }
                
                tPath=[[mainBundle_ resourcePath] stringByAppendingPathComponent:@"Documents.bundle"];
                
                if (tPath!=nil)
                {
                    documentBundle_=[[NSBundle bundleWithPath:tPath] retain];
                }
            }
        }
    }
    
    return self;
}

- (NSArray *) localizations
{
    if (mainBundle_!=nil)
    {
        return [mainBundle_ localizations];
    }
    
    return nil;
}

- (NSString *) localizedString:(NSString *) inString forLanguage:(NSString *) inLanguage
{
    static NSDictionary * cachedMainDictionary=nil;
    static NSDictionary * cachedSplashDictionary=nil;
    static NSDictionary * cachedDocumentDictionary=nil;
    static NSString * cachedLanguage=nil;
    NSString * tString=nil;
    
    if (cachedLanguage==nil || [cachedLanguage isEqualToString:inLanguage]==NO)
    {
        NSString * tPath;
        
        tPath=[mainBundle_ pathForResource:@"Localizable"
                                ofType:@"strings"
                           inDirectory:nil
                       forLocalization:inLanguage];
        
        [cachedMainDictionary release];
        
        cachedMainDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
        
        tPath=[splashBundle_ pathForResource:@"Localizable"
                                ofType:@"strings"
                           inDirectory:nil
                       forLocalization:inLanguage];
        
        [cachedSplashDictionary release];
        
        cachedSplashDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
        
        tPath=[documentBundle_ pathForResource:@"Localizable"
                                ofType:@"strings"
                           inDirectory:nil
                       forLocalization:inLanguage];
        
        [cachedDocumentDictionary release];
        
        cachedDocumentDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
    }
    
    // Try the Main Bundle 
    
    if (cachedMainDictionary!=nil)
    {
        tString=[cachedMainDictionary objectForKey:inString];
    }
    
    // Try the Splash Bundle 
    
    if (tString==nil)
    {
        if (cachedSplashDictionary!=nil)
        {
            tString=[cachedSplashDictionary objectForKey:inString];
        }
    }
    
    // Try the Document Bundle 
    
    if (tString==nil)
    {
        if (cachedDocumentDictionary!=nil)
        {
            tString=[cachedDocumentDictionary objectForKey:inString];
        }
    }
    
    return tString;
}

@end
