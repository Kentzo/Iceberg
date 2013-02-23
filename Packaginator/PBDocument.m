/*
Copyright (c) 2004-2009, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBDocument.h"
#import "ImageAndTextCell.h"

#import "NSDictionary+MutableDeepCopy.h"

#import "PBSimulatorController.h"

#import "PBPreferencePaneBuildController+Constants.h"

#import "PBPreferencePaneFilesController+Constants.h"

#import "PBBuildWindowController.h"

#include <unistd.h>
#include <sys/types.h>
#include <Carbon/Carbon.h>

#define SAFENODE(n) 	((PBProjectTree*)((n!=nil)?(n):(tree_)))

#define PBPackagePBoardType		@"PBPackagePBoardType"
#define PBExternalPBoardType		@"PBExternalPBoardType"

#define PBSettingsPBoardType		@"PBSettingsPBoardType"
#define PBDocumentsPBoardType		@"PBDocumentsPBoardType"
#define PBScriptsPBoardType		@"PBScriptsPBoardType"
#define PBPluginsPBoardType		@"PBPluginsPBoardType"
#define PBFilesPBoardType		@"PBFilesPBoardType"

#define PBDOCUMENT_RIGHTVIEW_MINWIDTH	460.0f

#define PBPANEVIEW_DIFF_HEIGHT	26.0f

static NSImage * sProjectNodeImage=nil;
static NSImage * sMetaPackageNodeImage=nil;
static NSImage * sPackageNodeImage=nil;
static NSImage * sSettingsNodeImage=nil;
static NSImage * sComponentsNodeImage=nil;
static NSImage * sFilesNodeImage=nil;
static NSImage * sResourcesNodeImage=nil;
static NSImage * sScriptsNodeImage=nil;
static NSImage * sPluginsNodeImage=nil;

static NSImage * sMetapackageImage=nil;
static NSImage * sPackageImage=nil;

static BOOL sImportedPackageDialog;

@implementation PBDocument

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (PBProjectNode *) projectNode
{
    PBProjectTree * tProjectTree;
    
    tProjectTree=(PBProjectTree *) [tree_ childAtIndex:0];
    
    return PROJECTNODE_DATA(tProjectTree);
}

- (PBObjectNode *) mainPackageNode
{
    PBProjectTree * tProjectTree;
    
    tProjectTree=(PBProjectTree *) [[tree_ childAtIndex:0] childAtIndex:0];
    
    return OBJECTNODE_DATA(tProjectTree);
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"PBDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    NSButtonCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    ImageAndTextCell *imageAndTextCell = nil;
    NSImageCell * tImageCell;
    
    [super windowControllerDidLoadNib:aController];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"Packages"];
    imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setEditable:YES];
    
    [tableColumn setDataCell:imageAndTextCell];
    
    [imageAndTextCell release];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[NSButtonCell alloc] initTextCell: @""];
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
    [tPrototypeCell setControlSize:NSMiniControlSize];
#else
	[tPrototypeCell setControlSize:NSSmallControlSize];
#endif
    
    [tPrototypeCell setEditable: YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    
    [tableColumn setDataCell:tPrototypeCell];
    
    [tPrototypeCell release];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"Flags"];
    
    tImageCell = [[NSImageCell alloc] initImageCell: nil];
    
    [tImageCell setImageAlignment:NSImageAlignCenter];
    [tImageCell setImageScaling:NSScaleNone];
    [tImageCell setImageFrameStyle:NSImageFrameNone];
    
    
    [tableColumn setDataCell:tImageCell];
    
    [tImageCell release];
    
    if (tree_==nil)
    {
        NSLog(@"No tree loaded");
    
        /*[self updateChangeCount:NSChangeDone];
        
        tree_=[PBProjectTree projectTreeWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testfile" ofType:@"plist"] andKeywordDictionary:nil];
    
        [tree_ retain];*/
    }
    
    [IBoutlineView_ registerForDraggedTypes:[NSArray arrayWithObjects:PBPackagePBoardType,
                                                                      PBExternalPBoardType,
                                                                      NSFilenamesPboardType,
                                                                      PBSettingsPBoardType,
                                                                      PBDocumentsPBoardType,
                                                                      PBScriptsPBoardType,
                                                                      PBFilesPBoardType,
                                                                      nil]];
    
    [IBoutlineView_ setAutoresizesOutlineColumn:NO];
    
    // Load images
    
    if (sMetaPackageNodeImage==nil)
    {
    	sMetaPackageNodeImage=[[NSImage imageNamed:@"metapackage16"] retain];
        sPackageNodeImage=[[NSImage imageNamed:@"package16"] retain];
        sSettingsNodeImage=[[NSImage imageNamed:@"settings"] retain];
        sComponentsNodeImage=[[NSImage imageNamed:@"Folder"] retain];
        sFilesNodeImage=[[NSImage imageNamed:@"file16"] retain];
        sResourcesNodeImage=[[NSImage imageNamed:@"document16"] retain];
        sScriptsNodeImage=[[NSImage imageNamed:@"scripts"] retain];
		sPluginsNodeImage=[[NSImage imageNamed:@"plugins"] retain];
    }
    
    // Stackable View
    
    [IBviewListView_ setLabelBarAppearance:MOViewListViewProjectBuilderLabelBars];
    
    [MOViewListView setUsesAnimation:NO];
    
    // Tree controllers
    
    projectController_=[PBProjectController projectController];
    
    resourcesController_=[PBResourcesController resourcesController];
    
    scriptsController_=[PBScriptsController scriptsController];
	
	pluginsController_=[PBPluginsController pluginsController];
    
    metaPackageSettingsController_=[PBMetaPackageSettingsController metaPackageSettingsController];
    componentsController_=[PBMetaPackageComponentsController metaPackageComponentsController];
    
    [componentsController_ setWindow:[aController window]];
    
    packageSettingsController_=[PBPackageSettingsController packageSettingsController];
    packageFilesController_=[PBPackageFilesController packageFilesController];
    
    defaultFilesHeight_=NSHeight([[packageFilesController_ view] bounds]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTree:)
                                                 name:@"PBTreeChanged"
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentDidUpdate:)
                                                 name:@"PBDocumentUpdated"
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentDidChange:)
                                                 name:@"PBDocumentChanged"
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentStatusDidChange:)
                                                 name:@"PBDocumentStatusChanged"
                                               object:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(expandSelectedRowNotification:)
                                                 name:@"PBDocumentExpandSelectedRow"
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundImageSettingsDidChange:)
                                                 name:@"PBBackgroundImageSettingsDidChange"
                                               object:self];
    
    [IBdocumentStatus_ setStringValue:@""];
    
    [IBdocumentProgressIndicator_ setUsesThreadedAnimation:YES];
    
    [IBoutlineView_ reloadData];
    
    [IBtype_ setStringValue:NSLocalizedString(@"No Selection",@"No comment")];
    
    [IBpopupButton_ setEnabled:NO];
    
    [[IBpopupButton_ itemAtIndex:0] setImage:[NSImage imageNamed:@"unselected.tif"]];
    
    [[IBpopupButton_ itemAtIndex:1] setImage:[NSImage imageNamed:@"selected.tif"]];
    
    [[IBpopupButton_ itemAtIndex:2] setImage:[NSImage imageNamed:@"required.tif"]];
    
    [IBoutlineView_ expandItem:[tree_ childAtIndex:0]];
    
    // Register for Builder Notifications
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(builderNotification:)
                                                            name:@"ICEBERGBUILDERNOTIFICATION"
                                                          object:nil
                                                          suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(builderNotification:)
                                                 name:@"ICEBERGBUILDERNOTIFICATION"
                                               object:nil];
    
    buildingState_=kPBBuildingNone;
    
    if (sMetapackageImage==nil)
    {
        sMetapackageImage=[[[NSWorkspace sharedWorkspace] iconForFileType:@"mpkg"] retain];
    }
    
    if (sPackageImage==nil)
    {
        sPackageImage=[[[NSWorkspace sharedWorkspace] iconForFileType:@"pkg"] retain];
    }
    
    defaultLeftViewWidth_=NSWidth([[[[IBrightView_ superview] subviews] objectAtIndex:0] frame]);
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)docType
{
    [tree_ writeToFile:fileName atomically:YES];
    
    return YES;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
    [tree_ release];
    
    tree_=[PBProjectTree projectTreeWithContentsOfFile:fileName  
                                  andKeywordDictionary:nil];
    
    [tree_ retain];
    
    return YES;
}

- (BOOL)revertToSavedFromFile:(NSString *)fileName ofType:(NSString *)type
{
    BOOL tResult;
    
    [IBoutlineView_ deselectAll:self];
    
    tResult=[super revertToSavedFromFile:fileName ofType:type];
    
    [IBoutlineView_ reloadData];
    
    [IBoutlineView_ expandItem:[tree_ childAtIndex:0]];
    
    return tResult;
}

- (void) updateTree:(NSNotification *) aNotification
{
    [self updateChangeCount:NSChangeDone];
    
    // is the notification for this instance of the controller
    
    [IBoutlineView_ reloadData];
    
    // Manage the PopupButton
    
    if (currentMasterTree_!=nil && [NODE_DATA(currentMasterTree_) type]==kPBPackageNode)
    {
        PBPackageNode * tNode;
        
        tNode=(PBPackageNode *) NODE_DATA(currentMasterTree_);
        
        if (tNode!=nil)
        {
            if ([tNode isRequired]==YES)
            {
                [IBpopupButton_ selectItemAtIndex:kObjectRequired+1];
                        
                [IBpopupButton_ setEnabled:NO];
            }
            else
            {
                [IBpopupButton_ selectItemAtIndex:[tNode attribute]+1];
                
                [IBpopupButton_ setEnabled:YES];
            }
        }
    }
}

#pragma mark -

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSArray * tSubviews;
    NSView * tViewLeft,* tViewRight;
    NSRect tLeftFrame,tRightFrame;
    NSRect tSplitViewFrame=[sender frame];
    
    tSubviews=[sender subviews];
    
    tViewLeft=[tSubviews objectAtIndex:0];
    
    tLeftFrame=[tViewLeft frame];
    
    tViewRight=[tSubviews objectAtIndex:1];
    
    if ([sender isSubviewCollapsed:tViewRight]==NO)
    {
        tRightFrame=[tViewRight frame];
        
        tRightFrame.size.width=NSWidth(tSplitViewFrame)-[sender dividerThickness]-NSWidth(tLeftFrame);
        
        if (NSWidth(tRightFrame)<PBDOCUMENT_RIGHTVIEW_MINWIDTH)
        {
            tRightFrame.size.width=PBDOCUMENT_RIGHTVIEW_MINWIDTH;
            
            tLeftFrame.size.width=NSWidth(tSplitViewFrame)-[sender dividerThickness]-NSWidth(tRightFrame);
            
            if (NSWidth(tLeftFrame)<0)
            {
                tLeftFrame.size.width=0;
            }
        }
        
        tRightFrame.size.height=NSHeight(tSplitViewFrame);
        
        tRightFrame.origin.y=0;
        
        [tViewRight setFrame:tRightFrame];
    }        
    else
    {
        tLeftFrame.size.width=NSWidth(tSplitViewFrame)-[sender dividerThickness];
    
        if (NSWidth(tLeftFrame)<0)
        {
            tLeftFrame.size.width=0;
        }
    }
    
    tLeftFrame.size.height=NSHeight(tSplitViewFrame);
        
    tLeftFrame.origin.y=0;
        
    [tViewLeft setFrame:tLeftFrame];
    
    [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
    if (subview==IBrightView_)
    {
        return YES;
    }
    
    return NO;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
    return (NSWidth([sender frame])-(PBDOCUMENT_RIGHTVIEW_MINWIDTH+[sender dividerThickness]));
}

