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

#import "PBFileTree.h"

#import "PBSearchRuleEditorController.h"

@interface PBFileInspectorController : NSObject
{
    IBOutlet id IBcenteredView_;
    IBOutlet id IBfileInfoView_;
    
    IBOutlet id IBviewListView_;
    
    IBOutlet id IBsearchRulesInfoView_;
    IBOutlet id IBgeneralInfoView_;
    
    IBOutlet id IBaddRuleButton_;
    IBOutlet id IBeditRuleButton_;
    IBOutlet id IBremoveRuleButton_;
    
    id currentView_;
    
    IBOutlet id IBsource_;
    IBOutlet id IBdestination_;
        
    IBOutlet id IBgroup_;
    IBOutlet id IBname_;
    IBOutlet id IBowner_;
    IBOutlet id IBtype_;
    IBOutlet id IBpathType_;
    
    int groupIndex_;
    int ownerIndex_;
    int pathTypeIndex_;
    
    BOOL canEditPermission_;
    int cachedPermission_;
    char cachedStatType_;
    int mixedPermission_;
    
    IBOutlet id IBpermissions_;
    IBOutlet id IBpermissionsArray_;
    IBOutlet id IBspecialBitsArray_;
    
    IBOutlet id IBrulesArray_;
    
    IBOutlet id IBwindow_;
    
    NSArray * selectedFiles_;
    PBFileTree * selectedFile_;
    id fileController_;
    
    PBSearchRuleEditorController * searchRuleEditorController_;
    NSMutableArray * rulesArray_;
    
    NSArray * internalDragData_;
}

- (IBAction) switchPathType:(id) sender;

- (IBAction) switchOwner:(id) sender;
- (IBAction) switchGroup:(id) sender;

- (IBAction) showHideInspector:(id) sender;

- (IBAction) showInspector:(NSNotification *)notification;

- (void) fileSelectionDidChange:(NSNotification *)notification;

- (void) postFileAttributesNotification:(BOOL) fileNameDidChange;

- (void) setFileType;

- (IBAction) revealSourceInFinder:(id) sender;
- (IBAction) switchPermissions:(id) sender;

- (IBAction) setFolderName:(id) sender;

- (IBAction) addRule:(id) sender;
- (IBAction) editRule:(id) sender;
- (IBAction) removeRule:(id) sender;

- (void) ruleEditionDidEndWithDictionary:(NSDictionary *) inDictionary edit:(BOOL) inEdit;

- (NSString *) uniqueNameForRule;

@end
