/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBResourcesController.h"
//#import "PBFileTextField.h"
#import "PBReferencedFileTextField.h"
#import "NSString+Iceberg.h"
#import "PBExtensionUtilities.h"
#import "PBmatrix.h"

@implementation PBResourcesController

+ (PBResourcesController *) resourcesController
{
    PBResourcesController * nController=nil;
    
    nController=[PBResourcesController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"Resources" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"Resources"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (void) awakeFromNib
{
    NSTextFieldCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    
    [IBlicenseArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    // Key
    
    licensesProvider_=[PBLicenseProvider defaultProvider];
    
    tableColumn = [IBlicenseArray_ tableColumnWithIdentifier: @"Key"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
    
    // Value
    
    tableColumn = [IBlicenseArray_ tableColumnWithIdentifier: @"Value"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    /*[IBimagePath_ setHintString:@"Default Background Image"];
    [IBwelcomePath_ setHintString:@"Default Welcome"];
    [IBreadMePath_ setHintString:@"No ReadMe"];
    [IBlicensePath_ setHintString:@"No License"];*/
}

- (void) treeWillChange
{
    [self updateImage:nil];
    [self updateWelcome:nil];
    [self updateReadMe:nil];
    [self updateLicense:nil];
    
    [super treeWillChange];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    NSDictionary * tImageDictionary;
    NSDictionary * tDictionary;
    id tMenuItem;
    NSString * tValue;
    
    [currentWelcomeLanguage_ release];
    
    currentWelcomeLanguage_=nil;
    
    [currentReadMeLanguage_ release];
    
    currentReadMeLanguage_=nil;
    
    [currentLicenseLanguage_ release];
    
    currentLicenseLanguage_=nil;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
    
    tDictionary=[objectNode_ resources];
    
    tImageDictionary=[tDictionary objectForKey:RESOURCE_BACKGROUND_KEY];
    
    [IBimageMode_ selectCellWithTagNoScrolling:[[tImageDictionary objectForKey:@"Mode"] intValue]];
    
    tValue=[tImageDictionary objectForKey:@"Path"];
    
    [IBimagePath_ setDocument:inDocument];
    
    if (tValue==nil)
    {
        [IBimagePath_ setPathType:kGlobalPath];
        
        [IBimagePath_ setStringValue:@""];
    }
    else
    {
        NSNumber * tNumber;
        int tType;
        
        tNumber=[tImageDictionary objectForKey:@"Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBimagePath_ _setPathType:tType];
        
        [IBimagePath_ setStringValue:tValue];
    }
    
    [IBimageScaling_ selectCellWithTagNoScrolling:[[tImageDictionary objectForKey:IFPkgFlagBackgroundScaling] intValue]];
    
    [IBimageAlignment_ selectItemAtIndex:[IBimageAlignment_ indexOfItemWithTag:[[tImageDictionary objectForKey:IFPkgFlagBackgroundAlignment] intValue]]];
    
    // Select the International Item if available
    
    [self updateWelcomeLanguage];
    
    tMenuItem=[IBwelcomeLanguage_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBwelcomeLanguage_ itemAtIndex:0];
    }
    
    [IBwelcomeLanguage_ selectItem:tMenuItem];
    
    [IBwelcomePath_ setDocument:inDocument];
    
    [self switchWelcomeLanguage:IBwelcomeLanguage_];
    
    // Select the International Item if available
    
    [self updateReadMeLanguage];
    
    tMenuItem=[IBreadMeLanguage_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBreadMeLanguage_ itemAtIndex:0];
    }
    
    [IBreadMeLanguage_ selectItem:tMenuItem];
    
    [IBreadMePath_ setDocument:inDocument];
    
    [self switchReadMeLanguage:IBreadMeLanguage_];
    
    // Select the International Item if available
    
    [self updateLicenseLanguage];

    tMenuItem=[IBlicenseLanguage_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBlicenseLanguage_ itemAtIndex:0];
    }
    
    [IBlicenseLanguage_ selectItem:tMenuItem];
    
    [IBlicensePath_ setDocument:inDocument];
    
    [self switchLicenseLanguage:IBlicenseLanguage_];
}

#pragma mark -

- (IBAction) selectImagePath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[[IBimagePath_ absolutePath] stringByExpandingTildeInPath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"'TIFF'",
                                                                 @"TIF",
                                                                 @"tif",
                                                                 @"TIFF",
                                                                 @"tiff",
                                                                 @"'JPEG'",
                                                                 @"JPG",
                                                                 @"jpg",
                                                                 @"JPEG",
                                                                 @"jpeg",
                                                                 @"'GIFf'",
                                                                 @"GIF",
                                                                 @"gif",
                                                                 @"'PDF '",
                                                                 @"PDF",
                                                                 @"pdf",
                                                                 @"'PICT'",
                                                                 @"PCT",
                                                                 @"pct",
                                                                 @"PICT",
                                                                 @"pict",
                                                                 @"'EPSF'",
                                                                 @"EPSI",
                                                                 @"epsi",
                                                                 @"EPSF",
                                                                 @"epsf",
                                                                 @"EPI",
                                                                 @"epi",
                                                                 @"EPS",
                                                                 @"eps",
                                                                 nil]
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(imageOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) imageOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBimagePath_ setAbsolutePath:[sheet filename]];
        
        [self updateImage:IBimageScaling_];
    }
}