#pragma mark -

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
    if (tree_!=nil)
    {
        return [SAFENODE(item) childAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
    return ![NODE_DATA(item) isLeaf];
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
    if (tree_!=nil)
    {
        return [SAFENODE(item) numberOfChildren];
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    int tType;
    
    tType=[NODE_DATA(item) type];
    
    if([[tableColumn identifier] isEqualToString: @"Packages"])
    {
        static NSDictionary * sTruncatedAttributes=nil;
        
        if (sTruncatedAttributes==nil)
        {
            NSMutableParagraphStyle * sTruncatableStyle;
            
            sTruncatableStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            
            if (sTruncatableStyle!=nil)
            {
                [sTruncatableStyle setLineBreakMode:NSLineBreakByTruncatingTail];
                
                sTruncatedAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:sTruncatableStyle,NSParagraphStyleAttributeName,
                                                                                  nil];
                
                [sTruncatableStyle release];
            }
        }
        
        objectValue = [NODE_DATA(item) name];
        
        if (sTruncatedAttributes!=nil)
        {
            return [[[NSAttributedString alloc] initWithString:objectValue attributes:sTruncatedAttributes] autorelease];
        }
        
        return objectValue;
    }
    else if ([NODE_DATA(item) isLeaf]==NO &&
             tType!=kComponentsNode &&
             tType!=kProjectNode)
    {
        if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
            objectValue = [NSNumber numberWithBool: [NODE_DATA(item) status]];
        }
        else if ([[tableColumn identifier] isEqualToString: @"Flags"])
        {
            if ([NODE_DATA([item nodeParent]) type]!=kProjectNode)
            {
                if (tType==kPBPackageNode)
                {
                    PBPackageNode * tPackageNode;
                    
                    tPackageNode=(PBPackageNode *) NODE_DATA(item);
                    
                    if ([tPackageNode isRequired]==YES)
                    {
                        return [NSImage imageNamed:@"required.tif"];
                    }
                }
                
                switch([((PBObjectNode *) NODE_DATA(item)) attribute])
                {
                    case kObjectUnselected:
                        objectValue=[NSImage imageNamed:@"unselected.tif"];
                        break;
                    case kObjectSelected:
                        objectValue=[NSImage imageNamed:@"selected.tif"];
                        break;
                    case kObjectRequired:
                        objectValue=[NSImage imageNamed:@"required.tif"];
                        break;
                }
            }
        }
    }
        
    return objectValue;
}

- (void)outlineView:(NSOutlineView *)olv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    canRenameItem_=NO;
    
    if ([[tableColumn identifier] isEqualToString: @"Status"])
    {
        if ([NODE_DATA(item) isLeaf]==NO &&
             [NODE_DATA(item) type]!=kComponentsNode &&
             [NODE_DATA(item) type]!=kProjectNode)
        {
            [NODE_DATA(item) setStatus:[object boolValue]];
            
            [self updateChangeCount:NSChangeDone];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PBComponentsListChanged"
                                                                object:self];
        }
    }
    else
    {
        if ([[tableColumn identifier] isEqualToString: @"Packages"])
        {
            if ([object isEqualToString:[NODE_DATA(item) name]]==NO)
            {
                [NODE_DATA(item) setName:object];
            
                [self updateChangeCount:NSChangeDone];
            
                [IBname_ setStringValue:object];
            }
        }
    }
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{    
    if ([[tableColumn identifier] isEqualToString: @"Status"])
    {
        int tStatus;
        
        tStatus=[NODE_DATA(item) status];
        
        if (tStatus!=-1)
        {
            if ([NODE_DATA([item nodeParent]) type]==kProjectNode)
            {
                [(NSButtonCell *)cell setImagePosition: NSNoImage];
            }
            else
            {
                [(NSButtonCell *)cell setImagePosition: NSImageOnly];
            }
        }
        else
        {
            [(NSButtonCell *)cell setImagePosition: NSNoImage];
        }
    }
    else
    if ([[tableColumn identifier] isEqualToString: @"Packages"])
    {
        NSImage * tImage=nil;
        
        switch([NODE_DATA(item) type])
        {
            case kProjectNode:
                tImage=sProjectNodeImage;
                break;
            case kPBMetaPackageNode:
                tImage=sMetaPackageNodeImage;
                break;
            case kPBPackageNode:
                tImage=sPackageNodeImage;
                break;
            case kSettingsNode:
                tImage=sSettingsNodeImage;
                break;
            case kComponentsNode:
                tImage=sComponentsNodeImage;
                break;
            case kFilesNode:
                tImage=sFilesNodeImage;
                break;
            case kResourcesNode:
                tImage=sResourcesNodeImage;
                break;
            case kScriptsNode:
                tImage=sScriptsNodeImage;
                break;
			case kPluginsNode:
                tImage=sPluginsNodeImage;
                break;
        }
        
        [(ImageAndTextCell*)cell setImage: tImage];
    }
}

#pragma mark -

// ================================================================
//  NSOutlineView data source methods. (dragging related)
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
    if ([items count]==1)
    {
        PBProjectTree * tProjectTree;
        NSString * tPasteBoardType;
        
        tProjectTree=[items objectAtIndex:0];
        
        switch([NODE_DATA(tProjectTree) type])
        {
            case kPBMetaPackageNode:
            case kPBPackageNode:
                [pboard declareTypes:[NSArray arrayWithObjects: PBPackagePBoardType,PBExternalPBoardType,nil] owner:self];
    
                [pboard setData:[NSData data] forType:PBPackagePBoardType]; 
                tPasteBoardType=PBExternalPBoardType;
                
                internalDragData_=items;
                break;
            default:
        	if (GetCurrentKeyModifiers()==(1<<optionKeyBit))
                {
                    switch([NODE_DATA(tProjectTree) type])
                    {
                        case kSettingsNode:
                            [pboard declareTypes:[NSArray arrayWithObject:PBSettingsPBoardType] owner:self];
                            
                            tPasteBoardType=PBSettingsPBoardType;
                            break;
                        case kFilesNode:
                            [pboard declareTypes:[NSArray arrayWithObject:PBFilesPBoardType] owner:self];
                            
                            tPasteBoardType=PBFilesPBoardType;
                            break;
                        case kResourcesNode:
                            [pboard declareTypes:[NSArray arrayWithObject:PBDocumentsPBoardType] owner:self];
                            
                            tPasteBoardType=PBDocumentsPBoardType;
                            break;
                        case kScriptsNode:
                            [pboard declareTypes:[NSArray arrayWithObject:PBScriptsPBoardType] owner:self];
                            
                            tPasteBoardType=PBScriptsPBoardType;
                            break;
						case kPluginsNode:
                            [pboard declareTypes:[NSArray arrayWithObject:PBPluginsPBoardType] owner:self];
                            
                            tPasteBoardType=PBPluginsPBoardType;
                            break;
                        default:
                            return NO;
                    }
                }
                else
                {
                    return NO;
                }
        }
        
        [pboard setPropertyList:[tProjectTree dictionary] forType:tPasteBoardType];
        
        return YES;
    }
    
    return NO;
}

