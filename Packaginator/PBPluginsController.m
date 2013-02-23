/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBPluginsController.h"
#import "ImageAndTextCell.h"
#import "PBPopUpButtonCell.h"
#import "NSString+Iceberg.h"
#import "PBMagicCheckButtonCell.h"

#define PBPluginsPluginsPBoardType	@"PBPluginsPluginsPBoardType"

@implementation PBPluginsController

+ (PBPluginsController *) pluginsController
{
    PBPluginsController * nController=nil;
    
    nController=[PBPluginsController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"Plugins" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"Plugins"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

#pragma mark -

- (void) awakeFromNib
{
	PBMagicCheckButtonCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
	NSPopUpButtonCell * popupButtonCell = nil;
	NSCell * tTextFieldCell;
	id tMenuItem;
	
	fileManager_=[NSFileManager defaultManager];
	
	[IBarray_ setIntercellSpacing:NSMakeSize(3,1)];
	
	// Status
	
	tableColumn = [IBarray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[[PBMagicCheckButtonCell alloc] initTextCell: @""] autorelease];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
	
	// Name
	
	tableColumn = [IBarray_ tableColumnWithIdentifier: @"Name"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
	
	// Reference
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Reference"];
    
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
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Path"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
    
	[IBarray_ registerForDraggedTypes:[NSArray arrayWithObjects:PBPluginsPluginsPBoardType,NSFilenamesPboardType,nil]];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    NSDictionary * tDictionary;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
	
	tDictionary=[objectNode_ plugins];
	
	// Plugins List
	
	[pluginsList_ release];
	
	pluginsList_=[[tDictionary objectForKey:PLUGINS_LIST_KEY] mutableCopy];
	
	[IBarray_ deselectAll:nil];
	
	[IBaddButton_ setEnabled:YES];
    
    [IBdeleteButton_ setEnabled:NO];
	
	[IBarray_ reloadData];
}

- (void) treeWillChange
{
    [super treeWillChange];
    
    [self updatePlugins:nil];
}

- (IBAction) updatePlugins:(id) sender
{
	NSMutableDictionary * tPluginsDictionary;
	
	tPluginsDictionary=[objectNode_ plugins];
	
	[tPluginsDictionary setObject:pluginsList_
						   forKey:PLUGINS_LIST_KEY];
						   	
	if (sender==IBarray_)
    {
        [self postNotificationChange];
    }
    
    if (sender!=nil)
    {
        [self setDocumentNeedsUpdate:YES];
    }
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (pluginsList_!=nil)
	{
		return [pluginsList_ count];
	}
	
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if (pluginsList_!=nil)
	{
		NSDictionary * tDictionary;
		NSNumber * tNumber;
		
		tDictionary=[pluginsList_ objectAtIndex:rowIndex];
		
		tNumber=[tDictionary objectForKey:@"Type"];
		
		if ([[aTableColumn identifier] isEqualToString: @"Status"])
		{
			if ([tNumber intValue]!=kPluginDefaultStep)
			{
				return [tDictionary objectForKey:@"Status"];
			}
		}
		else if ([[aTableColumn identifier] isEqualToString: @"Name"])
		{
			if ([tNumber intValue]==kPluginDefaultStep)
			{
				NSString * tLocalizedName;
				
				// Display in Bold
				
				tLocalizedName=NSLocalizedString([tDictionary objectForKey:@"Path"],@"No comments");
				
				if (tLocalizedName!=nil)
				{
					static NSDictionary * tBoldAttributes=nil;
					
					if (tBoldAttributes==nil)
					{
						tBoldAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:11.0f],NSFontAttributeName,nil];
					}
					
					return [[[NSAttributedString alloc] initWithString:tLocalizedName attributes:tBoldAttributes] autorelease];
				}
			}
			else
			{
				NSString * tPath;
            
            	tPath=[tDictionary objectForKey:@"Path"];
            
                if ([tPath length]>0)
                {
                    NSNumber * tNumber;
                    NSString * tAbsolutePath;
                    NSBundle * tBundle;
					
					
                    tNumber=[tDictionary objectForKey:@"Path Type"];
                    
                    tAbsolutePath=tPath;
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tAbsolutePath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                        }
                    }
					
					tBundle=[NSBundle bundleWithPath:tAbsolutePath];
					
					if (tBundle!=nil)
					{
						return [tBundle objectForInfoDictionaryKey:@"InstallerSectionTitle"];
					}
				}
			}
		}
		else if ([[aTableColumn identifier] isEqualToString: @"Path"])
		{
			if ([tNumber intValue]!=kPluginDefaultStep)
			{
				NSString * tPath;
            
            	tPath=[tDictionary objectForKey:@"Path"];
            
                if ([tPath length]>0)
                {
                    NSNumber * tNumber;
                    NSString * tAbsolutePath;
                    
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
                        return [[[NSAttributedString alloc] initWithString:tPath attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSForegroundColorAttributeName,nil]] autorelease];
                    }
                }
                
                return tPath;
            }
		}
	}
    
    return nil;
}