- (IBAction) revealImageInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBimagePath_ stringValue] inFileViewerRootedAtPath:@""];
}

- (IBAction) openImage:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace openFile:[IBimagePath_ stringValue]];
}

- (IBAction) updateImage:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tImageDictionary;
    int tPathType;
    
    tPathType=[IBimagePath_ pathType];
                                                               
    tImageDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBimageMode_ selectedCell] tag]],@"Mode",
                                                                [IBimagePath_ stringValue],@"Path",
                                                                [NSNumber numberWithInt:tPathType],@"Path Type",
                                                                [NSNumber numberWithInt:[[IBimageScaling_ selectedCell] tag]],IFPkgFlagBackgroundScaling,
                                                                [NSNumber numberWithInt:[[IBimageAlignment_ selectedItem] tag]],IFPkgFlagBackgroundAlignment,
                                                                nil];
    
    tDictionary=[objectNode_ resources];
    
    [tDictionary setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
    
    if (sender!=nil)
    {
        if (sender==IBimagePath_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

#pragma mark -

- (IBAction) updateWelcome:(id) sender
{
    NSDictionary * tDictionary;
    NSMutableDictionary * tResourcesDictionary;
    NSMutableDictionary * tMutableWelcomeDictionary;
    int tPathType;
    
    tPathType=[IBwelcomePath_ pathType];
    
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBwelcomeMode_ selectedCell] tag]],@"Mode",
                                                           [IBwelcomePath_ stringValue],@"Path",
                                                           [NSNumber numberWithInt:tPathType],@"Path Type",
                                                           nil];
    
    tResourcesDictionary=[objectNode_ resources];
    
    tMutableWelcomeDictionary=[[tResourcesDictionary objectForKey:RESOURCE_WELCOME_KEY] mutableCopy];
    
    [tMutableWelcomeDictionary setObject:tDictionary
                                  forKey:currentWelcomeLanguage_];
    
    [tResourcesDictionary setObject:tMutableWelcomeDictionary
                            forKey:RESOURCE_WELCOME_KEY];
                    
    [tMutableWelcomeDictionary release];
    
    if (sender!=nil)
    {
        if (sender==IBwelcomePath_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

- (IBAction) selectWelcomePath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[IBwelcomePath_ absolutePath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"txt",@"rtf",@"rtfd",@"html",@"htm",@"TXT",@"'TEXT'",@"RTF",@"RTFD",@"HTML",nil]
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(welcomeOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) welcomeOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBwelcomePath_ setAbsolutePath:[sheet filename]];
        
        [self updateWelcome:IBwelcomeMode_];
    }
}

- (IBAction) revealWelcomeInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBwelcomePath_ absolutePath] inFileViewerRootedAtPath:@""];
}

- (IBAction) openWelcome:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace openFile:[IBwelcomePath_ absolutePath]];
}

