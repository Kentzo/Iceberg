/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>

#include <sys/param.h>
#include <sys/types.h>

@interface PBProjectBuilder : NSObject
{
    NSFileManager * fileManager_;
    NSDistributedNotificationCenter * distributedNotificationCenter_;
    
    NSDictionary * projectSettings_;
    
    NSString * projectPath_;
    
    NSString * notificationPath_;
    NSString * referencePath_;
    
    int processID_;
    int userID_;
    gid_t groupID_;
    
    int unknownID_;
    int groupCount_;
    gid_t groups_[NGROUPS + 3];	/* NGROUPS + 1 + Unknwon + groupID_*/
    
    NSDictionary * folderAttributes_;
    mode_t fileAttributes_;
    
    BOOL removeDSStore_;
    BOOL removePbdevelopment_;
    BOOL removeCVS_;
    BOOL cheetahCompatibility_;
    
    NSString * splitForksToolName_;
	
	NSString * scratchLocation_;
    
    NSString * temporaryDirectoryPath_;
    
    NSString * buildVersion_;
    
    NSMutableDictionary * tokenDefinitions_;
    NSMutableDictionary * pathMappings_;
    
    BOOL importedPackage_;
    int64_t installedSize_;
    int64_t compressedSize_;
    
    BOOL rootIsYouDaddy_;	// Is the build folder located on a volume mounted by root?
    
    NSMutableArray * permissionsToFixFolderArray_;
	
	unsigned long OSVersion_;
}

+ (NSDictionary *) projectDictionaryWithContentsOfFile:(NSString *) inPath;

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo;

- (BOOL) fixFolderPermissions;

- (BOOL) copyObjectAtPath:(NSString *) inPath toPath:(NSString *) toPath;

- (BOOL) createDirectoryAtPath:(NSString *) inPath;

- (void) initializeGroups;

- (unsigned long) buildProjectAtPath:(NSString *) inProjectPath forProcessID:(int) inProcessID withUserID:(int) inUserID groupID:(int) inGroupID notificationPath:(NSString *) inNotificationPath splitForksToolName:(NSString *) inSplitForksToolName scratchPath:(NSString *) inScratchPath;

- (unsigned long) buildPackageWithDictionary:(NSDictionary *) inDictionary atPath:(NSString *) inPath;

- (unsigned long) buildMetapackageWithDictionary:(NSDictionary *) inDictionary atPath:(NSString *) inPath;

- (NSMutableString *) infoOptionsWithDictionary:(NSDictionary *) inDictionary;

- (NSMutableDictionary *) infoDictionaryWithDictionary:(NSDictionary *) inDictionary;

+ (NSString *) fileNameWithDictionary:(NSDictionary *) inDictionary;

- (BOOL) buildPath:(NSString *) inPath fixedPermissionAfter:(BOOL) inFixedPermissionAfter;

- (unsigned long) addBackgroundImageAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (unsigned long) addDocumentsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (unsigned long) addScriptsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (unsigned long) addPluginsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (unsigned long) addCustomIconAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (void) postNotificationWithCode:(int) inCode arguments:(NSArray *) inArguments;

- (int) buildPaxArchiveAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (BOOL) buildBundleVersionsAtPath:(NSString *) inPath withFileHierarchyAtPath:(NSString *) inFileHierarchyPath;

- (int) buildArchiveInfoAtPath:(NSString *) inPath;

- (int) buildPackageVersionAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;

- (BOOL) setFileAttributesAtPath:(NSString *) aPath;

- (BOOL) setFilePrivileges:(int) inPrivileges atPath:(NSString *) aPath;

- (BOOL) setFileOwner:(int) inOwner group:(int) inGroup atPath:(NSString *) aPath;

- (BOOL) setFileOwnerAtPath:(NSString *) aPath traverseHierarchy:(BOOL) inTraverseHierarchy;

- (BOOL) buildFileHierarchyComponent:(NSDictionary *) inDictionary atPath:(NSString *) inPath rootComponent:(BOOL) inRootComponent;

- (BOOL) buildTokenDefinitionsWithRules:(NSArray *) inRulesArray forPath:(NSString *) inPath;

- (NSMutableDictionary *) firstItemForHierarchy:(NSMutableDictionary *) inDictionary andDefaultLocation:(NSString *) inPath;

- (BOOL) optimizeHierarchy:(NSMutableDictionary *) inDictionary;

- (BOOL) createCommonSkeletonAtPath:(NSString *) inPath;

+ (BOOL) copyPath:(NSString *) fromPath toPath:(NSString *) toPath;

- (BOOL) checkUserPermissionAtPath:(NSString *) inPath;

@end
