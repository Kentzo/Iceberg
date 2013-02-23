#import "MDIPaneController.h"
#import "PBProjectAssistantEngine.h"
#import "PBTableView.h"
#import "ImageAndTextCell.h"
#import "PBSharedConst.h"

@interface NSString(CompareLastPathComponent) 

- (NSComparisonResult) compareLastPathComponent:(NSString *) other;

@end

@implementation NSString(CompareLastPathComponent)

- (NSComparisonResult) compareLastPathComponent:(NSString *) other;
{
    return [[self lastPathComponent] caseInsensitiveCompare:[other lastPathComponent]];
}

@end

@implementation MDIPaneController

- (void) awakeFromNib
{
    NSTableColumn *tableColumn = nil;
    ImageAndTextCell *imageAndTextCell = nil;
    
     tableColumn = [IBarray_ tableColumnWithIdentifier: @"Name"];
    imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setEditable: YES];
    [tableColumn setDataCell:imageAndTextCell];
    
    [imageAndTextCell release];
    
    [IBarray_ setIntercellSpacing:NSMakeSize(3,1)];
}

- (void) dealloc
{
    [pathsArray_ release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction) add:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setAllowsMultipleSelection:YES];
    
    [tOpenPanel setPrompt:NSLocalizedStringFromTableInBundle(@"Add",@"Localizable",[NSBundle bundleForClass:[self class]],@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:nil
                                  file:nil
                                 types:[NSArray arrayWithObject:@"mdimporter"]
                        modalForWindow:[IBarray_ window]
                         modalDelegate:self
                        didEndSelector:@selector(addOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) addOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        NSArray * tArray;
        int i,tCount;
        
        tArray=[sheet filenames];
        
        if (tArray!=nil)
        {
            tCount=[tArray count];
            
            [IBarray_ deselectAll:nil];
            
            // Only add the new mdimporter(s)
            
            for(i=0;i<tCount;i++)
            {
                if ([pathsArray_ containsObject:[tArray objectAtIndex:i]]==NO)
                {
                    [pathsArray_ addObject:[tArray objectAtIndex:i]];
                }
            }
            
            // Sort by name
        
            [pathsArray_ sortUsingSelector:@selector(compareLastPathComponent:)];
            
            // Refresh TableView
            
            [IBarray_ reloadData];
            
            // Update the selection
            
            // A COMPLETER
        }
    }
}

- (IBAction) remove:(id) sender
{
    NSEnumerator * tEnumerator;
    NSArray * tArray;
    int i,tCount;
    
    tEnumerator=[IBarray_ selectedRowEnumerator];
    
    tArray=[tEnumerator allObjects];
    
    tCount=[tArray count];
    
    for(i=tCount-1;i>=0;i--)
    {
        [pathsArray_ removeObjectAtIndex:[[tArray objectAtIndex:i] intValue]];
    }
    
    [IBarray_ deselectAll:nil];
    
    [IBarray_ reloadData];
}

