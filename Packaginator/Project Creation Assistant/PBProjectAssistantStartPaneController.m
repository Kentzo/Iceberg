/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectAssistantStartPaneController.h"
#import "PBProjectAssistantController.h"
#import "PBProjectAssistantEngine.h"

#define SAFEASSISTANTNODE(n) 	((PBAssistantTree*)((n!=nil)?(n):(tree_)))

@implementation PBProjectAssistantStartPaneController

- (void) awakeFromNib
{
    tree_=[[PBAssistantTree assistantTree] retain];
    
    typeAttribute_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:11],NSFontAttributeName,
                                                                nil];
                                                               
    templateAttribute_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:11],NSFontAttributeName,
                                                                nil];
}

- (void) initPaneWithEngine:(id) inEngine
{
    int i,tCount;
    
    [IBtemplateOutlineView_ deselectAll:self];
    
    [IBtemplateOutlineView_ reloadData];
    
    tCount=[tree_ numberOfChildren];
    
    for(i=0;i<tCount;i++)
    {
        [IBtemplateOutlineView_ expandItem:[tree_ childAtIndex:i]];
    }
    
    [mainController_ setEnableNextButton:NO];
}

- (void) dealloc
{
    [typeAttribute_ release];
    
    [templateAttribute_ release];
    
    [tree_ release];
    
    // A COMPLETER
    
    [super dealloc];
}

#pragma mark -

- (NSString *) nextPaneName
{
    return [[nextPaneName_ retain] autorelease];
}

- (void) setNextPaneName:(NSString *) inNextPaneName
{
    if (nextPaneName_!=inNextPaneName)
    {
        [nextPaneName_ release];
        
        nextPaneName_=[inNextPaneName copy];
    }
}

#pragma mark -

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
    return [SAFEASSISTANTNODE(item) childAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
    return [ASSISTANTNODE_DATA(item) isLeaf];
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
    return [SAFEASSISTANTNODE(item) numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    
    if([[tableColumn identifier] isEqualToString: @"Templates"])
    {
        if ([ASSISTANTNODE_DATA(item) type]==kATypeNode)
        {
            objectValue= [[NSAttributedString alloc] initWithString:[ASSISTANTNODE_DATA(item) name]
                                                         attributes:typeAttribute_];
        }
        else
        {
            objectValue= [[NSAttributedString alloc] initWithString:[ASSISTANTNODE_DATA(item) name]
                                                         attributes:templateAttribute_];
        }
        
        [objectValue autorelease];
    }
        
    return objectValue;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return ([ASSISTANTNODE_DATA(item) type]!=kATypeNode);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int tSelectedCount;
    
    tSelectedCount=[IBtemplateOutlineView_ numberOfSelectedRows];
    
    if (tSelectedCount>0)
    {
        NSString * tString=nil;
        NSString * tPath;
        NSFileManager * tFileManager;
        NSArray * tArray;
        NSMutableArray * tMutableArray;
        int i,tCount;
        
        tPath=[ASSISTANTNODE_DATA([IBtemplateOutlineView_ itemAtRow:[IBtemplateOutlineView_ selectedRow]]) path];
        
        tFileManager=[NSFileManager defaultManager];
        
        tArray=[tFileManager directoryContentsAtPath:tPath];
        
        tCount=[tArray count];
        
        tMutableArray=[NSMutableArray arrayWithCapacity:tCount];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tComponent;
            
            tComponent=[tArray objectAtIndex:i];
            
            if ([tComponent hasSuffix:@".desc"]==YES)
            {
                BOOL isDirectory;
                NSString * tLocalizationFolder;
                
                tLocalizationFolder=[tPath stringByAppendingPathComponent:tComponent];
                
                if ([tFileManager fileExistsAtPath:[tLocalizationFolder stringByAppendingPathComponent:@"description.txt"] isDirectory:&isDirectory]==YES &&
                    isDirectory==NO)
                {
                    [tMutableArray addObject:[tComponent stringByDeletingPathExtension]];
                }
            }
        }
        
        if ([tMutableArray count]!=0)
        {
            NSString * tPreferedLanguage;
            
            tPreferedLanguage=[[NSBundle preferredLocalizationsFromArray:tMutableArray] objectAtIndex:0];
            
            if (tPreferedLanguage!=nil)
            {
                NSString * tFilePath;
                
                tFilePath=[[tPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.desc",tPreferedLanguage]] stringByAppendingPathComponent:@"description.txt"];
                
                tString=[NSString stringWithContentsOfFile:tFilePath];
            }
        }
        
        // Look for international description
        
        if (tString==nil)
        {
            tString=[NSString stringWithContentsOfFile:[[ASSISTANTNODE_DATA([IBtemplateOutlineView_ itemAtRow:[IBtemplateOutlineView_ selectedRow]]) path] stringByAppendingPathComponent:@"description.txt"]];
        }
        
        if (tString!=nil)
        {
            [IBtemplateDescription_ setStringValue:tString];
        }
        else
        {
            [IBtemplateDescription_ setStringValue:NSLocalizedString(@"No description available.",@"No comment")];
        }
        
        [mainController_ setEnableNextButton:YES];
    }
    else
    {
        [IBtemplateDescription_ setStringValue:@""];
        
        [mainController_ setEnableNextButton:NO];
    }
}

#pragma mark -

- (BOOL) checkPaneValuesWithEngine:(id) inEngine
{
    [inEngine setTemplateFolderPath:[ASSISTANTNODE_DATA([IBtemplateOutlineView_ itemAtRow:[IBtemplateOutlineView_ selectedRow]]) path]];
    
    [inEngine setTemplateName:[ASSISTANTNODE_DATA([IBtemplateOutlineView_ itemAtRow:[IBtemplateOutlineView_ selectedRow]]) name]];
    
    return YES;
}

- (void) processWithEngine:(id) inEngine
{
    /*
      Overload this method to process the data provided by the user in this pane
      Don't forget to add the AKProcessEngine subclass header in the code
    */
}

@end