- (IBAction) switchWelcomeLanguage:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tWelcomeDictionary;
    NSDictionary * tLocalizedWelcomeDictionary;
    id tSelectedItem;
    NSString * oldLanguage;
    NSString * tValue;
    
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
                              @selector(removeWelcomeLocalizationSheetDidEnd:returnCode:contextInfo:),
                              nil,
                              NULL,
                              NSLocalizedString(@"This cannot be undone.",@"No comment"));
            return;
        case -111:
            partID_=kPBResourcesWelcome;
            
            [[PBLocalizationPanel localizationPanel] beginSheetModalForWindow:[IBview_ window]
                                                                modalDelegate:self
                                                               didEndSelector:@selector(localizationPanelDidEnd:returnCode:localization:)];
            return;
    }
    
    tDictionary=[objectNode_ resources];
    
    tWelcomeDictionary=[tDictionary objectForKey:RESOURCE_WELCOME_KEY];
    
    oldLanguage=currentWelcomeLanguage_;
    
    currentWelcomeLanguage_=[[IBwelcomeLanguage_ selectedItem] title];
    
    if ([currentWelcomeLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentWelcomeLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentWelcomeLanguage_ retain];
    
    tLocalizedWelcomeDictionary=[tWelcomeDictionary objectForKey:currentWelcomeLanguage_];

    [IBwelcomeMode_ selectCellWithTagNoScrolling:[[tLocalizedWelcomeDictionary objectForKey:@"Mode"] intValue]];
    
    tValue=[tLocalizedWelcomeDictionary objectForKey:@"Path"];
    
    if (tValue==nil)
    {
        [IBwelcomePath_ setPathType:kGlobalPath];
        
        [IBwelcomePath_ setStringValue:@""];
    }
    else
    {
        NSNumber * tNumber;
        int tType;
        
        tNumber=[tLocalizedWelcomeDictionary objectForKey:@"Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBwelcomePath_ _setPathType:tType];
        
        [IBwelcomePath_ setStringValue:tValue];
    }
}

- (void) updateWelcomeLanguage
{
    NSDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSMutableArray * tMutableArray;

    tDictionary=[objectNode_ resources];
    
    tDescriptionDictionary=[tDictionary objectForKey:RESOURCE_WELCOME_KEY];
    
    [IBwelcomeLanguage_ removeAllItems];
    
    tMutableArray=[[tDescriptionDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBwelcomeLanguage_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBwelcomeLanguage_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBwelcomeLanguage_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBwelcomeLanguage_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBwelcomeLanguage_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBwelcomeLanguage_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (void) removeWelcomeLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tDictionary;
        NSMutableDictionary * tWelcomeDictionary;
        id tMenuItem;
        
        tDictionary=[objectNode_ resources];
        
        tWelcomeDictionary=[[tDictionary objectForKey:RESOURCE_WELCOME_KEY] mutableCopy];
        
        [tWelcomeDictionary removeObjectForKey:currentWelcomeLanguage_];
        
        [tDictionary setObject:tWelcomeDictionary forKey:RESOURCE_WELCOME_KEY];
        
        // Update PopupButton
        
        [IBwelcomeLanguage_ removeItemWithTitle:currentWelcomeLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBwelcomeLanguage_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBwelcomeLanguage_ itemAtIndex:0];
        }
        
        [IBwelcomeLanguage_ selectItem:tMenuItem];
        
        [self switchWelcomeLanguage:IBwelcomeLanguage_];
        
        [self updateWelcome:IBwelcomeLanguage_];
    }
    else
    {
        [IBwelcomeLanguage_ selectItemWithTitle:currentWelcomeLanguage_];
    }
}

#pragma mark -

- (void) updateReadMe:(id) sender
{
    NSDictionary * tDictionary;
    NSMutableDictionary * tResourcesDictionary;
    NSMutableDictionary * tMutableReadMeDictionary;
    int tPathType;
    
    tPathType=[IBreadMePath_ pathType];
    
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBreadMeMode_ selectedCell] tag]],@"Mode",
                                                           [IBreadMePath_ stringValue],@"Path",
                                                           [NSNumber numberWithInt:tPathType],@"Path Type",
                                                           nil];
    
    tResourcesDictionary=[objectNode_ resources];
    
    tMutableReadMeDictionary=[[tResourcesDictionary objectForKey:RESOURCE_README_KEY] mutableCopy];
    
    [tMutableReadMeDictionary setObject:tDictionary
                                  forKey:currentReadMeLanguage_];
    
    [tResourcesDictionary setObject:tMutableReadMeDictionary
                            forKey:RESOURCE_README_KEY];
                    
    [tMutableReadMeDictionary release];
    
    if (sender!=nil)
    {
        if (sender==IBreadMePath_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }

}

- (IBAction) selectReadMePath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[IBreadMePath_ absolutePath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"txt",@"rtf",@"rtfd",@"html",@"htm",@"TXT",@"'TEXT'",@"RTF",@"RTFD",@"HTML",nil]
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(readMeOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) readMeOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBreadMePath_ setAbsolutePath:[sheet filename]];
        
        [self updateReadMe:IBreadMeMode_];
    }
}

- (IBAction) revealReadMeInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBreadMePath_ absolutePath] inFileViewerRootedAtPath:@""];
}

- (IBAction) openReadMe:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace openFile:[IBreadMePath_ absolutePath]];
}

