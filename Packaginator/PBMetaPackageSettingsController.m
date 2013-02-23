/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBMetaPackageSettingsController.h"
#import "PBReferencedFileTextField.h"

#import "PBExtensionUtilities.h"

@implementation PBMetaPackageSettingsController

+ (PBMetaPackageSettingsController *) metaPackageSettingsController
{
    PBMetaPackageSettingsController * nController=nil;
    
    nController=[PBMetaPackageSettingsController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"MPSettings" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"MPSettings"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    NSDictionary * tDictionary;
    NSDictionary * tDisplayInformationDictionary;
    NSDictionary * tVersionDictionary;
    NSString * tValue;
    id tMenuItem;
    NSString * tPath;
    NSNumber * tNumber;
    
    [currentDescriptionLanguage_ release];
    
    currentDescriptionLanguage_=nil;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
    
    [self setProjectTree:inProjectTree];
    
    tDictionary=[objectNode_ settings];
    
    [self updateDescriptionLanguage];
    
    // Select the International Item if available
    
    tMenuItem=[IBdescriptionLanguage_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBdescriptionLanguage_ itemAtIndex:0];
    }
    
    [IBdescriptionLanguage_ selectItem:tMenuItem];
    
    [self switchDescriptionLanguage:IBdescriptionLanguage_];
    
    tDisplayInformationDictionary=[tDictionary objectForKey:@"Display Information"];
    
    tValue=[tDisplayInformationDictionary objectForKey:@"CFBundleName"];
    
    if (tValue!=nil)
    {
        [IBdisplayInformationDisplayName_ setStringValue:tValue];
    }
    else
    {
        [IBdisplayInformationDisplayName_ setStringValue:@""];
    }
    
    tValue=[tDisplayInformationDictionary objectForKey:@"CFBundleIdentifier"];
    
    if (tValue!=nil)
    {
        [IBdisplayInformationIdentifier_ setStringValue:tValue];
    }
    else
    {
        [IBdisplayInformationIdentifier_ setStringValue:@""];
    }
    
    tValue=[tDisplayInformationDictionary objectForKey:@"CFBundleGetInfoString"];
    
    if (tValue!=nil)
    {
        [IBdisplayInformationGetInfoString_ setStringValue:tValue];
    }
    else
    {
        [IBdisplayInformationGetInfoString_ setStringValue:@""];
    }
    
    tValue=[tDisplayInformationDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if (tValue!=nil)
    {
        [IBdisplayInformationShortVersion_ setStringValue:tValue];
    }
    else
    {
        [IBdisplayInformationShortVersion_ setStringValue:@""];
    }
    
    tPath=[tDisplayInformationDictionary objectForKey:@"CFBundleIconFile"];
    
    [IBdisplayInformationIconPath_ setDocument:inDocument];
    
    if (tPath==nil)
    {
        [IBdisplayInformationIconPath_ setPathType:kGlobalPath];
        
        [IBdisplayInformationIconPath_ setStringValue:@""];
    }
    else
    {
        int tType;
        
        tNumber=[tDisplayInformationDictionary objectForKey:@"CFBundleIconFile Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBdisplayInformationIconPath_ setPathType:tType];
            
        [IBdisplayInformationIconPath_ setStringValue:tPath];
    }
    
    tVersionDictionary=[tDictionary objectForKey:@"Version"];
    
    [IBversionMajor_ setObjectValue:[tVersionDictionary objectForKey:IFMajorVersion]];
    [IBversionMinor_ setObjectValue:[tVersionDictionary objectForKey:IFMinorVersion]];
}

- (void) treeWillChange
{
    [self updateDescription:nil];
    [self updateDisplayInformation:nil];
    [self updateVersion:nil];
    
    [super treeWillChange];
}

- (void) updateDescriptionLanguage
{
    NSDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSMutableArray * tMutableArray;

    tDictionary=[objectNode_ settings];
    
    tDescriptionDictionary=[tDictionary objectForKey:@"Description"];
    
    [IBdescriptionLanguage_ removeAllItems];
    
    tMutableArray=[[tDescriptionDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBdescriptionLanguage_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBdescriptionLanguage_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBdescriptionLanguage_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBdescriptionLanguage_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBdescriptionLanguage_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBdescriptionLanguage_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    textHasBeenUpdated_=YES;
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    if ([notification object]==IBdescriptionDescription_)
    {
        [self updateDescription:IBdescriptionDescription_];
    }
}

- (IBAction) updateDescription:(id) sender
{
    NSDictionary * tDictionary;
    NSMutableDictionary * tSettingsDictionary;
    NSMutableDictionary * tMutableDescriptionDictionary;
        
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[IBdescriptionTitle_ stringValue],IFPkgDescriptionTitle,
                                                           [IBdescriptionVersion_ stringValue],IFPkgDescriptionVersion,
                                                           [NSString stringWithString:[IBdescriptionDescription_ string]] ,IFPkgDescriptionDescription,
                                                           [IBdescriptionDeleteWarning_ stringValue],IFPkgDescriptionDeleteWarning,
                                                           nil];
    
    tSettingsDictionary=[objectNode_ settings];
    
    tMutableDescriptionDictionary=[[tSettingsDictionary objectForKey:@"Description"] mutableCopy];
    
    [tMutableDescriptionDictionary setObject:tDictionary
                                      forKey:currentDescriptionLanguage_];
    
    [tSettingsDictionary setObject:tMutableDescriptionDictionary
                            forKey:@"Description"];
                    
    [tMutableDescriptionDictionary release];
    
    if (sender!=nil)
    {
        if (sender==IBdescriptionTitle_ ||
            sender==IBdescriptionVersion_ ||
            sender==IBdescriptionDescription_ ||
            sender==IBdescriptionDeleteWarning_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

- (IBAction) updateDisplayInformation:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tDisplayInformationDictionary;
    
    tDisplayInformationDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[IBdisplayInformationDisplayName_ stringValue],@"CFBundleName",
                                                                             [IBdisplayInformationIdentifier_ stringValue],@"CFBundleIdentifier",
                                                                             [IBdisplayInformationGetInfoString_ stringValue],@"CFBundleGetInfoString",
                                                                             [IBdisplayInformationShortVersion_ stringValue],@"CFBundleShortVersionString",
                                                                             [IBdisplayInformationIconPath_ stringValue],@"CFBundleIconFile",
                                                                             [NSNumber numberWithInt:[IBdisplayInformationIconPath_ pathType]],@"CFBundleIconFile Path Type",
                                                                             nil];
    
    tDictionary=[objectNode_ settings];
    
    [tDictionary setObject:tDisplayInformationDictionary forKey:@"Display Information"];
    
    if (sender!=nil)
    {
        if (sender==IBdisplayInformationDisplayName_ ||
            sender==IBdisplayInformationIdentifier_ ||
            sender==IBdisplayInformationGetInfoString_ ||
            sender==IBdisplayInformationShortVersion_ ||
            sender==IBdisplayInformationIconPath_)
        {
            if (textHasBeenUpdated_==NO)
            {
                return;
            }
        }
        
        [self setDocumentNeedsUpdate:YES];
    }
}

- (IBAction) updateVersion:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tVersionDictionary;
    
    tVersionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[IBversionMajor_ intValue]],IFMajorVersion,
                                                                  [NSNumber numberWithInt:[IBversionMinor_ intValue]],IFMinorVersion,
                                                                  nil];
    
    tDictionary=[objectNode_ settings];
    
    [tDictionary setObject:tVersionDictionary forKey:@"Version"];
    
    if (sender!=nil)
    {
        if (sender==IBversionMajor_ ||
            sender==IBversionMinor_)
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

- (IBAction) switchDescriptionLanguage:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSDictionary * tLocalizedDescriptionDictionary;
    id tSelectedItem;
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
                              @selector(removeLocalizationSheetDidEnd:returnCode:contextInfo:),
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
    
    tDictionary=[objectNode_ settings];
    
    tDescriptionDictionary=[tDictionary objectForKey:@"Description"];
    
    oldLanguage=currentDescriptionLanguage_;
    
    currentDescriptionLanguage_=[[IBdescriptionLanguage_ selectedItem] title];
    
    if ([currentDescriptionLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentDescriptionLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentDescriptionLanguage_ retain];
    
    tLocalizedDescriptionDictionary=[tDescriptionDictionary objectForKey:currentDescriptionLanguage_];
    
    if (tLocalizedDescriptionDictionary!=nil)
    {
        NSString * tString;
            
        tString=[tLocalizedDescriptionDictionary objectForKey:IFPkgDescriptionTitle];
    
        if (tString==nil)
        {
            tString=@"";
        }
        
        [IBdescriptionTitle_ setStringValue:tString];
        
        tString=[tLocalizedDescriptionDictionary objectForKey:IFPkgDescriptionVersion];
    
        if (tString==nil)
        {
            tString=@"";
        }
        
        [IBdescriptionVersion_ setStringValue:tString];
        
        tString=[tLocalizedDescriptionDictionary objectForKey:IFPkgDescriptionDescription];
    
        if (tString==nil)
        {
            tString=@"";
        }
        
        [IBdescriptionDescription_ setString:tString];
        
        tString=[tLocalizedDescriptionDictionary objectForKey:IFPkgDescriptionDeleteWarning];
    
        if (tString==nil)
        {
            tString=@"";
        }
        
        [IBdescriptionDeleteWarning_ setStringValue:tString];
    }
}

- (IBAction) selectIconPath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[IBdisplayInformationIconPath_ absolutePath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"icns",
                                                                 nil]
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(iconOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) iconOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBdisplayInformationIconPath_ setAbsolutePath:[sheet filename]];
        
        [self updateDisplayInformation:IBversionMajor_];
    }
}

