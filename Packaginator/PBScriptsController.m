/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBScriptsController.h"
#import "ImageAndTextCell.h"
#import "PBPopUpButtonCell.h"
#import "PBSharedConst.h"
#import "NSString+Iceberg.h"

#define PBScriptsFilesPBoardType	@"PBScriptsFilesPBoardType"
#define PBScriptsRequirementsPBoardType	@"PBScriptsRequirementsPBoardType"

@interface NSDictionary(ResourcePath) 

- (NSComparisonResult) compareResourcePath:(NSDictionary *) other;

@end

@implementation NSDictionary(ResourcePath)

- (NSComparisonResult) compareResourcePath:(NSDictionary *) other
{
    return [[((NSString *)[self objectForKey:@"Path"]) lastPathComponent] compare:[[other objectForKey:@"Path"] lastPathComponent] options:NSCaseInsensitiveSearch];
}
@end

@implementation PBScriptsController

+ (PBScriptsController *) scriptsController
{
    PBScriptsController * nController=nil;
    
    nController=[PBScriptsController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"Scripts" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"Scripts"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (void) dealloc
{
    [requirementsController_ release];
    
    [super dealloc];
}

- (void) awakeFromNib
{
    NSButtonCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    ImageAndTextCell *imageAndTextCell = nil;
    NSPopUpButtonCell * popupButtonCell = nil;
    NSCell * tTextFieldCell;
    id tMenuItem;
    
    // ** Requirements
    
    [IBrequirementsArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    // Status
    
    tableColumn = [IBrequirementsArray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
    
    // Label
    
    tableColumn = [IBrequirementsArray_ tableColumnWithIdentifier: @"Label"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
    
    // Level
    
    tableColumn = [IBrequirementsArray_ tableColumnWithIdentifier: @"Level"];
    
    popupButtonCell=[[[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease];
    
    [popupButtonCell setControlSize:NSSmallControlSize];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Requires",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:0];
    
    [tMenuItem setTag:0];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Recommends",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:1];
    
    [tMenuItem setTag:1];
    
    [popupButtonCell setBordered:NO];
    
    [popupButtonCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    [tableColumn setDataCell:popupButtonCell];
    
    // Double Action
    
    [IBrequirementsArray_ setTarget:self];
    [IBrequirementsArray_ setDoubleAction:@selector(editRequirements:)];
    
    [IBrequirementsArray_ registerForDraggedTypes:[NSArray arrayWithObject:PBScriptsRequirementsPBoardType]];
    
    // ** Installation Scripts
    
    [IBscriptsArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    // Status
    
    tableColumn = [IBscriptsArray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
    
    // Name
    
    tableColumn = [IBscriptsArray_ tableColumnWithIdentifier: @"Name"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
    
    // Reference
    
    tableColumn = [IBscriptsArray_ tableColumnWithIdentifier: @"Reference"];
    
    popupButtonCell=[[[PBPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease];
    
    [popupButtonCell setControlSize:NSSmallControlSize];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Project Relative",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:0];
    
    [tMenuItem setImage:[NSImage imageNamed:@"Relative13.tif"]];
    [tMenuItem setTag:kRelativeToProjectPath];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Absolute Path",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:1];
    
    [tMenuItem setImage:[NSImage imageNamed:@"Absolute13.tif"]];
    [tMenuItem setTag:kGlobalPath];
    
    [popupButtonCell setBordered:NO];
    
    [popupButtonCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    [tableColumn setDataCell:popupButtonCell];
    
    // Path
    
    tableColumn = [IBscriptsArray_ tableColumnWithIdentifier: @"Path"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
    
    [IBscriptsArray_ registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    
    // ** Resources
    
    [IBresourcesArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    // Status
    
    tableColumn = [IBresourcesArray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
    
    // Reference
    
    tableColumn = [IBresourcesArray_ tableColumnWithIdentifier: @"Reference"];
    
    popupButtonCell=[[[PBPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease];
    
    [popupButtonCell setControlSize:NSSmallControlSize];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Project Relative",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:0];
    
    [tMenuItem setImage:[NSImage imageNamed:@"Relative13.tif"]];
    [tMenuItem setTag:kRelativeToProjectPath];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Absolute Path",@"No comment")];
    
    tMenuItem=[popupButtonCell itemAtIndex:1];
    
    [tMenuItem setImage:[NSImage imageNamed:@"Absolute13.tif"]];
    [tMenuItem setTag:kGlobalPath];
    
    [popupButtonCell setBordered:NO];
    
    [popupButtonCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    [tableColumn setDataCell:popupButtonCell];
    
    // Name
    
    tableColumn = [IBresourcesArray_ tableColumnWithIdentifier: @"Files"];
    imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
    [imageAndTextCell setEditable:YES];
    [imageAndTextCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [tableColumn setDataCell:imageAndTextCell];
    
    [IBresourcesArray_ registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,
                                                                         PBScriptsFilesPBoardType,
                                                                         nil]];
    
    installationScriptsKeysArray_=[[NSArray alloc] initWithObjects:IFInstallationScriptsPreflight,
                                                                   IFInstallationScriptsPreinstall,
                                                                   IFInstallationScriptsPreupgrade,
                                                                   IFInstallationScriptsPostinstall,
                                                                   IFInstallationScriptsPostupgrade,
                                                                   IFInstallationScriptsPostflight,
                                                                   nil];
    
    fileManager_=[NSFileManager defaultManager];
    
    requirementsController_=[PBRequirementsController alloc];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    id tMenuItem;
    NSDictionary * tDictionary, * tScriptsDictionary;
    int i,tCount;
    
    [currentResourcesLanguage_ release];
    
    currentResourcesLanguage_=nil;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];

    tDictionary=[objectNode_ scripts];
    
    // Pre-Requirements
    
    [requirements_ release];
    
    requirements_=[[tDictionary objectForKey:SCRIPT_REQUIREMENTS_KEY] mutableCopy];
    
    [IBrequirementsArray_ deselectAll:nil];
    
    [IBaddButton_ setEnabled:YES];
    
    [IBeditButton_ setEnabled:NO];
    
    [IBdeleteButton_ setEnabled:NO];
	
	[IBrequirementsArray_ reloadData];
    
    // Installation Scripts
    
    tCount=[installationScriptsKeysArray_ count];
    
    [scripts_ release];
    
    scripts_=[[NSMutableDictionary alloc] initWithCapacity:tCount];
    
    tScriptsDictionary=[tDictionary objectForKey:SCRIPT_INSTALLATION_KEY];
    
    for(i=0;i<tCount;i++)
    {
        NSMutableDictionary * tScriptDictionary;
        
        tScriptDictionary=[[tScriptsDictionary objectForKey:[installationScriptsKeysArray_ objectAtIndex:i]] mutableCopy];
    
        [scripts_ setObject:tScriptDictionary forKey:[installationScriptsKeysArray_ objectAtIndex:i]];
        
        [tScriptDictionary release];
    }
    
    [IBscriptsArray_ deselectAll:nil];
    
    [IBscriptsArray_ reloadData];
    
    [IBchooseButton_ setEnabled:NO];
    
    // Resources
    
    [self updateResourcesLanguage];
    
    tMenuItem=[IBresourcesLanguage_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBresourcesLanguage_ itemAtIndex:0];
    }
    
    [IBresourcesLanguage_ selectItem:tMenuItem];
    
    [self switchResourcesLanguage:IBresourcesLanguage_];

    [IBdeleteResourceButton_ setEnabled:NO];
}

- (void) treeWillChange
{
    [super treeWillChange];
    
    [self updateRequirements:nil];
    
    [self updateInstallationScripts:nil];
    
    [self updateResources:nil];
}

#pragma mark -

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int tCount;
    
    if ([aNotification object]==IBrequirementsArray_)
    {
        tCount=[IBrequirementsArray_ numberOfSelectedRows];
        
        switch (tCount)
        {
            case 0:
                [IBeditButton_ setEnabled:NO];
                [IBdeleteButton_ setEnabled:NO];
                break;
            case 1:
                [IBeditButton_ setEnabled:YES];
                [IBdeleteButton_ setEnabled:YES];
                break;
            default:
                [IBeditButton_ setEnabled:NO];
                [IBdeleteButton_ setEnabled:YES];
                break;
        }
    }
    else if ([aNotification object]==IBscriptsArray_)
    {
        tCount=[IBscriptsArray_ numberOfSelectedRows];
        
        switch (tCount)
        {
            case 1:
                [IBchooseButton_  setEnabled:YES];
                break;
            default:
                [IBchooseButton_  setEnabled:NO];
                break;
        }
    }
    else if ([aNotification object]==IBresourcesArray_)
    {
        tCount=[IBresourcesArray_ numberOfSelectedRows];
        
        switch (tCount)
        {
            case 0:
                [IBdeleteResourceButton_  setEnabled:NO];
                break;
            default:
                [IBdeleteResourceButton_  setEnabled:YES];
                break;
        }
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView==IBrequirementsArray_)
    {
        if (requirements_!=nil)
        {
            return [requirements_ count];
        }
    }
    else if (IBresourcesArray_==aTableView)
    {
        if (resources_!=nil)
        {
            return [resources_ count];
        }
    }
    else if (IBscriptsArray_==aTableView)
    {
        if (scripts_!=nil)
        {
            return [installationScriptsKeysArray_ count];
        }
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if (aTableView==IBrequirementsArray_)
    {
        if (requirements_!=nil)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[requirements_ objectAtIndex:rowIndex];
            
            if ([[aTableColumn identifier] isEqualToString: @"Status"])
            {
                return [tDictionary objectForKey:@"Status"];
            }
            else if ([[aTableColumn identifier] isEqualToString: @"Label"])
            {
                return [tDictionary objectForKey:@"LabelKey"];
            }
        }
    }
    else if (IBresourcesArray_==aTableView)
    {
        if (resources_!=nil)
        {
            NSDictionary * tDictionary;
                
            tDictionary=[resources_ objectAtIndex:rowIndex];
                
            if ([[aTableColumn identifier] isEqualToString: @"Status"])
            {
                return [tDictionary objectForKey:@"Status"];
            }
            else if ([[aTableColumn identifier] isEqualToString: @"Files"])
            {
                return [tDictionary objectForKey:@"Path"];
            }
        }
    }
    else if (IBscriptsArray_==aTableView)
    {
        if (scripts_!=nil)
        {
            NSString * tKey;
                
            tKey=[installationScriptsKeysArray_ objectAtIndex:rowIndex];
                
            if ([[aTableColumn identifier] isEqualToString: @"Status"])
            {
                return [[scripts_ objectForKey:tKey] objectForKey:@"Status"];
            }
            else if ([[aTableColumn identifier] isEqualToString: @"Name"])
            {
                return NSLocalizedString(tKey,@"No comment");
            }
            else if ([[aTableColumn identifier] isEqualToString: @"Path"])
            {
                NSString * tPath;
            
            	tPath=[[scripts_ objectForKey:tKey] objectForKey:@"Path"];
            
                if ([tPath length]>0)
                {
                    NSNumber * tNumber;
                    NSString * tAbsolutePath;
                    
                    tNumber=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
                    
                    tAbsolutePath=tPath;
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tAbsolutePath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                        }
                    }

                    if ([fileManager_ fileExistsAtPath:tAbsolutePath]==NO)
                    {
                        return [[[NSAttributedString alloc] initWithString:tPath attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSForegroundColorAttributeName,nil]] autorelease];
                    }
                }
                
                return tPath;
            }
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{    
    if (tableView==IBrequirementsArray_)
    {
        if (requirements_!=nil)
        {
            if ([[tableColumn identifier] isEqualToString: @"Level"])
            {
                NSDictionary * tDictionary;
                NSString * tLevel;
                
                tDictionary=[requirements_ objectAtIndex:row];
                
                tLevel=[tDictionary objectForKey:@"Level"];
                
                [cell selectItemAtIndex:[cell indexOfItemWithTag:[tLevel intValue]]];
            }
        }
    }
    else if (IBresourcesArray_==tableView)
    {
        if (resources_!=nil)
        {
            NSMutableDictionary * tDictionary;

            if ([[tableColumn identifier] isEqualToString: @"Reference"])
            {
                NSNumber * tNumber;
                
                tDictionary=[resources_ objectAtIndex:row];
                
                tNumber=[tDictionary objectForKey:@"Path Type"];
                
                if (tNumber==nil)
                {
                    [cell selectItemAtIndex:[cell indexOfItemWithTag:kGlobalPath]];
                }
                else
                {
                    [cell selectItemAtIndex:[cell indexOfItemWithTag:[tNumber intValue]]];
                }
            }
            else
            if ([[tableColumn identifier] isEqualToString: @"Files"])
            {
            	NSImage * tIcon;
                NSString * tPath;
                
                tDictionary=[resources_ objectAtIndex:row];
                
                if (tDictionary!=nil)
                {
                    NSNumber * tNumber;
                    NSString * tAbsolutePath;
                    
                    tPath=[tDictionary objectForKey:@"Path"];
                
                    tNumber=[tDictionary objectForKey:@"Path Type"];
                    
                    tAbsolutePath=tPath;
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tAbsolutePath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                        }
                    }

                    if ([fileManager_ fileExistsAtPath:tAbsolutePath]==NO)
                    {
                        [(ImageAndTextCell*)cell setTextColor:[NSColor redColor]];
                    }
                    else
                    {
                        [(ImageAndTextCell*)cell setTextColor:[NSColor blackColor]];
                    }
                
                    tIcon=[tDictionary objectForKey:@"Icon"];
                
                    if (tIcon==nil)
                    {
                        tIcon=[[NSWorkspace sharedWorkspace] iconForFile:tAbsolutePath];
                        
                        [tIcon setSize:NSMakeSize(16,16)];
                        
                        [tDictionary setObject:tIcon forKey:@"Icon"];
                    }
                    
                    [(ImageAndTextCell*)cell setImage:tIcon];
                }
            }
        }
    }
    else if (IBscriptsArray_==tableView)
    {
        if ([[tableColumn identifier] isEqualToString: @"Reference"])
        {
            NSString * tKey;
            NSNumber * tNumber;
            
            tKey=[installationScriptsKeysArray_ objectAtIndex:row];
            
            tNumber=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
            if (tNumber==nil)
            {
                [cell selectItemAtIndex:[cell indexOfItemWithTag:kGlobalPath]];
            }
            else
            {
                [cell selectItemAtIndex:[cell indexOfItemWithTag:[tNumber intValue]]];
            }
        }
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if (tableView==IBrequirementsArray_)
    {
        if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
            NSMutableDictionary * tDictionary;
            
            tDictionary=[requirements_ objectAtIndex:row];
            
            [tDictionary setObject:object forKey:@"Status"];
            
            [self updateRequirements:IBrequirementsArray_];
        }
        else if ([[tableColumn identifier] isEqualToString: @"Level"])
        {
            int tTag;
            NSMutableDictionary * tDictionary;
            
            tTag=[[[tableColumn dataCellForRow:row] itemAtIndex:[object intValue]] tag];
            
            tDictionary=[requirements_ objectAtIndex:row];
            
            [tDictionary setObject:[NSNumber numberWithInt:tTag] forKey:@"Level"];
            
            [self updateRequirements:IBrequirementsArray_];
        }
    }
    else if (tableView==IBresourcesArray_)
    {
        if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
            [[resources_ objectAtIndex:row] setObject:object
                                               forKey:@"Status"];
            
            [self updateResources:IBresourcesArray_];
        }
        else if ([[tableColumn identifier] isEqualToString: @"Reference"])
        {
            int tTag,oldTag=kGlobalPath;
            NSNumber * tNumber;
            NSString * tPath;
            
            tTag=[[[tableColumn dataCellForRow:row] itemAtIndex:[object intValue]] tag];
            
            tNumber=[[resources_ objectAtIndex:row] objectForKey:@"Path Type"];
            
            if (tNumber!=nil)
            {
                oldTag=[tNumber intValue];
            }
            
            if (oldTag!=tTag)
            {
                [[resources_ objectAtIndex:row] setObject:[NSNumber numberWithInt:tTag] forKey:@"Path Type"];
            }
            
            tPath=[[resources_ objectAtIndex:row] objectForKey:@"Path"];
            
            if (tTag==kGlobalPath)
            {
                tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
            }
            else
            {
                tPath=[tPath stringByRelativizingToPath:[document_ folder]];
            }
            
            [[resources_ objectAtIndex:row] setObject:tPath forKey:@"Path"];
            
            textHasBeenUpdated_=YES;
            
            [self updateResources:IBresourcesArray_];
            
            [IBresourcesArray_ reloadData];
        }
    }
    else if (tableView==IBscriptsArray_)
    {
        NSString * tKey;
        
        tKey=[installationScriptsKeysArray_ objectAtIndex:row];
            
        if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
            [[scripts_ objectForKey:tKey] setObject:object forKey:@"Status"];
            
            [self updateInstallationScripts:IBscriptsArray_];
        }
        else if ([[tableColumn identifier] isEqualToString: @"Path"])
        {
            [[scripts_ objectForKey:tKey] setObject:object forKey:@"Path"];
            
            [self updateInstallationScripts:IBscriptsArray_];
        }
        else if ([[tableColumn identifier] isEqualToString: @"Reference"])
        {
            int tTag,oldTag=kGlobalPath;
            NSNumber * tNumber;
            NSString * tPath;
            
            tTag=[[[tableColumn dataCellForRow:row] itemAtIndex:[object intValue]] tag];
            
            tNumber=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
            if (tNumber!=nil)
            {
                oldTag=[tNumber intValue];
            }
            
            if (oldTag!=tTag)
            {
                [[scripts_ objectForKey:tKey] setObject:[NSNumber numberWithInt:tTag] forKey:@"Path Type"];
            }
            
            tPath=[[scripts_ objectForKey:tKey] objectForKey:@"Path"];
            
            if (tTag==kGlobalPath)
            {
                tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
            }
            else
            {
                tPath=[tPath stringByRelativizingToPath:[document_ folder]];
            }
            
            [[scripts_ objectForKey:tKey] setObject:tPath forKey:@"Path"];
            
            textHasBeenUpdated_=YES;
            
            [self updateInstallationScripts:IBscriptsArray_];
            
            [IBscriptsArray_ reloadData];
        }
    }
}

#pragma mark -

- (BOOL)tableView:(NSTableView *) tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    if (tableView==IBrequirementsArray_)
    {
        int i,tCount;
        NSMutableArray * tDragArray;
        
        [pboard declareTypes:[NSArray arrayWithObject: PBScriptsRequirementsPBoardType] owner:self];
    
        tCount=[rows count];
        
        tDragArray=[NSMutableArray arrayWithCapacity:tCount];
        
        for(i=0;i<tCount;i++)
        {
            [tDragArray addObject:[requirements_ objectAtIndex:[[rows objectAtIndex:i] intValue]]];
        }
        
        [pboard setPropertyList:tDragArray forType:PBScriptsRequirementsPBoardType];
    
        internalRequirementsDragData_=rows;
    }
    else if (tableView==IBresourcesArray_)
    {
        int i,tCount;
        NSMutableArray * tDragArray;
        
        [pboard declareTypes:[NSArray arrayWithObject: PBScriptsFilesPBoardType] owner:self];
        
        tCount=[rows count];
        
        tDragArray=[NSMutableArray arrayWithCapacity:tCount];
        
        for(i=0;i<tCount;i++)
        {
            [tDragArray addObject:[resources_ objectAtIndex:[[rows objectAtIndex:i] intValue]]];
        }
        
        [pboard setPropertyList:tDragArray forType:PBScriptsFilesPBoardType];
    }
    else if (tableView==IBscriptsArray_)
    {
        return NO;
    }
        
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*) tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    int i,tCount;
    NSArray * tArray;
                    
    if (op==NSTableViewDropAbove)
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
        
        if (tableView==IBrequirementsArray_)
        {
            if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBScriptsRequirementsPBoardType]]!=nil)
            {
            	if ([info draggingSource]==IBrequirementsArray_)
                {
                    // Internal Drag
                    
                    if ([internalRequirementsDragData_ count]==1)
                    {
                        int tOriginalRow=[[internalRequirementsDragData_ objectAtIndex:0] intValue];
                    
                        if (tOriginalRow!=row && row!=(tOriginalRow+1))
                        {
                            return NSDragOperationMove;
                        }
                    }
                    else
                    {
                        return NSDragOperationMove;
                    }
                }
                else
                {
                    // External Drag
                
                    if ([requirements_ count]==0)
                    {
                        [tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
                    }
                    
                    return NSDragOperationCopy;
                }
            }
        }
        else if (tableView==IBresourcesArray_)
        {
            // No internal drag and drop
        
            if ([info draggingSource]!=IBresourcesArray_)
            {
                if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
                {
                    // Check that the file is not already included
                    
                    int j,tCurrentCount;
                    NSString * tFirstPath;
                    BOOL find=NO;
                    int tInsertionIndex;
                    
                    tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
                    
                    tFirstPath=[tArray objectAtIndex:0];
                    
                    tCount=[tArray count];
                    
                    // Check that no file is already in the current list
                    
                    tInsertionIndex=tCurrentCount=[resources_ count];
                    
                    for(j=0;j<tCurrentCount;j++)
                    {
                        NSString * tCurrentPath;
                        
                        tCurrentPath=[[resources_ objectAtIndex:j] objectForKey:@"Path"];
                        
                        for(i=0;i<tCount;i++)
                        {
                            if ([tCurrentPath isEqualToString:[tArray objectAtIndex:i]]==YES)
                            {
                                return NSDragOperationNone;
                            }
                        }
                        
                        // Find the appropriate drop location
                        
                        if (find==NO && [[tFirstPath lastPathComponent] compare:[tCurrentPath lastPathComponent] options:NSCaseInsensitiveSearch]!=NSOrderedDescending)
                        {
                            find=YES;
                            tInsertionIndex=j;
                        }
                    }
                    
                    if (tCurrentCount>0)
                    {
                        [tableView setDropRow:tInsertionIndex dropOperation:op];
                    }
                    else
                    {
                        [tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
                    }
                    
                    return NSDragOperationCopy;
                }
                else
                {
                    if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBScriptsFilesPBoardType]]!=nil)
                    {
                        int j,tCurrentCount;
                        NSString * tFirstPath;
                        BOOL find=NO;
                        int tInsertionIndex;
                        
                        tArray=(NSArray *) [tPasteBoard propertyListForType:PBScriptsFilesPBoardType];
                        
                        tFirstPath=[[tArray objectAtIndex:0] objectForKey:@"Path"];
                        
                        tCount=[tArray count];
                        
                        // Check that no file is already in the current list
                        
                        tInsertionIndex=tCurrentCount=[resources_ count];
                        
                        for(j=0;j<tCurrentCount;j++)
                        {
                            NSString * tCurrentPath;
                            
                            tCurrentPath=[[resources_ objectAtIndex:j] objectForKey:@"Path"];
                            
                            for(i=0;i<tCount;i++)
                            {
                                if ([tCurrentPath isEqualToString:[[tArray objectAtIndex:i] objectForKey:@"Path"]]==YES)
                                {
                                    return NSDragOperationNone;
                                }
                            }
                            
                            // Find the appropriate drop location
                            
                            if (find==NO && [[tFirstPath lastPathComponent] compare:[tCurrentPath lastPathComponent] options:NSCaseInsensitiveSearch]!=NSOrderedDescending)
                            {
                                find=YES;
                                tInsertionIndex=j;
                            }
                        }
                        
                        if (tCurrentCount>0)
                        {
                            [tableView setDropRow:tInsertionIndex dropOperation:op];
                        }
                        else
                        {
                            [tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
                        }
                    
                        // Find the appropriate drop location
                    
                        return NSDragOperationCopy;
                    }
                }
            }
        }
    }
    else if (NSTableViewDropOn==op)
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
        
        if (tableView==IBscriptsArray_)
        {
            // No internal drag and drop
        
            if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
            {
                tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
                    
                tCount=[tArray count];
                
                if (tCount==1)
                {
                    BOOL isDirectory;

                    if ([fileManager_ fileExistsAtPath:[tArray objectAtIndex:0] isDirectory:&isDirectory]==YES && isDirectory==NO)
                    {
                        return NSDragOperationMove;
                    }
                }
            }
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard * tPasteBoard;
    int i,tCount=0;
    NSMutableArray * tNewSelectionArray;
    
    tPasteBoard=[info draggingPasteboard];
    
    tNewSelectionArray=[NSMutableArray array];
    
    if (tableView==IBrequirementsArray_)
    {
        if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBScriptsRequirementsPBoardType]]!=nil)
        {
            NSArray * tArray;
            
            tArray=(NSArray *) [tPasteBoard propertyListForType:PBScriptsRequirementsPBoardType];
            
            tCount=[tArray count];
            
            if ([info draggingSource]==IBrequirementsArray_)
            {
                // Internal Drag
                
                NSDictionary * tDictionary;
                int tRowIndex;
                NSMutableArray * tTemporaryArray;
                int tOriginalRow=row;
                
                tCount=[internalRequirementsDragData_ count];
                
                [IBrequirementsArray_ deselectAll:nil];
                
                tTemporaryArray=[NSMutableArray array];
                
                for(i=tCount-1;i>=0;i--)
                {
                    tRowIndex=[[internalRequirementsDragData_ objectAtIndex:i] intValue];
                    
                    tDictionary=(NSDictionary *) [requirements_ objectAtIndex:tRowIndex];
                    
                    [tTemporaryArray insertObject:tDictionary atIndex:0];
                    
                    [requirements_ removeObjectAtIndex:tRowIndex];
                    
                    if (tRowIndex<tOriginalRow)
                    {
                        row--;
                    }
                }
                
                for(i=tCount-1;i>=0;i--)
                {
                    tDictionary=(NSDictionary *) [tTemporaryArray objectAtIndex:i];
                    
                    [requirements_ insertObject:tDictionary atIndex:row];
                }
            }
            else
            {
                int tIndexRow=row;
        
                [IBrequirementsArray_ deselectAll:nil];
                
                // External Drag
            
                for(i=0;i<tCount;i++)
                {
                    NSDictionary * tDictionary;
                    
                    tDictionary=[tArray objectAtIndex:i];
                    
                    [requirements_ insertObject:tDictionary atIndex:tIndexRow++];
                }
            }
                
            [IBrequirementsArray_ reloadData];
            
            for(i=0;i<tCount;i++)
            {
                [IBrequirementsArray_ selectRow:row++ byExtendingSelection:YES];
            }
            
            [self updateRequirements:IBrequirementsArray_];
        }
    }
    else if (tableView==IBresourcesArray_)
    {
        NSArray * tArray;
        int j,tCurrentCount;
        NSMutableDictionary * nDictionary;
        
        if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
        {
            NSString * tPath;
            
            tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
            
            tCount=[tArray count];
            
            // Add the new files
            
            for(i=0;i<tCount;i++)
            {
                tPath=[tArray objectAtIndex:i];
                
                nDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tPath,@"Path",
                                                                              [NSNumber numberWithBool:YES],@"Status",
                                                                              nil];
                
                [resources_ addObject:nDictionary];
                    
                [tNewSelectionArray addObject:nDictionary];
            }
        }
        else if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBScriptsFilesPBoardType]]!=nil)
        {
            tArray=(NSArray *) [tPasteBoard propertyListForType:PBScriptsFilesPBoardType];
            
            tCount=[tArray count];
            
            // Add the new files
            
            for(i=0;i<tCount;i++)
            {
                nDictionary=[tArray objectAtIndex:i];
                
                [resources_ addObject:nDictionary];
                    
                [tNewSelectionArray addObject:nDictionary];
            }
        }
        
        // Sort the array
            
        [resources_ sortUsingSelector:@selector(compareResourcePath:)];
        
        // Compute the new selection
        
        tCurrentCount=[resources_ count];
        
        for(i=0;i<tCount;i++)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[tNewSelectionArray  objectAtIndex:i];
            
            for(j=0;j<tCurrentCount;j++)
            {
                if (tDictionary==[resources_ objectAtIndex:j])
                {
                    [tNewSelectionArray replaceObjectAtIndex:i
                                                    withObject:[NSNumber numberWithInt:j]];
                    
                    break;
                }
            }
        }
        
        [IBresourcesArray_ deselectAll:nil];
        
        [IBresourcesArray_ reloadData];
    
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBresourcesArray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue]
                    byExtendingSelection:YES];
        }
        
        [self updateResources:IBresourcesArray_];
    }
    else if (tableView==IBscriptsArray_)
    {
        NSArray * tArray;
        
        if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
        {
            NSString * tKey;
            NSNumber * tNumber;
            NSString * tPath;
            
            tKey=[installationScriptsKeysArray_ objectAtIndex:row];
        
            tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
            
            tPath=[tArray objectAtIndex:0];
            
            tNumber=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
            if (tNumber!=nil)
            {
                if ([tNumber intValue]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByRelativizingToPath:[document_ folder]];
                }
            }
            
            [[scripts_ objectForKey:tKey] setObject:tPath forKey:@"Path"];
            
            textHasBeenUpdated_=YES;
            
            [self updateInstallationScripts:IBscriptsArray_];
        }
    }
    
    return YES;
}