/*- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	if (pluginsList_!=nil)
	{
		NSDictionary * tDictionary;
		NSNumber * tNumber;
		
		tDictionary=[pluginsList_ objectAtIndex:rowIndex];
		
		tNumber=[tDictionary objectForKey:@"Type"];
		
		if ([tNumber intValue]!=kPluginDefaultStep)
		{
			return  YES;
		}
	}

	return NO;
}*/

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if (pluginsList_!=nil)
	{
		NSNumber * tNumber;
		NSDictionary * tDictionary;
			
		if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
			tDictionary=[pluginsList_ objectAtIndex:row];
            
            tNumber=[tDictionary objectForKey:@"Type"];
			
			if ([tNumber intValue]==kPluginDefaultStep)
			{
				[cell setEnabled:NO];
				[cell setTag:1];
			}
			else
			{
				[cell setEnabled:YES];
				[cell setTag:0];
			}
		}
		else
		if ([[tableColumn identifier] isEqualToString: @"Reference"])
        {
			tDictionary=[pluginsList_ objectAtIndex:row];
            
            tNumber=[tDictionary objectForKey:@"Type"];
			
			if ([tNumber intValue]==kPluginDefaultStep)
			{
				[cell setEnabled:NO];
				[cell setArrowPosition:NSPopUpNoArrow];
			}
			else
			{
				[cell setEnabled:YES];
				[cell setArrowPosition:NSPopUpArrowAtCenter];
				
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
		}
	}
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSDictionary * tDictionary;
	NSNumber * tNumber;
	
	tDictionary=[pluginsList_ objectAtIndex:row];
	
	tNumber=[tDictionary objectForKey:@"Type"];
			
	if (tNumber!=nil && [tNumber intValue]!=kPluginDefaultStep)
	{
		if ([[tableColumn identifier] isEqualToString: @"Status"])
		{
			[[pluginsList_ objectAtIndex:row] setObject:object
											   forKey:@"Status"];
			
			[self updatePlugins:IBarray_];
		}
		else if ([[tableColumn identifier] isEqualToString: @"Reference"])
		{
			int tTag,oldTag=kGlobalPath;
			NSNumber * tNumber;
			NSString * tPath;
			
			tTag=[[[tableColumn dataCellForRow:row] itemAtIndex:[object intValue]] tag];
			
			tNumber=[[pluginsList_ objectAtIndex:row] objectForKey:@"Path Type"];
			
			if (tNumber!=nil)
			{
				oldTag=[tNumber intValue];
			}
			
			if (oldTag!=tTag)
			{
				[[pluginsList_ objectAtIndex:row] setObject:[NSNumber numberWithInt:tTag] forKey:@"Path Type"];
			}
			
			tPath=[[pluginsList_ objectAtIndex:row] objectForKey:@"Path"];
			
			if (tTag==kGlobalPath)
			{
				tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
			}
			else
			{
				tPath=[tPath stringByRelativizingToPath:[document_ folder]];
			}
			
			[[pluginsList_ objectAtIndex:row] setObject:tPath forKey:@"Path"];
			
			textHasBeenUpdated_=YES;
			
			[self updatePlugins:IBarray_];
			
			[IBarray_ reloadData];
		}
	}
}

