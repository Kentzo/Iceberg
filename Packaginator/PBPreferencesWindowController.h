#import <Cocoa/Cocoa.h>

@interface PBPreferencesWindowController : NSObject
{
    IBOutlet id IBwindow_;
    
    NSDictionary * panesDictionary_;
    
    NSMutableDictionary * preferencePaneControllerDictionary_;
    
    id currentView_;
}

- (void) showPane:(id) sender;

+ (void) showPreferenceWindow;

@end