- (unsigned int)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)childIndex
{
    NSPasteboard * tPasteBoard;
    NSString * tAvailableType;
    
    tPasteBoard=[info draggingPasteboard];
    
    switch(childIndex)
    {
        case NSOutlineViewDropOnItemIndex:
            tAvailableType=[tPasteBoard availableTypeFromArray:[NSArray arrayWithObjects:PBSettingsPBoardType,
                                                                                         PBDocumentsPBoardType,
                                                                                         PBScriptsPBoardType,
                                                                                         PBFilesPBoardType,
                                                                                         nil]];
            
            if (tAvailableType!=nil)
            {
                switch([NODE_DATA(item) type])
                {
                    case kSettingsNode:
                        if ([tAvailableType isEqualToString:PBSettingsPBoardType]==YES)
                        {
                            // Check that the components kind are the same (i.e. both Packages or Metapackages)
                            
                            NSDictionary * tDictionary;
                            
                            tDictionary=(NSDictionary *) [tPasteBoard propertyListForType:tAvailableType];
                            
                            if ([NODE_DATA([item nodeParent]) type]==kPBPackageNode)
                            {
                                if ([tDictionary objectForKey:@"Options"]==nil)
                                {
                                    break;
                                }
                            }
                            else
                            {
                                if ([tDictionary objectForKey:@"Options"]!=nil)
                                {
                                    break;
                                }
                            }
                            
                            return NSDragOperationGeneric;
                        }
                        break;
                    case kResourcesNode:
                        if ([tAvailableType isEqualToString:PBDocumentsPBoardType]==YES)
                        {
                            return NSDragOperationGeneric;
                        }
                        break;
                    case kFilesNode:
                        if ([tAvailableType isEqualToString:PBFilesPBoardType]==YES)
                        {
                            return NSDragOperationGeneric;
                        }
                        break;
                    case kScriptsNode:
                        if ([tAvailableType isEqualToString:PBScriptsPBoardType]==YES)
                        {
                            return NSDragOperationGeneric;
                        }
                        break;
					 case kPluginsNode:
                        if ([tAvailableType isEqualToString:PBPluginsPBoardType]==YES)
                        {
                            return NSDragOperationGeneric;
                        }
                        break;
                }
            }
            break;
        default:
            switch([NODE_DATA(item) type])
            {
                case kProjectNode:
                    if ([item numberOfChildren]==0)
                    {
                    	if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
                        {
                            return [PBMetaPackageComponentsController validateDropOfFiles:info inTree:item];
                        }
                        else
                        {
                            return NSDragOperationGeneric;
                        }
                    }
                    break;
                case kComponentsNode:
                    if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
                    {
                        return [PBMetaPackageComponentsController validateDropOfFiles:info inTree:item];
                    }
                    else if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObjects:PBPackagePBoardType,PBExternalPBoardType,nil]]!=nil)
                    {
                        if ([info draggingSource]==IBoutlineView_)
                        {
                            if ([item isDescendantOfNodeInArray:internalDragData_]==YES)
                            {
                                return NSDragOperationNone;
                            }
                        }
                        
                        return NSDragOperationGeneric;
                    }
                    
                    break;
            }
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(int)childIndex
{
    NSPasteboard * tPasteBoard;
    NSMutableArray * tNewSelectionArray;
    int k,tNewCount;
    int tCount;
    
    tNewSelectionArray=[NSMutableArray array];
    
    tPasteBoard=[info draggingPasteboard];
    
    if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObjects: PBPackagePBoardType,PBExternalPBoardType,nil]]!=nil)
    {
        PBProjectTree * tProjectTree;
        
        if ([info draggingSource]==IBoutlineView_)
        {
            // Internal Drag, we need to move

            tProjectTree=(PBProjectTree *) [internalDragData_ objectAtIndex:0];
            
            if ([tProjectTree nodeParent]==targetItem)
            {
                int tIndex;
                
                tIndex=[targetItem indexOfChild:tProjectTree];
                
                if (tIndex<childIndex)
                {
                    childIndex--;
                }
            }
            
            [tProjectTree removeFromParent];
            
            [((PBProjectTree *) targetItem) insertChild:tProjectTree
                            atIndex:childIndex];
        
        
            selectionDidNotReallyChanged_=YES;		// Optimization (since the selected items are not changed)
            
            tCount=[IBoutlineView_ numberOfSelectedRows];
            
            if (tCount>0)
            {
                NSEnumerator * tEnumerator;
                NSNumber * tNumber;
            
                tEnumerator=[IBoutlineView_ selectedRowEnumerator];
                
                while (tNumber = (NSNumber *) [tEnumerator nextObject])
                {
                    [tNewSelectionArray addObject:[IBoutlineView_ itemAtRow:[tNumber intValue]]];
                }
            }
        }
        else
        {
            // External Drag, we need to add
            
            tProjectTree=[PBProjectTree projectTreeWithDictionary:[tPasteBoard propertyListForType:PBExternalPBoardType]];
            
            [((PBProjectTree *) targetItem) insertChild:tProjectTree
                            atIndex:childIndex];
            
            [tNewSelectionArray addObject:tProjectTree];
        }
    }
    else
    {
        if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject: NSFilenamesPboardType]]!=nil)
        {
        	tNewSelectionArray=[componentsController_ importPackagesWithArray:(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType]
                                                                            atRow:childIndex
                                                                 forComponentTree:targetItem
                                                                      andDocument:self];
        
        }
        else
        {
            NSString * tAvailableType;
            
            tAvailableType=[tPasteBoard availableTypeFromArray:[NSArray arrayWithObjects:PBSettingsPBoardType,
                                                                              PBDocumentsPBoardType,
                                                                              PBScriptsPBoardType,
                                                                              PBFilesPBoardType,
                                                                              nil]];
            
            if (tAvailableType!=nil)
            {
                NSDictionary * tDictionary;
                PBNode * tNode;
                PBObjectNode * tParentNode;
                
                tDictionary=(NSDictionary *) [tPasteBoard propertyListForType:tAvailableType];
                
                tNode=NODE_DATA(targetItem);
                
                tParentNode=OBJECTNODE_DATA([targetItem nodeParent]);
                
                switch([tNode type])
                {
                    case kSettingsNode:
                        [tParentNode setSettings:tDictionary];
                        break;
                    case kResourcesNode:
                        [tParentNode setResources:tDictionary];
                        break;
                    case kFilesNode:
                        [((PBPackageNode *) tParentNode) setFiles:tDictionary];
                        break;
                    case kScriptsNode:
                        [tParentNode setScripts:tDictionary];
                        break;
					case kPluginsNode:
                        [tParentNode setPlugins:tDictionary];
                        break;
                }
                
                [tNewSelectionArray addObject:targetItem];
            }
        }
    }
    
    [self updateChangeCount:NSChangeDone];
    
    tNewCount=[tNewSelectionArray count];
    
    if (tNewCount>0)
    {
        [IBoutlineView_ deselectAll:nil];
    }
    
    [IBoutlineView_ reloadData];
        
    for(k=0;k<tNewCount;k++)
    {
        [IBoutlineView_ selectRow:[IBoutlineView_ rowForItem:[tNewSelectionArray objectAtIndex:k]]
             byExtendingSelection:YES];
    }
    
    return YES;
}

#pragma mark -

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    switch([NODE_DATA(item) type])
    {
        case kPBMetaPackageNode:
        case kPBPackageNode:
            
            
            return canRenameItem_;
    }
    
    return NO;
}

#pragma mark -

- (void) clearListView
{
    int i,tCount;
    
    tCount=[IBviewListView_ numberOfViewListViewItems];
        
    for(i=tCount-1;i>=0;i--)
    {
        NSView * tView;
        
        tView=[[IBviewListView_ viewListViewItemAtIndex:i] view];
        
        [IBviewListView_ removeViewListViewItemAtIndex:i];
        
        [tView removeFromSuperview];
    }
}