#pragma mark -

- (IBAction) updateRequirements:(id) sender
{
    NSMutableDictionary * tScriptsDictionary;
    
    tScriptsDictionary=[objectNode_ scripts];
    
    [tScriptsDictionary setObject:requirements_
                           forKey:SCRIPT_REQUIREMENTS_KEY];
    
    if (sender!=nil)
    {
        [self setDocumentNeedsUpdate:YES];
    }
}

- (void) requirementDidChanged
{
    NSMutableDictionary * tRequirement;
    
    tRequirement=[requirementsController_ dictionary];
    
    switch(requirementDialogMode_)
    {
        case PBSCRIPT_ADD:
            [requirements_ addObject:tRequirement];
            
            [IBrequirementsArray_ selectRow:[requirements_ count]-1 byExtendingSelection:NO];
            break;
        case PBSCRIPT_EDIT:
            {
                int tSelectedRow;
                
                tSelectedRow=[IBrequirementsArray_ selectedRow];
                
                [requirements_ replaceObjectAtIndex:tSelectedRow withObject:tRequirement];
            }
            
            break;
    }
    
    [IBrequirementsArray_ reloadData];
    
    [self updateRequirements:IBrequirementsArray_];
}

- (IBAction) addRequirements:(id)sender
{
    requirementDialogMode_=PBSCRIPT_ADD;
    
    [requirementsController_ beginRequirementSheetForWindow:[IBview_ window]
                                             withDictionary:[PBObjectNode defaultRequirementMutableDictionaryWithLabel:[self uniqueNameForRequirement]]
                                             parent:self];
}

