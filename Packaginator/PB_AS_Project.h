#import <Foundation/Foundation.h>
#import "PBProjectTree.h"

@class PB_AS_Component;

@class PBDocument;

@interface PB_AS_Project : NSObject
{
    PBProjectTree * treeNode_;
    
    PBDocument * document_;
}

- (id) initWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode;

+ (id) projectWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode;

- (PBDocument *) document;

- (PB_AS_Component *) rootComponent;



- (void) notifySettingsChanged;

- (id) projectOptionForKey:(NSString *) inKey;

- (void) setProjectOption:(id) inOption forKey:(NSString *) inKey;

- (NSString *) buildLocation;

- (void) setBuildLocation:(NSString *) aString;

- (NSNumber *) removeDSStore;

- (void) setRemoveDSStore:(NSNumber *) aNumber;

- (NSNumber *) removePBDevelopement;

- (void) setRemovePBDevelopement:(NSNumber *) aNumber;

- (NSNumber *) removeCVSFolder;

- (void) setRemoveCVSFolder:(NSNumber *) aNumber;

- (NSNumber *) buildPumaCompatible;

- (void) setBuildPumaCompatible:(NSNumber *) aNumber;

- (NSString *) comments;

- (void) setComments:(NSString *) aString;

@end
