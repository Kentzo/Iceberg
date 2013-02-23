/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectController.h"
//#import "PBFileTextField.h"
#import "PBReferencedFileTextField.h"

@implementation PBProjectController

+ (PBProjectController *) projectController
{
    PBProjectController * nController=nil;
    
    nController=[PBProjectController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"Project" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"Project"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (IBAction) selectBuildPath:(id) sender
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
    
    [tOpenPanel beginSheetForDirectory:[IBprojectBuildPath_ absolutePath]
                                  file:nil
                                 types:nil
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(buildOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) buildOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBprojectBuildPath_ setAbsolutePath:[sheet filename]];
        
        [self updateProject:IBprojectBuildPath_];
    }
}

- (IBAction) revealProjectBuildInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBprojectBuildPath_ absolutePath] inFileViewerRootedAtPath:@""];
}

- (void) treeWillChange
{
    [self updateProject:nil];
    
    [super treeWillChange];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    NSDictionary * tDictionary;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
    
    projectNode_=(PBProjectNode *) NODE_DATA(inProjectTree);
    
    [IBprojectBuildPath_ setNoCheck:YES];
    
    [IBprojectPath_ setStringValue:[inDocument fileName]];
    
    tDictionary=[projectNode_ settings];
    
    if (tDictionary!=nil)
    {
        NSNumber * tNumber;
        NSString * tPath;
        int tType;
        
        tPath=[tDictionary objectForKey:@"Build Path"];
        
        tNumber=[tDictionary objectForKey:@"Build Path Type"];
        
        tType=[tNumber intValue];
            
        if (tType==0)
        {
            tType=kGlobalPath;
        }
        
        [IBprojectBuildPath_ setDocument:inDocument];
        
        [IBprojectBuildPath_ _setPathType:tType];
        
        if (tPath!=nil)
        {
            [IBprojectBuildPath_ setStringValue:tPath];
        }
        else
        {
            [IBprojectBuildPath_ setStringValue:@""];
        }
        
        [IBprojectComment_ setString:[tDictionary objectForKey:@"Comment"]];
        
        tNumber=[tDictionary objectForKey:@"Remove .DS_Store"];
        
        if (tNumber!=nil)
        {
            [IBprojectRemoveDSStore_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
        }
        else
        {
            [IBprojectRemoveDSStore_ setState:NSOnState];
        }
        
        tNumber=[tDictionary objectForKey:@"Remove .pbdevelopment"];
        
        if (tNumber!=nil)
        {
            [IBprojectRemovePBDevelopment_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
        }
        else
        {
            [IBprojectRemovePBDevelopment_ setState:NSOnState];
        }
        
        tNumber=[tDictionary objectForKey:@"Remove CVS"];
        
        if (tNumber!=nil)
        {
            [IBprojectRemoveCVS_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
        }
        else
        {
            [IBprojectRemoveCVS_ setState:NSOffState];
        }
        
        tNumber=[tDictionary objectForKey:@"10.1 Compatibility"];
        
        if (tNumber!=nil)
        {
            [IBproject101_ setState:([tNumber boolValue]==YES) ? NSOnState : NSOffState];
        }
        else
        {
            [IBproject101_ setState:NSOnState];
        }
    }
}

- (IBAction) updateProject:(id) sender
{
    NSMutableDictionary * tSettingsDictionary;
    
    tSettingsDictionary=[objectNode_ settings];
    
    [tSettingsDictionary setObject:[IBprojectBuildPath_ stringValue]
                            forKey:@"Build Path"];
    
    [tSettingsDictionary setObject:[NSNumber numberWithInt:[IBprojectBuildPath_ pathType]]
                            forKey:@"Build Path Type"];
                                                                            
    [tSettingsDictionary setObject:[IBprojectComment_ string]
                            forKey:@"Comment"];
                            
    [tSettingsDictionary setObject:[NSNumber numberWithBool:([IBprojectRemoveDSStore_ state]==NSOnState) ? YES : NO]
                            forKey:@"Remove .DS_Store"];
                            
    [tSettingsDictionary setObject:[NSNumber numberWithBool:([IBprojectRemovePBDevelopment_ state]==NSOnState) ? YES : NO]
                            forKey:@"Remove .pbdevelopment"];
    
    [tSettingsDictionary setObject:[NSNumber numberWithBool:([IBprojectRemoveCVS_ state]==NSOnState) ? YES : NO]
                            forKey:@"Remove CVS"];
    
    [tSettingsDictionary setObject:[NSNumber numberWithBool:([IBproject101_ state]==NSOnState) ? YES : NO]
                            forKey:@"10.1 Compatibility"];
                            
    if (sender!=nil)
    {
        [self setDocumentNeedsUpdate:YES];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    if ([aMenuItem action]==@selector(revealBuildInFinder:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBprojectBuildPath_ absolutePath];
        
        tFileManager=[NSFileManager defaultManager];
        
        return [tFileManager fileExistsAtPath:tPath];
    }
    
    return YES;
}

#pragma mark -

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBprojectBuildPath_)
    {
        NSFileManager * tFileManager=[NSFileManager defaultManager];
        BOOL isDirectory;
    
        return ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==YES);
    }
    
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    textHasBeenUpdated_=YES;
    
    [(PBReferencedFileTextField *) inTextField setAbsolutePath:inPath];
    
    if (inTextField==IBprojectBuildPath_)
    {
        [self updateProject:inTextField];
    }
    
    return YES;
}

@end
