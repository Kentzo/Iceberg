#import "PBSearchPlugInController.h"

@interface PBBundleIdentifierSearchPlugInController : PBSearchPlugInController
{
    IBOutlet id IBaddButton_;
    IBOutlet id IBexcludedDirsArray_;
    IBOutlet id IBidentifier_;
    IBOutlet id IBmaxDepthField_;
    IBOutlet id IBmaxDepthStepper_;
    IBOutlet id IBremoveButton_;
    IBOutlet id IBstartingPoint_;
    IBOutlet id IBsuccessCasePopupButton_;
    
    NSMutableArray * excludedArray_;
}

- (IBAction)addDirectory:(id)sender;

- (IBAction)removeDirectory:(id)sender;

- (void) deleteSelectedRowsOfTableView:(NSTableView *) sender;

- (void) removeDirectorySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
