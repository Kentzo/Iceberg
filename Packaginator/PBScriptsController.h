/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBController.h"
#import "PBRequirementsController.h"

#define PBSCRIPT_NONE	0
#define PBSCRIPT_ADD	1
#define PBSCRIPT_EDIT	2

@interface PBScriptsController : PBController
{
    IBOutlet id IBrequirementsArray_;
    
    NSArray * internalRequirementsDragData_;
    
    NSMutableArray * requirements_;
    
    IBOutlet id IBaddButton_;
    IBOutlet id IBdeleteButton_;
    IBOutlet id IBeditButton_;
    
    IBOutlet id IBchooseButton_;
    IBOutlet id IBscriptsArray_;
    
    NSArray * installationScriptsKeysArray_;
    NSMutableDictionary * scripts_;
    
    IBOutlet id IBresourcesArray_;
    IBOutlet id IBresourcesLanguage_;
    IBOutlet id IBdeleteResourceButton_;
    
    NSString * currentResourcesLanguage_;
    NSMutableArray * resources_;
    
    int selectedInstallationScript_;
    
    NSFileManager * fileManager_;
    
    int requirementDialogMode_;
    PBRequirementsController * requirementsController_;
}

+ (PBScriptsController *) scriptsController;

- (IBAction)selectInstallationScriptsPath:(id)sender;
- (void) installationScriptsOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (IBAction) updateInstallationScripts:(id) sender;

- (IBAction) revealScriptsInFinder:(id) sender;
- (IBAction) openScriptsInEditor:(id) sender;

- (IBAction)switchResourcesLanguage:(id)sender;
- (IBAction) updateResources:(id) sender;
- (void) updateResourcesLanguage;

- (void) removeResourcesLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void) requirementDidChanged;

- (IBAction) updateRequirements:(id) sender;

- (IBAction) addRequirements:(id)sender;
- (IBAction) editRequirements:(id)sender;
- (IBAction) deleteRequirements:(id)sender;

- (NSString *) uniqueNameForRequirement;

- (IBAction) addResources:(id)sender;
- (void) resourcesOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction) deleteResources:(id)sender;
- (IBAction) revealResourcesInFinder:(id) sender;

- (void) removeResourcesSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void) removeRequirementsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