- (NSArray *) paneArrayFromSelectionForMasterTree:(PBProjectTree **) outMasterTree
{
    NSMutableArray * nArray;
    NSEnumerator * tEnumerator;
    NSNumber * tRowNumber;
    PBProjectTree * tMasterTree=nil;
    BOOL completed=NO;
    
    nArray=[NSMutableArray array];
    
    tEnumerator=[IBoutlineView_ selectedRowEnumerator];
    
    while ((tRowNumber=[tEnumerator nextObject])!=nil)
    {
        int tRow;
        PBProjectTree * tNode;
        int tNodeType;
        PBProjectTree * cMasterTree=nil;
        
        
        tRow=[tRowNumber intValue];
        
        tNode=[IBoutlineView_ itemAtRow:tRow];
        
        tNodeType=[NODE_DATA(tNode) type];
        
        switch(tNodeType)
        {
            case kProjectNode:
            case kPBPackageNode:
            case kPBMetaPackageNode:
                cMasterTree=tNode;
                
                break;
            case kComponentsNode:
            case kSettingsNode:
            case kResourcesNode:
            case kFilesNode:
            case kScriptsNode:
			case kPluginsNode:
                cMasterTree=(PBProjectTree *) [tNode nodeParent];
                
                break;
        }
        
        if (tMasterTree==nil)
        {
            tMasterTree=cMasterTree;
        }
        else
        {
            if (cMasterTree!=tMasterTree)
            {
                return nil;
            }
        }
        
        switch(tNodeType)
        {
            case kProjectNode:
            case kComponentsNode:
            case kSettingsNode:
            case kResourcesNode:
            case kFilesNode:
            case kScriptsNode:
			case kPluginsNode:
                if (completed==NO)
                {
                    [nArray addObject:[NSNumber numberWithInt:tNodeType]];
                }
                
                break;
            case kPBPackageNode:
                completed=YES;
                
                [nArray addObject:[NSNumber numberWithInt:kSettingsNode]];
                [nArray addObject:[NSNumber numberWithInt:kResourcesNode]];
                [nArray addObject:[NSNumber numberWithInt:kScriptsNode]];
				[nArray addObject:[NSNumber numberWithInt:kPluginsNode]];
                [nArray addObject:[NSNumber numberWithInt:kFilesNode]];
                
                break;
            case kPBMetaPackageNode:
                completed=YES;
                
                [nArray addObject:[NSNumber numberWithInt:kSettingsNode]];
                [nArray addObject:[NSNumber numberWithInt:kResourcesNode]];
                [nArray addObject:[NSNumber numberWithInt:kScriptsNode]];
				[nArray addObject:[NSNumber numberWithInt:kPluginsNode]];
                [nArray addObject:[NSNumber numberWithInt:kComponentsNode]];
                
                break;
        }
    }
    
    *outMasterTree=tMasterTree;
    
    return nArray;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int tSelectedCount;
    id tController;
    int i,tCount;
    BOOL disablePopup=NO;
    
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
    
    if (selectionDidNotReallyChanged_==YES)
    {
        if (tSelectedCount>0)
        {
            selectionDidNotReallyChanged_=NO;
        }
        
        return;
    }
    
    if (currentControllers_!=nil)
    {
        tCount=[currentControllers_ count];
        
        for(i=0;i<tCount;i++)
        {
            tController=[currentControllers_ objectAtIndex:i];
            
            [tController treeWillChange];
        
            [[NSNotificationCenter defaultCenter] removeObserver:tController name:nil object:self];
        }
        
        [currentControllers_ release];
        
        currentControllers_=nil;
        
        
    }
    
    currentMasterTree_=nil;
    
    [self clearListView];
    
    if (tSelectedCount>=1)
    {
        NSArray * tPaneArray;
        
        tPaneArray=[self paneArrayFromSelectionForMasterTree:&currentMasterTree_];
        
        if (tPaneArray!=nil)
        {
            NSEnumerator * tEnumerator;
            NSNumber * tNumber;
            int tIndex=0;
            
            [IBviewListView_ disableLayout];
            
            tEnumerator=[tPaneArray objectEnumerator];
            
            currentControllers_=[[NSMutableArray alloc] initWithCapacity:4];
            
            while (tNumber=[tEnumerator nextObject])
            {
                switch([tNumber intValue])
                {
                    case kProjectNode:
                        [IBviewListView_ addStackedView:[projectController_ view] withLabel:NSLocalizedString(@"Project Settings",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:projectController_];
                        
                        break;
                    case kComponentsNode:
                        [IBviewListView_ addStackedView:[componentsController_ view] withLabel:NSLocalizedString(@"Components",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:componentsController_];
                                                                    
                        [[NSNotificationCenter defaultCenter] addObserver:componentsController_
                                                                selector:@selector(updateView:)
                                                                    name:@"PBComponentsListChanged"
                                                                object:self];
                                                                
                        break;
                    case kSettingsNode:
                        
                        switch([NODE_DATA(currentMasterTree_) type])
                        {
                            case kPBPackageNode:
                                [IBviewListView_ addStackedView:[packageSettingsController_ view] withLabel:NSLocalizedString(@"Settings",@"No comment")];
                                
                                [currentControllers_ addObject:packageSettingsController_];
                                break;
                            case kPBMetaPackageNode:
                                [IBviewListView_ addStackedView:[metaPackageSettingsController_ view] withLabel:NSLocalizedString(@"Settings",@"No comment")];
                                
                                [currentControllers_ addObject:metaPackageSettingsController_];
                                break;
                        }
                        
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        break;
                        
                    case kResourcesNode:
                        [IBviewListView_ addStackedView:[resourcesController_ view] withLabel:NSLocalizedString(@"Documents",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:resourcesController_];
                        
                        [[NSNotificationCenter defaultCenter] addObserver:resourcesController_
                                                                selector:@selector(backgroundImageSettingsDidChange:)
                                                                    name:@"PBBackgroundImageSettingsDidChange"
                                                                  object:self];
                        
                        break;
                        
                    case kFilesNode:
                        {
                            NSView * tView;
                            
                            tView=[packageFilesController_ view];
                            
                            if (NSHeight([tView bounds])!=defaultFilesHeight_)
                            {
                                [tView setFrameSize:NSMakeSize(NSWidth([tView bounds]),defaultFilesHeight_)];
                            }
                        }
                        
                        [IBviewListView_ addStackedView:[packageFilesController_ view] withLabel:NSLocalizedString(@"Files",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:packageFilesController_];
                        
                        break;
                        
                    case kScriptsNode:
                        [IBviewListView_ addStackedView:[scriptsController_ view] withLabel:NSLocalizedString(@"Scripts",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:scriptsController_];
                        
                        break;
					
					 case kPluginsNode:
                        [IBviewListView_ addStackedView:[pluginsController_ view] withLabel:NSLocalizedString(@"Plugins",@"No comment")];
                        [IBviewListView_ expandStackedViewAtIndex:tIndex++];
                        
                        [currentControllers_ addObject:pluginsController_];
                        
                        break;
                        
                    default:
                        break;
                }
            }
            
            [IBviewListView_ enableLayout];
            
            if (currentControllers_!=nil)
            {
                tCount=[currentControllers_ count];
                
                for(i=0;i<tCount;i++)
                {
                    tController=(PBController *) [currentControllers_ objectAtIndex:i];
                    
                    [tController initWithProjectTree:currentMasterTree_ forDocument:self];
                }
            }
            
            switch([NODE_DATA(currentMasterTree_) type])
            {
                case kProjectNode:
                    [IBtype_ setStringValue:NSLocalizedString(@"Project",@"No comment")];
                    [IBicon_ setImage:[NSImage imageNamed:@"IcebergDoc"]];
                        
                    disablePopup=YES;
                    break;
                case kPBMetaPackageNode:
                    [IBtype_ setStringValue:NSLocalizedString(@"Metapackage",@"No comment")];
                    
                    [IBicon_ setImage:sMetapackageImage];
                    
                    [IBpopupButton_ selectItemAtIndex:[((PBObjectNode *) NODE_DATA(currentMasterTree_)) attribute]+1];
                    break;
                case kPBPackageNode:
                    {
                        PBPackageNode * tPackageNode;
                        
                        [IBtype_ setStringValue:NSLocalizedString(@"Package",@"No comment")];
                        [IBicon_ setImage:sPackageImage];
                        
                        // We need to check the Required flag to see what we need to do
                        
                        tPackageNode=(PBPackageNode *) NODE_DATA(currentMasterTree_);
                        
                        if ([tPackageNode isRequired]==YES)
                        {
                            [IBpopupButton_ selectItemAtIndex:kObjectRequired+1];
                            disablePopup=YES;
                        }
                        else
                        {
                            [IBpopupButton_ selectItemAtIndex:[((PBObjectNode *) NODE_DATA(currentMasterTree_)) attribute]+1];
                        }
                    }
                    break;
            }
            
            [IBname_ setStringValue:[NODE_DATA(currentMasterTree_) name]];
        
            if ([NODE_DATA([currentMasterTree_ nodeParent]) type]==kProjectNode)
            {
                if ([IBpopupButton_ isEnabled]==YES)
                {
                    [IBpopupButton_ setEnabled:NO];
                }
                
                if ([IBname_ isEnabled]==NO)
                {
                    [IBname_ setEnabled:YES];
                }
            }
            else
            {
                if ([NODE_DATA(currentMasterTree_) type]==kProjectNode)
                {
                    if ([IBname_ isEnabled]==YES)
                    {
                        [IBname_ setEnabled:NO];
                    }
                }
                else
                {
                    if ([IBname_ isEnabled]==NO)
                    {
                        [IBname_ setEnabled:YES];
                    }
                }
                
                if (disablePopup==NO)
                {
                    if ([IBpopupButton_ isEnabled]==NO)
                    {
                        [IBpopupButton_ setEnabled:YES];
                    }
                }
                else
                {
                    if ([IBpopupButton_ isEnabled]==YES)
                    {
                        [IBpopupButton_ setEnabled:NO];
                    }
                }
            }
            
            [self windowDidResize:nil];
            
            return;
        }
    }
        
    [IBname_ setStringValue:@""];
    
    if (tSelectedCount==0)
    {
        [IBtype_ setStringValue:NSLocalizedString(@"No Selection",@"No comment")];
        [IBicon_ setImage:nil];
    }
    else
    {
        [IBtype_ setStringValue:NSLocalizedString(@"Multiple Selection",@"No comment")];
    }
    
    if ([IBname_ isEnabled]==YES)
    {
        [IBname_ setEnabled:NO];
    }
    
    if ([IBpopupButton_ isEnabled]==YES)
    {
        [IBpopupButton_ setEnabled:NO];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
    
    if (tAction==@selector(showHideBuildWindow:))
    {
        if ([[buildWindowController_ window] isVisible]==YES)
        {
            [aMenuItem setTitle:NSLocalizedString(@"Hide Build Log Window",@"No comment")];
        }
        else
        {
            [aMenuItem setTitle:NSLocalizedString(@"Show Build Log Window",@"No comment")];
        }
        
        return YES;
    }
    else
    if (tAction==@selector(build:))
    {
        if (buildingState_!=kPBBuildingNone)
        {
            return NO;
        }
    }
    else
    if (tAction==@selector(saveDocument:) ||
        tAction==@selector(saveDocumentAs:))
    {
        if (buildingState_==kPBBuildingLaunched)
        {
            return NO;
        }
    }
    else
    if (tAction==@selector(addFiles:) ||
        tAction==@selector(newFolder:) ||
        tAction==@selector(selectDefaultLocationPath:) ||
        tAction==@selector(expandAll:) ||
		tAction==@selector(expand:) ||
        tAction==@selector(expandOneLevel:))
    {
        if (currentMasterTree_!=nil)
        {
            if ([NODE_DATA(currentMasterTree_) type]==kPBPackageNode)
            {
                int i,tCount;
                
                tCount=[currentControllers_ count];
                
                for(i=0;i<tCount;i++)
                {
                    if ([currentControllers_ objectAtIndex:i]==packageFilesController_)
                    {
                        return [packageFilesController_ validateMenuItem:aMenuItem];
                    }
                }
            }
        }
        
        return NO;
    }
    else
    if (tAction==@selector(switchAttribute:))
    {
        return [IBpopupButton_ isEnabled];
    }
    else
    if (tAction==@selector(showHideHierarchy:))
    {
        NSRect tFrame;
        
        tFrame=[[IBoutlineView_ superview] frame];
        
        if (NSWidth(tFrame)<2)
        {
            [aMenuItem setTitle:NSLocalizedString(@"Show Hierarchy",@"No comment")];
        }
        else
        {
            [aMenuItem setTitle:NSLocalizedString(@"Hide Hierarchy",@"No comment")];
        }
    
        return YES;
    }
    else
    if (tAction==@selector(showFilesComponentsPane:))
    {
        PBProjectTree * tNode;
        
        tNode=currentMasterTree_;
        
        if (tNode==nil)
        {
            tNode=(PBProjectTree *) [tree_ childAtIndex:0];
        }
        
        if ([NODE_DATA(tNode) type]==kProjectNode)
        {
            tNode=(PBProjectTree *) [tNode childAtIndex:0];
        }
        
        if (tNode!=nil)
        {
            switch([NODE_DATA(tNode) type])
            {
                case kPBMetaPackageNode:
                    [aMenuItem setTitle:NSLocalizedString(@"Components",@"No comment")];
                    return YES;
                case kPBPackageNode:
                    [aMenuItem setTitle:NSLocalizedString(@"Files",@"No comment")];
                    
            }
            
            return YES;
        }
        
        return NO;
    }
    else
    if (tAction==@selector(showProjectPane:))
    {
        return YES;
    }
    else if (tAction==@selector(showSettingsPane:) ||
        tAction==@selector(showDocumentsPane:) ||
        tAction==@selector(showScriptsPane:))
    {
        return ([IBoutlineView_ numberOfSelectedRows]<=1);
    }
    else if (tAction==@selector(duplicate:))
	{
		int tSelectedCount;
    
        tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
    
        if (tSelectedCount==1)
        {
            PBProjectTree * tNode;
            int tSelectedRow;
            
            tSelectedRow=[IBoutlineView_ selectedRow];
        
            if (tSelectedRow>=0)
            {
                tNode=[IBoutlineView_ itemAtRow:tSelectedRow];
            
                if ([NODE_DATA(tNode) type]==kPBPackageNode && [NODE_DATA([tNode nodeParent]) type]==kComponentsNode)
                {
					return YES;
				}
			}
        }
        
		return NO;
	}
	else if (tAction==@selector(newComponent:) ||
        tAction==@selector(rename:) ||
        tAction==@selector(delete:) ||
        tAction==@selector(group:) ||
        tAction==@selector(ungroup:) ||
        tAction==@selector(importPackages:) ||
        tAction==@selector(sortByName:) ||
        tAction==@selector(sortByAttribute:))
    {
		int tSelectedCount;
    
        tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
    
        if (tSelectedCount==0)
        {
            return NO;
        }
        else
        if (tSelectedCount==1)
        {
            PBProjectTree * tNode;
            int tSelectedRow;
            
            tSelectedRow=[IBoutlineView_ selectedRow];
        
            if (tSelectedRow>=0)
            {
                tNode=[IBoutlineView_ itemAtRow:tSelectedRow];
            
                switch([NODE_DATA(tNode) type])
                {
                    case kProjectNode:
                        /*if ([tNode numberOfChildren]==0)
                        {
                            if (tAction!=@selector(newComponent:))
                            {
                                return NO;
                            }
                        }
                        else
                        {*/
                            return NO;
                        /*}*/
                        break;
                    case kComponentsNode:
                        if (tAction!=@selector(newComponent:) && 
                            tAction!=@selector(importPackages:) && 
                            tAction!=@selector(sortByName:) && 
                            tAction!=@selector(sortByAttribute:))
                        {
                            return NO;
                        }
                        break;
                    case kPBMetaPackageNode:
                        if (tAction==@selector(newComponent:) ||
                            tAction==@selector(importPackages:))
                        {
                            return YES;
                        }
                    case kPBPackageNode:
                        if (tAction==@selector(ungroup:))
                        {
                            if ([NODE_DATA([tNode nodeParent]) type]!=kComponentsNode ||
                                ([NODE_DATA([[[tNode nodeParent] nodeParent] nodeParent]) type]==kProjectNode &&
                                [[tNode nodeParent] numberOfChildren]!=1))
                            {
                                return NO;
                            }
                        }
                        else
                        if (tAction==@selector(delete:))
                        {
                            if ([NODE_DATA([tNode nodeParent]) type]==kProjectNode)
                            {
                                return NO;
                            }
                        }
                        else
                        if (tAction!=@selector(rename:) &&
                            
                            tAction!=@selector(group:))
                        {
                            return NO;
                        }
                        break;
                    default:
                        return NO;
                }
            }
        }
        else
        {
            if (tSelectedCount>1)
            {
                NSEnumerator * tEnumerator;
                NSNumber * tNumber;
                PBProjectTree * tParent=nil;
                int tCount=0;
                
                tEnumerator=[IBoutlineView_ selectedRowEnumerator];
                
                while (tNumber = (NSNumber *) [tEnumerator nextObject])
                {
                    int tIndex;
                    PBProjectTree * tNode;
                    
                    tIndex=[tNumber intValue];
                    
                    tNode=[IBoutlineView_ itemAtRow:tIndex];
                    
                    switch([NODE_DATA(tNode) type])
                    {
                        case kPBMetaPackageNode:
                        case kPBPackageNode:
                            if (tAction==@selector(delete:) ||
                                tAction==@selector(group:) ||
                                tAction==@selector(ungroup:))
                            {
                                if (tParent==nil)
                                {
                                    tParent=(PBProjectTree *) [tNode nodeParent];
                                }
                                else
                                if (tParent!=(PBProjectTree *) [tNode nodeParent] && tAction!=@selector(delete:))
                                {
                                    return NO;
                                }
                            }
                            else
                            {
                                return NO;
                            }
                            
                            tCount++;
                            break;
                        default:
                            return NO;
                    }
                }
                
                if (tAction==@selector(ungroup:))
                {
                    if ([tParent numberOfChildren]!=tCount ||
                        ([NODE_DATA([[tParent nodeParent] nodeParent]) type]==kProjectNode &&
                        [tParent numberOfChildren]!=1))
                    {
                        return NO;
                    }
                }
            }
        }
    }
    else
    {
        return [super validateMenuItem:aMenuItem];
    }
    
    return YES;
}

#pragma mark -

- (void) expandSelectedRowNotification:(NSNotification *)notification
{
    int tRow;
    id tItem;
    
    tRow=[IBoutlineView_ selectedRow];

    tItem=[IBoutlineView_ itemAtRow:tRow];

    if ([NODE_DATA(tItem) type]!=kPBMetaPackageNode)
    {
        if ([IBoutlineView_ isItemExpanded:tItem]==NO)
        {
            [IBoutlineView_ expandItem:tItem];
        }
		else
		{
			[IBoutlineView_ reloadData];
		}
    }
}

- (IBAction) newComponent:(id) sender
{
    [componentsController_ newComponent:sender];
}

- (IBAction) duplicate:(id) sender
{
	int tSelectedCount;
    
	tSelectedCount=[IBoutlineView_ numberOfSelectedRows];

	if (tSelectedCount==1)
	{
		PBProjectTree * tNode;
		int tSelectedRow;
		
		tSelectedRow=[IBoutlineView_ selectedRow];
	
		if (tSelectedRow>=0)
		{
			PBProjectTree * tParentNode;
			
			tNode=[IBoutlineView_ itemAtRow:tSelectedRow];
			
			tParentNode=(PBProjectTree *) [tNode nodeParent];
			
			if ([NODE_DATA(tNode) type]==kPBPackageNode && [NODE_DATA(tParentNode) type]==kComponentsNode)
			{
				NSMutableDictionary * tDisplayInformationDictionary;
				
				tDisplayInformationDictionary=[[NODE_DATA(tNode) settings] objectForKey:@"Display Information"];
				
				if (tDisplayInformationDictionary!=nil)
				{
					NSString * tOriginalName;
					NSString * tOriginalIdentifier;
					
					tOriginalName=[[NODE_DATA(tNode) name] copy];
					
					tOriginalIdentifier=[tDisplayInformationDictionary objectForKey:@"CFBundleIdentifier"];
					
					if (tOriginalName!=nil && tOriginalIdentifier!=nil)
					{
						NSMutableDictionary * tDictionary;
				
						[NODE_DATA(tNode) setName:[NSString stringWithFormat:NSLocalizedString(@"%@ copy",@""),tOriginalName]];
						
						[tDisplayInformationDictionary setObject:[NSString stringWithFormat:@"%@.copy",tOriginalIdentifier] forKey:@"CFBundleIdentifier"];
						
						tDictionary=[[tNode dictionary] mutableDeepCopy];
						
						[NODE_DATA(tNode) setName:tOriginalName];
						
						[tDisplayInformationDictionary setObject:tOriginalIdentifier forKey:@"CFBundleIdentifier"];
				
						if (tDictionary!=nil)
						{
							PBProjectTree * tProjectTreeCopy;
							
							tProjectTreeCopy=[PBProjectTree projectTreeWithDictionary:tDictionary];
							
							[tParentNode insertChild:tProjectTreeCopy atIndex:[tParentNode indexOfChild:tNode]+1];
							
							[tDictionary release];
							
							[IBoutlineView_ deselectAll:nil];
        
							[self updateChangeCount:NSChangeDone];
							
							[IBoutlineView_ reloadData];
						}
					}
				}
			}
		}
	}
}

- (IBAction) rename:(id) sender
{
    int tRow;
    
    tRow=[IBoutlineView_ selectedRow];
    
    canRenameItem_=YES;
    
    [IBoutlineView_ editColumn:[IBoutlineView_ columnWithIdentifier:@"Packages"] row:tRow withEvent:nil select:YES];
}

- (IBAction) deleteSelectedRowsOfOutlineView:(NSOutlineView *) outlineView
{
    [self delete:nil];
}

- (IBAction) delete:(id) sender
{
    NSString * tAlertTitle;
    NSString * tAlertMessage;
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSArray * tArray;
    int i,tCount;
    BOOL tContainsImportedPackage=NO;
    NSString * tReturnButton;
    NSString * tAlternateReturnButton;
    
    sImportedPackageDialog=NO;
    
    // Check whether we have Imported Packages or not
    
    tEnumerator=[IBoutlineView_ selectedRowEnumerator];
        
    tArray=[tEnumerator allObjects];
    
    tCount=[tArray count];
    
    for(i=0;i<tCount;i++)
    {
        int tIndex;
        PBProjectTree * tProjectTree;
        
        tNumber = (NSNumber *) [tArray objectAtIndex:i];
        
        tIndex=[tNumber intValue];
        
        tProjectTree=[IBoutlineView_ itemAtRow:tIndex];
        
        if ([NODE_DATA(tProjectTree) type]==kPBPackageNode)
        {
            // It's a Package, check it
            
            if ([((PBPackageNode *) NODE_DATA(tProjectTree)) isImported]==YES)
            {
                tContainsImportedPackage=YES;
                sImportedPackageDialog=YES;
                break;
            }
        }
    }
    
    if (tContainsImportedPackage==NO)
    {
        tAlertMessage=NSLocalizedString(@"This cannot be undone.",@"No comment");
        
        tReturnButton=NSLocalizedString(@"Delete",@"No comment");
        
        tAlternateReturnButton=nil;
    }
    else
    {
        if ([IBoutlineView_ numberOfSelectedRows]==1)
        {
            tAlertMessage=NSLocalizedString(@"The component to be deleted refers to a .pkg file on your disk. If you wish, the related file can be deleted.\n\nThis cannot be undone.",@"No comment");
            
            tReturnButton=NSLocalizedString(@"Delete Component",@"No comment");
            
            tAlternateReturnButton=NSLocalizedString(@"Delete Component & File",@"No comment");
        }
        else
        {
            tAlertMessage=NSLocalizedString(@"Some components to be deleted refer to .pkg files on your disk. If you wish, the related files can be deleted.\n\nThis cannot be undone.",@"No comment");
            
            tReturnButton=NSLocalizedString(@"Delete Components",@"No comment");
            
            tAlternateReturnButton=NSLocalizedString(@"Delete Components & Files",@"No comment");
        }
    }
    
    if ([IBoutlineView_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to delete this component?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to delete these components?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      tReturnButton,
                      (tAlternateReturnButton==nil) ? NSLocalizedString(@"Cancel",@"No comment") : tAlternateReturnButton,
                      (tAlternateReturnButton==nil) ? tAlternateReturnButton : NSLocalizedString(@"Cancel",@"No comment"),
                      [IBoutlineView_ window],
                      self,
                      @selector(removeDocControllerSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      &sImportedPackageDialog,
                      tAlertMessage);
}
    
- (void) removeDocControllerSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    BOOL tDeletePackage=NO;
    NSFileManager * tFileManager;
    BOOL tDialogLayout;
    
    tDialogLayout=*((BOOL *) contextInfo);
    
    tFileManager=[NSFileManager defaultManager];
    
    if (returnCode==NSAlertDefaultReturn || (tDialogLayout==YES && returnCode==NSAlertAlternateReturn))
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        if (returnCode==NSAlertAlternateReturn)
        {
            tDeletePackage=YES;
        }
        
        tEnumerator=[IBoutlineView_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            int tIndex;
            PBProjectTree * tProjectTree;
            
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            tIndex=[tNumber intValue];
            
            tProjectTree=[IBoutlineView_ itemAtRow:tIndex];
            
            if (tDeletePackage==YES)
            {
                if ([NODE_DATA(tProjectTree) type]==kPBPackageNode)
                {
                    // It's a Package, check it
                    
                    if ([((PBPackageNode *) NODE_DATA(tProjectTree)) isImported]==YES)
                    {
                        NSDictionary * tFilesDictionary;
                        NSString * tPath;
                        
                        // Remove the Package on Disk
                        
                        tFilesDictionary=[((PBPackageNode *) NODE_DATA(tProjectTree)) files];
                        
                        tPath=[tFilesDictionary objectForKey:@"Package Path"];
                        
                        if ([tFileManager removeFileAtPath:tPath handler:nil]==NO)
                        {
                            // A COMPLETER
                        }
                    }
                }
            }
            
            [tProjectTree removeFromParent];
        }
        
        [IBoutlineView_ deselectAll:nil];
        
        [self updateChangeCount:NSChangeDone];
        
        [IBoutlineView_ reloadData];
    }
}

- (IBAction) group:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    int i=0;
    PBProjectTree * nMetaPackageNode=nil;
    PBProjectTree * nComponentsNode=nil;
        
    tEnumerator=[IBoutlineView_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        int tIndex;
        PBProjectTree * tNode;
        PBProjectTree * tParent=nil;
        
        tIndex=[tNumber intValue];
        
        tNode=[IBoutlineView_ itemAtRow:tIndex];
        
        if (nComponentsNode==nil)
        {
            tParent=(PBProjectTree *) [tNode nodeParent];
            
            nMetaPackageNode=[PBProjectTree projectTreeWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[PBProjectTree uniqueNameWithComponentTree:tParent],@"Name",
                                                                                                                 [NSNumber numberWithInt:1],@"Status",
                                                                                                                 [NSNumber numberWithInt:0],@"Type",
                                                                                                                 nil]];
                        
            [tParent insertChild:nMetaPackageNode
                         atIndex:[tParent numberOfChildren]];
        
            nComponentsNode=(PBProjectTree *) [nMetaPackageNode childAtIndex:4];
        }
        
        [tNode removeFromParent];
                    
        [tNode setNodeParent:nComponentsNode];
                    
        [nComponentsNode insertChild:tNode
                             atIndex:i++];
    }
    
    [self updateChangeCount:NSChangeDone];
    
    [IBoutlineView_ deselectAll:self];
	
	[IBoutlineView_ reloadData];
    
    [IBoutlineView_ selectRow:[IBoutlineView_ rowForItem:nMetaPackageNode] byExtendingSelection:NO];
	
	[IBoutlineView_ expandItem:nMetaPackageNode];
    
    [IBoutlineView_ expandItem:nComponentsNode];
}

- (IBAction) ungroup:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    PBProjectTree * nMetaPackageNode=nil;
    PBProjectTree * nComponentsNode=nil;
    int tIndex;
    PBProjectTree * tNode;
        
    tEnumerator=[IBoutlineView_ selectedRowEnumerator];
    
    tNumber = (NSNumber *) [tEnumerator nextObject];
    
    tIndex=[tNumber intValue];
        
    tNode=[IBoutlineView_ itemAtRow:tIndex];
    
    nComponentsNode=(PBProjectTree *) [tNode nodeParent];
    
    nMetaPackageNode=(PBProjectTree *) [nComponentsNode nodeParent];
    
    nComponentsNode=(PBProjectTree *) [nMetaPackageNode nodeParent];
    
    do
    {
        tIndex=[tNumber intValue];
        
        tNode=[IBoutlineView_ itemAtRow:tIndex];
        
        [tNode removeFromParent];
                    
        [tNode setNodeParent:nComponentsNode];
                    
        [nComponentsNode insertChild:tNode
                             atIndex:[nComponentsNode numberOfChildren]];
    }
    while (tNumber = (NSNumber *) [tEnumerator nextObject]);
    
    [nMetaPackageNode removeFromParent];
    
    [self updateChangeCount:NSChangeDone];
    
    [IBoutlineView_ reloadData];
}

#pragma mark -

- (void) documentDidChange:(NSNotification *)notification
{
    NSDictionary * tUserInfo;
    NSString * tSection;
    
    tUserInfo=[notification userInfo];
    
    tSection=[tUserInfo objectForKey:@"Modified Section"];
    
    [self updateChangeCount:NSChangeDone];
    
    if (tSection!=nil)
    {
        PBProjectTree * tProjectTree;
        
        tProjectTree=[tUserInfo objectForKey:@"ProjectTree"];
        
        if (tProjectTree!=nil)
        {
            if ([tSection isEqualToString:@"Hierarchy"]==YES)
            {
                [IBoutlineView_ reloadData];
    
                if (tProjectTree==currentMasterTree_)
                {
                    [self outlineViewSelectionDidChange:nil];
                }
            }
            else
            {
                if ([tSection isEqualToString:@"Project"]==YES)
                {
                    if (currentControllers_!=nil)
                    {
                        if ([currentControllers_ containsObject:projectController_]==YES)
                        {
                            [projectController_ initWithProjectTree:tProjectTree forDocument:self];
                        }
                    }
                }
                else if ([tSection isEqualToString:@"Settings"]==YES)
                {
                    if (tProjectTree==currentMasterTree_)
                    {
                        if (currentControllers_!=nil)
                        {
                            int i,tCount;
                            id tController;
                            
                            tCount=[currentControllers_ count];
                            
                            for(i=0;i<tCount;i++)
                            {
                                tController=[currentControllers_ objectAtIndex:i];
                                
                                if (tController==metaPackageSettingsController_ ||
                                    tController==packageSettingsController_)
                                {
                                    [tController initWithProjectTree:tProjectTree forDocument:self];
                                
                                    break;
                                }
                            }
                        }
                        
                        // Take into account the Required option
                        
                        if ([tUserInfo objectForKey:@"Required"]!=nil)
                        {
                            [self outlineViewSelectionDidChange:nil];
                        }
                    }
                }
                else if ([tSection isEqualToString:@"Documents"]==YES)
                {
                    if (tProjectTree==currentMasterTree_)
                    {
                        if (currentControllers_!=nil)
                        {
                            if ([currentControllers_ containsObject:resourcesController_]==YES)
                            {
                                [resourcesController_ initWithProjectTree:tProjectTree forDocument:self];
                            }
                        }
                    }
                }
                else if ([tSection isEqualToString:@"Components"]==YES)
                {
                    if (currentControllers_!=nil)
                    {
                        if ([currentControllers_ containsObject:componentsController_]==YES)
                        {
                            [componentsController_ initWithProjectTree:currentMasterTree_ forDocument:self];
                        }
                    }
                }
                
                // A COMPLETER
            }
        }
    }
}

- (void) documentDidUpdate:(NSNotification *)notification
{
    [self updateChangeCount:NSChangeDone];
}

- (void) documentStatusDidChange:(NSNotification *)notification
{
    NSDictionary * tDictionary;
    
    tDictionary=[notification userInfo];
    
    if (tDictionary!=nil)
    {
        NSNumber * tNumber;
        NSString * tTitle;
        int tValue=0;
        
        tNumber=[tDictionary objectForKey:@"Status ID"];
        
        if (tNumber!=nil)
        {
            tValue=[tNumber intValue];
        }
        
        switch(tValue)
        {
            case 0:
                if ([IBdocumentProgressIndicator_ isIndeterminate]==NO)
                {
                    [IBdocumentProgressIndicator_ setIndeterminate:YES];
                }
                
                [IBdocumentStatus_ setStringValue:@""];
                
                if (isProgressIndicatorAnimating_==YES)
                {
                    [IBdocumentProgressIndicator_ stopAnimation:nil];
                    
                    isProgressIndicatorAnimating_=NO;
                }
                
                break;
            case 1:
                if ([IBdocumentProgressIndicator_ isIndeterminate]==NO)
                {
                    [IBdocumentProgressIndicator_ setIndeterminate:YES];
                }
                
                if (isProgressIndicatorAnimating_==NO)
                {
                    [IBdocumentProgressIndicator_ startAnimation:nil];
                
                    isProgressIndicatorAnimating_=YES;
                }
                
                tTitle=[tDictionary objectForKey:@"Status String"];
                
                if (tTitle!=nil)
                {
                    [IBdocumentStatus_ setStringValue:tTitle];
                }
                break;
            case 2:
                if ([IBdocumentProgressIndicator_ isIndeterminate]==YES)
                {
                    [IBdocumentProgressIndicator_ setIndeterminate:NO];
                }
                
                if (isProgressIndicatorAnimating_==NO)
                {
                    [IBdocumentProgressIndicator_ startAnimation:nil];
                
                    isProgressIndicatorAnimating_=YES;
                }
                
                [IBdocumentProgressIndicator_ setMinValue:[[tDictionary objectForKey:@"Status Min Value"] doubleValue]];
                [IBdocumentProgressIndicator_ setMaxValue:[[tDictionary objectForKey:@"Status Max Value"] doubleValue]];
                
                [IBdocumentProgressIndicator_ setDoubleValue:[IBdocumentProgressIndicator_ minValue]];
                
                tTitle=[tDictionary objectForKey:@"Status String"];
                
                if (tTitle!=nil)
                {
                    [IBdocumentStatus_ setStringValue:tTitle];
                }
                break;
            case 3:
                [IBdocumentProgressIndicator_ setDoubleValue:[[tDictionary objectForKey:@"Status Value"] doubleValue]];
                
                tTitle=[tDictionary objectForKey:@"Status String"];
                
                if (tTitle!=nil)
                {
                    [IBdocumentStatus_ setStringValue:tTitle];
                }
                break;
            case 4:
                if ([IBdocumentProgressIndicator_ isIndeterminate]==NO)
                {
                    [IBdocumentProgressIndicator_ setIndeterminate:YES];
                }
                
                tTitle=[tDictionary objectForKey:@"Status String"];
                
                if (tTitle!=nil)
                {
                    [IBdocumentStatus_ setStringValue:tTitle];
                }
                else
                {
                    [IBdocumentStatus_ setStringValue:@""];
                }
                
                if (isProgressIndicatorAnimating_==YES)
                {
                    [IBdocumentProgressIndicator_ stopAnimation:nil];
                    
                    isProgressIndicatorAnimating_=NO;
                }
                
                break;
        }
    }
}

#pragma mark -

- (IBAction) save:(id) sender
{
    [tree_ writeToFile:@"/Users/stephane/Projets/PackageBuilder/output.plist" atomically:YES];
}

- (IBAction) changeName:(id) sender
{
    NSString * tNewName;
    
    tNewName=[IBname_ stringValue];
    
    if ([tNewName length]>0 && [tNewName isEqualToString:[NODE_DATA(currentMasterTree_) name]]==NO)
    {
        [NODE_DATA(currentMasterTree_) setName:tNewName];
    
        [self updateChangeCount:NSChangeDone];
    
        [IBoutlineView_ reloadData];
    }
}

- (IBAction) switchAttribute:(id) sender
{
    int tAttribute,tNewAttribute;
    
    tAttribute=[((PBObjectNode *) NODE_DATA(currentMasterTree_)) attribute];
    
    tNewAttribute=[sender indexOfSelectedItem]-1;
    
    if (tAttribute!=tNewAttribute)
    {
        [((PBObjectNode *) NODE_DATA(currentMasterTree_)) setAttribute:tNewAttribute];
    
        [self updateChangeCount:NSChangeDone];
        
        [IBoutlineView_ reloadData];
    }
}

- (void) refreshUIForProjectTree:(PBProjectTree *) inProjectTree
{    
    [IBoutlineView_ reloadData];

    if (inProjectTree==currentMasterTree_)
    {
        [self outlineViewSelectionDidChange:nil];
    }
}

- (IBAction) importPackages:(id) sender
{
    [componentsController_ importPackages:sender];
}

- (IBAction) sortByName:(id)sender
{
    if ([[IBoutlineView_ window] firstResponder]==IBoutlineView_)
    {
        [componentsController_ sortByName:self];
    }
    else
    {
        [componentsController_ sortByName:sender];
    }
}

- (IBAction) sortByAttribute:(id)sender
{
    if ([[IBoutlineView_ window] firstResponder]==IBoutlineView_)
    {
        [componentsController_ sortByAttribute:self];
    }
    else
    {
        [componentsController_ sortByAttribute:sender];
    }
}

#pragma mark -

- (IBAction) showHideBuildWindow:(id) sender
{
    if ([[buildWindowController_ window] isVisible]==YES)
    {
        [[buildWindowController_ window] orderOut:self];
    }
    else
    {
        [buildWindowController_ showWindow:self cleanWindow:NO];
    }
}

- (IBAction) preview:(id) sender
{
    PBProjectTree * tProjectTree=currentMasterTree_;
    NSDictionary * tDictionary;
    
    if (tProjectTree==nil ||
        [NODE_DATA(tProjectTree) type]==kProjectNode)
    {
        tProjectTree=(PBProjectTree * ) [[tree_ childAtIndex:0] childAtIndex:0];
    }
    
    tDictionary=[PBResourcesController cleanDictionary:[((PBObjectNode *) NODE_DATA(tProjectTree)) resources] forDocument:self];
    
    [[PBSimulatorController defaultController] showSimulatorWithResourceDictionary:tDictionary
                                                                      fromDocument:self];
    
    
}

- (IBAction) build:(id) sender
{
    int tShowBuildWindowBehavior;
    
    // Notify the Build Window
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buildDidStart" object:self];
    
    tShowBuildWindowBehavior=[[NSUserDefaults standardUserDefaults] integerForKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW];
    
    if (tShowBuildWindowBehavior==PBPREFERENCEPANE_BUILD_SHOWWINDOW_ALWAYS)
    {
        [buildWindowController_ showWindow:self cleanWindow:YES];
    }
    
    [self buildAsynchronous:sender];
}

- (BOOL) buildSynchronous:(id) sender
{
    BOOL tResult;
    
    tResult=[self buildAsynchronous:sender];
    
    if (tResult==YES)
    {
        // Wait for the build result
        
    }
    
    return tResult;
}

- (BOOL) buildAsynchronous:(id) sender
{
    CFMessagePortRef tRemote;
    NSString * tProjectPath;
    NSString * tScratchPath;
    NSUserDefaults * tDefaults;
    NSString * tSplitForksToolName;
	
    tDefaults=[NSUserDefaults standardUserDefaults];
        
    tScratchPath=[tDefaults stringForKey:PBPREFERENCEPANE_BUILD_SCRATCH_LOCATION];
        
    if (tScratchPath==nil)
    {
        tScratchPath=@"/tmp";
    }
    
	tSplitForksToolName=[tDefaults stringForKey:PBPREFERENCEPANE_FILES_SPLITFORKSTOOLNAME];
	
	if (tSplitForksToolName==nil)
	{
		tSplitForksToolName=SPLITFORKSTOOL_GOLDIN;
	}
	
    launchAfterBuild_=NO;
    
    tProjectPath=[self fileName];
    
    if ([self isDocumentEdited]==YES)
    {
        int tBehavior;
        id tObject;
        
        tObject=[tDefaults objectForKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
        
        if (tObject==nil)
        {
            BOOL tBoolean;
            
            tBoolean=[tDefaults boolForKey:@"SaveBeforeBuild"];
            
            if (tBoolean==YES)
            {
                tBehavior=PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_ALWAYSSAVE;
            }
            else
            {
                tBehavior=PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_NEVERSAVE;
            }
        }
        else
        {
            tBehavior=[tDefaults integerForKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
        }
        
        switch(tBehavior)
        {
            case PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_ASKBEFOREBUILD:
                {
					int tReturnCode;
					NSString * tAlertTitle;
					NSMutableDictionary * tNotificationInfo;
					NSString * tFileName;
					
					tFileName=[self fileName];
					
					tAlertTitle=[NSString stringWithFormat:NSLocalizedString(@"Do you want to save the changes you made in the project \"%@\" before building it?",@"No comment"),[[tFileName lastPathComponent] stringByDeletingPathExtension]];
					
					tReturnCode=NSRunAlertPanel(tAlertTitle,@"",NSLocalizedString(@"Save",@"No comment"),NSLocalizedString(@"Don't Save",@"No comment"),NSLocalizedString(@"Cancel",@"No comment"));
					
					switch(tReturnCode)
					{
						case NSAlertDefaultReturn:		// Save
							[self saveDocument:nil];
							break;
						case NSAlertAlternateReturn:	// Don't Save
							tProjectPath=[self temporaryProjectPath];
							break;
						case NSAlertOtherReturn:		// Cancel
							
							tNotificationInfo=[NSMutableDictionary dictionary];
    
							[tNotificationInfo setObject:[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] forKey:@"Process ID"];
    
							[tNotificationInfo setObject:tFileName forKey:@"Project Path"];
	
							[tNotificationInfo setObject:[NSNumber numberWithInt:kPBNotificationBuildCancelledUnsavedFile] forKey:@"Code"];
            
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
																				object:nil
																			  userInfo:tNotificationInfo];
							
							return NO;
					}
				}
                
                break;
            case PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_ALWAYSSAVE:
                
                [self saveDocument:nil];
				
                break;
        
            case PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_NEVERSAVE:
                
                tProjectPath=[self temporaryProjectPath];
                
                break;
        }
    }
    
    tRemote=CFMessagePortCreateRemote(NULL,CFSTR("ICEBERGCONTROLTOWER"));

    if (tRemote!=NULL)
    {
        CFDataRef tDataRef;
        NSDictionary * tDictionary;
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tProjectPath,@"Project Path",
                                                               [self fileName],@"Notification Path",
                                                               [NSNumber numberWithInt:getuid()],@"User ID",
                                                               [NSNumber numberWithInt:getgid()],@"Group ID",
                                                               [NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]],@"Process ID",
                                                               tSplitForksToolName,@"SplitForks Tool",
															   tScratchPath,@"Scratch Path",
                                                               nil];
        
        
        if (tDictionary!=nil)
        {
            tDataRef=CFPropertyListCreateXMLData(kCFAllocatorDefault,(CFPropertyListRef) tDictionary);
        
            if (tDataRef!=NULL)
            {
                if (CFMessagePortSendRequest(tRemote,0,tDataRef, 20, 10, NULL, NULL)!=kCFMessagePortSuccess)
                {
                    NSBeep();
                    
                    return NO;
                }
                else
                {
                    buildingState_=kPBBuildingLaunched;
                }
                
                // Release Memory
                
                CFRelease(tDataRef);
            }
        }
        
        // Release memory
        
        CFRelease(tRemote);
    }
    else
    {
        NSBeep();
        
        NSBeginAlertSheet(NSLocalizedString(@"No signal from Iceberg Control Tower",@"No comment"),
                          nil,
                          nil,
                          nil,
                          [IBoutlineView_ window],
                          nil,
                      	  nil,
                          nil,
                          NULL,
                          NSLocalizedString(@"The Iceberg Control Tower is not responding. Iceberg can't build any project when this Daemon is not running.",@"No comment"));
        
        return NO;
    }
    
    return YES;
}

- (NSString *) temporaryProjectPath
{
    NSString * tTemporaryProjectPath=nil;
    NSString * tTempPath;
    BOOL isDirectory;
    NSFileManager * tFileManager;
    NSMutableDictionary * tNotificationInfo;
    NSString * tProjectPath;
    
    tProjectPath=[self fileName];
    
    tTempPath=[NSString stringWithFormat:@"/tmp/%d",getuid()];
    
    tFileManager=[NSFileManager defaultManager];
    
    tNotificationInfo=[NSMutableDictionary dictionary];
    
    [tNotificationInfo setObject:[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] forKey:@"Process ID"];
    
    [tNotificationInfo setObject:tProjectPath forKey:@"Project Path"];
    
    if ([tFileManager fileExistsAtPath:tTempPath isDirectory:&isDirectory]==NO)
    {
        if ([tFileManager createDirectoryAtPath:tTempPath attributes:nil]==NO)
        {
            NSBeep();
            
            // Post Notification
            
            [tNotificationInfo setObject:[NSNumber numberWithInt:kPBErrorCantCreateFolder] forKey:@"Code"];
            
            [tNotificationInfo setObject:[NSArray arrayWithObject:tTempPath] forKey:@"Arguments"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
                                                            object:nil
                                                        userInfo:tNotificationInfo];
            
            
            return nil;
        }
    }
    else
    {
        if (isDirectory==NO)
        {
            if ([tFileManager removeFileAtPath:tTempPath handler:nil]==NO)
            {
                NSBeep();
                
                // Post Notification
                
                [tNotificationInfo setObject:[NSNumber numberWithInt:kPBErrorCantRemoveFile] forKey:@"Code"];
            
                [tNotificationInfo setObject:[NSArray arrayWithObject:tTempPath] forKey:@"Arguments"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
                                                                object:nil
                                                            userInfo:tNotificationInfo];
                
                return nil;
            }
            else
            {
                if ([tFileManager createDirectoryAtPath:tTempPath attributes:nil]==NO)
                {
                    NSBeep();
                    
                    // Post Notification
                    
                    [tNotificationInfo setObject:[NSNumber numberWithInt:kPBErrorCantCreateFolder] forKey:@"Code"];
            
                    [tNotificationInfo setObject:[NSArray arrayWithObject:tTempPath] forKey:@"Arguments"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
                                                                    object:nil
                                                                userInfo:tNotificationInfo];
                    
                    return nil;
                }
            }
        }
    }

    tTemporaryProjectPath=[NSString stringWithFormat:@"/tmp/%d/%@",getuid(),[[self fileName] lastPathComponent]];
    
    if ([tree_ writeToFile:tTemporaryProjectPath atomically:YES]==NO)
    {
        NSBeep();
        
        // Post Notification
        
        [tNotificationInfo setObject:[NSNumber numberWithInt:kPBErrorCantWriteFile] forKey:@"Code"];
            
        [tNotificationInfo setObject:[NSArray arrayWithObject:tProjectPath] forKey:@"Arguments"];
                    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
                                                            object:nil
                                                            userInfo:tNotificationInfo];
        
        return nil;
    }
    
    return tTemporaryProjectPath;
}

- (IBAction) buildAndRun:(id) sender
{
    [self build:sender];
    
    launchAfterBuild_=YES;
}

- (IBAction) clean:(id) sender
{
    // Display the Warning sheet
    
    NSBeginAlertSheet(NSLocalizedString(@"clean title",@"No comment"),
                      NSLocalizedString(@"Clean",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      [IBoutlineView_ window],
                      self,
                      @selector(cleanSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"clean message",@"No comment"));
}

- (void) cleanSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        [self cleanBuildFolder];
    }
}

