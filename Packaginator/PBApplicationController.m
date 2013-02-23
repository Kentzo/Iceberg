/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBApplicationController.h"
#import "PBProjectTree.h"

#import "PBFileNameFormatter.h"

#import "PBCheetahPackageMakerDecoder+Iceberg.h"
#import "PBJaguarPackageMakerDecoder+Iceberg.h"
#import "PBTigerPackageMakerDecoder+Iceberg.h"

#import "PBProjectAssistantController.h"

#import "PBPreferencesWindowController.h"

@implementation PBApplicationController

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Check that the SplitForks tool is installed
    
    /*NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    if ([tFileManager fileExistsAtPath:@"/Developer/Tools/SplitForks"]==NO)
    {
        BOOL isDirectory;
        
        if ([tFileManager fileExistsAtPath:@"/Developer" isDirectory:&isDirectory]==NO || isDirectory==NO)
        {
            NSRunInformationalAlertPanel(NSLocalizedString(@"Developer Tools not installed title",@"No comment"),
                                         NSLocalizedString(@"Developer Tools not installed message",@"No comment"),
                                         nil,
                                         nil,
                                         nil);
        }
        else
        {
            NSRunInformationalAlertPanel(NSLocalizedString(@"SplitForks tool not found title",@"No comment"),
                                         NSLocalizedString(@"SplitForks tool not found message",@"No comment"),
                                         nil,
                                         nil,
                                         nil);
        }
    }*/
    
    
    
    if (floor(NSAppKitVersionNumber)>663.0)
    {
        NSUserDefaults * tDefaults;
        
        tDefaults=[NSUserDefaults standardUserDefaults];
    
        [tDefaults setBool:[tDefaults boolForKey:@"IcebergShowAllFiles"] forKey:@"AppleShowAllFiles"];
    
        [tDefaults synchronize];
    }
}

#pragma mark -

- (void) awakeFromNib
{
    PBFileNameFormatter *tFormatter;
    
    aboutBoxController_=[PBAboutBoxController alloc];
    
    tFormatter=[PBFileNameFormatter new];
    
    [tFormatter setCantStartWithADot:NO];
    
    [IBimportNewName_ setFormatter:tFormatter];
    
    [tFormatter release];
}

#pragma mark -

-(IBAction) showAboutBox:(id) sender
{
    [aboutBoxController_ showAboutBoxWindow];
}

-(IBAction) showPreferences:(id) sender
{
    [PBPreferencesWindowController showPreferenceWindow];
}

-(IBAction) newProject:(id) sender
{
    [[PBProjectAssistantController sharedProjectAssistantController] createNewProject];
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBimportNewName_ ||
        [aNotification object]==IBimportNewLocation_ ||
        [aNotification object]==IBimportOldLocation_)
    {
        if ([[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string] length]==0)
        {
            if ([IBimportFinishButton_ isEnabled]==YES)
            {
                [IBimportFinishButton_ setEnabled:NO];
            }
        }
        else
        {
            if ([IBimportFinishButton_ isEnabled]==NO)
            {
                [IBimportFinishButton_ setEnabled:YES];
            }
        }
    }
}

- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    if (control==IBimportNewName_)
    {
        NSBeep();
    }
}

#pragma mark -

- (IBAction) showPackageFormatDocumentation:(id) sender
{
    NSURL * tURL;
    
    // Try local first
    
    tURL=nil;
    
    if (NSAppKitVersionNumber>=664.0)
    {
        NSFileManager * tFileManager;
        
        tFileManager=[NSFileManager defaultManager];
        
        if ([tFileManager fileExistsAtPath:NSLocalizedString(@"/Developer/Documentation/DeveloperTools/Conceptual/SoftwareDistribution/index.html",@"No comment")]==YES)
        {
            tURL=[NSURL fileURLWithPath:NSLocalizedString(@"/Developer/Documentation/DeveloperTools/Conceptual/SoftwareDistribution/index.html",@"No comment")];
        }
    }
    
    if (tURL==nil)
    {
        tURL=[NSURL URLWithString:NSLocalizedString(@"http://developer.apple.com/documentation/DeveloperTools/Conceptual/SoftwareDistribution/index.html",@"No comment")];
    }
    
    if (tURL!=nil)
    {
        [[NSWorkspace sharedWorkspace] openURL:tURL];
    }
}

- (IBAction) showUserGuide:(id) sender
{
    NSURL * tURL=nil;
    NSString * tPath;
    
    tPath=[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"documentation"];
    
    if (tPath!=nil)
    {
        tURL=[NSURL fileURLWithPath:tPath];
    }
    
    if (tURL!=nil)
    {
        [[NSWorkspace sharedWorkspace] openURL:tURL];
    }
}