#pragma mark -

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int tCount;
	
	tCount=[IBarray_ numberOfSelectedRows];
        
	if (tCount>0)
	{
		NSEnumerator * tEnumerator;
		NSNumber * tNumber;
		
		tEnumerator=[IBarray_ selectedRowEnumerator];
        
        while (tNumber=[tEnumerator nextObject])
		{
			NSDictionary * tDictionary;
			
			tDictionary=[pluginsList_ objectAtIndex:[tNumber intValue]];
		
			tNumber=[tDictionary objectForKey:@"Type"];
			
			if (tNumber==nil || [tNumber intValue]==kPluginDefaultStep)
			{
				[IBdeleteButton_ setEnabled:NO];
				
				return;
			}
		}
		
		[IBdeleteButton_ setEnabled:YES];
	}
	else
	{
		[IBdeleteButton_ setEnabled:NO];
	}
}

#pragma mark -

- (BOOL)tableView:(NSTableView *) tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    int i,tCount;
	NSMutableArray * tDragArray;
	
	[pboard declareTypes:[NSArray arrayWithObject: PBPluginsPluginsPBoardType] owner:self];

	tCount=[rows count];
	
	tDragArray=[NSMutableArray arrayWithCapacity:tCount];
	
	for(i=0;i<tCount;i++)
	{
		NSDictionary * tDictionary;
		NSNumber * tNumber;
		
		tDictionary=[pluginsList_ objectAtIndex:[[rows objectAtIndex:i] intValue]];
		
		tNumber=[tDictionary objectForKey:@"Type"];
		
		if (tNumber==nil || [tNumber intValue]==kPluginDefaultStep)
		{
			return NO;
		}
		
		[tDragArray addObject:tDictionary];
	}
	
	[pboard setPropertyList:tDragArray forType:PBPluginsPluginsPBoardType];

	internalPluginsDragData_=rows;
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*) tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    int i,tCount;
    NSArray * tArray;
                    
    if (op==NSTableViewDropAbove && row<[pluginsList_ count])
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
        
        if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBPluginsPluginsPBoardType]]!=nil)
		{
			if ([info draggingSource]==IBarray_)
			{
				// Internal Drag
				
				if ([internalPluginsDragData_ count]==1)
				{
					int tOriginalRow=[[internalPluginsDragData_ objectAtIndex:0] intValue];
				
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
			
				if ([pluginsList_ count]==0)	// Very improbable case
				{
					[tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
				}
				
				return NSDragOperationCopy;
			}
		}
        else
		if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
		{
			// Check that the file is not already included
			
			int j,tCurrentCount;
			
			tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
			
			if ([PBPluginsController validateFiles:tArray]==YES)
			{
				tCount=[tArray count];
				
				// Check that no bundle is already in the current list
				
				tCurrentCount=[pluginsList_ count];
				
				for(j=0;j<tCurrentCount;j++)
				{
					NSString * tCurrentPath;
					
					tCurrentPath=[[pluginsList_ objectAtIndex:j] objectForKey:@"Path"];
					
					for(i=0;i<tCount;i++)
					{
						if ([tCurrentPath isEqualToString:[tArray objectAtIndex:i]]==YES)
						{
							return NSDragOperationNone;
						}
					}
				}
				
				return NSDragOperationCopy;
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
    
    if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:PBPluginsPluginsPBoardType]]!=nil)
	{
		NSArray * tArray;
		
		tArray=(NSArray *) [tPasteBoard propertyListForType:PBPluginsPluginsPBoardType];
		
		tCount=[tArray count];
		
		if ([info draggingSource]==IBarray_)
		{
			// Internal Drag
			
			NSDictionary * tDictionary;
			int tRowIndex;
			NSMutableArray * tTemporaryArray;
			int tOriginalRow=row;
			
			tCount=[internalPluginsDragData_ count];
			
			[IBarray_ deselectAll:nil];
			
			tTemporaryArray=[NSMutableArray array];
			
			for(i=tCount-1;i>=0;i--)
			{
				tRowIndex=[[internalPluginsDragData_ objectAtIndex:i] intValue];
				
				tDictionary=(NSDictionary *) [pluginsList_ objectAtIndex:tRowIndex];
				
				[tTemporaryArray insertObject:tDictionary atIndex:0];
				
				[pluginsList_ removeObjectAtIndex:tRowIndex];
				
				if (tRowIndex<tOriginalRow)
				{
					row--;
				}
			}
			
			for(i=tCount-1;i>=0;i--)
			{
				tDictionary=(NSDictionary *) [tTemporaryArray objectAtIndex:i];
				
				[pluginsList_ insertObject:tDictionary atIndex:row];
			}
		}
		else
		{
			int tIndexRow=row;
	
			[IBarray_ deselectAll:nil];
			
			// External Drag
		
			for(i=0;i<tCount;i++)
			{
				NSDictionary * tDictionary;
				
				tDictionary=[tArray objectAtIndex:i];
				
				[pluginsList_ insertObject:tDictionary atIndex:tIndexRow++];
			}
		}
			
		[IBarray_ reloadData];
		
		for(i=0;i<tCount;i++)
		{
			[IBarray_ selectRow:row++ byExtendingSelection:YES];
		}
		
		[self updatePlugins:IBarray_];
	}
	else
	if ([tPasteBoard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]!=nil)
	{
		NSMutableArray * tNewSelectionArray;
        int i,tCount;
        
        [IBarray_ deselectAll:nil];
        
		tNewSelectionArray=[self addPluginsWithArray:(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType]
											   atRow:row];
        
        [IBarray_ reloadData];
        
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue] byExtendingSelection:YES];
        }
		
		[self updatePlugins:IBarray_];
	}
	
	return YES;
}