- (void) cleanBuildFolder
{
    NSString * tBuildPath;
    PBProjectTree * tProjectTree;
    PBProjectNode * tProjectNode;
    
    // Clean the build folder (cleverly if possible)
    
    // Get the Build folder location
    
    tProjectTree=(PBProjectTree *) [tree_ childAtIndex:0];
    
    if (tProjectTree!=nil)
    {
        tProjectNode=(PBProjectNode *) NODE_DATA(tProjectTree);
    
        if (tProjectNode!=nil)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[tProjectNode settings];

            if (tDictionary!=nil)
            {
                NSMutableDictionary * tNotificationInfo;
				
				tBuildPath=[tDictionary objectForKey:@"Build Path"];
                
                if (tBuildPath==nil)
                {
                    tBuildPath=[[self folder] stringByAppendingPathComponent:@"build"];
                }
                else
                {
                    NSNumber * tNumber;
                    
                    tNumber=[tDictionary objectForKey:@"Build Path Type"];
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tBuildPath=[tBuildPath stringByAbsolutingWithPath:[self folder]];
                        }
                    }
                }
                
                if (tBuildPath!=nil)
                {
                    NSFileManager * tFileManager;
                    BOOL isDirectory;
                    
                    tFileManager=[NSFileManager defaultManager];
                    
                    if ([tFileManager fileExistsAtPath:tBuildPath isDirectory:&isDirectory]==YES && isDirectory==YES)
                    {
                        // Remove the Packages and Metapackages according to the current project information
    
                        [self cleanComponent:(PBProjectTree *) [tProjectTree childAtIndex:0] inFolder:tBuildPath];
                    }
                }
				
				// Post Notiifcation
				
				tNotificationInfo=[NSMutableDictionary dictionary];
    
				[tNotificationInfo setObject:[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] forKey:@"Process ID"];

				[tNotificationInfo setObject:[self fileName] forKey:@"Project Path"];

				[tNotificationInfo setObject:[NSNumber numberWithInt:kPBNotificationCleanBuildSuccess] forKey:@"Code"];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"ICEBERGBUILDERNOTIFICATION"
																	object:nil
																  userInfo:tNotificationInfo];
            }
        }
    }
}