- (IBAction) switchReadMeLanguage:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tReadMeDictionary;
    NSDictionary * tLocalizedReadMeDictionary;
    id tSelectedItem;
    NSString * oldLanguage;
    NSString * tValue;
    
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
                              @selector(removeReadMeLocalizationSheetDidEnd:returnCode:contextInfo:),
                              nil,
                              NULL,
                              NSLocalizedString(@"This cannot be undone.",@"No comment"));
            return;
        case -111:
            partID_=kPBResourcesReadMe;
            
            [[PBLocalizationPanel localizationPanel] beginSheetModalForWindow:[IBview_ window]
                                                                modalDelegate:self
                                                               didEndSelector:@selector(localizationPanelDidEnd:returnCode:localization:)];
            return;
    }
    
    tDictionary=[objectNode_ resources];
    
    tReadMeDictionary=[tDictionary objectForKey:RESOURCE_README_KEY];
    
    oldLanguage=currentReadMeLanguage_;
    
    currentReadMeLanguage_=[[IBreadMeLanguage_ selectedItem] title];
    
    if ([currentReadMeLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentReadMeLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentReadMeLanguage_ retain];
    
    tLocalizedReadMeDictionary=[tReadMeDictionary objectForKey:currentReadMeLanguage_];
    
    [IBreadMeMode_ selectCellWithTagNoScrolling:[[tLocalizedReadMeDictionary objectForKey:@"Mode"] intValue]];
    
    tValue=[tLocalizedReadMeDictionary objectForKey:@"Path"];
    
    if (tValue==nil)
    {
        [IBreadMePath_ setPathType:kGlobalPath];
        
        [IBreadMePath_ setStringValue:@""];
    }
    else
    {
        NSNumber * tNumber;
        int tType;
        
        tNumber=[tLocalizedReadMeDictionary objectForKey:@"Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBreadMePath_ _setPathType:tType];
        
        [IBreadMePath_ setStringValue:tValue];
    }
}

- (void) updateReadMeLanguage
{
    NSDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSMutableArray * tMutableArray;

    tDictionary=[objectNode_ resources];
    
    tDescriptionDictionary=[tDictionary objectForKey:RESOURCE_README_KEY];
    
    [IBreadMeLanguage_ removeAllItems];
    
    tMutableArray=[[tDescriptionDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBreadMeLanguage_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBreadMeLanguage_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBreadMeLanguage_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBreadMeLanguage_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBreadMeLanguage_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBreadMeLanguage_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (void) removeReadMeLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tDictionary;
        NSMutableDictionary * tReadMeDictionary;
        id tMenuItem;
        
        tDictionary=[objectNode_ resources];
        
        tReadMeDictionary=[[tDictionary objectForKey:RESOURCE_README_KEY] mutableCopy];
        
        [tReadMeDictionary removeObjectForKey:currentReadMeLanguage_];
        
        [tDictionary setObject:tReadMeDictionary forKey:RESOURCE_README_KEY];
        
        // Update PopupButton
        
        [IBreadMeLanguage_ removeItemWithTitle:currentReadMeLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBreadMeLanguage_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBreadMeLanguage_ itemAtIndex:0];
        }
        
        [IBreadMeLanguage_ selectItem:tMenuItem];
        
        [self switchReadMeLanguage:IBreadMeLanguage_];
        
        [self updateReadMe:IBreadMeLanguage_];
    }
    else
    {
        [IBreadMeLanguage_ selectItemWithTitle:currentReadMeLanguage_];
    }
}

#pragma mark -

- (void) updateLicense:(id) sender
{
    NSDictionary * tDictionary;
    NSMutableDictionary * tResourcesDictionary;
    NSMutableDictionary * tMutableLicenseDictionary;
    int tPathType;
    
    tPathType=[IBlicensePath_ pathType];
    
    if ([IBlicensePopup_ numberOfItems]>0)
    {
        // Clean the Keywords values
        
        int i,tCount;
        NSMutableDictionary * tValuesDictionary;
        
        tCount=[keywords_ count];
        
        tValuesDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[keywords_ objectAtIndex:i];
        
            [tValuesDictionary setObject:[values_ objectForKey:tKey] forKey:tKey];
        }
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBlicenseMode_ selectedCell] tag]],@"Mode",
                                                               [IBlicensePath_ stringValue],@"Path",
                                                               [NSNumber numberWithInt:tPathType],@"Path Type",
                                                               [[IBlicensePopup_ selectedItem] title],@"Template",
                                                               tValuesDictionary,@"Keywords",
                                                               nil];
    }
    else
    {
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBlicenseMode_ selectedCell] tag]],@"Mode",
                                                               [IBlicensePath_ stringValue],@"Path",
                                                               [NSNumber numberWithInt:tPathType],@"Path Type",
                                                               nil];
    }
    
    tResourcesDictionary=[objectNode_ resources];
    
    tMutableLicenseDictionary=[[tResourcesDictionary objectForKey:RESOURCE_LICENSE_KEY] mutableCopy];
    
    [tMutableLicenseDictionary setObject:tDictionary
                                  forKey:currentLicenseLanguage_];
    
    [tResourcesDictionary setObject:tMutableLicenseDictionary
                            forKey:RESOURCE_LICENSE_KEY];
                    
    [tMutableLicenseDictionary release];
    
    if (sender!=nil)
    {
        if (sender==IBlicensePath_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }

}

- (IBAction) selectLicensePath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[IBlicensePath_ absolutePath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"txt",@"rtf",@"rtfd",@"html",@"htm",@"TXT",@"'TEXT'",@"RTF",@"RTFD",@"HTML",nil]
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(licenseOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) licenseOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBlicensePath_ setAbsolutePath:[sheet filename]];
        
        [self updateLicense:IBlicenseMode_];
    }
}

- (IBAction) revealLicenseInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBlicensePath_ absolutePath] inFileViewerRootedAtPath:@""];
}

- (IBAction) openLicense:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace openFile:[IBlicensePath_ absolutePath]];
}

