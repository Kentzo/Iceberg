/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBController.h"

@implementation PBController

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    document_=inDocument;
    
    objectNode_=(PBObjectNode *) NODE_DATA(inProjectTree);
}

- (id) document
{
    return document_;
}

- (void) treeWillChange
{
}

- (void) localizationPanelDidEnd:(PBLocalizationPanel *) localizationPanel returnCode:(int) returnCode localization:(NSString *) localization
{
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    textHasBeenUpdated_=YES;
    
    //[self setDocumentNeedsUpdate:YES];
}

- (void) setDocumentNeedsUpdate:(BOOL) inUpdateNeeded
{
    if (inUpdateNeeded==YES)
    {
        textHasBeenUpdated_=NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentUpdated"
                                                            object:document_];
    }
}

- (id) view
{
    return IBview_;
}

- (id) objectNode
{
    return objectNode_;
}

- (id) projectTree
{
    return [[projectTree_ retain] autorelease]; 
}

- (void) setProjectTree:(PBProjectTree *) inProjectTree
{
    if (projectTree_!=inProjectTree)
    {
        [projectTree_ release];
        
        projectTree_=[inProjectTree retain];
    }
}

- (void) postNotificationChange
{
    static NSNotificationCenter * sNotificationCenter=nil;
    
    if (sNotificationCenter==nil)
    {
        sNotificationCenter=[NSNotificationCenter defaultCenter];
    }
    
    [sNotificationCenter postNotificationName:@"PBTreeChanged" object:document_];
}


@end