- (IBAction) editRequirements:(id)sender
{
    int tRow;
    
    tRow=[IBrequirementsArray_ selectedRow];
    
    if (tRow>=0)
    {
        requirementDialogMode_=PBSCRIPT_EDIT;
    
        [requirementsController_ beginRequirementSheetForWindow:[IBview_ window]
                                                 withDictionary:[requirements_ objectAtIndex:tRow]
                                                         parent:self];
    }
}

- (IBAction) deleteRequirements:(id)sender
{
    NSString * tAlertTitle;
    
    if ([IBrequirementsArray_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove this requirement?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove these requirements?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      NSLocalizedString(@"Remove",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      [IBview_ window],
                      self,
                      @selector(removeRequirementsSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));
}

#pragma mark -

- (IBAction) deleteSelectedRowsOfTableView:(NSTableView *) tableView
{
    if (tableView==IBrequirementsArray_)
    {
        [self deleteRequirements:nil];
    }
    else if (tableView==IBresourcesArray_)
    {
        [self deleteResources:nil];
    }
}

- (IBAction) deleteResources:(id)sender
{
    NSString * tAlertTitle;
    
    if ([IBresourcesArray_ numberOfSelectedRows]==1)
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
                      [IBview_ window],
                      self,
                      @selector(removeResourcesSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));

}

- (void) removeResourcesSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBresourcesArray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            [resources_ removeObjectAtIndex:[tNumber intValue]];
        }
        
        [IBresourcesArray_ deselectAll:nil];
        
        [IBresourcesArray_ reloadData];
        
        [self updateResources:IBresourcesArray_];
    }
}

