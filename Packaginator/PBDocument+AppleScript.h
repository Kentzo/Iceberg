#import "PBDocument.h"

@class PB_AS_Project;

@interface PBDocument (AppleScript)

/* Attributes */

- (PB_AS_Project *) project;

/* Commands */

- (id) handleBuildProjectScriptCommand:(NSScriptCommand *) inCommand;

- (void) handleCleanProjectScriptCommand:(NSScriptCommand *) inCommand;



@end
