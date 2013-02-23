#import <Cocoa/Cocoa.h>

@interface PBPreferencePaneController : NSObject
{
    IBOutlet id IBview_;
    
    NSUserDefaults * defaults_;
}

- (id) view;

- (void) updateWithDefaults;

- (IBAction) changeDefaults:(id) sender;

- (void) defaultsDidChanged:(NSNotification *) inNotification;

@end
