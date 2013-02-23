/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBPreferencesController.h"
#import "PBFileTextField.h"
#import "PBSharedConst.h"

@implementation PBPreferencesController

- (void) awakeFromNib
{
    NSUserDefaults * tDefaults;
    NSDictionary * tDictionary;
    NSTextFieldCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    NSString * tPath;
    int tDefaultReferenceStyle;
    id tMenuItem;
    NSImage * tImage;
    
    [IBkeywordsArray_ setIntercellSpacing:NSMakeSize(3,0)];
    
    // Key
    
    tableColumn = [IBkeywordsArray_ tableColumnWithIdentifier: @"Key"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
    
    // Value
    
    tableColumn = [IBkeywordsArray_ tableColumnWithIdentifier: @"Value"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    
    tMenuItem=[IBdefaultReferenceStyle_ itemAtIndex:[IBdefaultReferenceStyle_ indexOfItemWithTag:kRelativeToProjectPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tMenuItem=[IBdefaultReferenceStyle_ itemAtIndex:[IBdefaultReferenceStyle_ indexOfItemWithTag:kGlobalPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    tDefaultReferenceStyle=[tDefaults integerForKey:@"Default Reference Style"];
    
    if (tDefaultReferenceStyle==0)
    {
        tDefaultReferenceStyle=kGlobalPath;
        
        [tDefaults setInteger:tDefaultReferenceStyle forKey:@"Default Reference Style"];
        
        [tDefaults synchronize];
    }
    
    [IBdefaultReferenceStyle_ selectItemAtIndex:[IBdefaultReferenceStyle_ indexOfItemWithTag:tDefaultReferenceStyle]];
    
    [IBcopyPackage_ setState:([tDefaults boolForKey:@"CopyPackageOnImport"]==YES) ? NSOnState : NSOffState];
    
    [IBimportMetapackageComponents_ setState:([tDefaults boolForKey:@"ImportMetapackageComponents"]==YES) ? NSOnState : NSOffState];
    
    [IBsaveBuild_ setState:([tDefaults boolForKey:@"SaveBeforeBuild"]==YES) ? NSOnState : NSOffState];
    
    //[IBshowAllFiles_ setState:([tDefaults boolForKey:@"IcebergShowAllFiles"]==YES) ? NSOnState : NSOffState];
    
    tDictionary=[tDefaults dictionaryForKey:@"Keywords"];
    
    if (tDictionary!=nil)
    {
        keywordsDictionary_=[tDictionary mutableCopy];
    }
    else
    {
        keywordsDictionary_=[[NSMutableDictionary alloc] initWithCapacity:2];
        
        [keywordsDictionary_ setObject:@"My Great Company" forKey:@"COMPANY_NAME"];
        
        [keywordsDictionary_ setObject:@"com.mygreatcompany.pkg" forKey:@"COMPANY_PACKAGE_IDENTIFIER"];
        
        [tDefaults setObject:keywordsDictionary_ forKey:@"Keywords"];
        
        [tDefaults synchronize];
    }
    
    keysArray_=[[keywordsDictionary_ allKeys] mutableCopy];
    
    [keysArray_ sortUsingSelector:@selector(compare:)];
    
    [IBkeywordsArray_ reloadData];
    
    tPath=[tDefaults objectForKey:@"Scratch Path"];
    
    if (tPath==nil)
    {
        tPath=@"/tmp";
    }
    
    [IBscratchPath_ setStringValue:tPath];
    
    /*if (floor(NSAppKitVersionNumber)<=663.0)
    {
        // Not needed on version prior to Mac OS X 10.3
        
        [IBshowAllFiles_ setEnabled:NO];
    }*/
}

#pragma mark -

- (IBAction) selectScratchPath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:NO];
    [tOpenPanel setCanChooseDirectories:YES];
    
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    if ([tOpenPanel respondsToSelector:@selector(setCanCreateDirectories:)]==YES)
    {
        [tOpenPanel setCanCreateDirectories:YES];
    }
    else if ([tOpenPanel respondsToSelector:@selector(_setIncludeNewFolderButton:)]==YES)
    {
        [tOpenPanel _setIncludeNewFolderButton:YES];
    }
    
    [tOpenPanel beginSheetForDirectory:[[IBscratchPath_ stringValue] stringByExpandingTildeInPath]
                                  file:nil
                                 types:nil
                        modalForWindow:IBwindow_
                         modalDelegate:self
                        didEndSelector:@selector(scratchOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (IBAction) revealScratchInFinder:(id) sender
{
     NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBscratchPath_ stringValue] inFileViewerRootedAtPath:@""];
}

- (void) scratchOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBscratchPath_ setStringValue:[sheet filename]];
        
    	[self updatePreferences:IBscratchPath_];
    }
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [keysArray_ count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    NSString * tKey;
    
    tKey=[keysArray_ objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString: @"Key"])
    {
        return tKey;
    }
    else
    if ([[aTableColumn identifier] isEqualToString: @"Value"])
    {
    	return [keywordsDictionary_ objectForKey:tKey];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if ([[tableColumn identifier] isEqualToString: @"Value"])
    {
        NSUserDefaults * tDefaults;
        NSString * tKey;
        
        tDefaults=[NSUserDefaults standardUserDefaults];
        
    	tKey=[keysArray_ objectAtIndex:row];
        
        [keywordsDictionary_ setObject:object forKey:tKey];
        
        [tDefaults setObject:keywordsDictionary_ forKey:@"Keywords"];
        
        [tDefaults synchronize];
    }
}

#pragma mark -

- (IBAction) updatePreferences:(id) sender
{
    NSUserDefaults * tDefaults;
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    [tDefaults setInteger:[[IBdefaultReferenceStyle_ selectedItem] tag] forKey:@"Default Reference Style"];
    
    [tDefaults setBool:([IBcopyPackage_ state]==NSOnState) forKey:@"CopyPackageOnImport"];
    
    [tDefaults setBool:([IBimportMetapackageComponents_ state]==NSOnState) forKey:@"ImportMetapackageComponents"];
    
    [tDefaults setBool:([IBsaveBuild_ state]==NSOnState) forKey:@"SaveBeforeBuild"];
    
    [tDefaults setObject:[IBscratchPath_ stringValue] forKey:@"Scratch Path"];
    
    //[tDefaults setBool:([IBshowAllFiles_ state]==NSOnState) forKey:@"IcebergShowAllFiles"];
    
    [tDefaults synchronize];
}

- (IBAction) showPreferencesDialog:(id) sender
{
    
    if (IBwindow_==nil)
    {
        if ([NSBundle loadNibNamed:@"PBPreferences" owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"PBAboutBox"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    if ([IBwindow_ isVisible]==NO)
    {
        [IBwindow_ center];
    
        [IBwindow_ makeKeyAndOrderFront:nil];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
    if ([aMenuItem action]==@selector(revealScratchInFinder:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBscratchPath_ stringValue];
        
        tFileManager=[NSFileManager defaultManager];
        
        return [tFileManager fileExistsAtPath:tPath];
    }
    
    return YES;
}

#pragma mark -

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBscratchPath_)
    {
        NSFileManager * tFileManager=[NSFileManager defaultManager];
        BOOL isDirectory;
    
        return ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==YES);
    }
    
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBscratchPath_)
    {
        [IBscratchPath_ setStringValue:inPath];
        
    	[self updatePreferences:IBscratchPath_];
    }
    
    return YES;
}

@end