- (IBAction) deleteSelectedRowsOfTableView:(NSTableView *) tableView
{
    [self remove:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
    
    if (tAction==@selector(delete:))
    {
        if ([IBarray_ numberOfSelectedRows]==0)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (pathsArray_!=nil)
    {
        return [pathsArray_ count];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (pathsArray_!=nil)
    {
        if ([[aTableColumn identifier] isEqualToString: @"Name"])
        {
            return [[pathsArray_ objectAtIndex:rowIndex] lastPathComponent];
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{    
    if (pathsArray_!=nil)
    {
        if ([[tableColumn identifier] isEqualToString: @"Name"])
        {
            static NSImage * sImporterIcon;
            
            if (sImporterIcon==nil)
            {
                sImporterIcon=[[[NSWorkspace sharedWorkspace] iconForFile:[pathsArray_ objectAtIndex:row]] copy];
            
                [sImporterIcon setScalesWhenResized:YES];
            
                [sImporterIcon setSize:NSMakeSize(16,16)];
            }
       
            [(ImageAndTextCell*)cell setImage:sImporterIcon];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int tSelectedCount;
        
    tSelectedCount=[IBarray_ numberOfSelectedRows];
    
    [IBremoveButton_ setEnabled:tSelectedCount>=1];
    
    if (tSelectedCount==1)
    {
        [IBpath_ setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Path: %@",@"Localizable",[NSBundle bundleForClass:[self class]],@"No comment"),[pathsArray_ objectAtIndex:[IBarray_ selectedRow]]]];
    }
    else
    {
        [IBpath_ setStringValue:@""];
    }
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if (op==NSTableViewDropAbove)
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
    
    	if ([[tPasteBoard types] containsObject:NSFilenamesPboardType]!=nil)
        {
            // Check that these Importers are not already in the list
            
            NSArray * tArray;
            int i,tCount;
            
            tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
            
            if (tArray!=nil)
            {
                NSString * tDraggedPath;
                
                tCount=[tArray count];
                
                for(i=0;i<tCount;i++)
                {
                    tDraggedPath=[tArray objectAtIndex:i];
                    
                    if ([[tDraggedPath pathExtension] isEqualToString:@"mdimporter"]==NO)
                    {
                        break;
                    }
                    
                    if ([pathsArray_ containsObject:[tArray objectAtIndex:i]]==YES)
                    {
                        break;
                    }
                }
                
                if (i==tCount)
                {
                    return NSDragOperationCopy;
                }
            }
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    
    NSPasteboard * tPasteBoard;
        
    tPasteBoard=[info draggingPasteboard];
    
    if ([[tPasteBoard types] containsObject:NSFilenamesPboardType]!=nil)
    {
        NSArray * tArray;
        int i,tCount;
            
        tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];
            
        [IBarray_ deselectAll:nil];
        
        // Add the new Importers
        
        if (tArray!=nil)
        {
            tCount=[tArray count];
            
            for(i=0;i<tCount;i++)
            {
                [pathsArray_ addObject:[tArray objectAtIndex:i]];
            }
        }
        
        // Sort by name
        
        [pathsArray_ sortUsingSelector:@selector(compareLastPathComponent:)];
        
        [IBarray_ reloadData];
    }
    
    return YES;
}


#pragma mark -

- (void) initPaneWithEngine:(id) inEngine
{
    // Drag and Drop support (workaround for Cocoa design bug)
    
    [IBarray_ unregisterDraggedTypes];
    
    [IBarray_ registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    
    [IBpath_ setStringValue:@""];
    
    [pathsArray_ release];
    
    pathsArray_=[[NSMutableArray alloc] initWithCapacity:1];
    
    [IBremoveButton_ setEnabled:NO];
    
    [IBarray_ reloadData];
}

- (BOOL) checkPaneValuesWithEngine:(id) inEngine
{
    int tCount;
    
    tCount=[pathsArray_ count];
    
    if (tCount==1)
    {
        // Only one importer, we can use it to suggest the project name
    
        [inEngine setProjectName:[NSString stringWithFormat:@"%@ Importer",[[[pathsArray_ objectAtIndex:0] lastPathComponent] stringByDeletingPathExtension]]];
    }
        
    return YES;
}

- (void) processWithEngine:(id) inEngine
{
    NSMutableDictionary * tProjectDictionary;
    int i,tCount;
    
    tCount=[pathsArray_ count];
    
    if (tCount>0)
    {
        NSMutableDictionary * tDictionary;
        NSString * tPostflightScriptPath;
        NSUserDefaults * tDefaults;
    	int tDefaultReferenceStyle;
        
        tProjectDictionary=[inEngine projectDictionary];
        
        // Find the default Reference Style from the User Defaults
        
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        tDefaultReferenceStyle=[tDefaults integerForKey:@"Default Reference Style"];
    
        if (tDefaultReferenceStyle==0)
        {
            tDefaultReferenceStyle=kGlobalPath;
        }
        
        // Look for the Spotlight location in /Library
        
        tDictionary=[PBProjectDictionaryManager fileObjectAtPath:@"/Library/Spotlight" forPackageProject:tProjectDictionary];
        
        if (tDictionary!=nil)
        {
            NSMutableArray * tArray;
            
            // Add Spotlight Importers
                                
            tArray=[tDictionary objectForKey:@"Children"];
            
            for(i=0;i<tCount;i++)
            {
                NSDictionary * nDictionary;
                
                nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"Children",
                                                                        [NSNumber numberWithInt:80],@"GID",
                                                                        [pathsArray_ objectAtIndex:i],@"Path",
                                                                        [NSNumber numberWithInt:tDefaultReferenceStyle],@"Path Type",
                                                                        [NSNumber numberWithInt:509],@"Privileges",
                                                                        [NSNumber numberWithInt:3],@"Type",
                                                                        [NSNumber numberWithInt:0],@"UID",
                                                                        nil];
            
                [tArray addObject:nDictionary];
            }
        }
        
        // Update the postflight script
        
        tPostflightScriptPath=[[inEngine finalProjectPath] stringByAppendingPathComponent:@"ImporterPostflight.sh"];
        
        if (tPostflightScriptPath!=nil)
        {
            NSMutableString * tMutableString;
            
            tMutableString=[[NSMutableString alloc] initWithContentsOfFile:tPostflightScriptPath];
            
            if (tMutableString!=nil)
            {
                for(i=0;i<tCount;i++)
                {
                    NSString * tString;
                    
                    tString=[NSString stringWithFormat:@"/usr/bin/mdimport -r \"/Library/Spotlight/%@\"\n",[[pathsArray_ objectAtIndex:i] lastPathComponent]];
                    
                    [tMutableString appendString:tString];
                }
                
                [tMutableString appendString:@"\nexit 0"];
                
                [tMutableString writeToFile:tPostflightScriptPath atomically:YES];
            }
            else
            {
                NSLog(@"File \"ImporterPostflight.sh\" not found");
            }
        }
        
        if (tCount==1)
        {
            NSBundle * tBundle;
            NSString * tBundlePath;
                
            tBundlePath=[pathsArray_ objectAtIndex:0];
            
            tBundle=[NSBundle bundleWithPath:tBundlePath];
            
            if (tBundle!=nil)
            {
                NSMutableDictionary * tBranch;
                NSString * tShortVersionString;
                
                tShortVersionString=[tBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                
                // Description
                
                tBranch=[PBProjectDictionaryManager branchNamed:@"Settings:Description:International" forPackageProject:tProjectDictionary];
                
                if (tBranch!=nil)
                {
                    if (tShortVersionString!=nil)
                    {
                        [tBranch setObject:tShortVersionString forKey:IFPkgDescriptionVersion];
                    }
                }
                
                // Display Information
                
                tBranch=[PBProjectDictionaryManager branchNamed:@"Settings:Display Information" forPackageProject:tProjectDictionary];
                
                if (tBranch!=nil)
                {
                    NSString * tGetInfoString;
                
                    if (tShortVersionString!=nil)
                    {
                        [tBranch setObject:tShortVersionString forKey:@"CFBundleShortVersionString"];
                    }
                    
                    tGetInfoString=[tBundle objectForInfoDictionaryKey:@"CFBundleGetInfoString"];
                
                    if (tGetInfoString!=nil)
                    {
                        [tBranch setObject:tGetInfoString forKey:@"CFBundleGetInfoString"];
                    }
                }
                
                // Version
                
                tBranch=[PBProjectDictionaryManager branchNamed:@"Settings:Version" forPackageProject:tProjectDictionary];
                
                if (tBranch!=nil)
                {
                    float tVersionFloat;
                    
                    tVersionFloat=[tShortVersionString floatValue];
                    
                    if (tVersionFloat>0)
                    {
                        NSNumber * tNumber;
                        int tIntegerPart;
                        
                        tIntegerPart=tVersionFloat;
                        
                        tNumber=[NSNumber numberWithInt:tIntegerPart];
                        
                        if (tNumber!=nil)
                        {
                            [tBranch setObject:tNumber forKey:IFMajorVersion];
                        }
                        
                        tIntegerPart=(tVersionFloat-(tIntegerPart*1.0f));
                        
                        tNumber=[NSNumber numberWithInt:tIntegerPart];
                        
                        if (tNumber!=nil)
                        {
                            [tBranch setObject:tNumber forKey:IFMinorVersion];
                        }
                    }
                }
            }
            else
            {
                NSLog(@"%@ is not a bundle.",tBundlePath);
            }
        }
    }
}

@end
