/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBAssistantTree.h"

@implementation PBAssistantNode: NSObject

+ (id) assistantNodeWithName:(NSString *) inName type: (int) inType path:(NSString *) inPath
{
    return [[[PBAssistantNode alloc] initWithName:inName type:inType path:inPath] autorelease];
}

- (id) initWithName:(NSString *) inName type: (int) inType path:(NSString *) inPath
{
    self=[super init];
    
    if (self!=nil)
    {
        name_=[inName retain];
        
        type_=inType;
        
        path_=[inPath retain];
    }
    
    return self;
}

- (NSString *) name
{
    return [[name_ retain] autorelease];
}

- (int) type
{
    return type_;
}

- (NSString *) path
{
    return [[path_ retain] autorelease];
}

- (BOOL) isLeaf
{
    return (type_==kATypeNode);
}

@end

@implementation PBAssistantTree : TreeNode

+ (id) assistantTree
{
    PBAssistantTree * newTree;
    
    newTree=[[PBAssistantTree alloc] initWithData:[PBAssistantNode assistantNodeWithName:nil type:kARootNode path:nil]
                                         parent:nil
                                       children:[NSArray array]];

    if (newTree!=nil)
    {
        // Check /Library/Application Support/Packaginator folder
    
        NSArray * tTemplateTypes;
        NSString * tSubPath=nil;
        NSFileManager * tFileManager;
        NSString * tFolderPath;
        int i,tTypeCount;
        int tIndex=0;
        
        // A MODIFIER (obtention du path /Library/Application Support dynamiquement et gestion de ~/Library/Application Support
        
        tFolderPath=[NSString stringWithString:@"/Library/Application Support/Iceberg/Projects Templates"];
        
        tFileManager=[NSFileManager defaultManager];
        
        tTemplateTypes=[tFileManager directoryContentsAtPath:tFolderPath];
        
        tTypeCount=[tTemplateTypes count];
        
        for(i=0;i<tTypeCount;i++)
        {
            PBAssistantTree * newTypeNode;
            NSArray * tTemplates;
            NSString * tTypePath;
            int j,tTemplateCount;
            BOOL isDirectory;
            
            tSubPath=[tTemplateTypes objectAtIndex:i];
            
            tTypePath=[tFolderPath stringByAppendingPathComponent:tSubPath];
            
            if ([tFileManager fileExistsAtPath:tTypePath isDirectory:&isDirectory]==YES && isDirectory==YES)
            {
                int tTemplateIndex=0;
                
                newTypeNode=[[PBAssistantTree alloc] initWithData:[PBAssistantNode assistantNodeWithName:tSubPath type:kATypeNode path:nil]
                                                        parent:nil
                                                        children:[NSArray array]];
                
                [newTree insertChild: newTypeNode
                        atIndex: tIndex++];
                        
                [newTypeNode release];
                
                tTemplates=[tFileManager directoryContentsAtPath:tTypePath];
                
                tTemplateCount=[tTemplates count];
                
                for(j=0;j<tTemplateCount;j++)
                {
                    NSString * tTemplateName;
                    NSString * tTemplatePath;
                    PBAssistantTree * newTemplateNode;
                    BOOL isTemplateDirectory;
                    
                    tTemplateName=[tTemplates objectAtIndex:j];
                    
                    tTemplatePath=[tTypePath stringByAppendingPathComponent:tTemplateName];
                    
                    if ([tFileManager fileExistsAtPath:tTemplatePath isDirectory:&isTemplateDirectory]==YES && isTemplateDirectory==YES)
                    {
                    
                        newTemplateNode=[[PBAssistantTree alloc] initWithData:[PBAssistantNode assistantNodeWithName:tTemplateName type:kATemplateNode path:tTemplatePath]
                                                                    parent:nil
                                                                    children:nil];
                    
                        [newTypeNode insertChild: newTemplateNode
                                        atIndex: tTemplateIndex++];
                        
                        [newTemplateNode release];
                    }
                }
            }
        }
    }
    
    return [newTree autorelease];
}

@end