#pragma mark -

+ (BOOL) validateFiles:(NSArray *) inFiles
{
    int i,tCount;
    NSFileManager * tFileManager;
    
    tCount=[inFiles count];
    
    tFileManager=[NSFileManager defaultManager];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tPath=[inFiles objectAtIndex:i];
        
        BOOL isDirectory;
            
		if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==YES && isDirectory==YES)
		{
			NSString * tInfoPath;
			
			tInfoPath=[tPath stringByAppendingPathComponent:@"Contents/Info.plist"];
			
			if ([tFileManager fileExistsAtPath:tInfoPath isDirectory:&isDirectory]==YES && isDirectory==NO)
			{
				// Check that we're not trying to import a receipts
				
				NSString * tArchivePath;
				
				tArchivePath=[tPath stringByAppendingPathComponent:@"Contents/MacOS"];
				
				if ([tFileManager fileExistsAtPath:tArchivePath isDirectory:&isDirectory]==NO || isDirectory==NO)
				{
					break;
				}
			}
		}
        else
        {
            break;
        }
    }
    
    if (i==tCount)
    {
        return YES;
    }
    
    return NO;
}

- (NSMutableArray *) addPluginsWithArray:(NSArray *) inArray atRow:(int) inRow
{
	NSMutableArray * tNewSelectionArray;
    int i,tCount;
    NSFileManager * tFileManager;
	
	tCount=[inArray count];
    
    tFileManager=[NSFileManager defaultManager];
	
	tNewSelectionArray=[NSMutableArray array];
	
	for(i=0;i<tCount;i++)
    {
        NSString * tPath;
		NSMutableDictionary * nPluginDictionary;
		
        tPath=[inArray objectAtIndex:i];
		
		nPluginDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Status",
																			[NSNumber numberWithInt:kPluginCustomizedStep],@"Type",
																			tPath,@"Path",
																			[NSNumber numberWithInt:kGlobalPath],@"Path Type",
																			nil];
		if (nPluginDictionary!=nil)
		{

			[tNewSelectionArray addObject:[NSNumber numberWithInt:inRow]];
			
			[pluginsList_ insertObject:nPluginDictionary atIndex:inRow++];
		}
	}
	
	return tNewSelectionArray;
}

