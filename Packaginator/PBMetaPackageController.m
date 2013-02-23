#import "PBMetaPackageController.h"

@implementation PBMetaPackageController

- (id) metaPackageTree
{
    return [[projectTree_ retain] autorelease]; 
}

- (void) setMetaPackageTree:(PBProjectTree *) inMetaPackageTree
{
    if (projectTree_!=inMetaPackageTree)
    {
        [projectTree_ release];
        
        projectTree_=[inMetaPackageTree retain];
    }
}

@end