- (void) cleanComponent:(PBProjectTree *) inProjectTree inFolder:(NSString *) inPath
{
    NSString * tFileName;
    static NSFileManager * tFileManager=nil;
    BOOL isDirectory;
    NSString * tFilePath;
    NSString * tSuffix=nil;
    int tType;
    
    tFileManager=[NSFileManager defaultManager];
    
    tType=[NODE_DATA(inProjectTree) type];
    
    // Get the file name
    
    tFileName=[NODE_DATA(inProjectTree) name];
    
    switch(tType)
    {
        case kPBMetaPackageNode:	// Meta
            tSuffix=@".mpkg";
            break;
        case kPBPackageNode:
            tSuffix=@".pkg";
            break;
    }
    
    if ([tFileName hasSuffix:tSuffix]==NO)
    {
        tFileName=[tFileName stringByAppendingString:tSuffix];
    }
    
    tFilePath=[inPath stringByAppendingPathComponent:tFileName];
    
    if (tType==kPBMetaPackageNode)
    {
        PBProjectTree * tComponentsTree;
        PBProjectTree * tProjectTree;
        int i,tCount;
        NSString * tNewPath;
        NSString * tRelativeComponentDirectory;
        
        // Get the relative location
        
        tRelativeComponentDirectory=[((PBMetaPackageNode *) NODE_DATA(inProjectTree)) componentsDirectory];
        
        tNewPath=[[tFilePath stringByAppendingPathComponent:tRelativeComponentDirectory] stringByStandardizingPath];
        
        tComponentsTree=(PBProjectTree *) [inProjectTree childAtIndex:3];
        
        tCount=[tComponentsTree numberOfChildren];
        
        for(i=0;i<tCount;i++)
        {
            tProjectTree=(PBProjectTree *) [tComponentsTree childAtIndex:i];
            
            [self cleanComponent:tProjectTree inFolder:tNewPath];
        }
    }
    
    // Delete file on disk if it exists
    
    if ([tFileManager fileExistsAtPath:tFilePath isDirectory:&isDirectory]==YES && isDirectory==YES)
    {
        [tFileManager removeFileAtPath:tFilePath handler:nil];
    }
}

