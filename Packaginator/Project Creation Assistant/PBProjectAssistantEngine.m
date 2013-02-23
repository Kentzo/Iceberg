/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectAssistantEngine.h"

@implementation PBProjectAssistantEngine

- (id) init
{
    self=[super init];
    
    if (self)
    {
        options_=[[NSMutableDictionary alloc] initWithCapacity:1];
    
        [self setProjectDirectory:[NSString stringWithString:@"~/"]];
    }
    
    return self;
}

- (void) dealloc
{
    [finalProjectPath_ release];
    
    [options_ release];
    
    [templateFolderPath_ release];
    
    [templateName_ release];
    
    [projectName_ release];
    
    [projectDirectory_ release];

    [super dealloc];
}

#pragma mark -

- (NSMutableDictionary *) options
{
    return options_;
}

- (NSString *) finalProjectPath
{
    return [[finalProjectPath_ retain] autorelease];
}

- (void) setFinalProjectPath:(NSString *) inPath
{
    if (finalProjectPath_!=inPath)
    {
        [finalProjectPath_ release];
    
        finalProjectPath_=[inPath copy];
    }
}

- (NSString *) templateFolderPath
{
    return [[templateFolderPath_ retain] autorelease];
}

- (void) setTemplateFolderPath:(NSString *) inPath
{
    if (templateFolderPath_!=inPath)
    {
        [templateFolderPath_ release];
    
        templateFolderPath_=[inPath copy];
    }
}

- (NSString *) templateName
{
    return [[templateName_ retain] autorelease];
}

- (void) setTemplateName:(NSString *) inName
{
    if (templateName_!=inName)
    {
        [templateName_ release];
    
        templateName_=[inName copy];
    }
}

- (NSString *) projectName
{
    return [[projectName_ retain] autorelease];
}

- (void) setProjectName:(NSString *) inProjectName
{
    if (projectName_!=inProjectName)
    {
        [projectName_ release];
    
        projectName_=[inProjectName copy];
    }
}

- (NSString *) projectDirectory
{
    return [[projectDirectory_ retain] autorelease];
}

- (void) setProjectDirectory:(NSString *) inProjectDirectory
{
    if (projectDirectory_!=inProjectDirectory)
    {
        [projectDirectory_ release];
    
        projectDirectory_=[inProjectDirectory copy];
    }
}

- (NSMutableDictionary *) projectDictionary
{
    return mutableProjectDictionary_;
}

#pragma mark -

- (void) startProcessWithProjectDictionary:(NSMutableDictionary *) inDictionary;
{
    mutableProjectDictionary_=[inDictionary retain];
}

- (BOOL) endProcess
{
    [mutableProjectDictionary_ release];

    return YES;
}

@end