- (void) removeRequirementsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBrequirementsArray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            [requirements_ removeObjectAtIndex:[tNumber intValue]];
        }
        
        [IBrequirementsArray_ deselectAll:nil];
        
        [IBrequirementsArray_ reloadData];
        
        [self updateRequirements:IBrequirementsArray_];
    }
}

#pragma mark -

- (IBAction)selectInstallationScriptsPath:(id)sender
{
    NSOpenPanel * tOpenPanel;
    int tSelectedRow;
    NSString * tKey;
    NSString * tPath;
    NSNumber * tNumberType;
            
    tOpenPanel=[NSOpenPanel openPanel];
    
    tSelectedRow=[IBscriptsArray_ selectedRow];
    
    tKey=[installationScriptsKeysArray_ objectAtIndex:tSelectedRow];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    tPath=[[[scripts_ objectForKey:tKey] objectForKey:@"Path"] stringByExpandingTildeInPath];
    
    tNumberType=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
    if (tNumberType!=nil)
    {
        if ([tNumberType intValue]==kRelativeToProjectPath)
        {
            tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
        }
    }
    
    [tOpenPanel beginSheetForDirectory:tPath
                                  file:nil
                                 types:nil
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(installationScriptsOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) installationScriptsOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        int tSelectedRow;
        NSString * tKey;
        NSNumber * tNumberType;
        NSString * tPath;
        
        tSelectedRow=[IBscriptsArray_ selectedRow];
    
        tKey=[installationScriptsKeysArray_ objectAtIndex:tSelectedRow];
        
        tPath=[sheet filename];
        
        tNumberType=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
        if (tNumberType!=nil)
        {
            if ([tNumberType intValue]==kRelativeToProjectPath)
            {
                tPath=[tPath stringByRelativizingToPath:[document_ folder]];
            }
        }
        
        [[scripts_ objectForKey:tKey] setObject:tPath forKey:@"Path"];
        
        [IBscriptsArray_ reloadData];
        
        textHasBeenUpdated_=YES;
        
        [self updateInstallationScripts:IBscriptsArray_];
    }
}

