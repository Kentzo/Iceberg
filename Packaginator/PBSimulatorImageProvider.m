/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSimulatorImageProvider.h"
#import "PBSystemUtilities.h"
#import "PBInstallerLocator.h"

@implementation PBSimulatorImageProvider

+ (PBSimulatorImageProvider *) defaultProvider
{
    static PBSimulatorImageProvider * sImageProvider=nil;
    
    if (sImageProvider==nil)
    {
        sImageProvider=[[PBSimulatorImageProvider alloc] init];
    }
    
    return sImageProvider;
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
            // Check that this is the one we're looking for
            
            bundle_=[[NSBundle bundleWithPath:tPath] retain];
        }
    }
    
    return self;
}

- (NSImage *) imageNamed:(NSString *) inImageName
{
    NSImage * tImage=nil;

    if (bundle_!=nil)
    {
        NSString * tPath;
    
        tPath=[bundle_ pathForResource:inImageName ofType:@"tif"];
        
        if (tPath==nil)
        {
			 tPath=[bundle_ pathForResource:inImageName ofType:@"tiff"];
		}
		
        if (tPath!=nil)
        {
            tImage=[[NSImage alloc] initWithContentsOfFile:tPath];
        }
    }

    return [tImage autorelease];
}

@end
