/*
Copyright (c) 2004-2006, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBMetaPackageComponentsController.h"
#import "ImageAndTextCell.h"
#import "PBPopUpButtonCell.h"
#import "PBTableView.h"

#import "PBCheetahPackageMakerDecoder+Iceberg.h"
#import "PBJaguarPackageMakerDecoder+Iceberg.h"
#import "PBTigerPackageMakerDecoder+Iceberg.h"

#import "PBProjectTree+Import.h"

#import "PBImportReporterController.h"
#import "PBPreferencePaneImportController+Constants.h"

#define PBComponentPBoardType	@"PBComponentPBoardType"

@interface NSDictionary(ComponentName) 

- (NSComparisonResult) compareMPComponentName:(NSDictionary *) other;
- (NSComparisonResult) compareMPComponentAttribute:(NSDictionary *) other;

@end

@implementation NSDictionary(ComponentName)

- (NSComparisonResult) compareMPComponentName:(NSDictionary *) other
{
    return [((NSString *)[self objectForKey:@"Name"]) compare:[other objectForKey:@"Name"]];
}

- (NSComparisonResult) compareMPComponentAttribute:(NSDictionary *) other
{
    int tSelfValue,inValue;
    
    tSelfValue=[[self objectForKey:@"Attribute"] intValue];
    
    inValue=[[other objectForKey:@"Attribute"] intValue];
    
    if (tSelfValue>inValue)
    {
        return NSOrderedAscending;
    }
    else
    if (tSelfValue<inValue)
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

@end

@implementation PBMetaPackageComponentsController

+ (PBMetaPackageComponentsController *) metaPackageComponentsController
{
    PBMetaPackageComponentsController * nController=nil;
    
    nController=[PBMetaPackageComponentsController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"MPComponents" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"MPComponents"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (void) awakeFromNib
{
    NSButtonCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    ImageAndTextCell *imageAndTextCell = nil;
    PBPopUpButtonCell * popupButtonCell = nil;
    
    [IBarray_ showMenuForEmptySelection:YES];
    
    [IBarray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    // Status
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[NSButtonCell alloc] initTextCell: @""];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
    
    [tPrototypeCell release];
    
    // Packages
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Packages"];
    imageAndTextCell = [ImageAndTextCell new];
    [imageAndTextCell setEditable:YES];
    [imageAndTextCell setFont:[NSFont systemFontOfSize:12.0/*[NSFont smallSystemFontSize]*/]];
    [tableColumn setDataCell:imageAndTextCell];
    
    [imageAndTextCell release];
    
    // Attribute
    
    tableColumn = [IBarray_ tableColumnWithIdentifier: @"Attribute"];
    
    popupButtonCell=[[PBPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
    
    [popupButtonCell setControlSize:NSSmallControlSize];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Unselected",@"No comment")];
    
    [[popupButtonCell itemAtIndex:0] setImage:[NSImage imageNamed:@"unselected13.tif"]];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Selected",@"No comment")];
    
    [[popupButtonCell itemAtIndex:1] setImage:[NSImage imageNamed:@"selected13.tif"]];
    
    [popupButtonCell addItemWithTitle:NSLocalizedString(@"Required",@"No comment")];
    
    [[popupButtonCell itemAtIndex:2] setImage:[NSImage imageNamed:@"required13.tif"]];
    
    [popupButtonCell setBordered:NO];
    
    [popupButtonCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    [popupButtonCell setDrawsLabel:YES];
    
    [tableColumn setDataCell:popupButtonCell];
    
    [popupButtonCell release];
    
    metaPackageNodeImage_=[[NSImage imageNamed:@"metapackage16"] retain];
    packageNodeImage_=[[NSImage imageNamed:@"package16"] retain];
    
    [IBarray_ registerForDraggedTypes:[NSArray arrayWithObjects:PBComponentPBoardType,
                                                                NSFilenamesPboardType,
                                                                nil]];

    // Dialog sheet
    
    [[IBattributePopupButton_ itemAtIndex:0] setImage:[NSImage imageNamed:@"unselected.tif"]];
    
    [[IBattributePopupButton_ itemAtIndex:1] setImage:[NSImage imageNamed:@"selected.tif"]];
    
    [[IBattributePopupButton_ itemAtIndex:2] setImage:[NSImage imageNamed:@"required.tif"]];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
    
    [IBarray_ deselectAll:self];
    
    [self setProjectTree:inProjectTree];
    
    [IBrelativeTextField_ setStringValue:[((PBMetaPackageNode *) NODE_DATA(projectTree_)) componentsDirectory]];
    
    [self setRelativePopUpButtonWithPath:[((PBMetaPackageNode *) NODE_DATA(projectTree_)) componentsDirectory]];
    
    //[IBremoveButton_ setEnabled:NO];
    
    [IBarray_ reloadData];
}

- (void) treeWillChange
{
    [self updateComponents:nil];
    
    [super treeWillChange];
}

- (void) updateComponents:(id) sender
{
    [((PBMetaPackageNode *) NODE_DATA(projectTree_)) setComponentsDirectory:[IBrelativeTextField_ stringValue]];
    
    // A COMPLETER (test du path pour voir si c'est un vrai path)
    
    if (sender!=nil)
    {
        if (sender==IBrelativeTextField_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

- (void) setProjectTree:(PBProjectTree *) inMetaPackageTree
{
    [super setProjectTree:inMetaPackageTree];

    [componentsTree_ release];

    componentsTree_=(PBProjectTree *) [[inMetaPackageTree childAtIndex:PBPROJECTTREE_COMPONENTS_INDEX] retain];
}

- (void) setWindow:(NSWindow *) aWindow
{
    window_=aWindow;
}

- (IBAction)newComponent:(id)sender
{
    [IBnameTextField_ setStringValue:[PBProjectTree uniqueNameWithComponentTree:componentsTree_]];
    
    [IBtypePopupButton_ selectItemAtIndex:0];
    [IBattributePopupButton_ selectItemAtIndex:1];
    
    [IBokButton_ setEnabled:YES];
    
    [NSApp beginSheet:[IBokButton_ window]
       modalForWindow:window_
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:NULL];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [super controlTextDidChange:aNotification];
    
    if ([aNotification object]==IBnameTextField_)
    {
        if ([[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string] length]==0)
        {
            if ([IBokButton_ isEnabled]==YES)
            {
                [IBokButton_ setEnabled:NO];
            }
        }
        else
        {
            if ([IBokButton_ isEnabled]==NO)
            {
                [IBokButton_ setEnabled:YES];
            }
        }
    }
    else if ([aNotification object]==IBrelativeTextField_)
    {
        NSString * tString;
        
        tString=[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string];
        
        [self setRelativePopUpButtonWithPath:tString];
    }
}

- (void) setRelativePopUpButtonWithPath:(NSString *) inPath
{
    int tTag=-1;
    
    // A AMELIORER PAS MAL
    
    if ([inPath isEqualToString:@".."]==YES)
    {
        // Same Level
        
        tTag=1;
    }
    else if ([inPath isEqualToString:@"Contents/Resources/"]==YES ||
            [inPath isEqualToString:@"./Contents/Resources"]==YES)
    {
        // Inside Meta-Package
        
        tTag=0;
    }
    
    [IBrelativePopupButton_ selectItemAtIndex:[IBrelativePopupButton_ indexOfItemWithTag:tTag]];
}

- (void) endDialog:(id) sender
{
    if ([sender tag]==NSOKButton)
    {
        NSString * tComponentName;
        int tIndex;
        PBProjectTree * nComponentNode;
        NSDictionary * tDictionary;
        int tType;
            
        tComponentName=[IBnameTextField_ stringValue];
    
        tType=[[IBtypePopupButton_ selectedItem] tag];
            
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tComponentName,@"Name",
                                                            [NSNumber numberWithInt:1],@"Status",
                                                            [NSNumber numberWithInt:tType],@"Type",
                                                            [NSNumber numberWithInt:[IBattributePopupButton_ indexOfSelectedItem]-1],IFPkgFlagPackageSelection,
                                                            nil];
        
        nComponentNode=[PBProjectTree projectTreeWithDictionary:tDictionary];
                        
        tIndex=[componentsTree_ numberOfChildren];
        
        [componentsTree_ insertChild:nComponentNode
                                atIndex:tIndex];
                                    
        [self postNotificationChange];
                                                            
        [IBarray_ reloadData];
        
        [IBarray_ selectRow:tIndex byExtendingSelection:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentExpandSelectedRow" object:document_];
    }
    
    [NSApp endSheet:[IBokButton_ window]];
    [[IBokButton_ window] orderOut:self];
}

- (IBAction) deleteSelectedRowsOfTableView:(NSTableView *) tableView
{
    [self delete:nil];
}

- (IBAction) delete:(id)sender
{
    NSString * tAlertTitle;
    
    if ([IBarray_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to delete this component?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to delete theses components?",@"No comment");
    }
    
    NSBeginAlertSheet(tAlertTitle,
                      NSLocalizedString(@"Delete",@"No comment"),
                      NSLocalizedString(@"Cancel",@"No comment"),
                      nil,
                      window_,	//[IBview_ window],
                      self,
                      @selector(removeSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      NULL,
                      NSLocalizedString(@"This cannot be undone.",@"No comment"));

}

- (void) removeSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSEnumerator * tEnumerator;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBarray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            PBProjectTree * tNode;
            
            tNode=(PBProjectTree *) [componentsTree_ childAtIndex:[[tArray objectAtIndex:i] intValue]];
            
            [tNode removeFromParent];
        }
        
        [IBarray_ deselectAll:nil];
        
        [IBarray_ reloadData];
        
        [self postNotificationChange];
    }
}

- (IBAction)importPackages:(id)sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setAllowsMultipleSelection:YES];
    [tOpenPanel setDelegate:self];
    
    [tOpenPanel setPrompt:NSLocalizedString(@"Import",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:nil
                                  file:nil
                                 types:nil
                        modalForWindow:window_ //[IBarray_ window]
                         modalDelegate:self
                        didEndSelector:@selector(importPackagesPanelDidEnd:returnCode:contextInfo:)
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
        
        if ([tPathExtension isEqualToString:@"pkg"]==YES)
        {
            return [PBMetaPackageComponentsController validateFiles:[NSArray arrayWithObject:filename]];
        }
		else if ([tPathExtension isEqualToString:@"mpkg"]==YES)
        {
            NSString * tDistributionScriptPath;
			
			// We can't import Dsitribution Script (03/14/09)
			
			tDistributionScriptPath=[filename stringByAppendingPathComponent:@"Contents/distribution.dist"];
			
            if ([tFileManager fileExistsAtPath:tDistributionScriptPath isDirectory:&isDirectory]==YES)
            {
                 return NO;
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (void) importPackagesPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        NSMutableArray * tNewSelectionArray;
        int i,tCount;
        int selectedRow;
        
        selectedRow=[IBarray_ selectedRow];
        
        if (selectedRow==-1)
        {
            selectedRow=[componentsTree_ numberOfChildren];
        }
        else
        {
            NSArray * tArray;
            
            tArray=[[IBarray_ selectedRowEnumerator] allObjects];
            
            tCount=[tArray count];
            
            selectedRow=[[tArray objectAtIndex:(tCount-1)] intValue];
        }
        
        [IBarray_ deselectAll:nil];
        
        tNewSelectionArray=[self importPackagesWithArray:[sheet filenames]
                                                   atRow:selectedRow
                                        forComponentTree:componentsTree_
                                             andDocument:document_];
        
        [IBarray_ reloadData];
        
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue] byExtendingSelection:YES];
        }
        
        [self postNotificationChange];
    }
}

- (NSString *) finalPathForImportedComponentAtPath:(NSString *) inPath
{
    NSString * tFinalPath=nil;
    
    if (copyPackage_==YES)
    {
        NSString * tExtension;
        
        tExtension=[inPath pathExtension];
    
        if ([tExtension isEqualToString:@"pkg"]==YES ||
            [tExtension isEqualToString:@"mpkg"]==YES)
        {
            NSFileManager * tFileManager;
            NSEnumerator * tEnumerator;
            NSDictionary * tDictionary;
            
            // Check that we really need to copy the package
            
            tEnumerator=[copiedPaths_ objectEnumerator];
            
            while (tDictionary=[tEnumerator nextObject])
            {
                NSString * tOldPath;
                
                tOldPath=[tDictionary objectForKey:@"Old Path"];
                
                if (tOldPath!=nil)
                {
                    if ([inPath hasPrefix:tOldPath]==YES)
                    {
                        NSString * tFinalPart;
                        
                        tFinalPart=[inPath substringFromIndex:[tOldPath length]];
                        
                        tFinalPath=[[tDictionary objectForKey:@"New Path"] stringByAppendingString:tFinalPart];
                        
                        return tFinalPath;
                    }
                }
            }
            
            tFileManager=[NSFileManager defaultManager];
            
            tFinalPath=[projectImportPath_ stringByAppendingPathComponent:[inPath lastPathComponent]];
        
            if ([tFileManager fileExistsAtPath:tFinalPath]==YES)
            {
                if (replaceAll_==YES)
                {
                    if ([tFileManager removeFileAtPath:tFinalPath handler:nil]==NO)
                    {
                        NSBeep();
                        
                        NSBeginAlertSheet(NSLocalizedString(@"Import stopped",@"No comment"),
                                        nil,
                                        nil,
                                        nil,
                                        window_,
                                        nil,
                                        nil,
                                        nil,
                                        NULL,
                                        [NSString stringWithFormat:NSLocalizedString(@"Cant remove previous package",@"No comment"),[inPath lastPathComponent]]);
                
                        
                        return nil;
                    }
                }
                else
                {
                    int tReturnCode;
                    
                    tReturnCode=NSRunAlertPanel(NSLocalizedString(@"Import Packages",@"No comment"),
                                    [NSString stringWithFormat:NSLocalizedString(@"An older package named \"%@\" already exists in the \"Imported Packages\" location. Do you want to replace it with the newer one you're importing?",@"No comment"),[inPath lastPathComponent]],
                                    NSLocalizedString(@"Replace",@"No comment"),
                                    NSLocalizedString(@"Replace All",@"No comment"),
                                    NSLocalizedString(@"Cancel",@"No comment"));
                    
                    switch(tReturnCode)
                    {
                        case NSAlertAlternateReturn:	// Replace All
                            replaceAll_=YES;
                        case NSAlertDefaultReturn:	// Replace
                            if ([tFileManager removeFileAtPath:tFinalPath handler:nil]==NO)
                            {
                                NSBeep();
                                
                                NSBeginAlertSheet(NSLocalizedString(@"Import stopped",@"No comment"),
                                                nil,
                                                nil,
                                                nil,
                                                window_,
                                                nil,
                                                nil,
                                                nil,
                                                NULL,
                                                [NSString stringWithFormat:NSLocalizedString(@"Cant remove previous package",@"No comment"),[inPath lastPathComponent]]);
                        
                                return nil;
                            }
                            break;
                        
                        case NSAlertOtherReturn:	// Cancel
                            return nil;
                    }
                }
            }
            
            // Copy the Package into an import folder
            
            if ([tFileManager copyPath:inPath toPath:tFinalPath handler:nil]==NO)
            {
                NSBeep();
                
                NSBeginAlertSheet(NSLocalizedString(@"Import stopped",@"No comment"),
                                nil,
                                nil,
                                nil,
                                window_,
                                nil,
                                nil,
                                nil,
                                NULL,
                                [NSString stringWithFormat:NSLocalizedString(@"Cant copy package",@"No comment"),[inPath lastPathComponent]]);
                
                return nil;
            }
            else
            {
                // Copy succeeded, add the original path to the list of copied path
                
                [copiedPaths_ addObject:[NSDictionary dictionaryWithObjectsAndKeys:inPath,@"Old Path",
                                                                                   tFinalPath,@"New Path",
                                                                                   nil]];
            }
        }
        else
        {
            tFinalPath=[NSString stringWithString:inPath];
        }
    }
    else
    {
        tFinalPath=[NSString stringWithString:inPath];
    }
    
    return tFinalPath;
}

- (NSMutableArray *) importPackagesWithArray:(NSArray *) inArray atRow:(int) inRow forComponentTree:(PBProjectTree *) inComponentTree andDocument:(id) inDocument
{
    NSMutableArray * tNewSelectionArray;
    int i,tCount;
    NSFileManager * tFileManager;
    BOOL isDirectory;
    NSUserDefaults * tDefaults;
    BOOL tRecursiveImport=NO;
    NSMutableArray * tMissingComponents=nil;

    replaceAll_=NO;
    
    tDefaults=[NSUserDefaults standardUserDefaults];

    copyPackage_=[tDefaults boolForKey:PBPREFERENCEPANE_IMPORT_COPY_COMPONENT];
    
    tRecursiveImport=[tDefaults boolForKey:PBPREFERENCEPANE_IMPORT_SUBCOMPONENTS];
    
    tCount=[inArray count];
    
    tFileManager=[NSFileManager defaultManager];
    
    if (copyPackage_==YES)
    {
        if (projectImportPath_==nil)
        {
            projectImportPath_=[[[[inDocument fileName] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Imported Packages"] copy];
            
            copiedPaths_=[NSMutableArray array];
        }
        
        // Create the Import folder if needed
        
        if ([tFileManager fileExistsAtPath:projectImportPath_ isDirectory:&isDirectory]==NO)
        {
            // The folder needs to be created
        
            if ([tFileManager createDirectoryAtPath:projectImportPath_ attributes:nil]==NO)
            {
                NSBeep();
                
                NSBeginAlertSheet(NSLocalizedString(@"Import aborted",@"No comment"),
                                  nil,
                                  nil,
                                  nil,
                                  window_,
                                  nil,
                                  nil,
                                  nil,
                                  NULL,
                                  [NSString stringWithFormat:NSLocalizedString(@"Cant create the Imported Packages",@"No comment"),projectImportPath_]);
                
                return nil;
            }
        }
        else
        {
            if (isDirectory==NO)
            {
                // A File object exists at this location but it's not a Folder
                
                NSBeep();
                
                NSBeginAlertSheet(NSLocalizedString(@"Import aborted",@"No comment"),
                                  nil,
                                  nil,
                                  nil,
                                  window_,
                                  nil,
                                  nil,
                                  nil,
                                  NULL,
                                  [NSString stringWithFormat:NSLocalizedString(@"Files Imported Packages exists",@"No comment"),projectImportPath_]);
                
                return nil;
            }
        }
    }
    else
	{
		copiedPaths_=nil;
	}
	
    [copiedPaths_ retain];
    
    tNewSelectionArray=[NSMutableArray array];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tPath;
        PBProjectTree * tProjectTree=nil;
        NSString * tExtension;
        
        tPath=[inArray objectAtIndex:i];
        
        tExtension=[tPath pathExtension];
        
        if ([tExtension isEqualToString:@"mpkg"]==YES ||
            [tExtension isEqualToString:@"pkg"]==YES)
        {
            tProjectTree=[PBProjectTree projectTreeWithContentsOfComponent:tPath recursive:tRecursiveImport delegate:self missingComponents:&tMissingComponents];
        }
        else
        {
            NSData * tData;
            
            tData=[NSData dataWithContentsOfFile:tPath];
            
            if (tData!=nil)
            {
                id tObject;
                NSMutableDictionary * tDictionary;
                
                // Prepare the unarchiving
                
                if ([tExtension isEqualToString:@"pmproj"]==YES)
                {
                    // Tiger Format
                    
                    [NSKeyedUnarchiver setClass:[PBTigerMetaPackageDecoder class] forClassName:@"MPModel"];
                            
                    [NSKeyedUnarchiver setClass:[PBTigerSinglePackageDecoder class] forClassName:@"SPModel"];

                    [NSKeyedUnarchiver setClass:[PBTigerCorePackageDecoder class] forClassName:@"PModel"];
                    
                    [NSKeyedUnarchiver setClass:[PBTigerResources class] forClassName:@"Resources"];
                    
                    [NSKeyedUnarchiver setClass:[PBTigerLocalPath class] forClassName:@"LocalPath"];
                    
                    tObject=[NSKeyedUnarchiver unarchiveObjectWithData:tData];
                    
                    [tObject setSourcePath:[tPath stringByDeletingLastPathComponent]];
                }
                else
                {
                    // Jaguar Format
                    
                    [NSUnarchiver decodeClassName:@"IFMutableSinglePackage" asClassName:@"PBJaguarSinglePackageDecoder"];
                    
                    [NSUnarchiver decodeClassName:@"IFMutableMetaPackage" asClassName:@"PBJaguarMetaPackageDecoder"];
                    
                    [NSUnarchiver decodeClassName:@"IFCorePackage" asClassName:@"PBJaguarCorePackageDecoder"];
                    
                    // Cheetah Format
                    
                    [NSUnarchiver decodeClassName:@"PMMutablePackage" asClassName:@"PBCheetahSinglePackageDecoder"];
                    
                    [NSUnarchiver decodeClassName:@"PMMutableMetaPackage" asClassName:@"PBCheetahMetaPackageDecoder"];
                
                    [NSUnarchiver decodeClassName:@"PMSubPackageItem" asClassName:@"PBSubPackageItem"];
                    
                    tObject=[NSUnarchiver unarchiveObjectWithData:tData];
                }
            
            	if (tObject!=nil)
                {
                    tDictionary=[tObject dictionary];
                    
                    if (tDictionary!=nil)
                    {
                        tProjectTree=[PBProjectTree projectTreeWithDictionary:tDictionary];
                    }
                }
            }
            else
            {
                NSBeep();
                
                // A COMPLETER
            }
        }
        
        if (tProjectTree!=nil)
        {
            [tNewSelectionArray addObject:[NSNumber numberWithInt:inRow]];
            
            [inComponentTree insertChild:tProjectTree
                                atIndex:inRow++];
        }
        else
        {
            break;
        }
    }
    
    [copiedPaths_ release];
	
	copiedPaths_=nil;
    
    if (tMissingComponents!=nil)
    {
        [IBimportReporter_ beginReporterSheetForWindow:window_
                                                report:tMissingComponents];
    }
    
    return tNewSelectionArray;
}

#pragma mark -

- (IBAction) sortByName:(id)sender
{
    [self sort:sender usingSelector:@selector(compareMPComponentName:)];
}

- (IBAction) sortByAttribute:(id)sender
{
    [self sort:sender usingSelector:@selector(compareMPComponentAttribute:)];
}

- (void) sort:(id) sender usingSelector:(SEL) inSelector
{
    NSEnumerator * tEnumerator;
    NSArray * tArray;
    int i,tCount;
    NSMutableArray * tMutableArray;
    PBProjectTree * tComponentNode;
    int minRow=0;
    
    tEnumerator=[IBarray_ selectedRowEnumerator];
    
    tArray=[tEnumerator allObjects];
    
    tCount=[tArray count];
    
    if (tCount==0)
    {
        if (sender==document_)
        {
            // Sort All
        
            tMutableArray=[NSMutableArray array];
            
            tCount=[componentsTree_ numberOfChildren];
            
            for(i=0;i<tCount;i++)
            {
                int tAttribute;
                
                tComponentNode=(PBProjectTree *) [componentsTree_ childAtIndex:i];
            
                tAttribute=[OBJECTNODE_DATA(tComponentNode) attribute];
                
                if ([NODE_DATA(tComponentNode) type]==kPBPackageNode)
                {
                    PBPackageNode * tPackageNode;
                    
                    tPackageNode=(PBPackageNode *) NODE_DATA(tComponentNode);
                    
                    if ([tPackageNode isRequired]==YES)
                    {
                        tAttribute=kObjectRequired;
                    }
                }
                
                [tMutableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NODE_DATA(tComponentNode) name],@"Name",
                                                                                    [NSNumber numberWithInt:tAttribute],@"Attribute",
                                                                                    tComponentNode,@"Object",
                                                                                    nil]];
            }
            
            for(i=0;i<tCount;i++)
            {
                NSDictionary * tDictionary;
                
                tDictionary=[tMutableArray objectAtIndex:i];
            
                [componentsTree_ removeChild:[tDictionary objectForKey:@"Object"]];
            }
        }
        else
        {
            return;
        }
    }
    else
    {
        tMutableArray=[NSMutableArray array];
        
        minRow=[[tArray objectAtIndex:0] intValue];
        
        for(i=0;i<tCount;i++)
        {
            NSNumber * tNumber;
            int tAttribute;
            
            tNumber=[tArray objectAtIndex:i];
            
            int tIndex=[tNumber intValue];
            
            tComponentNode=(PBProjectTree *) [componentsTree_ childAtIndex:tIndex];
            
            tAttribute=[OBJECTNODE_DATA(tComponentNode) attribute];
                
            if ([NODE_DATA(tComponentNode) type]==kPBPackageNode)
            {
                PBPackageNode * tPackageNode;
                
                tPackageNode=(PBPackageNode *) NODE_DATA(tComponentNode);
                
                if ([tPackageNode isRequired]==YES)
                {
                    tAttribute=kObjectRequired;
                }
            }
            
            [tMutableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NODE_DATA(tComponentNode) name],@"Name",
                                                                                [NSNumber numberWithInt:tAttribute],@"Attribute",
                                                                                tComponentNode,@"Object",
                                                                                nil]];
        }
        
        for(i=0;i<tCount;i++)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[tMutableArray objectAtIndex:i];
        
            [componentsTree_ removeChild:[tDictionary objectForKey:@"Object"]];
        }
    }
    
    [tMutableArray sortUsingSelector:@selector(compareMPComponentName:)];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tDictionary;
            
        tDictionary=[tMutableArray objectAtIndex:i];
        
        [componentsTree_ insertChild:[tDictionary objectForKey:@"Object"]
                             atIndex:minRow+i];
    }
    
    [IBarray_ deselectAll:nil];
        
    [IBarray_ reloadData];
        
    if (sender!=document_)
    {
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:minRow+i byExtendingSelection:YES];
        }
    }
    
    [self postNotificationChange];
}