- (IBAction) updateInstallationScripts:(id) sender
{
    NSMutableDictionary * tScriptsDictionary;
    
    tScriptsDictionary=[objectNode_ scripts];
    
    [tScriptsDictionary setObject:scripts_
                            forKey:SCRIPT_INSTALLATION_KEY];
    
    if (sender!=nil)
    {
        if (sender==IBscriptsArray_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

- (IBAction) revealScriptsInFinder:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSWorkspace * tWorkSpace;
    NSString * tKey;
    NSString * tPath;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    tEnumerator=[IBscriptsArray_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        tKey=[installationScriptsKeysArray_ objectAtIndex:[tNumber intValue]];
        
        tPath=[[scripts_ objectForKey:tKey] objectForKey:@"Path"];
        
        if (tPath!=nil && [tPath length]>0)
        {
            NSNumber * tNumberType;
            
            tNumberType=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
            if (tNumberType!=nil)
            {
                if ([tNumberType intValue]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                }
            }
            
            if ([fileManager_ fileExistsAtPath:tPath]==YES)
            {
                [tWorkSpace selectFile:tPath inFileViewerRootedAtPath:@""];
            }
        }
    }
}

- (IBAction) openScriptsInEditor:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSWorkspace * tWorkSpace;
    NSString * tKey;
    NSString * tPath;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    tEnumerator=[IBscriptsArray_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        tKey=[installationScriptsKeysArray_ objectAtIndex:[tNumber intValue]];
        
        tPath=[[scripts_ objectForKey:tKey] objectForKey:@"Path"];
        
        if (tPath!=nil && [tPath length]>0)
        {
            NSNumber * tNumberType;
            
            tNumberType=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
            
            if (tNumberType!=nil)
            {
                if ([tNumberType intValue]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                }
            }
            
            if ([fileManager_ fileExistsAtPath:tPath]==YES && 
                [fileManager_ isExecutableFileAtPath:tPath]==NO)
            {
                //[tWorkSpace openFile:tPath withApplication:];	// A AMELIORER
                
                [tWorkSpace openFile:tPath];
            }
        }
    }
}

#pragma mark -

- (IBAction)switchResourcesLanguage:(id)sender
{
    NSMutableDictionary * tDictionary;
    id tSelectedItem;
    NSDictionary * tResourcesDictionary;
    NSArray * tArray;
    int i,tCount;
    NSString * oldLanguage;
    
    // Resign first responder to save the currently edited value
    
    [[IBview_ window] makeFirstResponder:nil];
    
    tSelectedItem=[sender selectedItem];
    
    switch([tSelectedItem tag])
    {
        case -222:
            NSBeginAlertSheet(NSLocalizedString(@"Do you really want to remove this localization?",@"No comment"),
                              NSLocalizedString(@"Remove",@"No comment"),
                              NSLocalizedString(@"Cancel",@"No comment"),
                              nil,
                              [IBview_ window],
                              self,
                              @selector(removeResourcesLocalizationSheetDidEnd:returnCode:contextInfo:),
                              nil,
                              NULL,
                              NSLocalizedString(@"This cannot be undone.",@"No comment"));
            return;
        case -111:
            [[PBLocalizationPanel localizationPanel] beginSheetModalForWindow:[IBview_ window]
                                                                modalDelegate:self
                                                               didEndSelector:@selector(localizationPanelDidEnd:returnCode:localization:)];
            return;
    }
    
    tDictionary=[objectNode_ scripts];
    
    tResourcesDictionary=[tDictionary objectForKey:SCRIPT_ADDITIONAL_KEY];
    
    oldLanguage=currentResourcesLanguage_;
    
    currentResourcesLanguage_=[[IBresourcesLanguage_ selectedItem] title];
    
    if ([currentResourcesLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentResourcesLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentResourcesLanguage_ retain];
    
    tArray=[tResourcesDictionary objectForKey:currentResourcesLanguage_];
    
    tCount=[tArray count];
    
    [resources_ release];
    
    resources_=[[NSMutableArray alloc] initWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSMutableDictionary * tFileObject;
        
        tFileObject=[[tArray objectAtIndex:i] mutableCopy];
        
        [resources_ addObject:tFileObject];
        
        [tFileObject release];
    }
    
    [IBresourcesArray_ deselectAll:nil];
    
    [IBresourcesArray_ reloadData];
}

- (IBAction) updateResources:(id) sender
{
    NSDictionary * tDictionary, * nDictionary;
    int i,tCount;
    NSMutableArray * tArray;
    NSMutableDictionary * tScriptsDictionary;
    NSMutableDictionary * tResourcesScriptsDictionary;
    
    tCount=[resources_ count];
    
    tArray=[NSMutableArray arrayWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        tDictionary=(NSDictionary *) [resources_ objectAtIndex:i];
        
        nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tDictionary objectForKey:@"Status"],@"Status",
                                                               [tDictionary objectForKey:@"Path"],@"Path",
                                                               [tDictionary objectForKey:@"Path Type"],@"Path Type",
                                                               nil];
    
        [tArray addObject:nDictionary];
    }
    
    tScriptsDictionary=[objectNode_ scripts];
    
    tResourcesScriptsDictionary=[[tScriptsDictionary objectForKey:SCRIPT_ADDITIONAL_KEY] mutableCopy];
    
    [tResourcesScriptsDictionary setObject:tArray
                                    forKey:currentResourcesLanguage_];
    
    [tScriptsDictionary setObject:tResourcesScriptsDictionary
                           forKey:SCRIPT_ADDITIONAL_KEY];
    
    [tResourcesScriptsDictionary release];
    
    if (sender!=nil)
    {
        [self setDocumentNeedsUpdate:YES];
    }
}

