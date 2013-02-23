/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
	+----------+-------------+---------------------------------------------------------+
    |   Date   |    Author   | Comments                                                |
    +----------+-------------+---------------------------------------------------------+
    | 01/03/07 |   S.Sudre   | Use lstat to check for the existence of a file to better|
	|          |             | deal with dead symlinks                                 |
	+----------+-------------+---------------------------------------------------------+
	|          |             |                                                         |
    +----------+-------------+---------------------------------------------------------+
*/

#import "PBPackageFilesController.h"
#import "ImageAndTextCell.h"
#include <sys/types.h>
#include <sys/stat.h>
#import "PBOutlineView.h"

#include <Carbon/Carbon.h>
#import "NSString+Iceberg.h"
#import "PBPreferencePaneFilesController+Constants.h"

#import "PBFileNameFormatter.h"

#define SAFEFILENODE(n) 	((PBFileTree*)((n!=nil)?(n):(fileTree_)))

#define PBFilePBoardType		@"PBFilePBoardType"
#define PBFileExternalPBoardType	@"PBFileExternalPBoardType"

@implementation PBPackageFilesController

+ (PBPackageFilesController *) packageFilesController
{
    PBPackageFilesController * nController=nil;
    
    nController=[PBPackageFilesController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"PFiles" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"PFiles"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

#pragma mark -

- (void) awakeFromNib
{
    ImageAndTextCell *imageAndTextCell = nil;
    NSTableColumn *tableColumn = nil;
    id tCell;
    NSSize tSize;
    PBFileNameFormatter * tFormater;
    id tMenuItem;
    NSImage * tImage;
    
	defaults_=[NSUserDefaults standardUserDefaults];
	
    // Imported View
    
    tMenuItem=[IBimportedReferencePopupButton_ itemAtIndex:[IBimportedReferencePopupButton_ indexOfItemWithTag:kRelativeToProjectPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative13" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tMenuItem=[IBimportedReferencePopupButton_ itemAtIndex:[IBimportedReferencePopupButton_ indexOfItemWithTag:kGlobalPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute13" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }

    
    [IBimportedView_ setTitle:NSLocalizedString(@"Imported Package",@"No comment")];
    
    [IBimportedReferencePopupButton_ setBordered:NO];
    
    tFormater=[PBFileNameFormatter new];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"Files"];
    imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
    [imageAndTextCell setEditable:YES];
    [imageAndTextCell setFont:[NSFont labelFontOfSize:11.0]];
    [imageAndTextCell setFormatter:tFormater];
    [tableColumn setDataCell:imageAndTextCell];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"owner"];
    tCell=[tableColumn dataCell];
    [tCell setFont:[NSFont labelFontOfSize:11.0]];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"group"];
    tCell=[tableColumn dataCell];
    [tCell setFont:[NSFont labelFontOfSize:11.0]];
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"rights"];
    tCell=[tableColumn dataCell];
    [tCell setFont:[NSFont labelFontOfSize:11.0]];
    
    [IBoutlineView_ setAutoresizesOutlineColumn:NO];
    
    tSize=[IBoutlineView_ intercellSpacing];
    
    tSize.height=1;
    
    [tFormater release];
    
    [IBoutlineView_ setIntercellSpacing:tSize];
    
    //[IBoutlineView_ setRecursiveExpandDenied:YES];
    
    [IBoutlineView_ setAcceptFirstClick:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileAttributesDidChange:)
                                                 name:@"PBFileAttributesDidChange"
                                               object:self];
    
    [IBoutlineView_ registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,
                                                                      PBFilePBoardType,
                                                                      PBFileExternalPBoardType,
                                                                      nil]];

    blackColor_=[[NSColor blackColor] retain];
    redColor_=[[NSColor redColor] retain];
    
    /* Set the Popup Relativity Sheet icons */
    
    tMenuItem=[IBreferenceStyle_ itemAtIndex:[IBreferenceStyle_ indexOfItemWithTag:kRelativeToProjectPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tMenuItem=[IBreferenceStyle_ itemAtIndex:[IBreferenceStyle_ indexOfItemWithTag:kGlobalPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    directoryServicesManager_=[PBDirectoryServicesManager defaultManager];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    PBPackageNode * tPackageNode;
    NSDictionary * tFilesDictionary;
    NSNumber * tNumber;
	
    isImported_=NO;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];

    [IBoutlineView_ deselectAll:self];
    
    [IBsetButton_ setEnabled:NO];
    
    if (fileTree_!=nil)
    {
        [fileTree_ release];
        fileTree_=nil;
    }
    
    tPackageNode=(PBPackageNode *) objectNode_;
    
    tFilesDictionary=[tPackageNode files];
    
    isImported_=[tPackageNode isImported];
    
    if (isImported_==NO)
    {
    	fileTree_=[[PBFileTree fileTreeWithDictionary:[tFilesDictionary objectForKey:@"Hierarchy"]
                                          projectPath:[document_ folder]] retain];
    
        [IBdefaultLocationPath_ setStringValue:[tFilesDictionary objectForKey:IFPkgFlagDefaultLocation]];
        
        defaultLocation_=[fileTree_ fileTreeAtPath:[tFilesDictionary objectForKey:IFPkgFlagDefaultLocation]];
    
        [IBcompress_ setEnabled:YES];
        [IBsplitForks_ setEnabled:YES];
        
        if ([IBimportedView_ superview]!=nil)
        {
            [IBimportedView_ retain];
            [IBimportedView_ removeFromSuperview];
        }
        
        
    }
    else
    {
        NSNumber * tPackagePathType;
        
        fileTree_=nil;
    
        [IBdefaultLocationPath_ setStringValue:[tFilesDictionary objectForKey:IFPkgFlagDefaultLocation]];
        
        [IBcompress_ setEnabled:NO];
        [IBsplitForks_ setEnabled:NO];
        
        if ([IBimportedView_ superview]==nil)
        {
            [[IBoutlineView_ superview] addSubview:IBimportedView_];
            
            [IBimportedView_ setFrame:[IBoutlineView_ frame]];
            [IBimportedView_ release];
        }
        
        tPackagePathType=[tFilesDictionary objectForKey:@"Package Path Type"];
        
        if (tPackagePathType!=nil)
        {
            [IBimportedReferencePopupButton_ selectItemAtIndex:[IBimportedReferencePopupButton_ indexOfItemWithTag:[tPackagePathType intValue]]];
        }
        else
        {
            [IBimportedReferencePopupButton_ selectItemAtIndex:[IBimportedReferencePopupButton_ indexOfItemWithTag:kGlobalPath]];
        }
    }
    
    [IBoutlineView_ reloadData];
    
    // Expand the items if needed
    
    if (isImported_==NO)
    {
        NSArray * tArray;
        
        tArray=[tFilesDictionary objectForKey:@"ExpandedRows"];
        
        if (tArray!=nil)
        {
            int i,tCount;
            
            tCount=[tArray count];
            
            for(i=0;i<tCount;i++)
            {
                [IBoutlineView_ expandItem:[IBoutlineView_ itemAtRow:[[tArray objectAtIndex:i] intValue]]];
            }
        }
		else
		{
			if ([self defaultRestoreForItem:fileTree_]==NO)
			{
				PBFileTree * tFileTree;
						
				// Expand '/'
				
				[IBoutlineView_ expandItem:[IBoutlineView_ itemAtRow:0]];
			
				// Expand the /Applications folder
				
				tFileTree=[fileTree_ fileTreeAtPath:@"/Applications"];
				
				if (tFileTree!=nil)
				{
					[IBoutlineView_ expandItem:tFileTree];
				}
				
				// Expand the /Library folder
				
				tFileTree=[fileTree_ fileTreeAtPath:@"/Library"];
				
				if (tFileTree!=nil)
				{
					[IBoutlineView_ expandItem:tFileTree];
				}
			}
		}
    }
    
    tNumber=[tFilesDictionary objectForKey:@"Compress"];
        
    if (tNumber==nil)
    {
        [IBcompress_ setState:NSOffState];
    }
    else
    {
        [IBcompress_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
    }
    
    tNumber=[tFilesDictionary objectForKey:@"Split Forks"];
    
    if (tNumber==nil)
    {
        [IBsplitForks_ setState:NSOffState];
    }
    else
    {
        [IBsplitForks_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
    }
}

- (void) treeWillChange
{
    [super treeWillChange];
    
    [self updateFiles:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBFileSelectionDidChange"
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Count",nil]];
}

- (IBAction) updateFiles:(id) sender
{
    NSMutableDictionary * tFilesDictionary;
    PBPackageNode * tPackageNode;
        
    tPackageNode=(PBPackageNode *) objectNode_;
    
    tFilesDictionary=[tPackageNode files];
    
    if (isImported_==NO)
    {
        NSMutableArray * tExpandedItems;
        int i,tCount;
        
        [tFilesDictionary setObject:[IBdefaultLocationPath_ stringValue] forKey:IFPkgFlagDefaultLocation];
        
        if (hierarchyChanged_==YES)
        {
            PBFileTree * tHierarchyTree_;
            NSDictionary * tDictionary;
            
            tHierarchyTree_=(PBFileTree *) [fileTree_ childAtIndex:0];
            
            if (tHierarchyTree_!=nil)
            {
                tDictionary=[tHierarchyTree_ dictionaryWithProjectAtPath:[document_ folder]];
                
                if (tDictionary!=nil)
                {
                    [tFilesDictionary setObject:tDictionary forKey:@"Hierarchy"];
                }
            }
            
            hierarchyChanged_=NO;
        }
        
        [tFilesDictionary setObject:[NSNumber numberWithBool:[IBcompress_ state]==NSOnState] forKey:@"Compress"];
        
        [tFilesDictionary setObject:[NSNumber numberWithBool:[IBsplitForks_ state]==NSOnState] forKey:@"Split Forks"];
    
        // Temporary save the list of expanded items sorted by index
            
		tCount=[IBoutlineView_ numberOfRows];
		
		tExpandedItems=[NSMutableArray arrayWithCapacity:tCount];
		
		for(i=0;i<tCount;i++)
		{
			if ([IBoutlineView_ isItemExpanded:[IBoutlineView_ itemAtRow:i]]==YES)
			{
				[tExpandedItems addObject:[NSNumber numberWithInt:i]];
			}
		}
		
		[tExpandedItems sortUsingSelector:@selector(compare:)];
		
		[tFilesDictionary setObject:tExpandedItems forKey:@"ExpandedRows"];
        
        if (sender!=nil)
        {
            [self setDocumentNeedsUpdate:YES];
        }
    }
    else
    {
        int tOldReferenceStyle;
        int tNewReferenceStyle;
        
        
        NSNumber * tOldReferenceStyleNumber;
        
        tOldReferenceStyle=kGlobalPath;
        
        tOldReferenceStyleNumber=[tFilesDictionary objectForKey:@"Package Path Type"];
        
        if (tOldReferenceStyleNumber!=nil)
        {
            tOldReferenceStyle=[tOldReferenceStyleNumber intValue];
        }
        
        tNewReferenceStyle=[[IBimportedReferencePopupButton_ selectedItem] tag];
        
        if (tOldReferenceStyle!=tNewReferenceStyle)
        {
            NSString * tOldPath;
            NSString * tNewPath=nil;
        
            tOldPath=[tFilesDictionary objectForKey:@"Package Path"];
            
            switch(tNewReferenceStyle)
            {
                case kGlobalPath:
                    tNewPath=[tOldPath stringByAbsolutingWithPath:[[document_ fileName] stringByDeletingLastPathComponent]];
                    break;
                case kRelativeToProjectPath:
                    tNewPath=[tOldPath stringByRelativizingToPath:[[document_ fileName] stringByDeletingLastPathComponent]];
                    break;
            }
            
            [tFilesDictionary setObject:[NSNumber numberWithInt:tNewReferenceStyle] forKey:@"Package Path Type"];
            
            [tFilesDictionary setObject:tNewPath forKey:@"Package Path"];
            
            [self setDocumentNeedsUpdate:YES];
        }
    }
}

- (BOOL) defaultRestoreForItem:(id) inItem
{
	if (inItem!=nil)
	{
		PBFileNode * tFileNode;
		int tFileType;
		
		tFileNode=FILENODE_DATA(inItem);
        
		tFileType=[tFileNode type];
		
		if (tFileType==kBaseNode || tFileType==kFileRootNode)
		{
			NSArray * tChildren;
			BOOL tRealItemFound=NO;
			
			if (tFileType==kBaseNode)
			{
				if ([inItem hasRealChildren]==NO)
				{
					return NO;
				}
				
				tRealItemFound=YES;
				
				// Expand the item
					
				[IBoutlineView_ expandItem:inItem];
			}	
					
			// Inspect the children
					
			tChildren=[inItem children];
					
			if (tChildren!=nil)
			{
				NSEnumerator * tEnumerator;
				
				tEnumerator=[tChildren objectEnumerator];
				
				if (tEnumerator!=nil)
				{
					id tChild;
					
					while (tChild=[tEnumerator nextObject])
					{
						if ([self defaultRestoreForItem:tChild]==YES)
						{
							tRealItemFound=YES;
						}
					}
				}
			}
			
			return tRealItemFound;
		}
	}

	return NO;
}

#pragma mark -

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
    return [SAFEFILENODE(item) childAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
    return ![FILENODE_DATA(item) isLeaf];
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
    return [SAFEFILENODE(item) numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    int tType;
    PBFileNode * tFileNode;
    
    
    tFileNode=FILENODE_DATA(item);
    
    tType=[tFileNode type];
    
    if([[tableColumn identifier] isEqualToString: @"Files"])
    {
        objectValue = [tFileNode fileName];
    }
    else
    if([[tableColumn identifier] isEqualToString: @"owner"])
    {
        if ([tFileNode link]==YES)
        {
            tFileNode=FILENODE_DATA([item nodeParent]);
        }
        
       	objectValue=[directoryServicesManager_ userAccountForUID:[tFileNode uid]];
        
        //objectValue=[PBPackageFilesController cachedOwnerNameForUID:[tFileNode uid]];
    }
    else
    if([[tableColumn identifier] isEqualToString: @"group"])
    {
        if ([tFileNode link]==YES)
        {
            tFileNode=FILENODE_DATA([item nodeParent]);
        }
        
        objectValue=[directoryServicesManager_ groupForGID:[tFileNode gid]];
        
        //objectValue=[PBPackageFilesController cachedGroupNameForGID:[tFileNode gid]];
    }
    else
    if([[tableColumn identifier] isEqualToString: @"rights"])
    {
        if ([tFileNode link]==YES)
        {
            objectValue= [FILENODE_DATA([item nodeParent]) privilegesStringRepresentationForLink];
        }
        else
        {
            objectValue= [tFileNode privilegesStringRepresentation];
        }
    }
    
    return objectValue;
}

- (void)outlineView:(NSOutlineView *)olv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString: @"Files"])
    {
        if ([[FILENODE_DATA(item) path] compare:object options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            if ([[FILENODE_DATA(item) path] compare:object]!=NSOrderedSame)
            {
                PBFileTree * tTree;
                PBFileTree * tParentTree;
                
                tTree=(PBFileTree *) item;
                
                tParentTree=(PBFileTree *) [tTree nodeParent];
                
                [tTree retain];
                
                [FILENODE_DATA(tTree) setPath:object];
                
                [tTree removeFromParent];
                
                [tParentTree insertSortedChild:tTree];
                
                [tTree release];
                
                [olv deselectAll:nil];
                
                hierarchyChanged_=YES;
                
                [olv reloadItem:tParentTree reloadChildren:YES];
                
                [olv selectRow:[olv rowForItem:tTree] byExtendingSelection:NO];
                
                [self updateFiles:IBoutlineView_];
            }
        }
        else
        {
            if ([((PBFileTree *)[item nodeParent]) containsTreeWithName:object]==YES)
            {
                NSBeep();
                
                //[olv selectRow:[olv rowForItem:item] byExtendingSelection:NO];
                
                [olv editColumn:[olv columnWithIdentifier:@"Files"] row:[olv rowForItem:item] withEvent:nil select:YES];
            }
            else
            {
                PBFileTree * tTree;
                PBFileTree * tParentTree;
                
                tTree=(PBFileTree *) item;
                
                tParentTree=(PBFileTree *) [tTree nodeParent];
                
                [tTree retain];
                
                [FILENODE_DATA(tTree) setPath:object];
                
                [tTree removeFromParent];
                
                [tParentTree insertSortedChild:tTree];
                
                [tTree release];
                
                [olv deselectAll:nil];
                
                hierarchyChanged_=YES;
                
                [olv reloadItem:tParentTree reloadChildren:YES];
                
                [olv selectRow:[olv rowForItem:tTree] byExtendingSelection:NO];
                
                [self updateFiles:IBoutlineView_];
            }
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return ([FILENODE_DATA(item) type] == kNewFolderNode);
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{    
    if ([[tableColumn identifier] isEqualToString: @"Files"])
    {
		PBFileNode * tFileNode;
        BOOL tFather=YES;
        static NSImage * sFolderIcon=nil;
        static NSImage * sDisabledFolderIcon=nil;
        
        tFileNode=FILENODE_DATA(item);
        
        switch([tFileNode type])
        {
            case kBaseNode:
                tFather=[item hasRealChildren];
            
            case kNewFolderNode:
        	[(ImageAndTextCell*)cell setTextColor:blackColor_];
                
                if (defaultLocation_==item)
                {
                    [(ImageAndTextCell*)cell setImage: [NSImage imageNamed:@"TargetLocation"]];
                }
                else    
                {
                    if (tFather==YES)
                    {
                        if (sFolderIcon==nil)
                        {
                            sFolderIcon=[[NSImage imageNamed:@"Folder"] retain];
                        }
                        
                        [(ImageAndTextCell*)cell setImage:sFolderIcon];
                    }
                    else
                    {
                        if (sDisabledFolderIcon==nil)
                        {
                            sDisabledFolderIcon=[[NSImage imageNamed:@"DisabledFolder"] retain];
                        }
                        
                        [(ImageAndTextCell*)cell setImage:sDisabledFolderIcon];

                    }
                }
                break;
            case kRealItemNode:
                
                [tFileNode fileExistenceOnDiskChanged];
                
                if ([tFileNode existsOnDisk]==NO)
                {
                    [(ImageAndTextCell*)cell setTextColor:redColor_];
                }
                else
                {
                    [(ImageAndTextCell*)cell setTextColor:blackColor_];
                }
                
                [(ImageAndTextCell*)cell setImage: [FILENODE_DATA(item) icon]];
                break;
        }
    }
}

#pragma mark -

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    [self postSelectionStatus];
}

- (void) postSelectionStatus
{
    int tSelectedCount;
    NSDictionary * tUserInfo;
    
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];

    if (tSelectedCount>0)
    {
        if (tSelectedCount==1)
        {
            int tSelectedRow;
            PBFileTree * tFileTree;
            
            tSelectedRow=[IBoutlineView_ selectedRow];
            
            tFileTree=[IBoutlineView_ itemAtRow:tSelectedRow];
                
            if ([FILENODE_DATA(tFileTree) type]==kRealItemNode || defaultLocation_==tFileTree)
            {
                [IBsetButton_ setEnabled:NO];
            }
            else
            {
                [IBsetButton_ setEnabled:YES];
            }
            
            tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tSelectedCount],@"Count",
                                                                 tFileTree,@"File",
                                                                 self,@"File Controller",
                                                                 nil];
        }
        else
        {
            NSEnumerator * tEnumerator;
            NSMutableArray * tArray;
            NSNumber * tNumber;
            
            tEnumerator=[IBoutlineView_ selectedRowEnumerator];
            
            tArray=[NSMutableArray arrayWithCapacity:tSelectedCount];
            
            while (tNumber=[tEnumerator nextObject])
            {
                [tArray addObject:[IBoutlineView_ itemAtRow:[tNumber intValue]]];
            }
            
            [IBsetButton_ setEnabled:NO];
            
            tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tSelectedCount],@"Count",
                                                                 tArray,@"Files",
                                                                 self,@"File Controller",	// To be able to call it back
                                                                 nil];
        
            /*tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tSelectedCount],@"Count",nil];*/
        }
    }
    else
    {
        tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Count",nil];
    }
    
    // Post notification
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBFileSelectionDidChange"
                                                        object:nil
                                                      userInfo:tUserInfo];
}