#pragma mark -

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    [pboard declareTypes:[NSArray arrayWithObject: PBComponentPBoardType] owner:self];
    
    [pboard setData:[NSData data] forType:PBComponentPBoardType]; 

    internalDragData_=rows;
        
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if (op==NSTableViewDropAbove)
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
    
    	if ([[tPasteBoard types] containsObject:NSFilenamesPboardType]!=nil)
        {
            return [PBMetaPackageComponentsController validateDropOfFiles:info inTree:componentsTree_];
        }
        else
        {
            if ([info draggingSource]==IBarray_)
            {
                if ([internalDragData_ count]==1)
                {
                    int tOriginalRow=[[internalDragData_ objectAtIndex:0] intValue];
                
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
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    
    NSPasteboard * tPasteBoard;
    int i,tCount;
    
    tPasteBoard=[info draggingPasteboard];
    
    if ([[tPasteBoard types] containsObject:NSFilenamesPboardType]!=nil)
    {
        // Package/Metapackage Import
        
        NSMutableArray * tNewSelectionArray;
        
        [IBarray_ deselectAll:nil];
        
        tNewSelectionArray=[self importPackagesWithArray:(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType]
                                                   atRow:row
                                        forComponentTree:componentsTree_
                                             andDocument:document_];
        
        [IBarray_ reloadData];
        
        tCount=[tNewSelectionArray count];
        
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:[[tNewSelectionArray objectAtIndex:i] intValue] byExtendingSelection:YES];
        }
    }
    else
    {
        PBProjectTree * tNode;
        int tRowIndex;
        int tOriginalRow=row;
        NSMutableArray * tTemporaryArray;
        
        tCount=[internalDragData_ count];
        
        [IBarray_ deselectAll:nil];
        
        tTemporaryArray=[NSMutableArray array];
        
        for(i=tCount-1;i>=0;i--)
        {
            tRowIndex=[[internalDragData_ objectAtIndex:i] intValue];
            
            tNode=(PBProjectTree *) [componentsTree_ childAtIndex:tRowIndex];
            
            [tTemporaryArray insertObject:tNode atIndex:0];
            
            [tNode removeFromParent];
            
            if (tRowIndex<tOriginalRow)
            {
                row--;
            }
        }
        
        for(i=tCount-1;i>=0;i--)
        {
            tNode=(PBProjectTree *) [tTemporaryArray objectAtIndex:i];
            
            [componentsTree_ insertChild:tNode
                                 atIndex:row];
        }
        
        [IBarray_ reloadData];
        
        for(i=0;i<tCount;i++)
        {
            [IBarray_ selectRow:row++ byExtendingSelection:YES];
        }
    }
    
    [self postNotificationChange];
    
    return YES;
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (projectTree_!=nil && componentsTree_!=nil)
    {
        return [componentsTree_ numberOfChildren];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if (projectTree_!=nil && componentsTree_!=nil)
    {
        PBProjectTree * tComponentNode;
        
        tComponentNode=(PBProjectTree *) [componentsTree_ childAtIndex:rowIndex];
        
        if ([[aTableColumn identifier] isEqualToString: @"Status"])
        {
            return [NSNumber numberWithBool: [NODE_DATA(tComponentNode) status]];
        }
        else
        if ([[aTableColumn identifier] isEqualToString: @"Packages"])
        {
            return [NODE_DATA(tComponentNode) name];
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{    
    PBProjectTree * tComponentTree;
        
    tComponentTree=(PBProjectTree *) [componentsTree_ childAtIndex:row];
        
    if ([[tableColumn identifier] isEqualToString: @"Packages"])
    {
        NSImage * tImage=nil;
        
        switch([NODE_DATA(tComponentTree) type])
        {
            case kPBMetaPackageNode:
                tImage=metaPackageNodeImage_;
                break;
            case kPBPackageNode:
                tImage=packageNodeImage_;
                break;
        }
        
        [(ImageAndTextCell*)cell setImage: tImage];
    }
    else
    if ([[tableColumn identifier] isEqualToString: @"Attribute"])
    {
        // If the node is a Package we need to check the Required flag
        
        if ([NODE_DATA(tComponentTree) type]==kPBPackageNode)
        {
            PBPackageNode * tPackageNode;
            
            tPackageNode=(PBPackageNode *) NODE_DATA(tComponentTree);
            
            if ([tPackageNode isRequired]==YES)
            {
                [cell selectItemAtIndex:kObjectRequired+1];
                [cell setEnabled:NO];
                
                return;
            }
            
            [cell setEnabled:YES];
        }
        else
        {
            [cell setEnabled:YES];
        }
        
        [cell selectItemAtIndex:[OBJECTNODE_DATA(tComponentTree) attribute]+1];
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    PBProjectTree * tComponentNode;
        
    tComponentNode=(PBProjectTree *) [componentsTree_ childAtIndex:row];
        
    if ([[tableColumn identifier] isEqualToString: @"Status"])
    {
        [NODE_DATA(tComponentNode) setStatus:[object boolValue]];
    }
    else
    if ([[tableColumn identifier] isEqualToString: @"Packages"])
    {
        [NODE_DATA(tComponentNode) setName:object];
    }
    else
    if ([[tableColumn identifier] isEqualToString: @"Attribute"])
    {
        int tAttribute;
        
        tAttribute=[object intValue]-1;
        
        if (tAttribute!=[OBJECTNODE_DATA(tComponentNode) attribute])
        {
            [OBJECTNODE_DATA(tComponentNode) setAttribute:tAttribute];
        }
    }
    
    [self postNotificationChange];
}

#pragma mark -

- (void) updateView:(NSNotification *) aNotification
{
    [IBarray_ reloadData];
}

- (void) switchRelative:(id) sender
{
    switch([[IBrelativePopupButton_ selectedItem] tag])
    {
        case 0:
            [((PBMetaPackageNode *) NODE_DATA(projectTree_)) setComponentsDirectory:[NSString stringWithString:@"Contents/Resources"]];
            break;
        case 1:
            [((PBMetaPackageNode *) NODE_DATA(projectTree_)) setComponentsDirectory:[NSString stringWithString:@".."]];
            break;
    }
    
    [IBrelativeTextField_ setStringValue:[((PBMetaPackageNode *) NODE_DATA(projectTree_)) componentsDirectory]];

    [self updateComponents:IBrelativePopupButton_];
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
    
    
    if (tAction==@selector(switchRelative:))
    {
        if ([aMenuItem tag]==-1)
        {
            return NO;
        }
    }
    else
    if (tAction==@selector(delete:))
    {
        if ([IBarray_ numberOfSelectedRows]==0)
        {
            return NO;
        }
    }
    else
    if (tAction==@selector(switchRelative:))
    {
    }
    else
    if (tAction==@selector(sortByName:) ||
        tAction==@selector(sortByAttribute:))
    {
        if ([IBarray_ numberOfSelectedRows]<2)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

+ (BOOL) validateFiles:(NSArray *) inFilesArray
{
    int i,tCount;
    NSFileManager * tFileManager;
    
    tCount=[inFilesArray count];
    
    tFileManager=[NSFileManager defaultManager];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tPath=[inFilesArray objectAtIndex:i];
        
        if ([[tPath pathExtension] isEqualToString:@"pkg"]==YES)
        {
            BOOL isDirectory;
            
            if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==YES && isDirectory==YES)
            {
                NSString * tInfoPath;
                
                tInfoPath=[tPath stringByAppendingPathComponent:@"Contents/Info.plist"];
                
                if ([tFileManager fileExistsAtPath:tInfoPath isDirectory:&isDirectory]==YES && isDirectory==NO)
                {
                    // Check that we're not trying to import a receipts
                    
                    NSString * tArchivePath;
                    
                    tArchivePath=[tPath stringByAppendingPathComponent:@"Contents/Archive.pax"];
                    
                    if ([tFileManager fileExistsAtPath:tArchivePath isDirectory:&isDirectory]==NO)
                    {
                        tArchivePath=[tPath stringByAppendingPathComponent:@"Contents/Archive.pax.gz"];
                        
                        if ([tFileManager fileExistsAtPath:tArchivePath isDirectory:&isDirectory]==NO || isDirectory==YES)
                        {
                            break;
                        }
                    }
                    else
                    {
                        if (isDirectory==YES)
                        {
                            break;
                        }
                    }
                }
                else
                {
                    // are we trying to import an old format package
                    
                    NSString * tPackageName;
                    
                    tPackageName=[[tPath lastPathComponent] stringByDeletingPathExtension];
                    
                    tInfoPath=[tPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Contents/Resources/%@.bom",tPackageName]];
                    
                    if ([tFileManager fileExistsAtPath:tInfoPath isDirectory:&isDirectory]==YES && isDirectory==NO)
                    {
                        // Check that we're not trying to import a receipts
                        
                        NSString * tArchivePath;
                        
                        tArchivePath=[tPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Contents/Resources/%@.pax",tPackageName]];
                        
                        if ([tFileManager fileExistsAtPath:tArchivePath isDirectory:&isDirectory]==NO)
                        {
                            tArchivePath=[tPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Contents/Resources/%@.pax.gz",tPackageName]];
                            
                            if ([tFileManager fileExistsAtPath:tArchivePath isDirectory:&isDirectory]==NO || isDirectory==YES)
                            {
                                break;
                            }
                        }
                        else
                        {
                            if (isDirectory==YES)
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
            }
            else
            {
                break;
            }
        }
        else if ([[tPath pathExtension] isEqualToString:@"mpkg"]==YES)
        {
            BOOL isDirectory;
            NSString * tDistributionScriptPath;
			
			if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==NO || isDirectory==NO)
            {
                 break;
            }
			
			// We can't import Dsitribution Script (03/14/09)
			
			tDistributionScriptPath=[tPath stringByAppendingPathComponent:@"Contents/distribution.dist"];
			
            if ([tFileManager fileExistsAtPath:tDistributionScriptPath isDirectory:&isDirectory]==YES)
            {
                 break;
            }
        }
        else if ([[tPath pathExtension] isEqualToString:@"pmsp"]==YES ||	// PackageMaker Package
                 [[tPath pathExtension] isEqualToString:@"pmsm"]==YES ||	// PackageMaker Metapackage
                 [[tPath pathExtension] isEqualToString:@"pmproj"]==YES)	// PackageMaker Project	
        {
            BOOL isDirectory;
            
            if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==NO || isDirectory==YES)
            {
                break;
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

+ (unsigned int) validateDropOfFiles:(id <NSDraggingInfo>)info inTree:(PBProjectTree *) inProjectTree
{
    NSArray * tArray;
    int tCount;
    NSPasteboard * tPasteBoard;
    
    tPasteBoard=[info draggingPasteboard];
    
    tArray=(NSArray *) [tPasteBoard propertyListForType:NSFilenamesPboardType];

    tCount=[tArray count];
    
    if ([NODE_DATA(inProjectTree) type]==kProjectNode)
    {
        if (tCount!=1)
        {
            return NSDragOperationNone;
        }
    }
    
    return (([PBMetaPackageComponentsController validateFiles:tArray]==YES) ? NSDragOperationCopy : NSDragOperationNone);
}

@end
