#import "PB_AS_Component.h"

@interface PB_AS_Metapackage : PB_AS_Component
{
    NSMutableArray * components_;
}

+ (id) metapackageWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode;

- (NSString *) componentsLocation;

- (void) setComponentsLocation:(NSString *) inComponentsLocation;

// Components

/*- (unsigned) countOfOrderedComponents;

- (id) objectInOrderedComponentsAtIndex:(unsigned) index;*/

- (NSMutableArray *) orderedComponents;

- (void) setOrderedComponents:(NSMutableArray *) inArray;

- (id) valueWithName:(NSString *)name inPropertyWithKey:(NSString *) inKey;

- (id) valueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey;

- (void) replaceValueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey withValue:(id)value;

- (void) insertValue:(id)value atIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey;

- (void) removeValueAtIndex:(unsigned)index fromPropertyWithKey:(NSString *) inKey;

- (void) insertValue:(id)value inPropertyWithKey:(NSString *) inKey;

//- (id)handleMoveCommand:(NSScriptCommand *)command;

@end
