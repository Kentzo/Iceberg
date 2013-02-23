#import "PBProjectTree.h"

#import "PBDocument.h"

@class PB_AS_Settings;
@class PB_AS_Documents;
@class PB_AS_Project;

@interface PB_AS_Component : NSObject
{
    PBDocument * document_;
    
    PBProjectTree * treeNode_;
    
    PB_AS_Component * parent_;
    
    PB_AS_Project * project_;
}

- (id) initWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode;

+ (id) componentWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode;

- (PBDocument *) document;

- (NSString *) name;

- (void) setName:(NSString *) inName;

- (NSNumber *) state;

- (void) setState:(NSNumber *) inState;

- (NSNumber *) attribute;

- (void) setAttribute:(NSNumber *) inNumber;

- (void) setParent:(PB_AS_Component *) inParent;

- (void) setProject:(PB_AS_Project *) inProject;

- (PBProjectTree *) treeNode;

- (PB_AS_Settings *) settings;

- (PB_AS_Documents *) documents;

- (void) notifyComponentHierarchyChanged;

- (void) notifyComponentsChanged;

@end