- (IBAction) revealIconInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBdisplayInformationIconPath_ stringValue] inFileViewerRootedAtPath:@""];
}

- (IBAction) openIcon:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace openFile:[IBdisplayInformationIconPath_ stringValue]];
}

#pragma mark -

- (void) removeLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tDictionary;
        NSMutableDictionary * tDescriptionDictionary;
        id tMenuItem;
        
        tDictionary=[objectNode_ settings];
        
        tDescriptionDictionary=[[tDictionary objectForKey:@"Description"] mutableCopy];
        
        [tDescriptionDictionary removeObjectForKey:currentDescriptionLanguage_];
        
        [tDictionary setObject:tDescriptionDictionary forKey:@"Description"];
        
        // Update PopupButton
        
        [IBdescriptionLanguage_ removeItemWithTitle:currentDescriptionLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBdescriptionLanguage_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBdescriptionLanguage_ itemAtIndex:0];
        }
        
        [IBdescriptionLanguage_ selectItem:tMenuItem];
        
        [self switchDescriptionLanguage:IBdescriptionLanguage_];
        
        [self updateDescription:IBdescriptionLanguage_];
    }
    else
    {
        [IBdescriptionLanguage_ selectItemWithTitle:currentDescriptionLanguage_];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction;
    
    tAction=[aMenuItem action];
    
    if (tAction==@selector(switchDescriptionLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentDescriptionLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    else
    if (tAction==@selector(revealIconInFinder:) ||
        tAction==@selector(openIcon:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBdisplayInformationIconPath_ stringValue];
        
        tFileManager=[NSFileManager defaultManager];
        
        return [tFileManager fileExistsAtPath:tPath];
    }
    
    return YES;
}

#pragma mark -

- (BOOL) shouldAddLocalization:(NSString *) inLocalization
{
    NSMutableDictionary * tDictionary;
    NSDictionary * tDescriptionDictionary;
    NSArray * tArray;
    
    int i,tCount;

    tDictionary=[objectNode_ settings];

    tDescriptionDictionary=[tDictionary objectForKey:@"Description"];

    tArray=[tDescriptionDictionary allKeys];
    
    tCount=[tArray count];
    
    // Check that the localization name is not already in the list
    
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
        NSDictionary * tDescriptionDictionary;
        NSMutableDictionary * tMutableDescriptionDictionary;

        tDictionary=[objectNode_ settings];
    
        tDescriptionDictionary=[tDictionary objectForKey:@"Description"];
        
        // Add the new language
        
        tMutableDescriptionDictionary=[tDescriptionDictionary mutableCopy];
        
        [tMutableDescriptionDictionary setObject:[PBObjectNode defaultDescriptionDictionaryWithName:[NODE_DATA(projectTree_) name]]
                                          forKey:localization];
        
        [tDictionary setObject:tMutableDescriptionDictionary
                        forKey:@"Description"];
        
        [tMutableDescriptionDictionary release];
        
        // Update the PopupButton
        
        [self updateDescriptionLanguage];
        
        [self updateDescription:IBdescriptionLanguage_];
        
        [IBdescriptionLanguage_ selectItemWithTitle:localization];
        
        [self switchDescriptionLanguage:IBdescriptionLanguage_];
    }
    else
    {
        [IBdescriptionLanguage_ selectItemWithTitle:currentDescriptionLanguage_];
    }
}

#pragma mark -

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBdisplayInformationIconPath_)
    {
        NSFileManager * tFileManager=[NSFileManager defaultManager];
        BOOL isDirectory;
    
        if ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==NO)
        {
            return ([PBExtensionUtilities extensionForIcnsFileAtPath:inPath]!=nil);
        }
    }
    
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    textHasBeenUpdated_=YES;
    
    [(PBReferencedFileTextField *) inTextField setAbsolutePath:inPath];
    
    if (inTextField==IBdisplayInformationIconPath_)
    {
        [self updateDisplayInformation:inTextField];
    }

    return YES;
}

@end
