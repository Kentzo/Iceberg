#import "PBImportReporterController.h"
#import "PBTableView.h"
#import "ImageAndTextCell.h"

@implementation PBImportReporterController

- (void) awakeFromNib
{
    ImageAndTextCell *imageAndTextCell = nil;
    NSTableColumn *tableColumn = nil;
    id tPrototypeCell;
    
    [IBarray_ setIntercellSpacing:NSMakeSize(3,0)];
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Component"];
    imageAndTextCell = [ImageAndTextCell new];
    [imageAndTextCell setEditable:YES];
    [imageAndTextCell setFont:[NSFont systemFontOfSize:11.0f]];
    [tableColumn setDataCell:imageAndTextCell];
    
    [imageAndTextCell release];
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Reason"];
    
    tPrototypeCell=[tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:11.0f]];
    [tableColumn setDataCell:tPrototypeCell];
    
    
    metaPackageNodeImage_=[[NSImage imageNamed:@"metapackage16"] retain];
    packageNodeImage_=[[NSImage imageNamed:@"package16"] retain];
    
}

- (void) beginReporterSheetForWindow:(NSWindow *) inWindow report:(NSArray *) inArray
{
    reportArray_=[inArray retain];
    
    [self performSelector:@selector(showSheetDelayedForWindow:) withObject:inWindow afterDelay:0.1f];
}

- (void) showSheetDelayedForWindow:(NSWindow *) inWindow
{
    [NSApp beginSheet:IBwindow_ modalForWindow:inWindow modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (IBAction)endDialog:(id)sender
{
    [NSApp endSheet:IBwindow_];
    
    [IBwindow_ orderOut:nil];
    
    [reportArray_ release];
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (reportArray_!=nil)
    {
        return [reportArray_ count];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if (reportArray_!=nil)
    {
        NSDictionary * tDictionary;
        
        tDictionary=[reportArray_ objectAtIndex:rowIndex];
        
        if ([[aTableColumn identifier] isEqualToString: @"Component"])
        {
            return [[tDictionary objectForKey:@"Path"] lastPathComponent];
        }
        else
        if ([[aTableColumn identifier] isEqualToString: @"Reason"])
        {
            int tReason;
            
            tReason=[[tDictionary objectForKey:@"Reason"] intValue];
            
            switch(tReason)
            {
                case 0:		// Error when copying component
                    return NSLocalizedString(@"Error during copy",@"No comment");
                case 1:		// Component not found on disk
                    return NSLocalizedString(@"Component not found",@"No comment");
                case 2:		// Error when importing component
                    return NSLocalizedString(@"Error during import",@"No comment");
            }
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int) rowIndex
{    
    if ([[tableColumn identifier] isEqualToString: @"Component"])
    {
        NSImage * tImage=nil;
        NSDictionary * tDictionary;
        NSString * tExtension;
        
        tDictionary=[reportArray_ objectAtIndex:rowIndex];
        
        tExtension=[[tDictionary objectForKey:@"Path"] pathExtension];
        
        if ([tExtension isEqualToString:@"pkg"]==YES)
        {
            tImage=packageNodeImage_;
        }
        else if ([tExtension isEqualToString:@"mpkg"]==YES)
        {
            tImage=metaPackageNodeImage_;
        }
        
        [(ImageAndTextCell*)cell setImage: tImage];
    }
}

@end