- (IBAction) switchLicenseLanguage:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tLicenseDictionary;
    NSDictionary * tLocalizedLicenseDictionary;
    id tSelectedItem;
    NSString * tString;
    NSArray * tTemplates;
    NSString * oldLanguage;
    NSString * tValue;
    
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
                              @selector(removeLicenseLocalizationSheetDidEnd:returnCode:contextInfo:),
                              nil,
                              NULL,
                              NSLocalizedString(@"This cannot be undone.",@"No comment"));
            return;
        case -111:
            partID_=kPBResourcesLicense;
            
            [[PBLocalizationPanel localizationPanel] beginSheetModalForWindow:[IBview_ window]
                                                                modalDelegate:self
                                                               didEndSelector:@selector(localizationPanelDidEnd:returnCode:localization:)];
            return;
    }
    
    tDictionary=[objectNode_ resources];
    
    tLicenseDictionary=[tDictionary objectForKey:RESOURCE_LICENSE_KEY];
    
    oldLanguage=currentLicenseLanguage_;
    
    currentLicenseLanguage_=[[IBlicenseLanguage_ selectedItem] title];
    
    if ([currentLicenseLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentLicenseLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentLicenseLanguage_ retain];
    
    tLocalizedLicenseDictionary=[tLicenseDictionary objectForKey:currentLicenseLanguage_];
    
    [IBlicenseMode_ selectCellWithTagNoScrolling:[[tLocalizedLicenseDictionary objectForKey:@"Mode"] intValue]];
    
    tValue=[tLocalizedLicenseDictionary objectForKey:@"Path"];
    
    if (tValue==nil)
    {
        [IBlicensePath_ setPathType:kGlobalPath];
        
        [IBlicensePath_ setStringValue:@""];
    }
    else
    {
        NSNumber * tNumber;
        int tType;
        
        tNumber=[tLocalizedLicenseDictionary objectForKey:@"Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBlicensePath_ _setPathType:tType];
        
        [IBlicensePath_ setStringValue:tValue];
    }
    
    [IBlicensePopup_ removeAllItems];
    
    tTemplates=[licensesProvider_ licensesForLanguage:currentLicenseLanguage_];
    
    if ([tTemplates count]>0)
    {
        [IBlicensePopup_ setEnabled:YES];
        
        [IBlicensePopup_ addItemsWithTitles:tTemplates];
    
        // Select the appropriate License
        
        tString=[tLocalizedLicenseDictionary objectForKey:@"Template"];
        
        if (tString!=nil)
        {
            [IBlicensePopup_ selectItemWithTitle:tString];
        }
        else
        {
            if ([IBlicensePopup_ numberOfItems]>0)
            {
                [IBlicensePopup_ selectItemAtIndex:0];
                
                tString=[[IBlicensePopup_ selectedItem] title];
            }
        }
        
        if ([IBlicensePopup_ numberOfItems]>0)
        {
            NSDictionary * tKeywordsDictionary;
            
            [keywords_ release];
            
            keywords_=nil;
            
            tKeywordsDictionary=[licensesProvider_ licenseKeywordsWithName:tString language:currentLicenseLanguage_];
            
            if (tKeywordsDictionary!=nil && tKeywordsDictionary!=[NSNull null])
            {
                NSMutableArray * tKeysArray;
                
                tKeysArray=[[tKeywordsDictionary allKeys] mutableCopy];
                
                [tKeysArray sortUsingSelector:@selector(compare:)];
                
                keywords_=[tKeysArray copy];
                
                [tKeysArray release];
            }
        }
        
        [values_ release];
        
        if ([tLocalizedLicenseDictionary objectForKey:@"Keywords"]==nil)
        {
            values_=[[NSMutableDictionary alloc] initWithCapacity:[keywords_ count]];
        }
        else
        {
            values_=[[tLocalizedLicenseDictionary objectForKey:@"Keywords"] mutableCopy];
        }
    }
    else
    {
        [keywords_ release];
            
        keywords_=nil;
            
        [values_ release];
        
        values_=nil;
        
        [IBlicensePopup_ setEnabled:NO];
    }
    
    [IBlicenseArray_ reloadData];
}

- (IBAction) switchLicenseTemplate:(id) sender
{
    NSString * tString;
    NSDictionary * tKeywordsDictionary;
    NSDictionary * tDictionary;
    NSDictionary * tLicenseDictionary;
    NSDictionary * tLocalizedLicenseDictionary;
    NSString * currentTemplate;
    
    [keywords_ release];
    
    keywords_=nil;
    
    // Check that the template is not the same
    
    tString=[[IBlicensePopup_ selectedItem] title];
    
    tDictionary=[objectNode_ resources];
    
    tLicenseDictionary=[tDictionary objectForKey:RESOURCE_LICENSE_KEY];
    
    tLocalizedLicenseDictionary=[tLicenseDictionary objectForKey:currentLicenseLanguage_];
    
    currentTemplate=[tLocalizedLicenseDictionary objectForKey:@"Template"];
    
    if ([tString isEqualToString:currentTemplate]==NO)
    {
        tKeywordsDictionary=[licensesProvider_ licenseKeywordsWithName:tString language:currentLicenseLanguage_];
            
        if (tKeywordsDictionary!=nil && tKeywordsDictionary!=[NSNull null])
        {
            NSMutableArray * tKeysArray;
                    
            tKeysArray=[[tKeywordsDictionary allKeys] mutableCopy];
            
            [tKeysArray sortUsingSelector:@selector(compare:)];
            
            keywords_=[tKeysArray copy];
            
            [tKeysArray release];
        }
        
        if (keywords_!=nil)
        {
            int i,tCount;
            
            tCount=[keywords_ count];
            
            for(i=0;i<tCount;i++)
            {
                NSString * tKey;
                    
                tKey=[keywords_ objectAtIndex:i];
                    
                if ([values_ objectForKey:tKey]==nil)
                {
                    [values_ setObject:@"" forKey:tKey];
                }
            }
        }
        
        [IBlicenseArray_ reloadData];
        
        [self updateLicense:IBlicenseArray_];
    }
}

#pragma mark -

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (aTableView==IBlicenseArray_)
    {
        return ([[aTableColumn identifier] isEqualToString: @"Key"]==NO);
    }
    
    return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView==IBlicenseArray_)
    {
        if (keywords_!=nil)
        {
            return [keywords_ count];
        }
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (aTableView==IBlicenseArray_)
    {
        if (keywords_!=nil)
        {
            if ([[aTableColumn identifier] isEqualToString: @"Key"])
            {
                NSString * tNativeKeyWord;
                
                tNativeKeyWord=[keywords_ objectAtIndex:rowIndex];
                
                return [tNativeKeyWord capitalizedString];
            }
            else
            {
                if ([[aTableColumn identifier] isEqualToString: @"Value"])
                {
                    return [values_ objectForKey:[keywords_ objectAtIndex:rowIndex]];
                }
            }
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if (tableView==IBlicenseArray_)
    {
        if ([[tableColumn identifier] isEqualToString: @"Value"])
        {
            NSString * tString;
            
            tString=[values_ objectForKey:[keywords_ objectAtIndex:row]];
            
            if ([tString isEqualToString:object]==NO)
            {
                [values_ setObject:object forKey:[keywords_ objectAtIndex:row]];
            
                [self updateLicense:IBlicenseArray_];
            }
        }
    }
}

- (void) updateLicenseLanguage
{
    NSDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSMutableArray * tMutableArray;

    tDictionary=[objectNode_ resources];
    
    tDescriptionDictionary=[tDictionary objectForKey:RESOURCE_LICENSE_KEY];
    
    [IBlicenseLanguage_ removeAllItems];
    
    tMutableArray=[[tDescriptionDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBlicenseLanguage_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBlicenseLanguage_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBlicenseLanguage_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBlicenseLanguage_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBlicenseLanguage_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBlicenseLanguage_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (void) removeLicenseLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tDictionary;
        NSMutableDictionary * tLicenseDictionary;
        id tMenuItem;
        
        tDictionary=[objectNode_ resources];
        
        tLicenseDictionary=[[tDictionary objectForKey:RESOURCE_LICENSE_KEY] mutableCopy];
        
        [tLicenseDictionary removeObjectForKey:currentLicenseLanguage_];
        
        [tDictionary setObject:tLicenseDictionary forKey:RESOURCE_LICENSE_KEY];
        
        // Update PopupButton
        
        [IBlicenseLanguage_ removeItemWithTitle:currentLicenseLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBlicenseLanguage_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBlicenseLanguage_ itemAtIndex:0];
        }
        
        [IBlicenseLanguage_ selectItem:tMenuItem];
        
        [self switchLicenseLanguage:IBlicenseLanguage_];
        
        [self updateLicense:IBlicenseLanguage_];
    }
    else
    {
        [IBlicenseLanguage_ selectItemWithTitle:currentLicenseLanguage_];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    if ([aMenuItem action]==@selector(switchWelcomeLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentWelcomeLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    else
    if ([aMenuItem action]==@selector(switchReadMeLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentReadMeLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    else
    if ([aMenuItem action]==@selector(switchLicenseLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentLicenseLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    else
    if ([aMenuItem action]==@selector(revealImageInFinder:) ||
        [aMenuItem action]==@selector(openImage:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBimagePath_ stringValue];
        
        tFileManager=[NSFileManager defaultManager];
        
        return ([tFileManager fileExistsAtPath:tPath]==YES);
    }
    else
    if ([aMenuItem action]==@selector(revealWelcomeInFinder:) ||
        [aMenuItem action]==@selector(openWelcome:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBwelcomePath_ absolutePath];
        
        tFileManager=[NSFileManager defaultManager];
        
        return ([tFileManager fileExistsAtPath:tPath]==YES);
    }
    else
    if ([aMenuItem action]==@selector(revealReadMeInFinder:) ||
        [aMenuItem action]==@selector(openReadMe:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBreadMePath_ absolutePath];
        
        tFileManager=[NSFileManager defaultManager];
        
        return ([tFileManager fileExistsAtPath:tPath]==YES);
    }
    else
    if ([aMenuItem action]==@selector(revealLicenseInFinder:) ||
        [aMenuItem action]==@selector(openLicense:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBlicensePath_ absolutePath];
        
        tFileManager=[NSFileManager defaultManager];
        
        return [tFileManager fileExistsAtPath:tPath];
    }
    
    return YES;
}

#pragma mark -

- (BOOL) shouldAddLocalization:(NSString *) inLocalization
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tPartDictionary=nil;
    NSArray * tArray;
    int i,tCount;

    tDictionary=[objectNode_ resources];
    
    switch(partID_)
    {
        case kPBResourcesWelcome:
            tPartDictionary=[tDictionary objectForKey:RESOURCE_WELCOME_KEY];
            break;
        case kPBResourcesReadMe:
            tPartDictionary=[tDictionary objectForKey:RESOURCE_README_KEY];
            break;
        case kPBResourcesLicense:
            tPartDictionary=[tDictionary objectForKey:RESOURCE_LICENSE_KEY];
            break;
    }

    tArray=[tPartDictionary allKeys];
    
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
        NSDictionary * tPartDictionary=nil;
        NSMutableDictionary * tMutablePartDictionary;
        id tPopupButton=nil;

        tDictionary=[objectNode_ resources];
        
        switch(partID_)
        {
            case kPBResourcesWelcome:
                tPartDictionary=[tDictionary objectForKey:RESOURCE_WELCOME_KEY];
                tPopupButton=IBwelcomeLanguage_;
                break;
            case kPBResourcesReadMe:
                tPartDictionary=[tDictionary objectForKey:RESOURCE_README_KEY];
                tPopupButton=IBreadMeLanguage_;
                break;
            case kPBResourcesLicense:
                tPartDictionary=[tDictionary objectForKey:RESOURCE_LICENSE_KEY];
                tPopupButton=IBlicenseLanguage_;
                break;
        }
        
        // Add the new language
        
        tMutablePartDictionary=[tPartDictionary mutableCopy];
        
        switch(partID_)
        {
            case kPBResourcesWelcome:
                [tMutablePartDictionary setObject:[PBObjectNode defaultWelcomeDictionary]
                                           forKey:localization];
                [tDictionary setObject:tMutablePartDictionary
                                forKey:RESOURCE_WELCOME_KEY];
                [self updateWelcomeLanguage];
                [self updateWelcome:tPopupButton];
                break;
            case kPBResourcesReadMe:
                [tMutablePartDictionary setObject:[PBObjectNode defaultReadMeDictionary]
                                           forKey:localization];
                [tDictionary setObject:tMutablePartDictionary
                                forKey:RESOURCE_README_KEY];
                [self updateReadMeLanguage];
                [self updateReadMe:tPopupButton];
                break;
            case kPBResourcesLicense:
                [tMutablePartDictionary setObject:[PBObjectNode defaultLicenseDictionary]
                                           forKey:localization];
                [tDictionary setObject:tMutablePartDictionary
                                forKey:RESOURCE_LICENSE_KEY];
                [self updateLicenseLanguage];
                [self updateLicense:tPopupButton];
                break;
        }
        
        // Update the PopupButton
        
        [tPopupButton selectItemWithTitle:localization];
        
        switch(partID_)
        {
            case kPBResourcesWelcome:
                [self switchWelcomeLanguage:tPopupButton];
                break;
            case kPBResourcesReadMe:
                [self switchReadMeLanguage:tPopupButton];
                break;
            case kPBResourcesLicense:
                [self switchLicenseLanguage:tPopupButton];
                break;
        }
        
        [tMutablePartDictionary release];
    }
    else
    {
        switch(partID_)
        {
            case kPBResourcesWelcome:
                [IBwelcomeLanguage_ selectItemWithTitle:currentWelcomeLanguage_];
                break;
            case kPBResourcesReadMe:
                [IBreadMeLanguage_ selectItemWithTitle:currentReadMeLanguage_];
                break;
            case kPBResourcesLicense:
                [IBlicenseLanguage_ selectItemWithTitle:currentLicenseLanguage_];
                break;
        }
    }
}

#pragma mark -

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBimagePath_)
    {
        return ([PBExtensionUtilities extensionForImageFileAtPath:inPath]!=nil);
    }
    else
    if (inTextField==IBwelcomePath_ ||
        inTextField==IBreadMePath_ ||
        inTextField==IBlicensePath_)
    {
        return ([PBExtensionUtilities extensionForTextFileAtPath:inPath]!=nil);
    }
    
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    textHasBeenUpdated_=YES;
    
    [(PBReferencedFileTextField *) inTextField setAbsolutePath:inPath];
    
    if (inTextField==IBimagePath_)
    {
        [self updateImage:inTextField];
    }
    else
    if (inTextField==IBwelcomePath_)
    {
        [self updateWelcome:inTextField];
    }
    else
    if (inTextField==IBreadMePath_)
    {
        [self updateReadMe:inTextField];
    }
    else
    if (inTextField==IBlicensePath_)
    {
        [self updateLicense:inTextField];
    }

    
    return YES;
}

#pragma mark -

+ (NSDictionary *) cleanDictionary:(NSDictionary *) inDictionary forDocument:(NSDocument *) inDocument
{
    NSDictionary * tCleanedDictionary=nil;
    NSDictionary * tDictionary;
    NSArray * tKeys;
    int i,tCount;
    NSMutableDictionary * tWelcomeDictionary;
    NSMutableDictionary * tReadMeDictionary;
    NSMutableDictionary * tLicenseDictionary;
    NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    // Welcome
    
    tDictionary=[inDictionary objectForKey:RESOURCE_WELCOME_KEY];
    
    tKeys=[tDictionary allKeys];
    
    tCount=[tKeys count];
    
    tWelcomeDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tLanguage;
        NSDictionary * tLanguageDictionary;
        
        tLanguage=[tKeys objectAtIndex:i];
        
        tLanguageDictionary=[tDictionary objectForKey:tLanguage];
        
        if (tLanguageDictionary!=nil)
        {
            NSNumber * tNumber;
            
            tNumber=[tLanguageDictionary objectForKey:@"Mode"];
            
            if ([tNumber intValue]==1)
            {
                NSString * tPath;
                
                tPath=[tLanguageDictionary objectForKey:@"Path"];
                
                if (tPath!=nil)
                {
                    if ([tPath length]>0)
                    {
                        tNumber=[tLanguageDictionary objectForKey:@"Path Type"];
                        
                        if (tNumber!=nil)
                        {
                            if ([tNumber intValue]==kRelativeToProjectPath)
                            {
                                tPath=[tPath stringByAbsolutingWithPath:[inDocument folder]];
                            }
                        }
                        
                        if ([tFileManager fileExistsAtPath:tPath]==YES)
                        {
                            [tWelcomeDictionary setObject:tLanguageDictionary forKey:tLanguage];
                        }
                    }
                }
            }
        }
    }
    
    // ReadMe
    
    tDictionary=[inDictionary objectForKey:RESOURCE_README_KEY];
    
    tKeys=[tDictionary allKeys];
    
    tCount=[tKeys count];
    
    tReadMeDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tLanguage;
        NSDictionary * tLanguageDictionary;
        
        tLanguage=[tKeys objectAtIndex:i];
        
        tLanguageDictionary=[tDictionary objectForKey:tLanguage];
        
        if (tLanguageDictionary!=nil)
        {
            NSNumber * tNumber;
            
            tNumber=[tLanguageDictionary objectForKey:@"Mode"];
            
            if ([tNumber intValue]==1)
            {
                NSString * tPath;
                
                tPath=[tLanguageDictionary objectForKey:@"Path"];
                
                if (tPath!=nil)
                {
                    if ([tPath length]>0)
                    {
                        tNumber=[tLanguageDictionary objectForKey:@"Path Type"];
                        
                        if (tNumber!=nil)
                        {
                            if ([tNumber intValue]==kRelativeToProjectPath)
                            {
                                tPath=[tPath stringByAbsolutingWithPath:[inDocument folder]];
                            }
                        }
                        
                        if ([tFileManager fileExistsAtPath:tPath]==YES)
                        {
                            [tReadMeDictionary setObject:tLanguageDictionary forKey:tLanguage];
                        }
                    }
                }
            }
        }
    }
    
    // License
    
    tDictionary=[inDictionary objectForKey:RESOURCE_LICENSE_KEY];
    
    tKeys=[tDictionary allKeys];
    
    tCount=[tKeys count];
    
    tLicenseDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tLanguage;
        NSDictionary * tLanguageDictionary;
        
        tLanguage=[tKeys objectAtIndex:i];
        
        tLanguageDictionary=[tDictionary objectForKey:tLanguage];
        
        if (tLanguageDictionary!=nil)
        {
            NSNumber * tNumber;
            
            tNumber=[tLanguageDictionary objectForKey:@"Mode"];
            
            if ([tNumber intValue]==1)
            {
                NSString * tPath;
                
                tPath=[tLanguageDictionary objectForKey:@"Path"];
                
                if (tPath!=nil)
                {
                    if ([tPath length]>0)
                    {
                        tNumber=[tLanguageDictionary objectForKey:@"Path Type"];
                        
                        if (tNumber!=nil)
                        {
                            if ([tNumber intValue]==kRelativeToProjectPath)
                            {
                                tPath=[tPath stringByAbsolutingWithPath:[inDocument folder]];
                            }
                        }
                        
                        if ([tFileManager fileExistsAtPath:tPath]==YES)
                        {
                            [tLicenseDictionary setObject:tLanguageDictionary forKey:tLanguage];
                        }
                    }
                }
            }
            else
            {
                if ([tNumber intValue]==2)
                {
                    [tLicenseDictionary setObject:tLanguageDictionary forKey:tLanguage];
                }
            }
        }
    }
    
    tCleanedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[inDictionary objectForKey:RESOURCE_BACKGROUND_KEY],RESOURCE_BACKGROUND_KEY,
                                                                  tWelcomeDictionary,RESOURCE_WELCOME_KEY,
                                                                  tReadMeDictionary,RESOURCE_README_KEY,
                                                                  tLicenseDictionary,RESOURCE_LICENSE_KEY,
                                                                  nil];
    
    return tCleanedDictionary;
}

#pragma mark -

- (void) backgroundImageSettingsDidChange:(NSNotification *)notification
{
    NSDictionary * tInfoDictionary;
    
    tInfoDictionary=[notification userInfo];

    [IBimageAlignment_ selectItemAtIndex:[IBimageAlignment_ indexOfItemWithTag:[[tInfoDictionary objectForKey:@"Alignment"] intValue]]];
    
    [IBimageScaling_ selectCellWithTagNoScrolling:[[tInfoDictionary objectForKey:@"Scaling"] intValue]];
    
    [self updateImage:IBimageAlignment_];
}

@end