#pragma mark -

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
    int i,tCount;
    int j;
    PBFileTree * tTree;
    NSMutableArray * tExternalDragArray;
    
    // We need to simplify the hierarchy and check no items is a base node
    
    tCount=[items count];
    
    internalDragArray_=[NSMutableArray arrayWithCapacity:tCount];
    
    tExternalDragArray=[NSMutableArray arrayWithCapacity:tCount];
    
    for(i=tCount-1;i>=0;i--)
    {
        tTree=[items objectAtIndex:i];
        
        if ([FILENODE_DATA(tTree) type]==kBaseNode)
        {
            return NO;
        }
        
        for(j=i-1;j>=0;j--)
        {
            if ([tTree isDescendantOfNode:[items objectAtIndex:j]]==YES)
            {
                break;
            }
        }
        
        if (j<0)
        {
            [internalDragArray_ insertObject:tTree atIndex:0];
            
            [tExternalDragArray insertObject:[tTree dictionaryWithProjectAtPath:nil] atIndex:0];
        }
    }
    
    [pboard declareTypes:[NSArray arrayWithObjects: PBFilePBoardType,PBFileExternalPBoardType,nil] owner:self];
    
    [pboard setPropertyList:tExternalDragArray forType:PBFileExternalPBoardType];
    
    [pboard setData:[NSData data] forType:PBFilePBoardType]; 
    
    return YES;
}

