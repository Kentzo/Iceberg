#import "PBLaunchServicesLookupPlugInController.h"
#import "PBOSTypeFormatter.h"

@implementation PBLaunchServicesLookupPlugInController

- (void) awakeFromNib
{
    PBOSTypeFormatter * tOSTypeFormatter;
    
    tOSTypeFormatter=[PBOSTypeFormatter new];
    
    [IBcreator_ setFormatter:tOSTypeFormatter];
    
    [tOSTypeFormatter release];
}

- (NSView *) previousKeyView
{
    return IBidentifier_;
}

- (void) setNextKeyView:(NSView *) inView
{
    [IBcreator_ setNextKeyView:inView];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary
{
    NSString * tCreator;
    NSString * tIdentifier;
    
    tIdentifier=[inDictionary objectForKey:@"identifier"];
    
    if (tIdentifier==nil)
    {
        tIdentifier=@"";
    }
    
    [IBidentifier_ setStringValue:tIdentifier];
    
    tCreator=[inDictionary objectForKey:@"creator"];
    
    if (tCreator==nil)
    {
        tCreator=@"";
    }
    
    [IBcreator_ setStringValue:tCreator];
}

- (NSDictionary *) dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"LaunchServicesLookup",@"searchPlugin",
                                                      [IBcreator_ stringValue],@"creator",
                                                      [IBidentifier_ stringValue],@"identifier",
                                                      nil];
}

- (BOOL) hasIncorrectValues
{
    NSString * tOSType;
    NSString * tIdentifier;
    
    tIdentifier=[IBidentifier_ stringValue];
    
    if ([tIdentifier length]==0)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The identifier value is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the identifier you entered and fix it.",@"No comment")];
    
        return YES;
    } 
    
    tOSType=[IBcreator_ stringValue];
    
    if (strlen([tOSType UTF8String])!=4)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The creator code is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the creator code you entered and fix it.",@"No comment")];
    }
    
    return NO;
}

- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    NSBeep();
}

@end
