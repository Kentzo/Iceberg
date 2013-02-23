/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBController.h"
#import "PBFileTree.h"

#import "PBDirectoryServicesManager.h"

@interface PBPackageFilesController : PBController
{
    IBOutlet id IBsetButton_;
    IBOutlet id IBdefaultLocationPath_;
    IBOutlet id IBoutlineView_;
    
    IBOutlet id IBcompress_;
    IBOutlet id IBsplitForks_;
    
    IBOutlet id IBimportedView_;
    IBOutlet id IBimportedReferencePopupButton_;
    
    PBFileTree * fileTree_;
    
    PBFileTree * defaultLocation_;
    
    NSMutableArray * internalDragArray_;
    
    BOOL isImported_;
    
    BOOL hierarchyChanged_;

    NSColor * blackColor_;
    
    NSColor * redColor_;
    
    IBOutlet id IBfileSheet_;
    IBOutlet id IBownerAndGroup_;
    IBOutlet id IBreferenceStyle_;

    PBFileTree * parentFileTree_;
    
    PBDirectoryServicesManager * directoryServicesManager_;
	
	NSUserDefaults * defaults_;
}

+ (PBPackageFilesController *) packageFilesController;

- (IBAction) updateFiles:(id) sender;

- (BOOL) defaultRestoreForItem:(id) inItem;

- (IBAction)addFiles:(id)sender;

- (void) addFilesPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction)selectDefaultLocationPath:(id)sender;

- (IBAction) newFolder:(id) sender;

- (IBAction) expandAll:(id) sender;

- (void) delayedExpandAll:(id) inObject;

- (IBAction) expand:(id) sender;

- (void) delayedExpand:(id) inObject;

- (IBAction) expandOneLevel:(id) sender;

- (IBAction) contract:(id) sender;

- (IBAction) delete:(id)sender;

- (void) removeFileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction) showInfo:(id)sender;
- (IBAction) revealInFinder:(id) sender;

- (IBAction) deleteSelectedRowsOfOutlineView:(NSOutlineView *) outlineView;

- (void) postSelectionStatus;

- (void) beginFileSheet:(NSArray *) inFiles;
- (IBAction) endFileSheet:(id) sender;
- (void) fileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void) _addFiles:(NSArray *) inFilesArray keepOwnerAndGroup:(BOOL) inKeepOwnerAndGroup referenceStyle:(int) inReferenceStyle;

@end