- (unsigned int)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)childIndex
{
    NSPasteboard * tPasteBoard;
    NSArray * tArray;
    int i,tCount;
    PBFileNode * tFileNode;
    
    tFileNode=FILENODE_DATA(item);
    
    tPasteBoard=[info draggingPasteboard];
    
    switch(childIndex)
    {
        case NSOutlineViewDropOnItemIndex:
            break;
        default:
            if ([tFileNode type]==kFileRootNode)
            {
                return NSDragOperationNone;
            }
            
            if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject: NSFilenamesPboardType]]!=nil)
            {
                NSString * tPath;
                PBFileTree * tChildTree;
                NSArray * tChildren;
                NSString * tName;
                int k,tChildrenCount;
                BOOL find=NO;
                
                tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
                        
                tCount=[tArray count];
                        
                for(i=0;i<tCount;i++)
                {
                    tPath=[tArray objectAtIndex:i];
                            
                    if ([item containsTreeWithName:[tPath lastPathComponent]]==YES)
                    {
                        return NSDragOperationNone;
                    }
                }
                
                tPath=[tArray objectAtIndex:0];
                
                tName=[tPath lastPathComponent];
                
                tChildren=[item children];
                
                tChildrenCount=[tChildren count];
                
                for(k=0;k<tChildrenCount;k++)
                {
                    tChildTree=[tChildren objectAtIndex:k];
                    
                    if ([tName compare:[FILENODE_DATA(tChildTree) fileName] options:NSCaseInsensitiveSearch]!=NSOrderedDescending)
                    {
                        [olv setDropItem:item dropChildIndex:k];
                        find=YES;
                        
                        break;
                    }
                }
                
                if (find==NO)
                {
                    [olv setDropItem:item dropChildIndex:k];
                }
                
                return [info draggingSourceOperationMask];
            }
            else
            {
                PBFileTree * tFileTree;
                NSString * tName=nil;
                
                if ([info draggingSource]==IBoutlineView_)
                {
                    if ([item isDescendantOfNodeInArray:internalDragArray_]==YES)
                    {
                        return NSDragOperationNone;
                    }
                    
                    // We need to check the name and eventually switch the drop location
                    
                    tCount=[internalDragArray_ count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        tFileTree=[internalDragArray_ objectAtIndex:i];
                        
                        tName=[FILENODE_DATA(tFileTree) fileName];
                        
                        if ([item containsTreeWithName:tName]==YES)
                        {
                            return NSDragOperationNone;
                        }
                    }
                    
                    tFileTree=[internalDragArray_ objectAtIndex:0];
                    
                    tName=[FILENODE_DATA(tFileTree) fileName];
                }
                else
                {
                    // External Drag
                    
                    NSArray * tExternalArray;
                    NSDictionary * tDictionary;
                    
                    tExternalArray=[[info draggingPasteboard] propertyListForType:PBFileExternalPBoardType];
                    
                    // We need to check the name and eventually switch the drop location
                    
                    tCount=[tExternalArray count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        tDictionary=[tExternalArray objectAtIndex:i];
                        
                        if (tDictionary!=nil)
                        {
                            tName=[tDictionary objectForKey:@"Path"];
                        
                            if (tName==nil)
                            {
                                return NSDragOperationNone;
                            }
                            else
                            {
                                tName=[tName lastPathComponent];
                                
                                if ([item containsTreeWithName:tName]==YES)
                                {
                                    return NSDragOperationNone;
                                }
                            }
                        }
                    }
                    
                    tDictionary=[tExternalArray objectAtIndex:0];
                    
                    tName=[[tDictionary objectForKey:@"Path"] lastPathComponent];
                }
                    
                // Find the appropriate drop location based on the first name of the dropped objects
                
                {
                    PBFileTree * tChildTree;
                    NSArray * tChildren;
                    int k,tChildrenCount;
                    BOOL find=NO;
                
                    tChildren=[item children];
                
                    tChildrenCount=[tChildren count];
                    
                    for(k=0;k<tChildrenCount;k++)
                    {
                        tChildTree=[tChildren objectAtIndex:k];
                        
                        if ([tName compare:[FILENODE_DATA(tChildTree) fileName] options:NSCaseInsensitiveSearch]!=NSOrderedDescending)
                        {
                            [olv setDropItem:item dropChildIndex:k];
                            find=NO;
                            
                            break;
                        }
                    }
                    
                    if (find==NO)
                    {
                        [olv setDropItem:item dropChildIndex:k];
                    }
                }
                
                return NSDragOperationGeneric;
            }
            break;
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(int)childIndex
{
    PBFileTree * tFileTree;
    NSPasteboard * tPasteBoard;
    NSMutableArray * tNewSelectionArray;
    int k,tNewCount;
    
    tPasteBoard=[info draggingPasteboard];
    
    tNewSelectionArray=[NSMutableArray array];
    
    if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject: NSFilenamesPboardType]]!=nil)
    {
        // Drag & Drop of a real item
        
        NSArray * tArray;
        BOOL tShowCustomizationDialog=YES;
		id tObject;
		
        parentFileTree_=targetItem;
        
        tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
        
		tObject=[defaults_ objectForKey: PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	
		if (tObject!=nil)
		{
			tShowCustomizationDialog=[defaults_ boolForKey: PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
		}
		
		if (tShowCustomizationDialog==YES)
		{
			[self beginFileSheet:tArray];
		}
		else
		{
			BOOL tDefaultKeepPermissionMode;
			int tDefaultReferenceStyle;
			
			tDefaultKeepPermissionMode=[defaults_ boolForKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
			
			tDefaultReferenceStyle=[defaults_ integerForKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    
			if (tDefaultReferenceStyle==0)
			{
				tDefaultReferenceStyle=kGlobalPath;
				
				[defaults_ setInteger:tDefaultReferenceStyle forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
			}
			
			[self _addFiles:tArray keepOwnerAndGroup:tDefaultKeepPermissionMode referenceStyle:tDefaultReferenceStyle];
		}
        
        return YES;
    }
    else
    {
        if ([info draggingSource]==IBoutlineView_)
        {
            // Internal Drag, we need to move

            int i,tCount;
            
            tCount=[internalDragArray_ count];
            
            for(i=0;i<tCount;i++)
            {
                tFileTree=(PBFileTree *) [internalDragArray_ objectAtIndex:i];
            
                [tFileTree retain];
                
                [tFileTree removeFromParent];
                
                [targetItem insertSortedChild:tFileTree];
                
                [tFileTree release];
                
                [tNewSelectionArray addObject:tFileTree];
            }
        }
        else
        {
            // External Drag, we copy
            
            NSArray * tExternalArray;
            int i,tCount;
            
            tExternalArray=[tPasteBoard propertyListForType:PBFileExternalPBoardType];
            
            tCount=[tExternalArray count];
            
            for(i=0;i<tCount;i++)
            {
                NSDictionary * tDictionary;
                
                tDictionary=[tExternalArray objectAtIndex:i];
                
                tFileTree=[PBFileTree fileNodeWithDictionary:tDictionary projectPath:nil];
                
                [targetItem insertSortedChild:tFileTree];
                
                [tNewSelectionArray addObject:tFileTree];
            }
        }
    }
    
    [IBoutlineView_ deselectAll:nil];
    
    hierarchyChanged_=YES;
    
    [IBoutlineView_ reloadData];
    
    tNewCount=[tNewSelectionArray count];
    
    for(k=0;k<tNewCount;k++)
    {
        [IBoutlineView_ selectRow:[IBoutlineView_ rowForItem:[tNewSelectionArray objectAtIndex:k]]
             byExtendingSelection:YES];
    }
    
    [self updateFiles:IBoutlineView_];
    
    return YES;
}

#pragma mark -

- (void) fileAttributesDidChange:(NSNotification *)notification
{
    if (notification!=nil)
    {
    	NSDictionary * tUserInfo;
        
        tUserInfo=[notification userInfo];
        
        if (tUserInfo!=nil)
        {
            PBFileTree * tFileTree;
            
            tFileTree=[tUserInfo objectForKey:@"File"];
            
            if (tFileTree!=nil)
            {
                hierarchyChanged_=YES;
        
                // Did the file name change?
                
                if ([tUserInfo objectForKey:@"NameDidChange"]!=nil)
                {
                    if ([IBoutlineView_ editedRow]!=-1)
                    {
                        NSText * tFieldEditor;
                        
                        // Get the field editor
                        
                        tFieldEditor=[[IBoutlineView_ window] fieldEditor:NO forObject:IBoutlineView_];
                        
                        if (tFieldEditor!=nil)
                        {
                            [tFieldEditor setString:[FILENODE_DATA(tFileTree) fileName]];
                        }
                    }
                }
                
                // Refresh the appropriate row
                    
                [IBoutlineView_ reloadItem:tFileTree reloadChildren:[IBoutlineView_ isItemExpanded:tFileTree]];
                    
                [self updateFiles:IBoutlineView_];
            }
            else
            {
                NSArray * tArray;
                
                tArray=[tUserInfo objectForKey:@"Files"];
            
                if (tArray!=nil)
                {
                    NSEnumerator * tEnumerator;
                    
                    hierarchyChanged_=YES;
        
                    tEnumerator=[tArray objectEnumerator];
                    
                    // Refresh the appropriate rows
                    
                    while (tFileTree=[tEnumerator nextObject])
                    {
                        [IBoutlineView_ reloadItem:tFileTree reloadChildren:[IBoutlineView_ isItemExpanded:tFileTree]];
                    }
                        
                    [self updateFiles:IBoutlineView_];
                }
            }
        }
    }
}

#pragma mark -

- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    NSBeep();
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    PBFileTree * tFileTree;
    int tSelectedCount;
    
    if ([aMenuItem action]==@selector(switchImportPackageReferenceStyle:))
    {
        return YES;
    }
	
	if ([aMenuItem action]==@selector(expandAll:) && isImported_==NO)
    {
        // A COMPLETER
		
		return YES;
    }
    
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
    
    if (tSelectedCount>=1 && ([aMenuItem action]==@selector(showInfo:)))
    {
        return YES;
    }
    
    if (tSelectedCount==1)
    {
        int tSelectedRow;
        
        if ([aMenuItem action]==@selector(addFiles:))
        {
            return YES;
        }
        
        tSelectedRow=[IBoutlineView_ selectedRow];
    
        if (tSelectedRow>=0)
        {
            tFileTree=[IBoutlineView_ itemAtRow:tSelectedRow];
        
            switch([FILENODE_DATA(tFileTree) type])
            {
                case kBaseNode:
                    if ([aMenuItem action]==@selector(newFolder:) ||
                        [aMenuItem action]==@selector(selectDefaultLocationPath:))
                    {
                        return YES;
                    }
                    break;
                case kNewFolderNode:
                    if ([aMenuItem action]==@selector(delete:) ||
                        [aMenuItem action]==@selector(newFolder:) ||
                        [aMenuItem action]==@selector(selectDefaultLocationPath:))
                    {
                        return YES;
                    }
                    break;
                case kRealItemNode:
                    if ([aMenuItem action]==@selector(delete:) ||
                        [aMenuItem action]==@selector(newFolder:) ||
                        [aMenuItem action]==@selector(revealInFinder:))
                    {
                        return YES;
                    }
                    else
                    if (([aMenuItem action]==@selector(expand:) ||
                        [aMenuItem action]==@selector(expandOneLevel:))
                        && [tFileTree numberOfChildren]==0)
                    {
                        NSString * tPath;
                        NSFileManager * tFileManager;
                        BOOL isDirectory;
                        
                        tPath=[FILENODE_DATA(tFileTree) path];
                        
                        tFileManager=[NSFileManager defaultManager];
                        
                        if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==YES && isDirectory==YES)
                        {
                            NSDictionary * tFileAttributes;
                            NSString * tString;
                            
                            tFileAttributes=[tFileManager fileAttributesAtPath:tPath traverseLink:NO];
                            
                            tString=[tFileAttributes objectForKey:NSFileType];
                            
                            if (tString!=nil)
                            {
                                return ([tString isEqualToString:NSFileTypeDirectory]);
                            }
                        }
                    }
                    else
                    if ([aMenuItem action]==@selector(contract:))
                    {
                        if ([tFileTree numberOfChildren]!=0)
                        {
                            return YES;
                        }
                    }
                    break;
            }
            
            return NO;
        }
    }
    else
    {
        if (tSelectedCount>1)
        {
            PBFileNode * tFileNode;
            
            NSEnumerator * tEnumerator;
            NSNumber * tNumber;
            
            if ([aMenuItem action]==@selector(delete:))
            {
                tEnumerator=[IBoutlineView_ selectedRowEnumerator];
            
                while (tNumber = (NSNumber *) [tEnumerator nextObject])
                {
                    int tIndex;
                    
                    tIndex=[tNumber intValue];
                
                    tFileTree=(PBFileTree *) [IBoutlineView_ itemAtRow:tIndex];
                    
                    tFileNode=FILENODE_DATA(tFileTree);
                    
                    if ([tFileNode type]==kBaseNode)
                    {
                        return NO;
                    }
                }
            }
            else
            if ([aMenuItem action]==@selector(revealInFinder:))
            {
                tEnumerator=[IBoutlineView_ selectedRowEnumerator];
            
                while (tNumber = (NSNumber *) [tEnumerator nextObject])
                {
                    int tIndex;
                    
                    tIndex=[tNumber intValue];
                
                    tFileTree=(PBFileTree *) [IBoutlineView_ itemAtRow:tIndex];
                    
                    tFileNode=FILENODE_DATA(tFileTree);
                    
                    if ([tFileNode type]!=kRealItemNode)
                    {
                        return NO;
                    }
                }
            }
            else
            {
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

- (IBAction) newFolder:(id) sender
{
    int tRow;
    id tItem;
    PBFileTree * tParentTree=nil;
    PBFileNode * tParentNode;
    PBFileTree * tNewFolderTree=nil;
    
    tRow=[IBoutlineView_ selectedRow];

    tItem=[IBoutlineView_ itemAtRow:tRow];
    
    switch([FILENODE_DATA(tItem) type])
    {
        case kBaseNode:
        case kNewFolderNode:
            tParentTree=(PBFileTree *) tItem;
            break;
        case kRealItemNode:
            tParentTree=(PBFileTree *) [tItem nodeParent];
            break;
    }
    
    if (tParentTree!=nil)
    {
        if ([IBoutlineView_ isItemExpanded:tParentTree]==NO)
        {
            [IBoutlineView_ expandItem:tParentTree];
        }
    
        tParentNode=FILENODE_DATA(tParentTree);
            
        
        
        tNewFolderTree=[[PBFileTree alloc] initWithData:[PBFileNode newFolderFileNodeWithName:[PBFileTree uniqueNameWithParentFileTree:tParentTree]
                                                                                    icon:nil
                                                                                    user:[tParentNode uid]
                                                                                    group:[tParentNode gid]
                                                                                privileges:([tParentNode privileges] & ACCESSPERMS)]
                                                parent:nil
                                                children:[NSArray array]];
        
        if (tNewFolderTree!=nil)
        {
            [tParentTree insertSortedChild:tNewFolderTree];
            
            [tNewFolderTree release];
            
            hierarchyChanged_=YES;
            
            [IBoutlineView_ reloadData];
            
            tRow=[IBoutlineView_ rowForItem:tNewFolderTree];
            
            [IBoutlineView_ scrollRowToVisible:tRow];
            
            [IBoutlineView_ selectRow:tRow byExtendingSelection:NO];
            
            [IBoutlineView_ editColumn:[IBoutlineView_ columnWithIdentifier:@"Files"] row:tRow withEvent:nil select:YES];
            
            [self updateFiles:IBoutlineView_];
        }
    }
}

- (IBAction) expandAll:(id) sender
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Expanding...",@"No comment"),@"Status String",
                                                                   [NSNumber numberWithInt:1],@"Status ID",
                                                                   nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                        object:document_
                                                        userInfo:tDictionary];
                                                            
    [self performSelector:@selector(delayedExpandAll:)
               withObject:[NSNumber numberWithBool:(([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)!=0)]
               afterDelay:0.1f];
}

- (void) delayedExpandAll:(id) inObject
{
    BOOL tExpandedOne=NO;
			
	tExpandedOne=[fileTree_ expandAll:[inObject boolValue] withProjectPath:[document_ folder]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
														object:document_
													  userInfo:[NSDictionary dictionary]];
	
	if (tExpandedOne==YES)
	{
		hierarchyChanged_=YES;
	
		[IBoutlineView_ reloadData];

		[self updateFiles:IBoutlineView_];
	}
}

- (IBAction) expand:(id) sender
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Expanding...",@"No comment"),@"Status String",
                                                                   [NSNumber numberWithInt:1],@"Status ID",
                                                                   nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                        object:document_
                                                        userInfo:tDictionary];
                                                            
    [self performSelector:@selector(delayedExpand:)
               withObject:[NSNumber numberWithBool:(GetCurrentKeyModifiers() & (1<<optionKeyBit))!=0]
               afterDelay:0.1];
}

- (void) delayedExpand:(id) inObject
{
    PBFileTree * tFileTree;
    int tSelectedCount;
        
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
        
    if (tSelectedCount==1)
    {
        int tSelectedRow;
        
        tSelectedRow=[IBoutlineView_ selectedRow];
    
        if (tSelectedRow>=0)
        {
            tFileTree=[IBoutlineView_ itemAtRow:tSelectedRow];
            
            [tFileTree expand:[inObject boolValue]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                object:document_
                                                              userInfo:[NSDictionary dictionary]];
            
            hierarchyChanged_=YES;
            
            [IBoutlineView_ reloadItem:tFileTree];
        
            [self updateFiles:IBoutlineView_];
        }
    }
}

- (IBAction) contract:(id) sender
{
    PBFileTree * tFileTree;
    int tSelectedCount;
        
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
        
    if (tSelectedCount==1)
    {
        int tSelectedRow;
        
        tSelectedRow=[IBoutlineView_ selectedRow];
    
        if (tSelectedRow>=0)
        {
            tFileTree=[IBoutlineView_ itemAtRow:tSelectedRow];
            
            [IBoutlineView_ collapseItem:tFileTree];
            
            [tFileTree contract];
            
            hierarchyChanged_=YES;
            
            [IBoutlineView_ reloadItem:tFileTree];
            
            [self updateFiles:IBoutlineView_];
        }
    }
}

- (IBAction) expandOneLevel:(id) sender
{
    PBFileTree * tFileTree;
    int tSelectedCount;
        
    tSelectedCount=[IBoutlineView_ numberOfSelectedRows];
        
    if (tSelectedCount==1)
    {
        int tSelectedRow;
        
        tSelectedRow=[IBoutlineView_ selectedRow];
    
        if (tSelectedRow>=0)
        {
            tFileTree=[IBoutlineView_ itemAtRow:tSelectedRow];
            
            [tFileTree expandOneLevel:(GetCurrentKeyModifiers() & (1<<optionKeyBit))!=0];
            
            hierarchyChanged_=YES;
            
            [IBoutlineView_ reloadItem:tFileTree];
            
            [self updateFiles:IBoutlineView_];
        }
    }
}

#pragma mark -

- (void) beginFileSheet:(NSArray *) inFiles
{
    int tDefaultReferenceStyle;
    BOOL tDefaultKeepPermissionMode;
	
	tDefaultKeepPermissionMode=[defaults_ boolForKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
	
    tDefaultReferenceStyle=[defaults_ integerForKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    
    if (tDefaultReferenceStyle==0)
    {
        tDefaultReferenceStyle=kGlobalPath;
        
        [defaults_ setInteger:tDefaultReferenceStyle forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    }
    
    inFiles=[inFiles copy];
    
    // Prepare the sheet
    
    [IBownerAndGroup_ setState:(tDefaultKeepPermissionMode==YES) ? NSOnState : NSOffState];
    
    [IBreferenceStyle_ selectItemAtIndex:[IBreferenceStyle_ indexOfItemWithTag:tDefaultReferenceStyle]];
    
    [NSApp beginSheet:IBfileSheet_
       modalForWindow:[IBoutlineView_ window]
        modalDelegate:self
       didEndSelector:@selector(fileSheetDidEnd:returnCode:contextInfo:)
          contextInfo:inFiles];
}

- (IBAction) endFileSheet:(id) sender
{
    [NSApp endSheet:IBfileSheet_ returnCode:[sender tag]];
}

- (void) _addFiles:(NSArray *) inFilesArray keepOwnerAndGroup:(BOOL) inKeepOwnerAndGroup referenceStyle:(int) inReferenceStyle
{
	NSFileManager * tFileManager;
	NSString * tPath;
	NSEnumerator * tEnumerator;
	NSMutableArray * tNewSelectionArray;
	BOOL couldNeedToBeExpanded=NO;
	PBFileNode * tTargetNode=nil;
	int i,tCount;
	
	switch([FILENODE_DATA(parentFileTree_) type])
	{
		case kBaseNode:
		case kNewFolderNode:
			couldNeedToBeExpanded=YES;
			break;
		case kRealItemNode:
			break;
	}
	
	if (inKeepOwnerAndGroup==NO)
	{
		tTargetNode=FILENODE_DATA(parentFileTree_);
	}
	
	tNewSelectionArray=[NSMutableArray array];
	
	tFileManager=[NSFileManager defaultManager];
	
	tEnumerator=[inFilesArray objectEnumerator];
	
	while (tPath=[tEnumerator nextObject])
	{
		PBFileTree * tFileTree;
		id tFileNode;
		
		// 01/03/07 : Removed fileExistsAtPath:isDirectory: call
		
		tFileNode=[PBFileNode fileNodeWithType:kRealItemNode
										  path:tPath
									  pathType:inReferenceStyle];
										
		if (tFileNode!=nil)
		{
			struct stat tStat;

			if (lstat([tPath fileSystemRepresentation], &tStat)==0)
			{
				if (inKeepOwnerAndGroup==NO)
				{
					[tFileNode setUid:[tTargetNode uid]];
					[tFileNode setGid:[tTargetNode gid]];
				}
				else
				{
					[tFileNode setUid:tStat.st_uid];
					[tFileNode setGid:tStat.st_gid];
				}
				
				[tFileNode setPrivileges: (tStat.st_mode & ALLPERMS)];
			}
			else
			{
				// A COMPLETER
			}
			
			tFileTree=[[PBFileTree alloc] initWithData:tFileNode
												parent:parentFileTree_
											  children:nil];

			[parentFileTree_ insertSortedChild:tFileTree];
								
			[tFileTree release];
			
			[tNewSelectionArray addObject:tFileTree];
		}
	}
	
	[IBoutlineView_ deselectAll:nil];

	hierarchyChanged_=YES;
	
	[IBoutlineView_ reloadData];
	
	if (couldNeedToBeExpanded==YES)
	{
		if ([IBoutlineView_ isItemExpanded:parentFileTree_]==NO)
		{
			[IBoutlineView_ expandItem:parentFileTree_];
		}
	}
	
	tCount=[tNewSelectionArray count];
	
	for(i=0;i<tCount;i++)
	{
		[IBoutlineView_ selectRow:[IBoutlineView_ rowForItem:[tNewSelectionArray objectAtIndex:i]]
			 byExtendingSelection:YES];
	}
	
	[self updateFiles:IBoutlineView_];
}

- (void) fileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSArray * tArray;
    
    tArray=(NSArray *) contextInfo;
    
    if (returnCode==NSOKButton)
    {
		[self _addFiles:tArray keepOwnerAndGroup:([IBownerAndGroup_ state]==NSOnState) referenceStyle:[[IBreferenceStyle_ selectedItem] tag]];
	}
    
    [tArray release];

    [sheet orderOut:self];
}

#pragma mark -

- (IBAction)addFiles:(id)sender
{
    NSOpenPanel * tOpenPanel;
    int tSelectedRow;
    
    tSelectedRow=[IBoutlineView_ selectedRow];
    
    parentFileTree_=[IBoutlineView_ itemAtRow:tSelectedRow];
        
    if ([FILENODE_DATA(parentFileTree_) type]==kRealItemNode)
    {
        parentFileTree_=(PBFileTree *) [parentFileTree_ nodeParent];
    }
    
    if (floor(NSAppKitVersionNumber)<=663.0)
    {
        // Does not work on Panther, the buggy OS
    
        [defaults_ setBool:YES forKey:@"AppleShowAllFiles"];
    }
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setResolvesAliases:NO];
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setCanChooseDirectories:YES];
    [tOpenPanel setAllowsMultipleSelection:YES];
    [tOpenPanel setTreatsFilePackagesAsDirectories:YES];
    [tOpenPanel setDelegate:self];
    
    [tOpenPanel setPrompt:NSLocalizedString(@"Add...",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:nil
                                  file:nil
                                 types:nil
                        modalForWindow:[IBoutlineView_ window]
                         modalDelegate:self
                        didEndSelector:@selector(addFilesPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
    
    if (floor(NSAppKitVersionNumber)<=663.0)
    {
        [defaults_ setBool:NO forKey:@"AppleShowAllFiles"];
    }
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    // A AMELIORER (We need to be able to add items from these places)
	
	BOOL isDirectory;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDirectory]==YES)
	{
		if (isDirectory==NO)
		{
			return ![parentFileTree_ containsTreeWithName:[filename lastPathComponent]];
		}
	}
	
	return YES;
}

- (void) addFilesPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        NSArray * tFileNames;
		
		tFileNames=[sheet filenames];
		
		if (tFileNames!=nil)
		{
			NSEnumerator * tEnumerator;
			
			tEnumerator=[tFileNames objectEnumerator];
			
			if (tEnumerator!=nil)
			{
				NSString * tPath;
				BOOL tShowCustomizationDialog=YES;
				id tObject;
		
				// A AMELIORER
				
				while (tPath=[tEnumerator nextObject])
				{
					if ([parentFileTree_ containsTreeWithName:[tPath lastPathComponent]]==YES)
					{
						NSBeep();
						
						return;
					}
				}
				
				tObject=[defaults_ objectForKey: PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	
				if (tObject!=nil)
				{
					tShowCustomizationDialog=[defaults_ boolForKey: PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
				}
				
				if (tShowCustomizationDialog==YES)
				{
					[self performSelector:@selector(beginFileSheet:) withObject:tFileNames afterDelay:0.f];
				}
				else
				{
					BOOL tDefaultKeepPermissionMode;
					int tDefaultReferenceStyle;
					
					tDefaultKeepPermissionMode=[defaults_ boolForKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
					
					tDefaultReferenceStyle=[defaults_ integerForKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
			
					if (tDefaultReferenceStyle==0)
					{
						tDefaultReferenceStyle=kGlobalPath;
						
						[defaults_ setInteger:tDefaultReferenceStyle forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
					}
					
					[self _addFiles:tFileNames keepOwnerAndGroup:tDefaultKeepPermissionMode referenceStyle:tDefaultReferenceStyle];
				}
			}
		}
    }
}

- (IBAction) deleteSelectedRowsOfOutlineView:(NSOutlineView *) outlineView
{
    [self delete:nil];
}

- (IBAction)delete:(id)sender
{
    NSString * tAlertTitle;
    
    if ([IBoutlineView_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove this item?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove these items?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      NSLocalizedString(@"Remove",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      [IBoutlineView_ window],
                      self,
                      @selector(removeFileSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));
}

- (void) removeFileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBoutlineView_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            int tIndex;
            PBFileTree * tNode;
            
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            tIndex=[tNumber intValue];
            
            tNode=[IBoutlineView_ itemAtRow:tIndex];
            
            [tNode removeFromParent];
        }
        
        [IBoutlineView_ deselectAll:nil];
        
        hierarchyChanged_=YES;
        
        [IBoutlineView_ reloadData];
        
        [self updateFiles:IBoutlineView_];
    }
}

- (IBAction) showInfo:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBShowFileInspector"
                                                        object:nil];
}

- (IBAction) revealInFinder:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSWorkspace * tWorkSpace;
    PBFileTree * tNode;
     
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    tEnumerator=[IBoutlineView_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        tNode=[IBoutlineView_ itemAtRow:[tNumber intValue]];
        
        [tWorkSpace selectFile:[FILENODE_DATA(tNode) path] inFileViewerRootedAtPath:@""];
    }
}

- (IBAction)selectDefaultLocationPath:(id)sender
{
    int tRow;
    
    tRow=[IBoutlineView_ selectedRow];

    if (defaultLocation_!=[IBoutlineView_ itemAtRow:tRow])
    {
        defaultLocation_=[IBoutlineView_ itemAtRow:tRow];
    
        [IBoutlineView_ reloadData];
    
    	[IBdefaultLocationPath_ setStringValue:[defaultLocation_ filePath]];
    
        [self updateFiles:IBsetButton_];
    }
}

- (IBAction)switchImportPackageReferenceStyle:(id)sender
{
    [self updateFiles:IBsetButton_];
}

@end
