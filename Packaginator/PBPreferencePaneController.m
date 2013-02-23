#import "PBPreferencePaneController.h"

@implementation PBPreferencePaneController

- (void) awakeFromNib
{
    defaults_=[NSUserDefaults standardUserDefaults];
    
    [self updateWithDefaults];
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        
    }
    
    return self;
}

- (void) dealloc
{
    // Remove observer
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

#pragma mark -

- (id) view
{
    return IBview_;
}

- (void) updateWithDefaults
{
    // To be overriden
}

- (IBAction) changeDefaults:(id) sender
{
    // To be overriden
}

- (void) defaultsDidChanged:(NSNotification *) inNotification
{
    [self updateWithDefaults];
}

@end
