#import "PBBuildTree.h"

@implementation PBBuildNodeData

+ (id) nodeWithTitle:(NSString *) inTitle type: (int) inType buildType:(int) inBuildType status:(int) inStatus
{
    return [[[PBBuildNodeData alloc] initWithTitle:inTitle type:inType buildType:inBuildType status:inStatus] autorelease];
}

+ (id) rootNode
{
    return [PBBuildNodeData nodeWithTitle:nil type:PBBUILDTREE_TYPE_ROOT buildType:-1 status:-1];
}

- (id) initWithTitle:(NSString *) inTitle type:(int) inType buildType:(int) inBuildType status:(int) inStatus
{
    self=[super init];
    
    if (self!=nil)
    {
        title_=[inTitle retain];
        
        type_=inType;
        
        buildType_=inBuildType;
        
        status_=inStatus;
    }
    
    return self;
}

- (void) dealloc
{
	[title_ release];

	[super dealloc];
}

- (BOOL) isLeaf
{
    switch(type_)
    {
        case PBBUILDTREE_TYPE_STEP:
            return YES;
        default:
            break;
    }
    
    return NO;
}

- (NSString *) title
{
    return [[title_ retain] autorelease]; 
}

- (void) setTitle:(NSString *) inTitle
{
    if (title_!=inTitle)
    {
        [title_ release];
        
        title_=[inTitle copy];
    }
}

- (int) buildType
{
    return buildType_;
}

- (void) setBuildType:(int) inBuildType
{
    buildType_=inBuildType;
}


- (int) type
{
    return type_;
}

- (void) setType:(int) inType
{
    type_=inType;
}

- (int) status
{
    return status_;
}

- (void) setStatus:(int) inStatus
{
    status_=inStatus;
}

@end

@implementation PBBuildTreeNode

+ (id) buildTree
{
    PBBuildTreeNode * rootNode=nil;
    
    rootNode=[[PBBuildTreeNode alloc] initWithData:[PBBuildNodeData rootNode]
                                            parent:nil
                                          children:[NSArray array]];
    
    return [rootNode autorelease];
}

@end