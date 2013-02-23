/* PBImportReporterController */

#import <Cocoa/Cocoa.h>

@interface PBImportReporterController : NSObject
{
    IBOutlet id IBarray_;
    
    IBOutlet id IBwindow_;
    
    NSArray * reportArray_;
    
    NSImage * metaPackageNodeImage_;
    NSImage * packageNodeImage_;
}

- (void) showSheetDelayedForWindow:(NSWindow *) inWindow;

- (void) beginReporterSheetForWindow:(NSWindow *) inWindow report:(NSArray *) inArray;

- (IBAction)endDialog:(id)sender;

@end
