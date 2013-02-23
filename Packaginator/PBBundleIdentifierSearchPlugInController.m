#import "PBBundleIdentifierSearchPlugInController.h"

@implementation PBBundleIdentifierSearchPlugInController

- (void) awakeFromNib
{
    /*id tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    
    tableColumn = [IBexcludedDirsArray_ tableColumnWithIdentifier: @"Path"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:11.0]];*/

    [IBexcludedDirsArray_ setIntercellSpacing:NSMakeSize(3,1)];
}

- (NSView *) previousKeyView
{
    return IBidentifier_;
}

- (void) setNextKeyView:(NSView *) inView
{
    [IBexcludedDirsArray_ setNextKeyView:inView];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary
{
    NSString * tStartingPoint;
    NSString * tIdentifier;
    NSNumber * tMaxDepth;
    NSString * tSuccessCase;
    
    tIdentifier=[inDictionary objectForKey:@"identifier"];
    
    if (tIdentifier==nil)
    {
        tIdentifier=@"";
    }
    
    [IBidentifier_ setStringValue:tIdentifier];
    
    tStartingPoint=[inDictionary objectForKey:@"startingPoint"];
    
    if (tStartingPoint==nil)
    {
        tStartingPoint=@"/";
    }
    
    [IBstartingPoint_ setStringValue:tStartingPoint];
    
    tMaxDepth=[inDictionary objectForKey:@"maxDepth"];
    
    if (tMaxDepth==nil)
    {
        tMaxDepth=[NSNumber numberWithInt:6];
    }
    
    [IBmaxDepthField_ setObjectValue:tMaxDepth];
    
    [IBmaxDepthStepper_ setObjectValue:tMaxDepth];
    
    [excludedArray_ release];
    
    excludedArray_=[[inDictionary objectForKey:@"excludedDirs"] mutableCopy];
    
    if (excludedArray_==nil)
    {
        excludedArray_=[[NSMutableArray alloc] initWithCapacity:3];
    }
    
    tSuccessCase=[inDictionary objectForKey:@"successCase"];
    
    if (tSuccessCase==nil)
    {
        tSuccessCase=@"findOne";
    }
    
    [IBsuccessCasePopupButton_ selectItemWithTitle:tSuccessCase];
    
    [IBexcludedDirsArray_ deselectAll:nil];
    
    [IBexcludedDirsArray_ reloadData];
    
    [IBremoveButton_ setEnabled:NO];
}

- (NSDictionary *) dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"BundleIdentifierSearch",@"searchPlugin",
                                                      [IBstartingPoint_ stringValue],@"startingPoint",
                                                      [IBidentifier_ stringValue],@"identifier",
                                                      [NSNumber numberWithInt:[IBmaxDepthStepper_ intValue]],@"maxDepth",
                                                      excludedArray_,@"excludedDirs",
                                                      [IBsuccessCasePopupButton_ titleOfSelectedItem],@"successCase",
                                                      nil];
}

- (BOOL) hasIncorrectValues
{
    NSString * tStartingPoint;
    NSString * tIdentifier;
    int i,tCount;
    
    tStartingPoint=[IBstartingPoint_ stringValue];
    
    if ([PBSearchPlugInController checkAbsolutePath:tStartingPoint]==NO)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The path value is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the path you entered and fix it.",@"No comment")];
                         
        return YES;
    }
    
    tIdentifier=[IBidentifier_ stringValue];
    
    if ([tIdentifier length]==0)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The identifier value is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the identifier you entered and fix it.",@"No comment")];
    
        return YES;
    }
    
    tCount=[excludedArray_ count];
    
    for(i=0;i<tCount;i++)
    {
        if ([PBSearchPlugInController checkAbsolutePath:[excludedArray_ objectAtIndex:i]]==NO)
        {
            [self showAlertWithTitle:NSLocalizedString(@"One of the path values for the excluded directories is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the paths you entered and fix them.",@"No comment")];
                         
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -

- (BOOL) validateMenuItem:(NSMenuItem *)aMenuItem
{
    return YES;
}

- (void) deleteSelectedRowsOfTableView:(NSTableView *) sender
{
    [self removeDirectory:nil];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [excludedArray_ count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [excludedArray_ objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    [excludedArray_ replaceObjectAtIndex:rowIndex withObject:object];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBexcludedDirsArray_)
    {
        int tSelectedCount;
        
        tSelectedCount=[IBexcludedDirsArray_ numberOfSelectedRows];
    
        [IBremoveButton_ setEnabled:tSelectedCount>=1];
    }
}

- (IBAction)addDirectory:(id)sender
{
    NSString * tExcludedDir;
    
    tExcludedDir=[NSString stringWithString:@"/"];
    
    [excludedArray_ addObject:tExcludedDir];
    
    [IBexcludedDirsArray_ selectRow:[excludedArray_ count]-1 byExtendingSelection:NO];
    
    [IBexcludedDirsArray_ editColumn:0
                                 row:[excludedArray_ count]-1
                           withEvent:nil
                              select:YES];
}

- (IBAction)removeDirectory:(id)sender
{
    NSString * tAlertTitle;
    
    if ([IBexcludedDirsArray_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove this directory from the list?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove these directories from the list?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      NSLocalizedString(@"Remove",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      [IBview_ window],
                      self,
                      @selector(removeDirectorySheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));
}

- (void) removeDirectorySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSEnumerator * tEnumerator;
        NSNumber * tNumber;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBexcludedDirsArray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        if ([IBexcludedDirsArray_ editedRow]!=-1)
        {
            [IBexcludedDirsArray_ abortEditing];
        }
        
        for(i=tCount-1;i>=0;i--)
        {
            int tIndex;
            
            tNumber = (NSNumber *) [tArray objectAtIndex:i];
            
            tIndex=[tNumber intValue];
            
            [excludedArray_ removeObjectAtIndex:tIndex];
        }
        
        [IBexcludedDirsArray_ deselectAll:nil];
        
        [IBexcludedDirsArray_ reloadData];
    }
}

@end