- (void) updateResourcesLanguage
{
    NSDictionary * tDictionary;
    NSDictionary * tResourcesDictionary;
    NSMutableArray * tMutableArray;

    tDictionary=[objectNode_ scripts];
    
    tResourcesDictionary=[tDictionary objectForKey:SCRIPT_ADDITIONAL_KEY];
    
    [IBresourcesLanguage_ removeAllItems];
    
    tMutableArray=[[tResourcesDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBresourcesLanguage_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBresourcesLanguage_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBresourcesLanguage_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBresourcesLanguage_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBresourcesLanguage_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBresourcesLanguage_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (void) removeResourcesLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tDictionary;
        NSMutableDictionary * tResourcesDictionary;
        id tMenuItem;
        
        tDictionary=[objectNode_ scripts];
        
        tResourcesDictionary=[[tDictionary objectForKey:SCRIPT_ADDITIONAL_KEY] mutableCopy];
        
        [tResourcesDictionary removeObjectForKey:currentResourcesLanguage_];
        
        [tDictionary setObject:tResourcesDictionary forKey:SCRIPT_ADDITIONAL_KEY];
        
        // Update PopupButton
        
        [IBresourcesLanguage_ removeItemWithTitle:currentResourcesLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBresourcesLanguage_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBresourcesLanguage_ itemAtIndex:0];
        }
        
        [IBresourcesLanguage_ selectItem:tMenuItem];
        
        [self switchResourcesLanguage:IBresourcesLanguage_];
        
        [self updateResources:IBresourcesLanguage_];
    }
    else
    {
        [IBresourcesLanguage_ selectItemWithTitle:currentResourcesLanguage_];
    }
}

