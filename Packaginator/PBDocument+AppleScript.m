#import "PBDocument+AppleScript.h"

#import "PB_AS_Project.h"

@implementation PBDocument (AppleScript)

/* Attributes */

- (PB_AS_Project *) project
{
    PB_AS_Project * tProject=nil;
    
    if (tree_!=nil)
    {
        tProject=[[PB_AS_Project alloc] initWithDocument:self andTreeNode:(PBProjectTree *) [tree_ childAtIndex:0]];
    }
    
    return tProject;
}

#pragma mark -

/* Commands */

- (id) handleBuildProjectScriptCommand:(NSScriptCommand *) inCommand
{
    return [NSNumber numberWithBool:[self buildSynchronous:nil]];
}

- (void) handleCleanProjectScriptCommand:(NSScriptCommand *) inCommand
{
    [self cleanBuildFolder];
}

@end