#pragma mark -

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
    if (currentMasterTree_!=nil)
    {
        if ([NODE_DATA(currentMasterTree_) type]==kPBPackageNode)
        {
            int i,tCount;
            
            tCount=[currentControllers_ count];
            
            for(i=0;i<tCount;i++)
            {
                if ([currentControllers_ objectAtIndex:i]==packageFilesController_)
                {
                    [packageFilesController_ postSelectionStatus];
                    return;
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBFileSelectionDidChange"
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Count"]];
}

- (void)windowWillClose:(NSNotification *)notification
{

    if ([[IBoutlineView_ window] isMainWindow]==YES)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PBFileSelectionDidChange"
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"Count"]];
    }
    
    // Remove Observers
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void) builderNotification:(NSNotification *)notification
{
    // Overridden
}

#pragma mark -

- (IBAction) addFiles:(id)sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ addFiles:sender];
    }
}

- (IBAction) newFolder:(id) sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ newFolder:sender];
    }
}

- (IBAction) selectDefaultLocationPath:(id)sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ selectDefaultLocationPath:sender];
    }
}

- (IBAction) expandAll:(id)sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ expandAll:sender];
    }
}

- (IBAction) expand:(id)sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ expand:sender];
    }
}

- (IBAction) expandOneLevel:(id)sender
{
    if (packageFilesController_!=nil)
    {
        [packageFilesController_ expandOneLevel:sender];
    }
}