- (IBAction) revealResourcesInFinder:(id) sender
{
    NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSWorkspace * tWorkSpace;
    NSString * tPath;
    NSDictionary * tDictionary;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    tEnumerator=[IBresourcesArray_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        tDictionary=[resources_ objectAtIndex:[tNumber intValue]];
        
        tPath=[tDictionary objectForKey:@"Path"];
        
        if (tPath!=nil && [tPath length]>0)
        {
            NSNumber * tNumberType;
            
            tNumberType=[tDictionary objectForKey:@"Path Type"];
            
            if (tNumberType!=nil)
            {
                if ([tNumberType intValue]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                }
            }
            
            if ([fileManager_ fileExistsAtPath:tPath]==YES)
            {
                [tWorkSpace selectFile:tPath inFileViewerRootedAtPath:@""];
            }
        }
    }
}

- (IBAction) addResources:(id)sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setAllowsMultipleSelection:YES];
    [tOpenPanel setCanChooseDirectories:YES];
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Add...",@"No comment")];
    
    [tOpenPanel setDelegate:self];
    
    [tOpenPanel beginSheetForDirectory:nil
                                  file:nil
                                 types:nil
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(resourcesOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    // If an item is already in the list, it should not be selected again
    
    int i,tCount;
    
    tCount=[resources_ count];
    
    for(i=0;i<tCount;i++)
    {
        if ([[[resources_ objectAtIndex:i] objectForKey:@"Path"] compare:filename options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void) resourcesOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        NSString * tPath;
        NSDictionary * nDictionary;
        int i,tCount;
        int j,tCurrentCount;
        NSMutableArray * tNewSelectionArray;
        NSArray * tArray;
        
    	tNewSelectionArray=[NSMutableArray array];
    
        tArray=[sheet filenames];
        
        tCount=[tArray count];
        
        // Add the new files
        
        for(i=0;i<tCount;i++)
        {
            tPath=[tArray objectAtIndex:i];
            
            nDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tPath,@"Path",
                                                                          [NSNumber numberWithBool:YES],@"Status",
                                                                          nil];
            
            [resources_ addObject:nDictionary];
                
            [tNewSelectionArray addObject:nDictionary];
        }
        
        // Sort the array
            
        [resources_ sortUsingSelector:@selector(compareResourcePath:)];
        
        // Compute the new selection
        
        tCurrentCount=[resources_ count];
        
        for(i=0;i<tCount;i++)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[tNewSelectionArray  objectAtIndex:i];
            
            for(j=0;j<tCurrentCount;j++)
            {
                if (tDictionary==[resources_ objectAtIndex:j])
                {
                    [tNewSelectionArray replaceObjectAtIndex:i
                                                    withObject:[NSNumber numberWithInt:j]];
                    
                    break;
                }
            }
        }
        
        [IBresourcesArray_ deselectAll:nil];
        
        [IBresourcesArray_ reloadData];
    
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBresourcesArray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue]
                    byExtendingSelection:YES];
        }
        
        [self updateResources:IBresourcesArray_];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
    
    if (tAction==@selector(switchResourcesLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentResourcesLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    else if (tAction==@selector(deleteResources:))
	{
		return ([IBresourcesArray_ numberOfSelectedRows]>0);
	}
    else if (tAction==@selector(revealResourcesInFinder:))
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSString * tPath;
    
    	tEnumerator=[IBresourcesArray_ selectedRowEnumerator];
    
        while (tNumber = (NSNumber *) [tEnumerator nextObject])
        {
            int tIndex=[tNumber intValue];
            
            tPath=[[resources_ objectAtIndex:tIndex] objectForKey:@"Path"];
            
            if (tPath!=nil && [tPath length]>0)
            {
                NSNumber * tNumberType;
                
                tNumberType=[[resources_ objectAtIndex:tIndex] objectForKey:@"Path Type"];
                
                if (tNumberType!=nil)
                {
                    if ([tNumberType intValue]==kRelativeToProjectPath)
                    {
                        tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                    }
                }
                
                if ([fileManager_ fileExistsAtPath:tPath]==YES)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }
    else if (tAction==@selector(openScriptsInEditor:) ||
             tAction==@selector(revealScriptsInFinder:))
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSString * tKey;
        NSString * tPath;
    
    	tEnumerator=[IBscriptsArray_ selectedRowEnumerator];
    
        while (tNumber = (NSNumber *) [tEnumerator nextObject])
        {
            tKey=[installationScriptsKeysArray_ objectAtIndex:[tNumber intValue]];
            
            tPath=[[scripts_ objectForKey:tKey] objectForKey:@"Path"];
            
            if (tPath!=nil && [tPath length]>0)
            {
                NSNumber * tNumberType;
                
                tNumberType=[[scripts_ objectForKey:tKey] objectForKey:@"Path Type"];
                
                if (tNumberType!=nil)
                {
                    if ([tNumberType intValue]==kRelativeToProjectPath)
                    {
                        tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                    }
                }
                
                if ([fileManager_ fileExistsAtPath:tPath]==YES)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (BOOL) shouldAddLocalization:(NSString *) inLocalization
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tResourcesDictionary;
    NSArray * tArray;
    int i,tCount;

    tDictionary=[objectNode_ scripts];

    tResourcesDictionary=[tDictionary objectForKey:SCRIPT_ADDITIONAL_KEY];

    tArray=[tResourcesDictionary allKeys];
    
    tCount=[tArray count];
    
    // Check that the Language is not already in the list
    
    for(i=0;i<tCount;i++)
    {
        if ([[tArray objectAtIndex:i] compare:inLocalization options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            return NO;
        }
    }

    return YES;
}

- (void) localizationPanelDidEnd:(PBLocalizationPanel *) localizationPanel returnCode:(int) returnCode localization:(NSString *) localization
{
    if (returnCode==NSOKButton)
    {
        NSMutableDictionary * tDictionary;
        NSDictionary * tResourcesDictionary;
        NSMutableDictionary * tMutableResourcesDictionary;
        

        tDictionary=[objectNode_ scripts];
    
        tResourcesDictionary=[tDictionary objectForKey:SCRIPT_ADDITIONAL_KEY];
        
        // Add the new language
        
        tMutableResourcesDictionary=[tResourcesDictionary mutableCopy];
        
        [tMutableResourcesDictionary setObject:[NSArray array]
                                          forKey:localization];
        
        [tDictionary setObject:tMutableResourcesDictionary
                        forKey:SCRIPT_ADDITIONAL_KEY];
        
        [tMutableResourcesDictionary release];
        
        // Update the PopupButton
        
        [self updateResourcesLanguage];
        
        [self updateResources:IBresourcesLanguage_];
        
        [IBresourcesLanguage_ selectItemWithTitle:localization];
        
        [self switchResourcesLanguage:IBresourcesLanguage_];
    }
    else
    {
        [IBresourcesLanguage_ selectItemWithTitle:currentResourcesLanguage_];
    }
}

#pragma mark -

- (NSString *) uniqueNameForRequirement
{
    int _sIndex=0;
    static NSString * tLocalizedBaseName=nil;
    int i,tCount;
    NSString * tString;
    
    if (tLocalizedBaseName==nil)
    {
        tLocalizedBaseName=[[NSString alloc] initWithString:NSLocalizedString(@"Untitled Requirement",@"No comment")];
    }
    
    tCount=[requirements_ count];
    
    do
    {
        NSDictionary * tDictionary;
        
        if (_sIndex>0)
        {
            tString=[[NSString alloc] initWithFormat:@"%@ %d",tLocalizedBaseName,_sIndex];
        }
        else
        {
            tString=[[NSString alloc] initWithString:tLocalizedBaseName];
        }
        
        _sIndex++;
        
        for(i=0;i<tCount;i++)
        {
            tDictionary=[requirements_ objectAtIndex:i];
            
            if ([[tDictionary objectForKey:@"LabelKey"] isEqualToString:tString]==YES)
            {
                break;
            }
        }
        
        if (i==tCount)
        {
            break;
        }
        
        [tString release];
    }
    while (_sIndex<65535);
    
    return [tString autorelease];
}

@end
