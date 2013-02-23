#import <Cocoa/Cocoa.h>

#import "PBBuildTree.h"

@interface PBBuildWindowController : NSObject
{
    IBOutlet id IBoutlineView_;
    IBOutlet id IBdetailView_;
    IBOutlet id IBsplitView_;
    
    IBOutlet id IBstatusLabel_;
    
    NSDictionary * statusAttributesDictionary_;
    NSDictionary * explanationAttributesDictionary_;
    
    IBOutlet id IBwindow_;
    
    IBOutlet id document_;
    
    PBBuildTreeNode * tree_;
    
    PBBuildTreeNode * currentBuildNode_;
    
    NSUserDefaults * defaults_;
}

- (NSWindow *) window;

- (void) buildDidStart:(NSNotification *)notification;

- (void) builderNotification:(NSNotification *)notification;

- (void) updateBuildTreeWithCode:(int) inStatusCode arguments:(NSArray *) inArguments;

- (IBAction)hideWindow:(id)sender;

- (IBAction)showWindow:(id)sender cleanWindow:(BOOL) inCleanWindow;

- (IBAction) build:(id) sender;
- (IBAction) buildAndRun:(id) sender;
- (IBAction) clean:(id) sender;
- (IBAction) preview:(id) sender;

- (IBAction) showHideBuildWindow:(id) sender;

@end
