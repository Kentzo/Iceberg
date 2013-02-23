/*
 *  NSString+CarbonUtilities.h category
 *
 *  Created by Nathan Day on Sat Aug 03 2002.
 *  Copyright (c) 2002 Nathan Day. All rights reserved.\
 */

/*
    Modifications:
    
    S.Sudre: #import were modifed to use CoreServices instead of Carbon
*/

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

@interface NSString (CarbonUtilities)

+ (NSString *)stringWithFSRef:(const FSRef *)aFSRef;
- (BOOL)getFSRef:(FSRef *)aFSRef;

- (NSString *)resolveAliasFile;

@end
