/*
Copyright (c) 2004-2005, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBJaguarPackageMakerDecoder.h"

@implementation PBJaguarCorePackageDecoder

- (id) initWithCoder:(NSCoder *) coder
{
    unsigned int tValue;
    
    [coder decodeObject];
    
    [coder decodeObject];
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    infoDictionary_=[[coder decodeObject] retain];
    
    descriptionDictionary_=[[coder decodeObject] retain];
    
    defaultLanguage_=[[coder decodeObject] retain];
    
    resourcesDirectory_=[[coder decodeObject] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *) coder
{
    unsigned int tValue;
    
    [coder encodeConditionalObject:nil];
    
    [coder encodeConditionalObject:nil];
    
    tValue=0;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    [coder encodeObject:infoDictionary_];
    
    [coder encodeObject:descriptionDictionary_];
    
    [coder encodeObject:defaultLanguage_];
    
    [coder encodeObject:resourcesDirectory_];
}

@end

@implementation PBJaguarSinglePackageDecoder

- (id) initWithCoder:(NSCoder *) coder
{
    unsigned int tValue;
    
    self=[super initWithCoder:coder];
    
    [coder decodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    compressArchive_=tValue;
    
    rootDirectory_=[[coder decodeObject] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    unsigned int tValue;
    
    [super encodeWithCoder:coder];
    
    tValue=compressArchive_;
    
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&tValue];
    
    [coder encodeObject:rootDirectory_];
}

@end

@implementation PBJaguarMetaPackageDecoder

- (id) initWithCoder:(NSCoder *) coder
{
    self=[super initWithCoder:coder];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

@end