- (IBAction) showIcebergWebSite:(id) sender
{
    NSURL * tURL=nil;
    
    tURL=[NSURL URLWithString:NSLocalizedString(@"http://s.sudre.free.fr/Software/Iceberg.html",@"No comment")];
    
    if (tURL!=nil)
    {
        [[NSWorkspace sharedWorkspace] openURL:tURL];
    }
}

#pragma mark -

- (IBAction)importCancel:(id)sender
{
    [NSApp stopModal];
    
    [IBimportAssistantWindow_ orderOut:self];
}

- (IBAction)importFinish:(id)sender
{
    NSFileManager * tFileManager;
    NSString * tDirectory;
    BOOL isDirectory;
    NSString * tOldProjectPath;
    
    tFileManager=[NSFileManager defaultManager];
    
    tOldProjectPath=[[IBimportOldLocation_ stringValue] stringByExpandingTildeInPath];
    
    if ([tFileManager fileExistsAtPath:tOldProjectPath]==NO)
    {
        NSBeep();
            
        NSBeginAlertSheet(NSLocalizedString(@"The PackageMaker project you specified does not exist.",@"No comment"),
                            nil,
                            nil,
                            nil,
                            IBimportAssistantWindow_,
                            nil,
                            nil,
                            nil,
                            NULL,
                            NSLocalizedString(@"Please select another project path.",@"No comment"));
    }
    else
    {
        tDirectory=[[IBimportNewLocation_ stringValue] stringByExpandingTildeInPath];
        
        if ([tFileManager fileExistsAtPath:tDirectory isDirectory:&isDirectory]==NO)
        {
            NSBeep();
            
            NSBeginAlertSheet(NSLocalizedString(@"The project directory you specified does not exist.",@"No comment"),
                                nil,
                                nil,
                                nil,
                                IBimportAssistantWindow_,
                                nil,
                                nil,
                                nil,
                                NULL,
                                NSLocalizedString(@"Please select another location for the project.",@"No comment"));
        }
        else
        {
            if (isDirectory==NO)
            {
                NSBeep();
            
                NSBeginAlertSheet(NSLocalizedString(@"The project directory you specified is not a directory.",@"No comment"),
                                    nil,
                                    nil,
                                    nil,
                                    IBimportAssistantWindow_,
                                    nil,
                                    nil,
                                    nil,
                                    NULL,
                                    NSLocalizedString(@"Please select another location for the project.",@"No comment"));
            }
            else
            {
                NSString * tProjectName;
                NSString * tNewPath;
                
                // Check the name of the file
                
                tProjectName=[IBimportNewName_ stringValue];
                    
                // Check that there's not already a folder with that name
                
                tNewPath=[tDirectory stringByAppendingPathComponent:tProjectName];
                
                if ([tFileManager fileExistsAtPath:tNewPath]==YES)
                {
                    NSBeep();
    
                    NSBeginAlertSheet(NSLocalizedString(@"A project already exists at this location.",@"No comment"),
                                        nil,
                                        nil,
                                        nil,
                                        IBimportAssistantWindow_,
                                        nil,
                                        nil,
                                        nil,
                                        NULL,
                                        NSLocalizedString(@"Please select another location for the project.",@"No comment"));
                }
                else
                {
                    NSData * tData;
                    
                    // Try to read the PackageMaker project (.pmsm, .pmsp, .pmproj)
                    
                    // Tiger Format
                    
                    tData=[NSData dataWithContentsOfFile:tOldProjectPath];
                    
                    if (tData!=nil)
                    {
                        id tObject;
                        NSMutableDictionary * tProjectDictionary;
                        
                        if ([[tOldProjectPath pathExtension] isEqualToString:@"pmproj"]==YES)
                        {
                            [NSKeyedUnarchiver setClass:[PBTigerMetaPackageDecoder class] forClassName:@"MPModel"];
                            
                            [NSKeyedUnarchiver setClass:[PBTigerSinglePackageDecoder class] forClassName:@"SPModel"];
        
                            [NSKeyedUnarchiver setClass:[PBTigerCorePackageDecoder class] forClassName:@"PModel"];
                            
                            [NSKeyedUnarchiver setClass:[PBTigerResources class] forClassName:@"Resources"];
                            
                            [NSKeyedUnarchiver setClass:[PBTigerLocalPath class] forClassName:@"LocalPath"];
                            
                            tObject=[NSKeyedUnarchiver unarchiveObjectWithData:tData];
                            
                            [tObject setSourcePath:[tOldProjectPath stringByDeletingLastPathComponent]];
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
                            tProjectDictionary=[tObject projectDictionary];
                    
                            if (tProjectDictionary!=nil)
                            {
                                NSString * tFinalProjectPath;
                                NSMutableDictionary * tFileAttributesDictionary;
                                
                                // Set the new name for the package if needed
                                
                                // A COMPLETER
                                
                                // Create the new project directory
                                
                                if ([tFileManager createDirectoryAtPath:tNewPath attributes:nil]==YES)
                                {
                                    // Create the new project file
                                    
                                    tFinalProjectPath=[tNewPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.packproj",tProjectName]];
                                    
                                    [tProjectDictionary writeToFile:tFinalProjectPath atomically:YES];
                            
                                    tFileAttributesDictionary=[[tFileManager fileAttributesAtPath:tFinalProjectPath traverseLink:NO] mutableCopy];
                                    
                                    [tFileAttributesDictionary setObject:[NSNumber numberWithBool:YES] forKey:NSFileExtensionHidden];
                
                                    [tFileManager changeFileAttributes:tFileAttributesDictionary
                                                                atPath:tFinalProjectPath];
                                                            
                                    [NSApp stopModal];
                    
                                    [IBimportAssistantWindow_ orderOut:self];
                                    
                                    // Open the new project
                                    
                                    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfFile:tFinalProjectPath
                                                                                                            display:YES];
                                }
                                else
                                {
                                    NSBeep();
                                    
                                    NSBeginAlertSheet(NSLocalizedString(@"Iceberg is not able to create the project folder.",@"No comment"),
                                        nil,
                                        nil,
                                        nil,
                                        IBimportAssistantWindow_,
                                        nil,
                                        nil,
                                        nil,
                                        NULL,
                                        [NSString stringWithFormat:NSLocalizedString(@"Check that you have write privileges for \"%@\".",@"No comment"),[tNewPath stringByDeletingLastPathComponent]]);
                                }
                            }
                            else
                            {
                                NSBeep();
                                
                                NSBeginAlertSheet(NSLocalizedString(@"Iceberg is not able to import this project.",@"No comment"),
                                        nil,
                                        nil,
                                        nil,
                                        IBimportAssistantWindow_,
                                        nil,
                                        nil,
                                        nil,
                                        NULL,
                                        [NSString stringWithFormat:NSLocalizedString(@"Check that the \"%@\" file is really a PackageMaker project.",@"No comment"),[tOldProjectPath lastPathComponent]]);
                            }
                        }
                        else
                        {
                            NSBeep();
                            
                            NSBeginAlertSheet(NSLocalizedString(@"Iceberg is not able to import this project.",@"No comment"),
                                        nil,
                                        nil,
                                        nil,
                                        IBimportAssistantWindow_,
                                        nil,
                                        nil,
                                        nil,
                                        NULL,
                                        NSLocalizedString(@"Iceberg does not support Distribution List yet.",@"No comment"));
                        }
                    }
                    else
                    {
                        NSBeep();
                        
                        // A COMPLETER
                    }
                }
            }
        } 
    }
    
}

