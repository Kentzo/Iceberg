/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSplashProvider.h"
#import "PBSystemUtilities.h"
#import "PBInstallerLocator.h"

@implementation PBSplashProvider

+ (PBSplashProvider *) defaultProvider
{
    static PBSplashProvider * sSplashProvider=nil;
    
    if (sSplashProvider==nil)
    {
        sSplashProvider=[[PBSplashProvider alloc] init];
    }
    
    return sSplashProvider;
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
            NSBundle * tBundle;
			
			// Check that this is the one we're looking for
            
            tBundle=[NSBundle bundleWithPath:tPath];
            
            tPath=nil;
            
            if (tBundle!=nil)
            {
                isTigrou_=([PBSystemUtilities systemMajorVersion]>=PBTiger);
                
                if (isTigrou_==NO)
                {
                    tPath=[[tBundle resourcePath] stringByAppendingPathComponent:@"Splash.bundle"];
                }
                else
                {
                    tPath=[[tBundle builtInPlugInsPath] stringByAppendingPathComponent:@"Introduction.bundle"];
                }
                
                if (tPath!=nil)
                {
                    bundle_=[[NSBundle bundleWithPath:tPath] retain];
                }
            }
        }
    }
    
    return self;
}

- (NSString *) pathWithLanguage:(NSString *) inEnglishName
{
    if (bundle_!=nil)
    {
        if (isTigrou_==NO)
        {
            return [bundle_ pathForResource:@"Splash"
                                     ofType:@"rtf"
                                inDirectory:nil
                            forLocalization:inEnglishName];
        }
        else
        {
             return [bundle_ pathForResource:@"Default"
                                     ofType:@"rtf"
                                inDirectory:nil
                            forLocalization:inEnglishName];
        }
    }
    
    return nil;
}

@end
