#import "PBBundleVersionFilterPlugInController.h"

@implementation PBBundleVersionFilterPlugInController

- (NSView *) previousKeyView
{
    return IBminVersion_;
}

- (void) setNextKeyView:(NSView *) inView
{
    [IBmaxVersion_ setNextKeyView:inView];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary
{
    NSString * tMinVersion;
    NSString * tMaxVersion;
    
    tMinVersion=[inDictionary objectForKey:@"minVersion"];
    
    if (tMinVersion==nil)
    {
        tMinVersion=@"";
    }
    
    [IBminVersion_ setStringValue:tMinVersion];
    
    tMaxVersion=[inDictionary objectForKey:@"maxVersion"];
    
    if (tMaxVersion==nil)
    {
        tMaxVersion=@"";
    }
    
    [IBmaxVersion_ setStringValue:tMaxVersion];
}

- (NSDictionary *) dictionary
{
    NSString * tMinVersion;
    NSString * tMaxVersion;
    NSMutableDictionary * tMutableDictionary;
    
    tMinVersion=[IBminVersion_ stringValue];
    
    tMaxVersion=[IBmaxVersion_ stringValue];
    
    tMutableDictionary=[NSMutableDictionary dictionary];
    
    [tMutableDictionary setObject:@"BundleVersionFilter" forKey:@"searchPlugin"];
    
    if ([tMinVersion length]>0)
    {
        [tMutableDictionary setObject:tMinVersion forKey:@"minVersion"];
    }
    
    if ([tMaxVersion length]>0)
    {
        [tMutableDictionary setObject:tMaxVersion forKey:@"maxVersion"];
    }
    
    return tMutableDictionary;
}

- (BOOL) hasIncorrectValues
{
    NSString * tMinVersion;
    NSString * tMaxVersion;
    
    tMinVersion=[IBminVersion_ stringValue];
    tMaxVersion=[IBmaxVersion_ stringValue];
    
    if ([tMinVersion length]==0 && [tMinVersion length]==0)
    {
        [self showAlertWithTitle:NSLocalizedString(@"At lest one version is required",@"No comment")
                         message:NSLocalizedString(@"You need to provide at least one of the value : either the minimum or maximum version.",@"No comment")];
    
        return YES;
    } 
    
    return NO;
}


@end