- (IBAction)selectNewLocation:(id)sender
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
    
    [tOpenPanel beginSheetForDirectory:[[IBimportNewLocation_ stringValue] stringByExpandingTildeInPath]
                                  file:nil
                                 types:nil
                        modalForWindow:IBimportAssistantWindow_
                         modalDelegate:self
                        didEndSelector:@selector(importAssistantSelectNewLocationPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) importAssistantSelectNewLocationPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBimportNewLocation_ setStringValue:[[sheet directory] stringByAbbreviatingWithTildeInPath]];
    }
}

- (IBAction)selectOldProject:(id)sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setCanChooseDirectories:NO];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    [tOpenPanel beginSheetForDirectory:[[IBimportNewLocation_ stringValue] stringByExpandingTildeInPath]
                                  file:nil
                                 types:[NSArray arrayWithObjects:@"pmsp",@"pmsm",@"pmproj",nil]
                        modalForWindow:IBimportAssistantWindow_
                         modalDelegate:self
                        didEndSelector:@selector(importAssistantSelectOldProjectPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) importAssistantSelectOldProjectPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBimportOldLocation_ setStringValue:[sheet filename]];
    }
}

- (IBAction)importProject:(id) sender
{
    // Clean all values
    
    [IBimportOldLocation_ setStringValue:@""];
    
    [IBimportNewName_ setStringValue:@""];
    
    [IBimportNewLocation_ setStringValue:@"~/"];
    
    [IBimportAssistantWindow_ makeFirstResponder:IBimportOldLocation_];

    [IBimportFinishButton_ setEnabled:NO];
    
    [NSApp runModalForWindow:IBimportAssistantWindow_];
}

@end
