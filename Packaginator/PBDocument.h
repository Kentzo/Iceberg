/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>
#import "PBProjectTree.h"
#import <MOKit/MOKit.h>

#import "PBProjectController.h"

#import "PBResourcesController.h"
#import "PBScriptsController.h"

#import "PBMetaPackageSettingsController.h"
#import "PBMetaPackageComponentsController.h"

#import "PBPackageSettingsController.h"
#import "PBPackageFilesController.h"

#import "PBPluginsController.h"

enum
{
    kPBBuildingNone,
    kPBBuildingLaunched,
    kPBBuildingStarted,
    kPBBuildingEnded
};

@interface PBDocument : NSDocument
{
    // Build Window Controller
    
    IBOutlet id buildWindowController_;

    // ---------------------------
    
    IBOutlet id IBdocumentStatus_;
    IBOutlet id IBdocumentProgressIndicator_;
    
    IBOutlet id IBoutlineView_;
    IBOutlet id IBrightView_;
    
    IBOutlet id IBname_;
    IBOutlet id IBicon_;
    IBOutlet id IBtype_;
    IBOutlet id IBpopupButton_;
    
    IBOutlet MOViewListView * IBviewListView_;
    
    PBProjectTree * tree_;
    
    NSArray * internalDragData_;
    
    BOOL canRenameItem_;
    
    BOOL isProgressIndicatorAnimating_;
    
    PBProjectController * projectController_;
    
    PBResourcesController * resourcesController_;
    PBScriptsController * scriptsController_;
	
	PBPluginsController * pluginsController_;
    
    PBMetaPackageSettingsController * metaPackageSettingsController_;
    
    PBMetaPackageComponentsController * componentsController_;
    
    PBPackageSettingsController * packageSettingsController_;
    
    PBPackageFilesController * packageFilesController_;
    float defaultFilesHeight_;
    
    PBProjectTree * currentMasterTree_;
    
    NSMutableArray * currentControllers_;
    
    BOOL selectionDidNotReallyChanged_;
    
    int buildingState_;
    BOOL launchAfterBuild_;
    
    float defaultLeftViewWidth_;
    float oldLeftViewWidth_;
}

- (PBProjectNode *) projectNode;
- (PBObjectNode *) mainPackageNode;

- (void) clearListView;

- (IBAction) newComponent:(id) sender;

- (IBAction) duplicate:(id) sender;

- (IBAction) rename:(id) sender;

- (void) removeDocControllerSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction) delete:(id) sender;

- (IBAction) deleteSelectedRowsOfOutlineView:(NSOutlineView *) outlineView;

- (IBAction) group:(id) sender;
- (IBAction) ungroup:(id) sender;

- (IBAction) sortByName:(id)sender;
- (IBAction) sortByAttribute:(id)sender;

- (IBAction) save:(id) sender;

- (IBAction) changeName:(id) sender;
- (IBAction) switchAttribute:(id) sender;

- (void) updateTree:(NSNotification *) aNotification;

- (void) documentDidChange:(NSNotification *)notification;

- (void) documentDidUpdate:(NSNotification *)notification;

- (void) documentStatusDidChange:(NSNotification *)notification;

- (void) builderNotification:(NSNotification *)notification;

- (IBAction) addFiles:(id)sender;
- (IBAction) newFolder:(id) sender;
- (IBAction) selectDefaultLocationPath:(id)sender;

- (IBAction) expandAll:(id)sender;

- (IBAction) expand:(id)sender;
- (IBAction) expandOneLevel:(id)sender;

- (IBAction) importPackages:(id) sender;

- (void) expandSelectedRowNotification:(NSNotification *)notification;

- (IBAction) showHideBuildWindow:(id) sender;

- (IBAction) preview:(id) sender;
- (IBAction) build:(id) sender;

- (BOOL) buildAsynchronous:(id) sender;
- (BOOL) buildSynchronous:(id) sender;

- (NSString *) temporaryProjectPath;

- (IBAction) buildAndRun:(id) sender;
- (IBAction) clean:(id) sender;
- (void) cleanSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void) cleanBuildFolder;

- (void) cleanComponent:(PBProjectTree *) inProjectTree inFolder:(NSString *) inPath;

- (IBAction) showHideHierarchy:(id) sender;

- (IBAction) showProjectPane:(id) sender;
- (IBAction) showSettingsPane:(id) sender;
- (IBAction) showDocumentsPane:(id) sender;
- (IBAction) showScriptsPane:(id) sender;
- (IBAction) showPluginsPane:(id) sender;
- (IBAction) showFilesComponentsPane:(id) sender;

- (void) showPaneAtRelativeIndex:(int) inRelativeIndex;

- (NSArray *) paneArrayFromSelectionForMasterTree:(PBProjectTree **) outMasterTree;

- (void) backgroundImageSettingsDidChange:(NSNotification *)notification;

- (void) refreshUIForProjectTree:(PBProjectTree *) inProjectTree;

// Need to be improved from a design point of view


@end