#pragma mark -

- (IBAction) showHideHierarchy:(id) sender
{
    NSRect tFrame;
    NSScrollView * tLeftView;
    NSSplitView * tSplitView;
    NSWindow * tWindow;
    NSView * tContentView;
    NSSize tContentSize;
    
    tSplitView=(NSSplitView *) [IBrightView_ superview];
    
    tLeftView=[[tSplitView subviews] objectAtIndex:0];
    
    tWindow=[IBrightView_ window];
    
    tContentView=[tWindow contentView];
    
    tContentSize=[tContentView bounds].size;
    
    tFrame=[tLeftView frame];
    
    if (NSWidth(tFrame)<2)
    {
        // Show Hierarchy
        
        float tWindowWidth;
        
        tWindowWidth=tContentSize.width;
        
        if (oldLeftViewWidth_==0)
        {
            // Manually set to width 0
        
            oldLeftViewWidth_=defaultLeftViewWidth_;
        }
        
        if (([tSplitView dividerThickness]+oldLeftViewWidth_+PBDOCUMENT_RIGHTVIEW_MINWIDTH)>tWindowWidth)
        {
            [tWindow setContentSize:NSMakeSize([tSplitView dividerThickness]+oldLeftViewWidth_+PBDOCUMENT_RIGHTVIEW_MINWIDTH,tContentSize.height)];
        }
        
        tFrame.size.width=oldLeftViewWidth_;
        
        [tLeftView setFrame:tFrame];
        
        [IBrightView_ setFrame:NSMakeRect([tSplitView dividerThickness],0,NSWidth([tSplitView bounds])-[tSplitView dividerThickness],tFrame.size.height)];
        
        oldLeftViewWidth_=0;
    }
    else
    {
        oldLeftViewWidth_=NSWidth(tFrame);
        
        // Hide Hierarchy
        
        tFrame.size.width=0;
        
        [tLeftView setFrame:tFrame];
        
        [IBrightView_ setFrame:NSMakeRect([tSplitView dividerThickness],0,NSWidth([tSplitView bounds])-[tSplitView dividerThickness],tFrame.size.height)];
    }
    
    [tSplitView display];
    
    // Workaround for a bug in Mac OS X 10.2
    
    if (floor(NSAppKitVersionNumber)<=663.0)
    {
        [IBrightView_ display];
    }
}

- (IBAction) showProjectPane:(id) sender
{
    [IBoutlineView_ selectRow:0 byExtendingSelection:NO];
}

- (IBAction) showSettingsPane:(id) sender
{
    [self showPaneAtRelativeIndex:PBPROJECTTREE_SETTINGS_INDEX];
}

- (IBAction) showDocumentsPane:(id) sender
{
    [self showPaneAtRelativeIndex:PBPROJECTTREE_DOCUMENTS_INDEX];
}

- (IBAction) showScriptsPane:(id) sender
{
    [self showPaneAtRelativeIndex:PBPROJECTTREE_SCRIPTS_INDEX];
}

- (IBAction) showPluginsPane:(id) sender
{
	[self showPaneAtRelativeIndex:PBPROJECTTREE_PLUGINS_INDEX];
}

- (IBAction) showFilesComponentsPane:(id) sender
{
    [self showPaneAtRelativeIndex:PBPROJECTTREE_COMPONENTS_INDEX];
}

- (void) showPaneAtRelativeIndex:(int) inRelativeIndex
{
    PBProjectTree * tNode;
    int tParentRow;
    id tProjectRowItem;
    
    tNode=currentMasterTree_;
    
    if (tNode==nil)
    {
        tNode=(PBProjectTree *) [tree_ childAtIndex:0];
    }
    
    if ([NODE_DATA(tNode) type]==kProjectNode)
    {
        tNode=(PBProjectTree *) [tNode childAtIndex:0];
    }
    
    tProjectRowItem=[IBoutlineView_ itemAtRow:0];
    
    if ([IBoutlineView_ isItemExpanded:tProjectRowItem]==NO)
    {
        [IBoutlineView_ expandItem:tProjectRowItem];
    }
    
    tParentRow=[IBoutlineView_ rowForItem:tNode];
    
    if ([IBoutlineView_ isItemExpanded:tNode]==NO)
    {
        [IBoutlineView_ expandItem:tNode];
    }
    
    [IBoutlineView_ selectRow:tParentRow+inRelativeIndex+1 byExtendingSelection:NO];
}

#pragma mark -

- (void)windowDidResize:(NSNotification *)aNotification
{
    if ([currentControllers_ count]==1)
    {
        if ([currentControllers_ objectAtIndex:0]==packageFilesController_)
        {
            NSView * tPane;
            NSView * tScrollView;
            NSView * tListView;
            NSRect tScrollViewFrame;
            NSRect tListViewFrame;
            NSRect tPaneFrame;
            float tHeight,tNewHeight;
            BOOL listViewNeedsUpdate=NO;
            
            tPane=[packageFilesController_ view];
            
            tListView=[tPane superview];
            
            tScrollView=[tListView superview]; 
            
            
            tPaneFrame=[tPane frame];
            
            tListViewFrame=[tListView frame];
            
            tScrollViewFrame=[tScrollView frame];
            
            tHeight=NSHeight(tListViewFrame);
            
            tNewHeight=NSHeight(tScrollViewFrame);
            
            if (tHeight>tNewHeight)
            {
                if (tNewHeight<=(defaultFilesHeight_+PBPANEVIEW_DIFF_HEIGHT))
                {
                    if (tHeight==(defaultFilesHeight_+PBPANEVIEW_DIFF_HEIGHT))
                    {
                        return;
                    }
                    
                    tHeight=defaultFilesHeight_+PBPANEVIEW_DIFF_HEIGHT;
                }
                else
                {
                    tHeight=tNewHeight;
                }
                
                listViewNeedsUpdate=YES;
            }
            
            if (listViewNeedsUpdate==YES)
            {
                tListViewFrame.size.height=tHeight;
                
                [tListView setFrameSize:tListViewFrame.size];
            }
            
            tPaneFrame.size.height=tHeight-PBPANEVIEW_DIFF_HEIGHT;
            
            [tPane setFrameSize:tPaneFrame.size];
        }
    }
}

- (void) backgroundImageSettingsDidChange:(NSNotification *)notification
{
    // Check that we shall not let the resourcesController_ handle this
    
    if ([currentControllers_ containsObject:resourcesController_]==NO)
    {
        PBProjectTree * tProjectTree=currentMasterTree_;
        
        if (tProjectTree==nil ||
            [NODE_DATA(tProjectTree) type]==kProjectNode)
        {
            tProjectTree=(PBProjectTree * ) [[tree_ childAtIndex:0] childAtIndex:0];
        }
        
        if (tProjectTree!=nil)
        {
            NSMutableDictionary * tResourcesDictionary;
            NSDictionary * tImageDictionary;
            NSDictionary * tOldImageDictionary;
            NSDictionary * tUserInfo;
            
            tUserInfo=[notification userInfo];
            
            // Modify the settings directly in the dictionary
            
            tResourcesDictionary=[OBJECTNODE_DATA(tProjectTree) resources];
            
            tOldImageDictionary=[tResourcesDictionary objectForKey:RESOURCE_BACKGROUND_KEY];
            
            tImageDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tOldImageDictionary objectForKey:@"Mode"],@"Mode",
                                                                        [tOldImageDictionary objectForKey:@"Path"],@"Path",
                                                                        [tUserInfo objectForKey:@"Scaling"],IFPkgFlagBackgroundScaling,
                                                                	[tUserInfo objectForKey:@"Alignment"],IFPkgFlagBackgroundAlignment,
                                                                        nil];
            
            [tResourcesDictionary setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
            
            // Mark the document as updated
            
            [self updateChangeCount:NSChangeDone];
        }
    }
}

@end
