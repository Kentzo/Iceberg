/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBCheetahPackageMakerDecoder.h"

@implementation PBCheetahCorePackageDecoder

- (id) initWithCoder:(NSCoder * ) coder
{
    packageTitle_=[[coder decodeObject] retain];
    
    packageVersion_=[[coder decodeObject] retain];
    
    packageDescription_=[[coder decodeObject] retain];

    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:packageTitle_];
    
    [coder encodeObject:packageVersion_];
    
    [coder encodeObject:packageDescription_];
}

@end

@implementation PBCheetahSinglePackageDecoder

- (id) initWithCoder:(NSCoder * ) coder
{
    unsigned int tValue;
    
    rootDirectory_=[[coder decodeObject] retain];
    
    resourcesDirectory_=[[coder decodeObject] retain];
    
    [super initWithCoder:coder];
    
    packageWarning_=[[coder decodeObject] retain];
    
    defaultLocation_=[[coder decodeObject] retain];
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    compressArchive_=(tValue >> 24);
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    needsRootAuthorization_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    required_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    relocatable_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    requiresReboot_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    useUserMask_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    overwritePermissions_=tValue;
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    installFat_=tValue;
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    unsigned int tValue;
    
    [coder encodeObject:rootDirectory_];
    
    [coder encodeObject:resourcesDirectory_];
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:packageWarning_];
    
    [coder encodeObject:defaultLocation_];
    
    tValue=((unsigned int) compressArchive_)<<24;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=needsRootAuthorization_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=required_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=relocatable_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=requiresReboot_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=useUserMask_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=overwritePermissions_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    tValue=installFat_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
}

@end

#pragma mark -

@implementation PBSubPackageItem

- (id) initWithCoder:(NSCoder * ) coder
{
    packageName_=[[coder decodeObject] retain];
    
    flags_=[[coder decodeObject] retain];
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:packageName_];
    
    [coder encodeObject:flags_];
}

@end

#pragma mark -

@implementation PBCheetahMetaPackageDecoder

- (id) initWithCoder:(NSCoder * ) coder
{
    [super initWithCoder:coder];
    
    subpackageLocation_=[[coder decodeObject] retain];
    
    resourcesDirectory_=[[coder decodeObject] retain];
    
    components_=[[coder decodeObject] retain];
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:subpackageLocation_];
    
    [coder encodeObject:resourcesDirectory_];
    
    [coder encodeObject:components_];
}

@end
