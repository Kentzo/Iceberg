/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectAssistantStopPaneController.h"
#import "PBFileNameFormatter.h"
#import "PBProjectAssistantEngine.h"
#import "PBProjectAssistantController.h"

@implementation PBProjectAssistantStopPaneController

- (void) awakeFromNib
{
    PBFileNameFormatter *tFormatter;
    
    tFormatter=[PBFileNameFormatter new];
    
    [tFormatter setCantStartWithADot:NO];
    
    [IBprojectName_ setFormatter:tFormatter];
    
    [tFormatter release];
}

- (void) initPaneWithEngine:(id) inEngine
{
    NSString * tString;
    
    tString=[inEngine projectName];
    
    if (tString==nil)
    {
        tString=@"";
    }
    else
    {
        if ([tString length]>0)
        {
            [mainController_ setEnableNextButton:YES];
        }
    }
    
    [IBprojectName_ setStringValue:tString];
    
    tString=[inEngine projectDirectory];
    
    if (tString==nil)
    {
        tString=@"~/";
    }
    
    [IBprojectDirectory_ setStringValue:tString];
    
    [[IBprojectName_ window] makeFirstResponder:IBprojectName_];
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBprojectName_ ||
        [aNotification object]==IBprojectDirectory_)
    {
        if ([[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string] length]==0)
        {
            [mainController_ setEnableNextButton:NO];
        }
        else
        {
            [mainController_ setEnableNextButton:YES];
        }
        
        // A COMPLETER (meilleure gestion de la chaine vide dans l'un des champs)
    }
}

- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    if (control==IBprojectName_)
    {
        NSBeep();
    }
}

#pragma mark -

- (IBAction) selectDirectory:(id) sender
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
    
    [tOpenPanel beginSheetForDirectory:[[IBprojectDirectory_ stringValue] stringByExpandingTildeInPath]
                                  file:nil
                                 types:nil
                        modalForWindow:[IBprojectName_ window]
                         modalDelegate:self
                        didEndSelector:@selector(assistantOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) assistantOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBprojectDirectory_ setStringValue:[[sheet directory] stringByAbbreviatingWithTildeInPath]];
    }
}

#pragma mark -

- (BOOL) checkPaneValuesWithEngine:(id) inEngine
{
    NSString * tProjectDirectory;
    BOOL isDirectory;
    NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    tProjectDirectory=[[IBprojectDirectory_ stringValue] stringByExpandingTildeInPath];
    
    if ([tFileManager fileExistsAtPath:tProjectDirectory isDirectory:&isDirectory]==NO)
    {
        NSBeep();
        
        NSBeginAlertSheet(NSLocalizedString(@"The project directory you specified does not exist.",@"No comment"),
                            nil,
                            nil,
                            nil,
                            [IBprojectDirectory_ window],
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
                                [IBprojectDirectory_ window],
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
            
            tProjectName=[IBprojectName_ stringValue];
                
            // Check that there's not already a folder with that name
            
            tNewPath=[tProjectDirectory stringByAppendingPathComponent:tProjectName];
            
            if ([tFileManager fileExistsAtPath:tNewPath]==YES)
            {
                NSBeep();

                NSBeginAlertSheet(NSLocalizedString(@"A project already exists at this location.",@"No comment"),
                                    nil,
                                    nil,
                                    nil,
                                    [IBprojectDirectory_ window],
                                    nil,
                                    nil,
                                    nil,
                                    NULL,
                                    NSLocalizedString(@"Please select another location for the project.",@"No comment"));
            }
            else
            {
                [inEngine setProjectName:tProjectName];
    
                [inEngine setProjectDirectory:tProjectDirectory];
    
                return YES;
            }
        }
    }
        
    return NO;
}

@end
