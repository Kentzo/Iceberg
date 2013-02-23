#import <Cocoa/Cocoa.h>
#import "PBController.h"

@interface PBMetaPackageController : PBController
{
}

- (id) metaPackageTree;

- (void) setMetaPackageTree:(PBProjectTree *) inMetaPackageTree;

@end
