#import <Foundation/Foundation.h>
#import "TreeNode.h"

#define PBBUILDTREE_TYPE_ROOT		0
#define PBBUILDTREE_TYPE_COMPONENT	1
#define PBBUILDTREE_TYPE_STEP		2
#define PBBUILDTREE_TYPE_STEP_FAILED	3
#define PBBUILDTREE_TYPE_PROJECT	4

#define PBBUILDTREE_STATUS_RUNNING	0
#define PBBUILDTREE_STATUS_SUCCESS	1
#define PBBUILDTREE_STATUS_FAILURE	2

#define PBBUILDTREE_NODE(n)	((PBBuildTreeNode*) n)
#define PBBUILDNODE_DATA(n) 	((PBBuildNodeData *)[PBBUILDTREE_NODE((n)) nodeData])

@interface PBBuildNodeData: TreeNodeData
{
    int status_;
    int type_;
    int buildType_;
    NSString * title_;
}

+ (id) nodeWithTitle:(NSString *) inTitle type: (int) inType buildType:(int) inBuildType status:(int) inStatus;

- (id) initWithTitle:(NSString *) inTitle type: (int) inType buildType:(int) inBuildType status:(int) inStatus;

+ (id) rootNode;

- (BOOL) isLeaf;

- (NSString *) title;

- (void) setTitle:(NSString *) inTitle;

- (int) buildType;

- (void) setBuildType:(int) inBuildType;

- (int) type;

- (void) setType:(int) inType;

- (int) status;

- (void) setStatus:(int) inStatus;

@end

@interface PBBuildTreeNode : TreeNode
{

}

+ (id) buildTree;

@end
