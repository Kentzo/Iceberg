#import "NSApplication+AppleScript.h"
#import "PBApplicationController.h"

#import "PBPreferencePaneFilesController+Constants.h"
#import "PBPreferencePaneImportController+Constants.h"
#import "PBPreferencePaneBuildController+Constants.h"
#import "PBPreferencePaneTemplateKeywordsController+Constants.h"

@implementation NSApplication (AppleScript)

/* Attributes */

- (NSNumber *) copyPackageWhenImporting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_IMPORT_COPY_COMPONENT];
}

- (void) setCopyPackageWhenImporting:(NSNumber *) aNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:aNumber forKey:PBPREFERENCEPANE_IMPORT_COPY_COMPONENT];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_IMPORT_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) importMetapackageComponents
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_IMPORT_SUBCOMPONENTS];
}

- (void) setImportMetapackageComponents:(NSNumber *) aNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:aNumber forKey:PBPREFERENCEPANE_IMPORT_SUBCOMPONENTS];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_IMPORT_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) unsavedProject
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
}

- (void) setUnsavedProject:(NSNumber *) aNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:aNumber forKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_BUILD_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) showWindow
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW];
}

- (void) setShowWindow:(NSNumber *) aNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:aNumber forKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_BUILD_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) hideWindow
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW];
}

- (void) setHideWindow:(NSNumber *) aNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:aNumber forKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_BUILD_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSString *) scratchFolderLocation
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_BUILD_SCRATCH_LOCATION];
}

- (void) setScratchFolderLocation:(NSString *) aString
{
    [[NSUserDefaults standardUserDefaults] setObject:aString forKey:PBPREFERENCEPANE_BUILD_SCRATCH_LOCATION];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_BUILD_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}



- (NSNumber *) defaultPermissionsMode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
}

- (void) setDefaultPermissionsMode:(NSNumber *) inNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:inNumber forKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_FILES_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) defaultReferenceStyle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
}

- (void) setDefaultReferenceStyle:(NSNumber *) inNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:inNumber forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_FILES_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

- (NSNumber *) showFilesCustomizationDialog
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
}

- (void) setshowFilesCustomizationDialog:(NSNumber *) inNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:inNumber forKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PBPREFERENCEPANE_FILES_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                        object:nil];
}

@end