- (IBAction) addPlugin:(id) sender
{
	NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setAllowsMultipleSelection:YES];
    [tOpenPanel setDelegate:self];
    
    [tOpenPanel setPrompt:NSLocalizedString(@"Add",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:nil
                                  file:nil
                                 types:nil
                        modalForWindow:[IBarray_ window]
                         modalDelegate:self
                        didEndSelector:@selector(addPluginsPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	NSFileManager * tFileManager;
    BOOL isDirectory;
	
    tFileManager=[NSFileManager defaultManager];
    
    if ([tFileManager fileExistsAtPath:filename isDirectory:&isDirectory]==YES && isDirectory==YES)
    {
        NSString * tPathExtension;
        
        tPathExtension=[filename pathExtension];
        
        if ([tPathExtension isEqualToString:@"bundle"]==YES)
        {
            if([PBPluginsController validateFiles:[NSArray arrayWithObject:filename]]==YES)
			{
				int i,tCount;
				
				// Check that no bundle is already in the current list
				
				tCount=[pluginsList_ count];
				
				for(i=0;i<tCount;i++)
				{
					NSString * tCurrentPath;
					
					tCurrentPath=[[pluginsList_ objectAtIndex:i] objectForKey:@"Path"];
					
					if ([tCurrentPath isEqualToString:filename]==YES)
					{
						return NO;
					}
				}
			}
        }
        
        return YES;
    }
    
    return NO;
}

- (void) addPluginsPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        NSMutableArray * tNewSelectionArray;
        int i,tCount;
        int selectedRow;
        
        selectedRow=[IBarray_ selectedRow];
        
        if (selectedRow==-1)
        {
            selectedRow=[pluginsList_ count]-1;		// No item can be after FinishUp
        }
        else
        {
            NSArray * tArray;
            
            tArray=[[IBarray_ selectedRowEnumerator] allObjects];
            
            tCount=[tArray count];
            
            selectedRow=[[tArray objectAtIndex:(tCount-1)] intValue]+1;
        }
        
		if (selectedRow>=[pluginsList_ count])
		{
			selectedRow=[pluginsList_ count]-1;
		}
		
        [IBarray_ deselectAll:nil];
        
		tNewSelectionArray=[self addPluginsWithArray:[sheet filenames]
											   atRow:selectedRow];
        
        [IBarray_ reloadData];
        
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue] byExtendingSelection:YES];
        }
        
        [self postNotificationChange];
    }
}

- (IBAction) deleteSelectedRowsOfTableView:(NSTableView *) tableView
{
	[self removePlugin:nil];
}

- (IBAction) removePlugin:(id) sender
{
    NSString * tAlertTitle;
    
    if ([IBarray_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove this Plugin?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove these Plugins?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      NSLocalizedString(@"Remove",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      [IBview_ window],
                      self,
                      @selector(removePluginsSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));

}

- (void) removePluginsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
		NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBarray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            [pluginsList_ removeObjectAtIndex:[tNumber intValue]];
        }
        
        [IBarray_ deselectAll:nil];
        
        [IBarray_ reloadData];
        
        [self updatePlugins:IBarray_];
	}
}

- (IBAction) revealInFinder:(id) sender
{
	NSEnumerator * tEnumerator;
    NSNumber * tNumber;
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    tEnumerator=[IBarray_ selectedRowEnumerator];
    
    while (tNumber = (NSNumber *) [tEnumerator nextObject])
    {
        NSNumber * tTypeNumber;
		NSDictionary * tDictionary;
		
		
		tDictionary=[pluginsList_ objectAtIndex:[tNumber intValue]];
        
        tTypeNumber=[tDictionary objectForKey:@"Type"];
			
		if (tTypeNumber!=nil && [tTypeNumber intValue]!=kPluginDefaultStep)
		{
			NSString * tPath;
			
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
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
	
	if (tAction==@selector(removePlugin:) ||
		tAction==@selector(revealInFinder:))
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
    
    	tEnumerator=[IBarray_ selectedRowEnumerator];
    
        while (tNumber = (NSNumber *) [tEnumerator nextObject])
        {
            int tIndex=[tNumber intValue];
            NSDictionary * tDictionary;
			NSNumber * tTypeNumber;
			
			tDictionary=[pluginsList_ objectAtIndex:tIndex];
			
			tTypeNumber=[tDictionary objectForKey:@"Type"];
			
			if (tTypeNumber==nil || [tTypeNumber intValue]==kPluginDefaultStep)
			{
				return NO;
			}
        }
    }
	
	return YES;
}

@end
