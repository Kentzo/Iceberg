/*
Copyright (c) 2004-2006, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>
#import "PBController.h"

@interface PBMetaPackageComponentsController : PBController
{
    IBOutlet id IBimportReporter_;
    
    IBOutlet id IBarray_;
    
    IBOutlet id IBrelativeTextField_;
    IBOutlet id IBrelativePopupButton_;
    
    IBOutlet id IBnameTextField_;
    IBOutlet id IBtypePopupButton_;
    IBOutlet id IBattributePopupButton_;
    IBOutlet id IBokButton_;
    
    PBProjectTree * componentsTree_;
    
    NSImage * metaPackageNodeImage_;
    NSImage * packageNodeImage_;
    
    NSArray * internalDragData_;
    
    NSString * projectImportPath_;
    BOOL copyPackage_;
    NSMutableArray * copiedPaths_;
    BOOL replaceAll_;
    NSWindow * window_;
}

+ (PBMetaPackageComponentsController *) metaPackageComponentsController;

- (void) setWindow:(NSWindow *) aWindow;

- (void) endDialog:(id) sender;

- (IBAction)newComponent:(id)sender;

- (IBAction)importPackages:(id)sender;

- (void) importPackagesPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction) deleteSelectedRowsOfTableView:(NSTableView *) tableView;

- (IBAction) delete:(id)sender;

- (void) sort:(id) sender usingSelector:(SEL) inSelector;
- (IBAction) sortByName:(id)sender;
- (IBAction) sortByAttribute:(id)sender;

- (void) updateView:(NSNotification *) aNotification;

- (void) removeSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void) updateComponents:(id) sender;

- (void) switchRelative:(id) sender;

- (void) setRelativePopUpButtonWithPath:(NSString *) inPath;

- (NSMutableArray *) importPackagesWithArray:(NSArray *) inArray atRow:(int) inRow forComponentTree:(PBProjectTree *) inComponentTree andDocument:(id) inDocument;

+ (unsigned int) validateDropOfFiles:(id <NSDraggingInfo>)info inTree:(PBProjectTree *) inProjectTree;

+ (BOOL) validateFiles:(NSArray *) inFilesArray;

- (NSString *) finalPathForImportedComponentAtPath:(NSString *) inPath;

@end
