/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>
#import "PBAboutBoxController.h"

@interface PBApplicationController : NSObject
{
    PBAboutBoxController * aboutBoxController_;
    
    IBOutlet id IBimportAssistantWindow_;
    IBOutlet id IBimportFinishButton_;
    IBOutlet id IBimportNewLocation_;
    IBOutlet id IBimportNewName_;
    IBOutlet id IBimportOldLocation_;
}

-(IBAction) showAboutBox:(id) sender;
-(IBAction) showPreferences:(id) sender;

-(IBAction) newProject:(id) sender;

- (IBAction) showPackageFormatDocumentation:(id) sender;
- (IBAction) showUserGuide:(id) sender;
- (IBAction) showIcebergWebSite:(id) sender;

// Import Assistant

- (IBAction)importCancel:(id)sender;
- (IBAction)importFinish:(id)sender;

- (IBAction)selectNewLocation:(id)sender;

- (void) importAssistantSelectNewLocationPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction)selectOldProject:(id)sender;

- (void) importAssistantSelectOldProjectPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction)importProject:(id) sender;

@end
