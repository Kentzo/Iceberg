#import <Cocoa/Cocoa.h>

@interface NSApplication (AppleScript)

/* Attributes */

// Files

- (NSNumber *) defaultPermissionsMode;

- (void) setDefaultPermissionsMode:(NSNumber *) inNumber;

- (NSNumber *) defaultReferenceStyle;

- (void) setDefaultReferenceStyle:(NSNumber *) inNumber;

- (NSNumber *) showFilesCustomizationDialog;

- (void) setshowFilesCustomizationDialog:(NSNumber *) inNumber;

// Import

- (NSNumber *) copyPackageWhenImporting;

- (void) setCopyPackageWhenImporting:(NSNumber *) aNumber;

- (NSNumber *) importMetapackageComponents;

- (void) setImportMetapackageComponents:(NSNumber *) aNumber;

// Building

- (NSString *) scratchFolderLocation;

- (void) setScratchFolderLocation:(NSString *) aString;

- (NSNumber *) unsavedProject;

- (void) setUnsavedProject:(NSNumber *) aNumber;

- (NSNumber *) showWindow;

- (void) setShowWindow:(NSNumber *) aNumber;

- (NSNumber *) hideWindow;

- (void) setHideWindow:(NSNumber *) aNumber;

@end
