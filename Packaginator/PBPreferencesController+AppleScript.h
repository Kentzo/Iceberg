#import "PBPreferencesController.h"

@interface PBPreferencesController (AppleScript)

- (NSNumber *) defaultReferenceStyle;
- (void) setDefaultReferenceStyle:(NSNumber *) inNumber;

- (BOOL) copyPackageWhenImporting;
- (void) setCopyPackageWhenImporting:(BOOL) aBool;

- (BOOL) importMetapackageComponents;
- (void) setImportMetapackageComponents:(BOOL) aBool;

- (BOOL) saveProjectBeforeBuilding;
- (void) setSaveProjectBeforeBuilding:(BOOL) aBool;

- (NSString *) scratchFolderLocation;
- (void) setScratchFolderLocation:(NSString *) aString;

@end
