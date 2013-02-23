/*
Copyright (c) 2004-2008, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectBuilder.h"
#import "PBSharedConst.h"
#import "PBExtensionUtilities.h"
#import "PBLicenseProvider.h"
#include "FTSUtilities.h"
#import "NSArray+Iceberg.h"
#import "NSString+Iceberg.h"

#include "FSCopyObject.h"	// We use this code to work around at least 2 bugs in NSFileManager in Mac OS X 10.2
#include <CoreServices/CoreServices.h>
#include <sys/syslimits.h>

#import "NDResourceFork.h"		// We use this code for the custom icon
#import "NSString+CarbonUtilities.h"

#import "PBProjectRemoverErrorHandler.h"

#include <sys/param.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <err.h>
#include <grp.h>
#include <pwd.h>
#include <errno.h>
#include <fts.h>
#include <string.h>
#include <unistd.h>

#define	IS_ATOMICAL NO

#define PBPACKAGECREATORVERSION @"IcebergBuilder 1.2.9"

static OSErr MyFSPathMakeRef( const unsigned char *path, FSRef *ref );

@interface NSDictionary (Components)

- (BOOL) compareComponents:(NSDictionary *) inDictionary;

@end

@implementation NSDictionary (Components)

- (BOOL) compareComponents:(NSDictionary *) inDictionary
{
    return [[self objectForKey:IFPkgFlagPackageLocation] compare:[inDictionary objectForKey:IFPkgFlagPackageLocation] options:NSCaseInsensitiveSearch];
}

@end

@implementation PBProjectBuilder

- (id) init
{
	self=[super init];
	
	if (self!=nil)
	{
		Gestalt(gestaltSystemVersion,(long *) &OSVersion_);
	}
	
	return self;
}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
    [self postNotificationWithCode:kPBDebugInfo
                         arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@: %@",[errorInfo objectForKey:@"Error"],[errorInfo objectForKey:@"Path"]]]];
    
    return YES;
}

- (BOOL) fixFolderPermissions
{
    NSEnumerator * tEnumerator;
    NSString * tFolderPath;
    
    tEnumerator=[permissionsToFixFolderArray_ objectEnumerator];
    
    while (tFolderPath=[tEnumerator nextObject])
    {
        if ([self setFilePrivileges:S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH atPath:tFolderPath]==NO)
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) copyObjectAtPath:(NSString *) inPath toPath:(NSString *) toPath
{
    BOOL tResult;
    
    tResult=[fileManager_ copyPath:inPath toPath:toPath handler:self];
    
    if (tResult==NO)
    {
        [self postNotificationWithCode:kPBErrorCantCopyFile
                             arguments:[NSArray arrayWithObjects:inPath,
                                                                 toPath,
                                                                 nil]];
    }
    
    return tResult;
}

- (BOOL) createDirectoryAtPath:(NSString *) inPath
{
    BOOL tResult;
    
    tResult=[fileManager_ createDirectoryAtPath:inPath attributes:folderAttributes_];

    if (tResult==NO)
    {
        [self postNotificationWithCode:kPBErrorCantCreateFolder
                             arguments:[NSArray arrayWithObject:inPath]];
    }
    /*else
    {
        [permissionsToFixFolderArray_ addObject:inPath];
    }*/
    
    return tResult;
}

+ (NSDictionary *) projectDictionaryWithContentsOfFile:(NSString *) inPath
{
    NSData * tData;
    NSDictionary * tDictionary=nil;
    
    tData=[NSData dataWithContentsOfFile:inPath];
    
    if (tData!=nil)
    {
        NSString * errorString;
        NSPropertyListFormat format;
        
        tDictionary=(NSDictionary *) [NSPropertyListSerialization propertyListFromData:tData
                                                                      mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                                format:&format
                                                                      errorDescription:&errorString];
        
        if (tDictionary==nil)
        {
            [errorString release];
        }
    }
    
    return tDictionary;
}

- (BOOL) checkUserPermissionAtPath:(NSString *) inPath
{
    struct stat tStat;
    int i;
    
    if (lstat([inPath fileSystemRepresentation], &tStat)!=0)
    {
        [self postNotificationWithCode:kPBErrorUnknown
                             arguments:[NSArray arrayWithObject:@"checkUserPermissionAtPath"]];
        
        return NO;
    }

    // Check that the user can read and write
    
    /*[self postNotificationWithCode:kPBDebugInfo
                         arguments:[NSArray arrayWithObject:
    [NSString stringWithFormat:@"Path: %@ / File Owner ID: %d File Group ID: %d User ID: %d Permissions:%x",inPath,tStat.st_uid,tStat.st_gid,userID_,tStat.st_mode]]];*/
    
    if (userID_==tStat.st_uid || unknownID_==tStat.st_uid)
    {
        if ((tStat.st_mode & (S_IRUSR + S_IWUSR)) == (S_IRUSR + S_IWUSR))
        {
            return YES;
        }
    }

    for(i=0;i<groupCount_;i++)
    {
        if (groups_[i]==tStat.st_gid)
        {
            if ((tStat.st_mode & (S_IRGRP + S_IWGRP)) == (S_IRGRP + S_IWGRP))
            {
                return YES;
            }
        }
    }
        
    if ((tStat.st_mode & (S_IROTH + S_IWOTH)) != (S_IROTH + S_IWOTH))
    {
        [self postNotificationWithCode:kPBErrorInsufficientPrivileges
                             arguments:[NSArray arrayWithObject:inPath]];
        
        return NO;
    }
    
    return YES;
}

- (void) initializeGroups
{
    struct passwd * tPassword;
    
    // groupID_
    
    groupCount_=0;
    
    groups_[groupCount_]=groupID_;
    
    groupCount_++;
    
    // Group and user 'unknown'
    
    tPassword = getpwnam("unknown");
    
    if (tPassword!=NULL)
    {
        groups_[groupCount_]=tPassword->pw_gid;
        
        groupCount_++;
        
        unknownID_=tPassword->pw_uid;
    }
    
    // Supplemental Groups
    
    tPassword = getpwuid(userID_);
    
    if (tPassword!=NULL)
    {
        gid_t gid,lastGid=-1;
        int i, tCount;
	gid_t tGroups[NGROUPS + 1];
        
        tCount = NGROUPS + 1;
        
        (void) getgrouplist(tPassword->pw_name, tPassword->pw_gid, tGroups, &tCount);

	for (i=0;i<tCount;i++)
        {
            gid = tGroups[i];
            
            if (lastGid!=gid)
            {
            	groups_[groupCount_]=gid;
            
                groupCount_++;
		
                lastGid = gid;
            }
	}
    }
}

- (unsigned long) buildProjectAtPath:(NSString *) inProjectPath forProcessID:(int) inProcessID withUserID:(int) inUserID groupID:(int) inGroupID notificationPath:(NSString *) inNotificationPath splitForksToolName:(NSString *) inSplitForksToolName scratchPath:(NSString *) inScratchPath
{
    NSDictionary * tProjectDictionary;
    NSDictionary * tSystemVersionDictionary;
    
    projectPath_=[inProjectPath copy];
    
    notificationPath_=[inNotificationPath copy];
    
    referencePath_=[notificationPath_ stringByDeletingLastPathComponent];
    
    processID_=inProcessID;
    
    rootIsYouDaddy_=YES;
    
    fileManager_=[NSFileManager defaultManager];
    
	//Scratch location
	
    if (inScratchPath!=nil)
    {
        BOOL isDirectory;
        
        if ([fileManager_ fileExistsAtPath:inScratchPath isDirectory:&isDirectory]==NO || isDirectory==NO)
        {
            [self postNotificationWithCode:kPBErrorScratchDoesNotExist
                                 arguments:[NSArray arrayWithObject:inScratchPath]];
            
            scratchLocation_=nil;
        }
        else
        {
            scratchLocation_=[inScratchPath copy];
        }
    }
    
    if (scratchLocation_==nil)
    {
        scratchLocation_=[[NSString alloc] initWithString:NSTemporaryDirectory()];
    }
    
	// SplitForks Tool Name
	
	if (inSplitForksToolName==nil)
	{
		splitForksToolName_=[[NSString alloc] initWithString:@"goldin"];	// A AMELIORER (Utiliser une constante)
	}
	else
	{
		splitForksToolName_=[inSplitForksToolName copy];
	}
	
    // Get the OS Build version
    
    tSystemVersionDictionary=[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    
    if (tSystemVersionDictionary!=nil)
    {
        buildVersion_=[[tSystemVersionDictionary objectForKey:@"ProductBuildVersion"] copy];
    }
    
    // Read the document and launch the building
    
    tProjectDictionary=[PBProjectBuilder projectDictionaryWithContentsOfFile:inProjectPath];
    
    if (tProjectDictionary!=nil)
    {
        BOOL isDirectory;
        NSDictionary * tProjectSettings;
        NSDictionary * tProjectHierarchy;
        NSString * tBuildPath=nil;
        NSNumber * tNumber;
        BOOL needsToBuild=YES;
        
        // Initialize Project info
        
        distributedNotificationCenter_=[NSDistributedNotificationCenter defaultCenter];
        
        userID_=inUserID;
        groupID_=inGroupID;
        
        [self initializeGroups];
        
        permissionsToFixFolderArray_=[NSMutableArray arrayWithCapacity:10];
        
        folderAttributes_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:/*S_IRWXU+S_IRWXG+S_IRWXO*/S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH],NSFilePosixPermissions,
                                                                       nil];
        
        
        fileAttributes_=S_IRUSR+S_IRGRP+S_IROTH;
        
        // Read the Project Settings
    
        tProjectSettings=[tProjectDictionary objectForKey:@"Settings"];
        
        if (tProjectSettings!=nil)
        {
            NSNumber * tNumber;
            
            tBuildPath=[tProjectSettings objectForKey:@"Build Path"];
            
            tNumber=[tProjectSettings objectForKey:@"Build Path Type"];
            
            if (tNumber!=nil)
            {
                if ([tNumber intValue]==kRelativeToProjectPath)
                {
                    tBuildPath=[tBuildPath stringByAbsolutingWithPath:referencePath_];
                }
            }
        }
        
        if (tBuildPath==nil)
        {
            // We need to create the Build Path by our own
            
            // We use inNotificationPath because it's the real project path
            
            tBuildPath=[[inNotificationPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"build"];
        }
        
        // Read the other settings
    
        tNumber=[tProjectSettings objectForKey:@"Remove .DS_Store"];
        
        if (tNumber==nil)
        {
            removeDSStore_=YES;
        }
        else
        {
            removeDSStore_=[tNumber boolValue];
        }
        
        tNumber=[tProjectSettings objectForKey:@"Remove .pbdevelopment"];
        
        if (tNumber==nil)
        {
            removePbdevelopment_=YES;
        }
        else
        {
            removePbdevelopment_=[tNumber boolValue];
        }
        
        tNumber=[tProjectSettings objectForKey:@"Remove CVS"];
        
        if (tNumber==nil)
        {
            removeCVS_=NO;
        }
        else
        {
            removeCVS_=[tNumber boolValue];
        }
        
        tNumber=[tProjectSettings objectForKey:@"10.1 Compatibility"];
        
        if (tNumber==nil)
        {
            cheetahCompatibility_=YES;
        }
        else
        {
            cheetahCompatibility_=[tNumber boolValue];
        }
        
        [self postNotificationWithCode:kPBBuildingStart
                             arguments:nil];
        
        [self postNotificationWithCode:kPBBuildingPreparingBuildFolder
                             arguments:[NSArray arrayWithObject:tBuildPath]];
        
        // Make sure the user can work in the Build Path
        
        if ([fileManager_ fileExistsAtPath:tBuildPath isDirectory:&isDirectory]==YES)
        {
            struct statfs tStatfs;
            
            if (statfs([tBuildPath fileSystemRepresentation],&tStatfs)==0)
            {
                rootIsYouDaddy_=(tStatfs.f_owner==0);
            }
            
            if (rootIsYouDaddy_==NO)
            {
                seteuid(userID_);
                setegid(groupID_);
            }
            
            if (isDirectory==YES)
            {
                // Check that the user can read and write
                
                if ([self checkUserPermissionAtPath:tBuildPath]==NO)
                {
                    return 1;
                }
                
                needsToBuild=NO;
            }
            else
            {
                // Try to remove the Build file
                
                if ([fileManager_ removeFileAtPath:tBuildPath handler:self]==NO)
                {
                    [self postNotificationWithCode:kPBErrorCantRemoveFile
                                         arguments:[NSArray arrayWithObject:tBuildPath]];
                
                    return 1;
                }
            }
        }
        else
        {
            struct statfs tStatfs;
            
            // The build folder does not exist
            
            if ([fileManager_ fileExistsAtPath:[tBuildPath stringByDeletingLastPathComponent] isDirectory:&isDirectory]==NO)
            {
                // The parent folder does not exist either, we try to fall back to the project folder path
            
                tBuildPath=[[inNotificationPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"build"];
            
                if ([fileManager_ fileExistsAtPath:tBuildPath isDirectory:&isDirectory]==YES)
                {
                    if (statfs([tBuildPath fileSystemRepresentation],&tStatfs)==0)
                    {
                        rootIsYouDaddy_=(tStatfs.f_owner==0);
                    }
                    
                    if (isDirectory==YES)
                    {
                        // Check that the user can read and write
                        
                        if ([self checkUserPermissionAtPath:tBuildPath]==NO)
                        {
                            return 1;
                        }
                        
                        needsToBuild=NO;
                    }
                    else
                    {
                        // Try to remove the Build file
                        
                        if ([fileManager_ removeFileAtPath:tBuildPath handler:self]==NO)
                        {
                            [self postNotificationWithCode:kPBErrorCantRemoveFile
                                                arguments:[NSArray arrayWithObject:tBuildPath]];
                        
                            return 1;
                        }
                    }
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorFolderDoesNotExist
                                         arguments:[NSArray arrayWithObject:tBuildPath]];
                        
                    return 1;
                }
            }
            else
            {
                if (statfs([[tBuildPath stringByDeletingLastPathComponent] fileSystemRepresentation],&tStatfs)==0)
                {
                    rootIsYouDaddy_=(tStatfs.f_owner==0);
                }
            }
            
            if (rootIsYouDaddy_==NO)
            {
                seteuid(userID_);
                setegid(groupID_);
            }
        }
        
        if (needsToBuild==YES)
        {
            if ([self checkUserPermissionAtPath:[tBuildPath stringByDeletingLastPathComponent]]==NO)
            {
                return 1;
            }
            
            // Create the Build Folder if needed
            
            if ([self createDirectoryAtPath:tBuildPath]==NO)
            {
                return 1;
            }
            
            if (rootIsYouDaddy_==YES)
			{
				if ([self setFileOwnerAtPath:tBuildPath traverseHierarchy:NO]==NO)
				{
					[self postNotificationWithCode:kPBErrorInsufficientPrivileges
										 arguments:[NSArray arrayWithObject:tBuildPath]];
                
					return 1;
				}
			}
        }
        
        // Build the Package and MetaPackage hierarchy
        
        tProjectHierarchy=[tProjectDictionary objectForKey:@"Hierarchy"];
        
        if (tProjectHierarchy!=nil)
        {
            NSNumber * tObjectType;
            
            tObjectType=[tProjectHierarchy objectForKey:@"Type"];
            
            if (tObjectType!=nil)
            {
                int tReturnCode=-1;
                
                switch([tObjectType intValue])
                {
                    case kPBMetaPackageNode:	// Meta
                        
                        tReturnCode=[self buildMetapackageWithDictionary:tProjectHierarchy atPath:tBuildPath];
                        break;
                    case kPBPackageNode:
                                             
                        tReturnCode=[self buildPackageWithDictionary:tProjectHierarchy atPath:tBuildPath];
                        break;
                }
                
                if (tReturnCode==0)
                {
                    if ([self fixFolderPermissions]==YES)
                    {
                        [self postNotificationWithCode:kPBBuildingComplete
                                             arguments:nil];
                    }
                }
            }
            else
            {
                [self postNotificationWithCode:kPBErrorMissingInformation
                                     arguments:[NSArray arrayWithObject:@"Type"]];
            }
        }
        else
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Hierarchy"]];
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorUnknown
                             arguments:[NSArray arrayWithObject:@"projectDictionaryWithContentsOfFile"]];
        
        return 1;
    }
    
    return 0;
}

- (BOOL) createCommonSkeletonAtPath:(NSString *) inPath
{
    NSString * tContentsPath;
    NSString * tPkgInfoPath;
    NSData * tPkgInfoData;
    NSString * tResourcesPath;
    
    // Build the Main Folder
    
    if ([self createDirectoryAtPath:inPath]==NO)
    {
        return NO;
    }
    
    // Build the Contents Folder
    
    tContentsPath=[inPath stringByAppendingPathComponent:@"Contents"];
    
    if ([self createDirectoryAtPath:tContentsPath]==NO)
    {
        return NO;
    }
    
    // Create the PkgInfo file
    
    tPkgInfoPath=[tContentsPath stringByAppendingPathComponent:@"PkgInfo"];
    
    tPkgInfoData=[NSData dataWithBytes:"pmkrpkg1" length:8];
    
    if (tPkgInfoData!=nil)
    {
        if ([tPkgInfoData writeToFile:tPkgInfoPath atomically:IS_ATOMICAL]==NO)
        {
            [self postNotificationWithCode:kPBErrorCantCreateFile
                             arguments:[NSArray arrayWithObject:tPkgInfoPath]];
        
            return NO;
        }
        
        if ([self setFileAttributesAtPath:tPkgInfoPath]==NO)
        {
            return NO;
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorOutOfMemory
                             arguments:nil];
        
        return NO;
    }
    
    // Create the Resources folder
    
    tResourcesPath=[tContentsPath stringByAppendingPathComponent:@"Resources"];
    
    if ([self createDirectoryAtPath:tResourcesPath]==NO)
    {
        return NO;
    }
    
    return YES;
}

- (unsigned long) buildMetapackageWithDictionary:(NSDictionary *) inDictionary atPath:(NSString *) inPath
{
    NSDictionary * tAttributes;
    NSString * tName;
    NSString * tMetaPackagePath;
    NSString * tContentsPath;
    NSString * tResourcesPath;
    NSString * tInfoPath;
    NSNumber * tNumber;
    
    tName=[PBProjectBuilder fileNameWithDictionary:inDictionary];
    
    // Remove the old Package if needed
    
    tMetaPackagePath=[inPath stringByAppendingPathComponent:tName];
    
    if ([fileManager_ fileExistsAtPath:tMetaPackagePath]==YES)
    {
        if ([fileManager_ removeFileAtPath:tMetaPackagePath handler:self]==NO)
        {
            [self postNotificationWithCode:kPBErrorCantRemoveFile
                                 arguments:[NSArray arrayWithObject:tMetaPackagePath]];
                
            return NO;
        }
    }
    
    // Check whether we need to build the Package or not
    
    tNumber=[inDictionary objectForKey:@"Status"];
    
    if (tNumber!=nil)
    {
        if ([tNumber intValue]==0)
        {
            return 0;
        }
    }
    
    // Create the default skeleton
    
    [self postNotificationWithCode:kPBBuildingMetapackage
                         arguments:[NSArray arrayWithObject:tName]];
    
    if ([self createCommonSkeletonAtPath:tMetaPackagePath]==NO)
    {
        return 1;
    }
    
    tContentsPath=[tMetaPackagePath stringByAppendingPathComponent:@"Contents"];
    
    tResourcesPath=[tContentsPath stringByAppendingPathComponent:@"Resources"];
    
    // Create the Info.plist file
    
    tInfoPath=[tContentsPath stringByAppendingPathComponent:@"Info.plist"];
    
    [self postNotificationWithCode:kPBBuildingCreateInfoPlist
                         arguments:[NSArray array]];
    
    tAttributes=[inDictionary objectForKey:@"Attributes"];
    
    if (tAttributes!=nil)
    {
        NSDictionary * tSettings;
        NSArray * tComponents=nil;
        NSDictionary * tComponentDictionary;
        NSDictionary * tDescriptionDictionary;
        int i,tCount=0;
        NSMutableDictionary * tInfoDictionary;
        NSString * tComponentsPath;
        NSString * tRelativeComponentDirectory=nil;
        
        tInfoDictionary=[self infoDictionaryWithDictionary:tAttributes];
        
        if (tInfoDictionary!=nil)
        {
            //NSDictionary * tDisplayInformationDictionary;
            
            tComponents=[tAttributes objectForKey:@"Components"];
        
            if (tComponents!=nil)
            {
                NSMutableArray * tInfoComponentsArray;
                NSMutableString * tCheetahList=nil;
                
                tCount=[tComponents count];
                
                if (cheetahCompatibility_==YES)
                {
                    tCheetahList=[NSMutableString string];
                }
                
                // Relative location of components
                    
                tRelativeComponentDirectory=[inDictionary objectForKey:IFPkgFlagComponentDirectory];
                    
                [tInfoDictionary setObject:tRelativeComponentDirectory forKey:IFPkgFlagComponentDirectory];
                    
                // List of components
                    
                tInfoComponentsArray=[NSMutableArray arrayWithCapacity:tCount];
                    
                for(i=0;i<tCount;i++)
                {
                    
                    int tStatus;
                    
                    tStatus=1;
                    
                    tComponentDictionary=[tComponents objectAtIndex:i];
                    
                    tNumber=[tComponentDictionary objectForKey:@"Status"];
                    
                    if (tNumber!=nil)
                    {
                        tStatus=[tNumber intValue];
                    }
                    
                    if (tStatus==1)
                    {
                        NSDictionary * tInfoComponent;
                        NSString * tSelectionState=@"";
                        NSString * tFileName;
                        
                        tNumber=[tComponentDictionary objectForKey:IFPkgFlagPackageSelection];
                        
                        if (tNumber!=nil)
                        {
                            switch([tNumber intValue])
                            {
                                case kObjectUnselected:
                                    tSelectionState=@"unselected";
                                    break;
                                case kObjectSelected:
                                    tSelectionState=@"selected";
                                    break;
                                case kObjectRequired:
                                    tSelectionState=@"required";
                                    break;
                            }
                        }
                        else
                        {
                            tSelectionState=@"selected";
                        }
                        
                        tFileName=[PBProjectBuilder fileNameWithDictionary:tComponentDictionary];
                        
                        if (cheetahCompatibility_==YES)
                        {
                            [tCheetahList appendString:[NSString stringWithFormat:@"%@:%@\n",tFileName,[tSelectionState capitalizedString]]];
                        }
                        
                        tInfoComponent=[NSDictionary dictionaryWithObjectsAndKeys:tFileName,IFPkgFlagPackageLocation,
                                                                                  tSelectionState,IFPkgFlagPackageSelection,
                                                                                  nil];
                        
                        if (tInfoComponent!=nil)
                        {
                            [tInfoComponentsArray addObject:tInfoComponent];
                        }
                    }
                }
                
                // Check that all the subpackages have different names
                
                if ([tInfoComponentsArray containsTwins:@selector(compareComponents:)]==YES)
                {
                    NSDictionary * tSibbling;
                    
                    tSibbling=[tInfoComponentsArray findFirstTwins:@selector(compareComponents:)];
                    
                    [self postNotificationWithCode:kPBErrorPackageSameNames
                                         arguments:[NSArray arrayWithObjects:tName,[tSibbling objectForKey:IFPkgFlagPackageLocation],nil]];
        
                    return 1;
                }
                
                // A COMPLETER (gestion des cas plus complexes)
                
                [tInfoDictionary setObject:tInfoComponentsArray forKey:IFPkgFlagPackageList];
                
                if (cheetahCompatibility_==YES)
                {
                    [tCheetahList writeToFile:[tResourcesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.list",[tName stringByDeletingPathExtension]]] atomically:IS_ATOMICAL];
                }
            }
            else
            {
                [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Components"]];
        
                return 1;
            }
            
            // Save the dictionary on Disk
                
            if ([tInfoDictionary writeToFile:tInfoPath atomically:IS_ATOMICAL]==NO)
            {
                [self postNotificationWithCode:kPBErrorCantCreateFile
                             arguments:[NSArray arrayWithObject:tInfoPath]];
        
                return 1;
            }
            
            if ([self setFileAttributesAtPath:tInfoPath]==NO)
            {
                return 1;
            }
        }
        else
		{
			return 1;
		}
		
        // Create Description.plist
    
        tSettings=[tAttributes objectForKey:@"Settings"];
        
        [self postNotificationWithCode:kPBBuildingCreateDescriptionPlist
                             arguments:[NSArray array]];
        
        tDescriptionDictionary=[tSettings objectForKey:@"Description"];
        
        if (tDescriptionDictionary!=nil)
        {
            NSArray * tLanguages;
            
            tLanguages=[tDescriptionDictionary allKeys];
            
            if (tLanguages!=nil)
            {
                int j,tLanguageCount;
                
                tLanguageCount=[tLanguages count];
                
                for(j=0;j<tLanguageCount;j++)
                {
                    NSString * tLanguage;
                    NSString * tLocalizationPath;
                    NSString * tLocalizedDescriptionPath;
                    NSDictionary * tLocalizedDescription;
					BOOL isInternational;
					
					isInternational=NO;
					
                    tLanguage=[tLanguages objectAtIndex:j];
                    
                    // Create the Folder if needed
                    
                    if ([tLanguage isEqualToString:@"International"]==YES)
                    {
                        tLocalizationPath=tResourcesPath;
						
						isInternational=YES;
                    }
                    else
                    {
                        tLocalizationPath=[tResourcesPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                    }
                    
                    tLocalizedDescriptionPath=[tLocalizationPath stringByAppendingPathComponent:@"Description.plist"];
                    
                    if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                    {
                        if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                        {
                            return 1;
                        }
                    }
                    
                    tLocalizedDescription=[tDescriptionDictionary objectForKey:tLanguage];
					
					if (isInternational==YES && tLanguageCount>1)
                    {
                        NSString * tTitleString, * tDescriptionString;
                        
                        tTitleString=[tLocalizedDescription objectForKey:IFPkgDescriptionTitle];
                        
                        tDescriptionString=[tLocalizedDescription objectForKey:IFPkgDescriptionVersion];
                        
                        if ([tTitleString length]==0 && [tDescriptionString length]==0)
                        {
                            goto cheetahBail;
                        }
                    }
                    
                    if ([tLocalizedDescription writeToFile:tLocalizedDescriptionPath atomically:IS_ATOMICAL]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCreateFile
                                             arguments:[NSArray arrayWithObject:tLocalizedDescriptionPath]];
        
                        return 1;
                    }
                    
                    if ([self setFileAttributesAtPath:tLocalizedDescriptionPath]==NO)
                    {
                        return 1;
                    }
                    
cheetahBail:

                    if (cheetahCompatibility_==YES)
                    {
                        NSMutableString * tDescriptionInfoString;
                        
                        tDescriptionInfoString=[NSMutableString string];
                        
                        [tDescriptionInfoString appendString:@"#\n# Human-readable string for this group of packages\n#\n"];
                        
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Title\t%@\n\n",[tLocalizedDescription objectForKey:IFPkgDescriptionTitle]]];
                        
                        [tDescriptionInfoString appendString:@"#\n# Version\n#\n"];
                        
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Version\t%@\n\n",[tLocalizedDescription objectForKey:IFPkgDescriptionVersion]]];
                        
                        [tDescriptionInfoString appendString:@"#\n# MetaPackage Description\n#\n"];
                        
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Description\t%@\n\n",[tLocalizedDescription objectForKey:IFPkgDescriptionDescription]]];
                        
                        [tDescriptionInfoString appendString:@"#\n# Where to search for packages. For a real release, this would\n# be relative to the .mpkg directory (probably \"..\")\n#\n"];
                        
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"PackageLocation\t%@\n",tRelativeComponentDirectory]];
                        
                        tLocalizedDescriptionPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",[tName stringByDeletingPathExtension]]];
                        
                        if ([tDescriptionInfoString writeToFile:tLocalizedDescriptionPath atomically:IS_ATOMICAL]==NO)
                        {
                            [self postNotificationWithCode:kPBErrorCantCreateFile
                                                 arguments:[NSArray arrayWithObject:tLocalizedDescriptionPath]];
            
                            return 1;
                        }
                    }
                }
            }
        }
        
        // Add Custom icon if needed
        
        if ([self addCustomIconAtPath:tMetaPackagePath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Background picture if needed
        
        if ([self addBackgroundImageAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Welcome, ReadMe, License if needed
        
        if ([self addDocumentsAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Scripts if needed
        
        if ([self addScriptsAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Plugins if needed
		
		if ([self addPluginsAtPath:tContentsPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
		
		if (cheetahCompatibility_==YES)
        {
            [self postNotificationWithCode:kPBBuildingCreatePackageVersion
                                 arguments:[NSArray array]];
            
            // Create package_version file
        
            if ([self buildPackageVersionAtPath:tResourcesPath withDictionary:tSettings]!=0)
            {
                // A COMPLETER
            }
        }
        
        // Set File Owner and Group
        
        if ([self setFileOwnerAtPath:tMetaPackagePath traverseHierarchy:YES]==NO)
        {
            return 1;
        }
        
        // Create the subpackages
            
        tComponentsPath=[[tMetaPackagePath stringByAppendingPathComponent:tRelativeComponentDirectory] stringByStandardizingPath];
        
        // Create the necessary folder if necessary
        
        if ([self buildPath:tComponentsPath fixedPermissionAfter:YES]==YES)
        {
        	for(i=0;i<tCount;i++)
            {
                NSNumber * tNumber;
                int tStatus;
                
                tStatus=1;
                
                tComponentDictionary=[tComponents objectAtIndex:i];
                
                tNumber=[tComponentDictionary objectForKey:@"Status"];
                
                if (tNumber!=nil)
                {
                    tStatus=[tNumber intValue];
                }
                
                if (tStatus==1)
                {
                    tNumber=[tComponentDictionary objectForKey:@"Type"];
                    
                    if (tNumber!=nil)
                    {
                        unsigned long tReturnCode=-1;
                        
                        switch([tNumber intValue])
                        {
                            case kPBMetaPackageNode:
                                tReturnCode=[self buildMetapackageWithDictionary:tComponentDictionary atPath:tComponentsPath];
                                break;
                            case kPBPackageNode:
                                tReturnCode=[self buildPackageWithDictionary:tComponentDictionary atPath:tComponentsPath];
                                break;
                        }
                        
                        if (tReturnCode!=0)
                        {
                            return 1;
                        }
                    }
                }
            }
        }
        else
        {
            return 1;
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Attributes"]];
        
        return 1;
    }
    
    [self postNotificationWithCode:kPBBuildingComponentSucceeded
                         arguments:[NSArray arrayWithObject:tName]];
    
    return 0;
}

- (unsigned long) buildPackageWithDictionary:(NSDictionary *) inDictionary atPath:(NSString *) inPath
{
    NSDictionary * tAttributes;
    NSString * tName;
    NSString * tPackagePath;
    NSString * tContentsPath;
    NSString * tResourcesPath;
    NSString * tInfoPath;
    NSNumber * tNumber;
    
    // Reset the Token Definitions and Path Mappings
    
    installedSize_=-1;
    
    [tokenDefinitions_ release];
    
    tokenDefinitions_=nil;
    
    [pathMappings_ release];
    
    pathMappings_=nil;
    
    // Create the default skeleton
    
    tName=[PBProjectBuilder fileNameWithDictionary:inDictionary];
    
    // Remove the old Package if needed
    
    tPackagePath=[inPath stringByAppendingPathComponent:tName];
    
    if ([fileManager_ fileExistsAtPath:tPackagePath]==YES)
    {
        if ([fileManager_ removeFileAtPath:tPackagePath handler:self]==NO)
        {
            [self postNotificationWithCode:kPBErrorCantRemoveFile
                                 arguments:[NSArray arrayWithObject:tPackagePath]];
                
            return NO;
        }
    }
    
    // Check whether we need to build the Package or not
    
    tNumber=[inDictionary objectForKey:@"Status"];
    
    if (tNumber!=nil)
    {
        if ([tNumber intValue]==0)
        {
            return 0;
        }
    }
    
    // Create the default skeleton
    
    [self postNotificationWithCode:kPBBuildingPackage
                         arguments:[NSArray arrayWithObject:tName]];
    
    if ([self createCommonSkeletonAtPath:tPackagePath]==NO)
    {
        return 1;
    }
    
    tContentsPath=[tPackagePath stringByAppendingPathComponent:@"Contents"];
    
    tResourcesPath=[tContentsPath stringByAppendingPathComponent:@"Resources"];
    
    // Create the Info.plist file
    
    tInfoPath=[tContentsPath stringByAppendingPathComponent:@"Info.plist"];
    
    [self postNotificationWithCode:kPBBuildingCreateInfoPlist
                         arguments:[NSArray array]];
    
    tAttributes=[inDictionary objectForKey:@"Attributes"];
    
    if (tAttributes!=nil)
    {
        NSDictionary * tSettings;
        NSDictionary * tDescriptionDictionary;
        NSMutableDictionary * tInfoDictionary;
        NSMutableString * tCheetahInfoString=nil;
        NSString * tDefaultLocation=nil;
        
        tInfoDictionary=[self infoDictionaryWithDictionary:tAttributes];
        
        if (tInfoDictionary!=nil)
        {
            NSDictionary * tFilesDictionary;
            NSDictionary * tSettings;
            NSNumber * tValue;
            NSDictionary * tOptionsDictionary;
            //NSDictionary * tDisplayInformationDictionary;
            
            if (cheetahCompatibility_==YES)
            {
                tCheetahInfoString=[self infoOptionsWithDictionary:tAttributes];
            }
            
            tSettings=[tAttributes objectForKey:@"Settings"];
    
            tFilesDictionary=[tAttributes objectForKey:@"Files"];
            
            if (tFilesDictionary!=nil)
            {
                tDefaultLocation=[tFilesDictionary objectForKey:IFPkgFlagDefaultLocation];
                
                if (tDefaultLocation!=nil)
                {
                    [tInfoDictionary setObject:tDefaultLocation forKey:IFPkgFlagDefaultLocation];
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:IFPkgFlagDefaultLocation]];
                
                    return 1;
                }
            }
            else
            {
                [self postNotificationWithCode:kPBErrorMissingInformation
                                     arguments:[NSArray arrayWithObject:@"Files"]];
                
                return 1;
            }
            
            if (tSettings!=nil)
            {
                tOptionsDictionary=[tSettings objectForKey:@"Options"];
                
                if (tOptionsDictionary!=nil)
                {
                    NSArray * tArray;
                    int i,tCount;
                    NSString * tKey;
                    
                    tArray=[NSArray arrayWithObjects:IFPkgFlagAllowBackRev,
                                                    IFPkgFlagFollowLinks,
                                                    IFPkgFlagIsRequired,
                                                    IFPkgFlagOverwritePermissions,
                                                    IFPkgFlagRelocatable,
                                                    IFPkgFlagRootVolumeOnly,
                                                    IFPkgFlagUpdateInstalledLanguages,
                                                    nil];
                    
                    tCount=[tArray count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        tKey=[tArray objectAtIndex:i];
                        
                        tValue=[tOptionsDictionary objectForKey:tKey];
                    
                        if (tValue!=nil)
                        {
                            [tInfoDictionary setObject:tValue forKey:tKey];
                        }
                        else
                        {
                            [self postNotificationWithCode:kPBErrorMissingInformation
                                                arguments:[NSArray arrayWithObject:tKey]];
                    
                            return 1;
                        }
                    }
                    
                    tValue=[tOptionsDictionary objectForKey:IFPkgFlagAuthorizationAction];
                    
                    if (tValue!=nil)
                    {
                        switch([tValue intValue])
                        {
                            case 0:
                                [tInfoDictionary setObject:@"NoAuthorization" forKey:IFPkgFlagAuthorizationAction];
                                break;
                            case 1:
                                [tInfoDictionary setObject:@"AdminAuthorization" forKey:IFPkgFlagAuthorizationAction];
                                break;
                            case 2:
                                [tInfoDictionary setObject:@"RootAuthorization" forKey:IFPkgFlagAuthorizationAction];
                                break;
                        }
                    }
                    else
                    {
                        [self postNotificationWithCode:kPBErrorMissingInformation
                                            arguments:[NSArray arrayWithObject:IFPkgFlagAuthorizationAction]];
                    
                        return 1;
                    }
                        
                    tValue=[tOptionsDictionary objectForKey:IFPkgFlagRestartAction];
                    
                    if (tValue!=nil)
                    {
                        switch([tValue intValue])
                        {
                            case 0:
                                [tInfoDictionary setObject:@"NoRestart" forKey:IFPkgFlagRestartAction];
                                break;
                            case 1:
                                [tInfoDictionary setObject:@"RecommendedRestart" forKey:IFPkgFlagRestartAction];
                                break;
                            case 2:
                                [tInfoDictionary setObject:@"RequiredRestart" forKey:IFPkgFlagRestartAction];
                                break;
                            case 3:
                                [tInfoDictionary setObject:@"Shutdown" forKey:IFPkgFlagRestartAction];
                                break;
                            case 4:
                                [tInfoDictionary setObject:@"RequiredLogout" forKey:IFPkgFlagRestartAction];
                                break;
                        }
                    }
                    else
                    {
                        [self postNotificationWithCode:kPBErrorMissingInformation
                                            arguments:[NSArray arrayWithObject:IFPkgFlagRestartAction]];
                    
                        return 1;
                    }
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:@"Options"]];
                    
                    return 1;
                }
            }
            else
            {
                [self postNotificationWithCode:kPBErrorMissingInformation
                                     arguments:[NSArray arrayWithObject:@"Settings"]];
                
                return 1;
            }
        }
        else
		{
			return 1;
		}
		
        // Create Description.plist
    
        tSettings=[tAttributes objectForKey:@"Settings"];
        
        [self postNotificationWithCode:kPBBuildingCreateDescriptionPlist
                             arguments:[NSArray array]];
        
        tDescriptionDictionary=[tSettings objectForKey:@"Description"];
        
        if (tDescriptionDictionary!=nil)
        {
            NSArray * tLanguages;
            
            tLanguages=[tDescriptionDictionary allKeys];
            
            if (tLanguages!=nil)
            {
                int j,tLanguageCount;
                
                tLanguageCount=[tLanguages count];
                
                for(j=0;j<tLanguageCount;j++)
                {
                    NSString * tLanguage;
                    NSString * tLocalizationPath;
                    NSString * tLocalizedDescriptionPath;
                    NSDictionary * tLocalizedDescription;
                    BOOL isInternational=NO;
                    
                    tLanguage=[tLanguages objectAtIndex:j];
                    
                    // Create the Folder if needed
                    
                    if ([tLanguage isEqualToString:@"International"]==YES)
                    {
                        tLocalizationPath=tResourcesPath;
                        
                        isInternational=YES;
                    }
                    else
                    {
                        tLocalizationPath=[tResourcesPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                    }
                    
                    tLocalizedDescriptionPath=[tLocalizationPath stringByAppendingPathComponent:@"Description.plist"];
                    
                    if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                    {
                        if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                        {
                            return 1;
                        }
                    }
                    
                    tLocalizedDescription=[tDescriptionDictionary objectForKey:tLanguage];
                    
                    // Check that values are set
                    
                    if (isInternational==YES && tLanguageCount>1)
                    {
                        NSString * tTitleString, * tDescriptionString;
                        
                        tTitleString=[tLocalizedDescription objectForKey:IFPkgDescriptionTitle];
                        
                        tDescriptionString=[tLocalizedDescription objectForKey:IFPkgDescriptionVersion];
                        
                        if ([tTitleString length]==0 && [tDescriptionString length]==0)
                        {
                            continue;
                        }
                    }
                    
                    if ([tLocalizedDescription writeToFile:tLocalizedDescriptionPath atomically:IS_ATOMICAL]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCreateFile
                                             arguments:[NSArray arrayWithObject:tLocalizedDescriptionPath]];
        
                        return 1;
                    }
                    
                    if ([self setFileAttributesAtPath:tLocalizedDescriptionPath]==NO)
                    {
                        return 1;
                    }
                    
                    if (cheetahCompatibility_==YES)
                    {
                        NSMutableString * tDescriptionInfoString;
                        
                        tDescriptionInfoString=[NSMutableString string];
                        
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Title %@\n",[tLocalizedDescription objectForKey:IFPkgDescriptionTitle]]];
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Version %@\n",[tLocalizedDescription objectForKey:IFPkgDescriptionVersion]]];
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"Description %@\n",[tLocalizedDescription objectForKey:IFPkgDescriptionDescription]]];
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"DefaultLocation %@\n",tDefaultLocation]];
                        [tDescriptionInfoString appendString:[NSString stringWithFormat:@"DeleteWarning %@\n",[tLocalizedDescription objectForKey:IFPkgDescriptionDeleteWarning]]];
                        
                        [tDescriptionInfoString appendString:tCheetahInfoString];
                        
                        tLocalizedDescriptionPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",[tName stringByDeletingPathExtension]]];
                        
                        if ([tDescriptionInfoString writeToFile:tLocalizedDescriptionPath atomically:IS_ATOMICAL]==NO)
                        {
                            [self postNotificationWithCode:kPBErrorCantCreateFile
                                                 arguments:[NSArray arrayWithObject:tLocalizedDescriptionPath]];
            
                            return 1;
                        }
                        
                        // A COMPLETER (permissions sur le fichier)
                    }
                }
            }
        }
        else
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Description"]];
                
            return 1;
        }
        
        // Add Custom icon if needed
        
        if ([self addCustomIconAtPath:tPackagePath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Background picture if needed
        
        if ([self addBackgroundImageAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Welcome, ReadMe, License if needed
        
        if ([self addDocumentsAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Copy Scripts if needed
        
        if ([self addScriptsAtPath:tResourcesPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
		
		// Copy Plugins if needed
		
		if ([self addPluginsAtPath:tContentsPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        // Create the pax archive
    
        if ([self buildPaxArchiveAtPath:tContentsPath withDictionary:tAttributes]!=0)
        {
            return 1;
        }
        
        if (importedPackage_==NO)
        {
            if (installedSize_!=-1)
            {
                [tInfoDictionary setObject:[NSNumber numberWithLongLong:installedSize_] forKey:IFPkgFlagInstalledSize];
            }
        }
        else
        {
            NSDictionary * tFilesDictionary;
            
            tFilesDictionary=[tAttributes objectForKey:@"Files"];
    
            if (tFilesDictionary!=nil)
            {
                NSDictionary * tImportedOptions;
                
                tImportedOptions=[tFilesDictionary objectForKey:@"Imported Options"];
                
                if (tImportedOptions!=nil)
                {
                    [tInfoDictionary addEntriesFromDictionary:tImportedOptions];
                }
            }
        }
        
        // Create the package_version file
        
        [self postNotificationWithCode:kPBBuildingCreatePackageVersion
                             arguments:[NSArray array]];
        
        if ([self buildPackageVersionAtPath:tResourcesPath withDictionary:tSettings]!=0)
        {
            // A COMPLETER
        }
        
        // Create the TokenDefinitions.plist file if needed
        
        if (tokenDefinitions_!=nil && [tokenDefinitions_ count]>0)
        {
            NSString * tTokenDefinitionsPath;
            
            [self postNotificationWithCode:kPBBuildingCreateTokenDefinitionsPlist
                                 arguments:[NSArray array]];
            
            tTokenDefinitionsPath=[tResourcesPath stringByAppendingPathComponent:@"TokenDefinitions.plist"];
            
            if ([tokenDefinitions_ writeToFile:tTokenDefinitionsPath atomically:IS_ATOMICAL]==NO)
            {
                [self postNotificationWithCode:kPBErrorCantCreateFile
                                     arguments:[NSArray arrayWithObject:tTokenDefinitionsPath]];
            }
            
            if ([self setFileAttributesAtPath:tTokenDefinitionsPath]==NO)
            {
                return 1;
            }
        }
        
        // Add the PathMappings in the Info.plist dictionary if needed
        
        if (pathMappings_!=nil && [pathMappings_ count]>0)
        {
            [tInfoDictionary setObject:pathMappings_ forKey:IFPkgPathMappings];
        }
        
        // Save the Info.plist file
        
        if ([tInfoDictionary writeToFile:tInfoPath atomically:IS_ATOMICAL]==NO)
        {
            [self postNotificationWithCode:kPBErrorCantCreateFile
                                    arguments:[NSArray arrayWithObject:tInfoPath]];
    
            return 1;
        }
        
        if ([self setFileAttributesAtPath:tInfoPath]==NO)
        {
            return 1;
        }
                         
        // Set Owner and Group on the whole Package
        
        if ([self setFileOwnerAtPath:tPackagePath traverseHierarchy:YES]==NO)
        {
            return 1;
        }
    }
    else
    {
        // A COMPLETER
    }
    
    [self postNotificationWithCode:kPBBuildingComponentSucceeded
                         arguments:[NSArray arrayWithObject:tName]];
    
    return 0;
}

#pragma mark -

- (NSMutableDictionary *) infoDictionaryWithDictionary:(NSDictionary *) inDictionary
{
    NSMutableDictionary * tInfoDictionary=nil;
    NSDictionary * tSettings;
    NSDictionary * tResources;
    NSDictionary * tScripts;
    
    tSettings=[inDictionary objectForKey:@"Settings"];
    
    tScripts=[inDictionary objectForKey:@"Scripts"];
    
    tResources=[inDictionary objectForKey:@"Documents"];
    
    if (tResources==nil)
    {
        tResources=[inDictionary objectForKey:@"Resources"];
    }
    
    if (tSettings!=nil)
    {
        NSString * tString;
        
        tInfoDictionary=[NSMutableDictionary dictionary];
        
        if (tInfoDictionary!=nil)
        {
            NSDictionary * tVersionDictionary;
            
            NSDictionary * tDisplayInformationDictionary;
            
            // CFBundleDevelopmentRegion
			
			[tInfoDictionary setObject:@"English" forKey:@"CFBundleDevelopmentRegion"];
			
			// Package version
            
            tVersionDictionary=[tSettings objectForKey:@"Version"];
            
            if (tVersionDictionary!=nil)
            {
                NSNumber * tNumber;
                
                tNumber=[tVersionDictionary objectForKey:IFMajorVersion];
                
                if (tNumber!=nil)
                {
                    [tInfoDictionary setObject:tNumber forKey:IFMajorVersion];
                }
                else
                {
                    [tInfoDictionary setObject:[NSNumber numberWithInt:1] forKey:IFMajorVersion];
                }
                
                tNumber=[tVersionDictionary objectForKey:IFMinorVersion];
                
                if (tNumber!=nil)
                {
                    [tInfoDictionary setObject:tNumber forKey:IFMinorVersion];
                }
                else
                {
                    [tInfoDictionary setObject:[NSNumber numberWithInt:0] forKey:IFMinorVersion];
                }
            }
            else
            {
                [tInfoDictionary setObject:[NSNumber numberWithInt:1] forKey:IFMajorVersion];
                
                [tInfoDictionary setObject:[NSNumber numberWithInt:0] forKey:IFMinorVersion];
            }
            
            // File format version
            
            [tInfoDictionary setObject:[NSNumber numberWithFloat:0.1f] forKey:IFPkgFormatVersion];
                            
            // Display Information
            
            tDisplayInformationDictionary=[tSettings objectForKey:@"Display Information"];
            
            if (tDisplayInformationDictionary!=nil)
            {
                tString=[tDisplayInformationDictionary objectForKey:@"CFBundleGetInfoString"];
                
                if (tString!=nil && [tString length]>0)
                {
                    [tInfoDictionary setObject:tString forKey:@"CFBundleGetInfoString"];
                }
                
                tString=[tDisplayInformationDictionary objectForKey:@"CFBundleIdentifier"];
                
                if (tString!=nil && [tString length]>0)
                {
                    [tInfoDictionary setObject:tString forKey:@"CFBundleIdentifier"];
                }
				else
				{
					[self postNotificationWithCode:kPBErrorMissingInformation
										 arguments:[NSArray arrayWithObject:@"CFBundleIdentifier"]];
					
					return nil;
				}
                
                tString=[tDisplayInformationDictionary objectForKey:@"CFBundleName"];
                
                if (tString!=nil && [tString length]>0)
                {
                    [tInfoDictionary setObject:tString forKey:@"CFBundleName"];
                }
                
                tString=[tDisplayInformationDictionary objectForKey:@"CFBundleShortVersionString"];
                
                if (tString!=nil && [tString length]>0)
                {
                    [tInfoDictionary setObject:tString forKey:@"CFBundleShortVersionString"];
                }
            }
            
            // Package Creator
            
            [tInfoDictionary setObject:PBPACKAGECREATORVERSION forKey:IFPkgCreator];
            
            // Build Date
            
            [tInfoDictionary setObject:[NSDate date] forKey:IFPkgBuildDate];
            
            // Build Version
            
            if (buildVersion_!=nil)
            {
                [tInfoDictionary setObject:buildVersion_ forKey:IFPkgBuildVersion];
            }
            
            if (tResources!=nil)
            {
                NSDictionary * tBackgroundImageDictionary;
                
                // Background Image
            
                tBackgroundImageDictionary=[tResources objectForKey:@"Background Image"];
            
                if (tBackgroundImageDictionary!=nil)
                {
                    NSNumber * tMode;
                    NSNumber * tNumber;
                    
                    tMode=[tBackgroundImageDictionary objectForKey:@"Mode"];
                
                    if (tMode!=nil)
                    {
                        if ([tMode intValue]==1)
                        {
                            tString=[tBackgroundImageDictionary objectForKey:@"Path"];
                            
                            if (tString!=nil && [tString length]>0)
                            {
                                tNumber=[tBackgroundImageDictionary objectForKey:IFPkgFlagBackgroundAlignment];
                                
                                if (tNumber!=nil)
                                {
                                    tString=@"center";
                                    
                                    switch([tNumber intValue])
                                    {
                                        case 0:
                                            tString=@"center";
                                            break;
                                        case 1:
                                            tString=@"top";
                                            break;
                                        case 2:
                                            tString=@"topleft";
                                            break;
                                        case 3:
                                            tString=@"topright";
                                            break;
                                        case 4:
                                            tString=@"left";
                                            break;
                                        case 5:
                                            tString=@"bottom";
                                            break;
                                        case 6:
                                            tString=@"bottomleft";
                                            break;
                                        case 7:
                                            tString=@"bottomright";
                                            break;
                                        case 8:
                                            tString=@"right";
                                            break;
                                    }
                                    
                                    [tInfoDictionary setObject:tString forKey:IFPkgFlagBackgroundAlignment];
                                }
                                
                                tNumber=[tBackgroundImageDictionary objectForKey:IFPkgFlagBackgroundScaling];
                                
                                if (tNumber!=nil)
                                {
                                    tString=@"tofit";
                                    
                                    switch([tNumber intValue])
                                    {
                                        case 0:
                                            tString=@"proportional";
                                            break;
                                        case 1:
                                            tString=@"tofit";
                                            break;
                                        case 2:
                                            tString=@"none";
                                            break;
                                    }
                                    
                                    [tInfoDictionary setObject:tString forKey:IFPkgFlagBackgroundScaling];
                                }
                            }
                        }
                    }
                }
            }
            
            if (tScripts!=nil)
            {
                NSArray * tRequirements;
                
                tRequirements=[tScripts objectForKey:@"Requirements"];
                
                if (tRequirements!=nil)
                {
                    int i,tCount;
                    NSDictionary * tRequirementObject;
                    NSMutableArray * tBuiltRequirementArray;
                    
                    tCount=[tRequirements count];
                    
                    if (tCount>0)
                    {
                        NSArray * tKeyArray;
                        int j,tKeysCount;
                        
                        tKeyArray=[NSArray arrayWithObjects:@"LabelKey",
                                                            @"SpecType",
                                                            @"SpecArgument",
                                                            @"SpecProperty",
                                                            @"TestOperator",
                                                            @"TestObject",
                                                            nil];
                        
                        tKeysCount=[tKeyArray count];
                        
                        tBuiltRequirementArray=[NSMutableArray arrayWithCapacity:tCount];
                    
                        for(i=0;i<tCount;i++)
                        {
                            NSNumber * tNumber;
                            NSMutableDictionary * tRequirementDictionary;
                            NSDictionary * tAlertDialogDictionary;
                            NSEnumerator * tLanguageEnumerator;
                            NSString * tLanguage;
                            
                            tRequirementObject=[tRequirements objectAtIndex:i];
                            
                            tNumber=[tRequirementObject objectForKey:@"Status"];
                            
                            if (tNumber!=nil)
                            {
                                if ([tNumber boolValue]==NO)
                                {
                                    continue;
                                }
                            }
                            
                            tRequirementDictionary=[NSMutableDictionary dictionary];
                            
                            tNumber=[tRequirementObject objectForKey:@"Level"];		// If Level is not set, then requires is used.
                            
                            [tRequirementDictionary setObject:([tNumber intValue]==0) ? @"requires" : @"recommends" forKey:@"Level"];
                            
                            for(j=0;j<tKeysCount;j++)
                            {
                                id tObject;
                                NSString * tKey;
                                
                                tKey=[tKeyArray objectAtIndex:j];
                                
                                tObject=[tRequirementObject objectForKey:tKey];
                                
                                if (tObject!=nil)
                                {
                                    [tRequirementDictionary setObject:tObject forKey:tKey];
                                }
                            }
                            
                            // TitleKey and MessageKey
                            
                            tAlertDialogDictionary=[tRequirementObject objectForKey:@"AlertDialog"];
                            
                            tLanguageEnumerator=[tAlertDialogDictionary keyEnumerator];
                            
                            while ((tLanguage=(NSString *) [tLanguageEnumerator nextObject])!=nil)
                            {
                                NSDictionary * tLocalizedAlertDialogDictionary;
                                NSString * tTitleKey;
                                NSString * tMessageKey;
                            
                                tLocalizedAlertDialogDictionary=[tAlertDialogDictionary objectForKey:tLanguage];
                                
                                tTitleKey=[tLocalizedAlertDialogDictionary objectForKey:@"TitleKey"];
                                tMessageKey=[tLocalizedAlertDialogDictionary objectForKey:@"MessageKey"];
                                
                                if ([tTitleKey length]>0 || [tMessageKey length]>0)
                                {
                                    [tRequirementDictionary setObject:[NSString stringWithFormat:@"titlekey%d",i] forKey:@"TitleKey"];
                                    [tRequirementDictionary setObject:[NSString stringWithFormat:@"messagekey%d",i] forKey:@"MessageKey"];
                                
                                    break;
                                }
                            }
                            
                            [tBuiltRequirementArray addObject:tRequirementDictionary];
                        }
                        
                        tCount=[tBuiltRequirementArray count];
                    
                        if (tCount>0)
                        {
                            [tInfoDictionary setObject:tBuiltRequirementArray forKey:IFRequirementDicts];
                        }
                    }
                }
            }
        }
    }
    
    return tInfoDictionary;
}

- (NSMutableString *) infoOptionsWithDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tSettings;
    NSDictionary * tOptionsDictionary;
    NSMutableString * tMutableString;
        
    tMutableString=[NSMutableString string];    
    
    [tMutableString appendString:@"\n### Package Flags\n\n"];
    
    tSettings=[inDictionary objectForKey:@"Settings"];

    if (tSettings!=nil)
    {
        tOptionsDictionary=[tSettings objectForKey:@"Options"];
        
        if (tOptionsDictionary!=nil)
        {
            NSNumber * tValue;
            
            // NeedsAuthorization
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagAuthorizationAction];
            
            if (tValue!=nil)
            {
                switch([tValue intValue])
                {
                    case 0:
                        [tMutableString appendString:@"NeedsAuthorization NO\n"];
                        break;
                    case 1:
                    case 2:
                        [tMutableString appendString:@"NeedsAuthorization YES\n"];
                        break;
                }
            }
            
            // Required
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagIsRequired];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"Required %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // Relocatable
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagRelocatable];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"Relocatable %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // RequiresReboot
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagRestartAction];
            
            if (tValue!=nil)
            {
                switch([tValue intValue])
                {
                    case 0:
                    case 4:
                        [tMutableString appendString:@"RequiresReboot NO\n"];
                        break;
                    case 1:
                    case 2:
                    case 3:
                        [tMutableString appendString:@"RequiresReboot YES\n"];
                        break;
                }
            }
            
            // UseUserMask
            
            [tMutableString appendString:@"UseUserMask NO\n"];
            
            // OverwritePermissions
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagOverwritePermissions];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"OverwritePermissions %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // InstallFat
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagInstallFat];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"InstallFat %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // AllowBackRev
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagAllowBackRev];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"AllowBackRev %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // RootVolumeOnly
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagRootVolumeOnly];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"RootVolumeOnly %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
            
            // OnlyUpdateInstalledLanguages
            
            tValue=[tOptionsDictionary objectForKey:IFPkgFlagUpdateInstalledLanguages];
            
            if (tValue!=nil)
            {
                [tMutableString appendString:[NSString stringWithFormat:@"OnlyUpdateInstalledLanguages %@\n",([tValue boolValue]==YES) ? @"YES" : @"NO"]];
            }
        }
    }
    
    return tMutableString;
}

#pragma mark -

- (unsigned long ) addCustomIconAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary;
{
    NSDictionary * tSettings;
    
    tSettings=[inDictionary objectForKey:@"Settings"];
    
    if (tSettings!=nil)
    {
        NSMutableDictionary * tDisplayInformationDictionary=nil;
        
        // Display Information
            
        tDisplayInformationDictionary=[tSettings objectForKey:@"Display Information"];
    
        if (tDisplayInformationDictionary!=nil)
        {
            NSString * tPath;
            
            tPath=[tDisplayInformationDictionary objectForKey:@"CFBundleIconFile"];
            
            if (tPath!=nil && [tPath length]>0)
            {
                NSNumber * tNumber;
                        
                tNumber=[tDisplayInformationDictionary objectForKey:@"CFBundleIconFile Path Type"];
                        
                if (tNumber!=nil)
                {
                    if ([tNumber intValue]==kRelativeToProjectPath)
                    {
                        tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                    }
                }
            
                if ([fileManager_ fileExistsAtPath:tPath]==YES)
                {
                    NSString * tExtension;
                            
                    tExtension=[PBExtensionUtilities extensionForIcnsFileAtPath:tPath];
                    
                    if (tExtension!=nil)
                    {
                        NDResourceFork * tNewResourceFork;
                        NSString * tIconName=@"Icon\r";
                        NSString * tNewIconPath;
                        NSData * tIconData;
                        FSRef fileRef;
                        FSRef folderRef;
                        
                        tIconData=[[NSData alloc] initWithContentsOfFile:tPath];
                        
                        if (tIconData!=nil)
                        {
                            tNewIconPath=[inPath stringByAppendingPathComponent:tIconName];
                        
                            // Create the Icon\r resource file
                            
                            tNewResourceFork=[[NDResourceFork alloc] initForWritingAtPath:tNewIconPath];
                            
                            if (tNewResourceFork!=nil)
                            {
                                [tNewResourceFork addData:tIconData type:'icns' Id:-16455 name:@""];
                            
                                [tNewResourceFork release];
                            }
                            else
                            {
                                // A COMPLETER
                                
                                return 1;
                            }
                            
                            [tIconData release];
                        }
                        else
                        {
                            // A COMPLETER
                            
                            return 1;
                        }
                    
                        // Set the file type and creator
                        
                        if ([tNewIconPath getFSRef:&fileRef]==YES)
                        {
                            FSCatalogInfo tCatalogInfo;
                        
                            if (noErr==FSGetCatalogInfo(&fileRef,kFSCatInfoFinderInfo,&tCatalogInfo,NULL,NULL,NULL))
                            {
                                FileInfo tFileInfo;
                                
                                memcpy((void *) &tFileInfo,(void *) &tCatalogInfo.finderInfo,sizeof(FileInfo));
                                
                                tFileInfo.fileType='icon';
                                tFileInfo.fileCreator='MACS';
                                
                                tFileInfo.finderFlags|=kIsInvisible;
                                
                                memcpy((void *) &tCatalogInfo.finderInfo,(void *) &tFileInfo,sizeof(FileInfo));
                                
                                if (noErr!=FSSetCatalogInfo(&fileRef,kFSCatInfoFinderInfo,&tCatalogInfo))
                                {
                                    // A COMPLETER
                                    
                                    return 1;
                                }
                            }
                            else
                            {
                                // A COMPLETER
                                
                                return 1;
                            }
                        }
                        else
                        {
                            // A COMPLETER
                            
                            return 1;
                        }
                    
                        // Set the Custom Icon flag
                        
                        if ([inPath getFSRef:&folderRef]==YES)
                        {
                            FSCatalogInfo tCatalogInfo;
                        
                            if (noErr==FSGetCatalogInfo(&folderRef,kFSCatInfoFinderInfo,&tCatalogInfo,NULL,NULL,NULL))
                            {
                                FolderInfo tFolderInfo;
                                
                                memcpy((void *) &tFolderInfo,(void *) &tCatalogInfo.finderInfo,sizeof(FolderInfo));
                                
                                tFolderInfo.finderFlags|=kHasCustomIcon;
                                
                                memcpy((void *) &tCatalogInfo.finderInfo,(void *) &tFolderInfo,sizeof(FolderInfo));
                                
                                if (noErr!=FSSetCatalogInfo(&folderRef,kFSCatInfoFinderInfo,&tCatalogInfo))
                                {
                                    // A COMPLETER
                                    
                                    return 1;
                                }
                            }
                            else
                            {
                                // A COMPLETER
                                
                                return 1;
                            }
                        }
                        else
                        {
                            // A COMPLETER
                            
                            return 1;
                        }
                    }
                    else
                    {
                        [self postNotificationWithCode:kPBErrorIncorrectFileType
                                                    arguments:[NSArray arrayWithObject:tPath]];
        
                        return 1;
                    }
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                            arguments:[NSArray arrayWithObject:tPath]];

                    return 1;
                }
            }
        }
    }
    
    return 0;
}

- (unsigned long) addBackgroundImageAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tResources;
        
    tResources=[inDictionary objectForKey:@"Documents"];
    
    if (tResources==nil)
    {
        tResources=[inDictionary objectForKey:@"Resources"];
    }
    
    if (tResources!=nil)
    {
        NSDictionary * tBackgroundImageDictionary;
        
        // Background Image
    
        tBackgroundImageDictionary=[tResources objectForKey:@"Background Image"];
    
        if (tBackgroundImageDictionary!=nil)
        {
            NSNumber * tMode;
            
            tMode=[tBackgroundImageDictionary objectForKey:@"Mode"];
        
            if (tMode!=nil)
            {
                if ([tMode intValue]==1)
                {
                    NSString * tPath;
                    NSNumber * tNumber;
                    
                    tPath=[tBackgroundImageDictionary objectForKey:@"Path"];
                    
                    tNumber=[tBackgroundImageDictionary objectForKey:@"Path Type"];
                        
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                        }
                    }
                    
                    if (tPath!=nil && [tPath length]>0)
                    {
                        [self postNotificationWithCode:kPBBuildingCopyBackgroundImage
                                             arguments:[NSArray arrayWithObject:tPath]];
                        
                        if ([fileManager_ fileExistsAtPath:tPath]==YES)
                        {
                            /*NSString * tExtension;
                            
                            tExtension=[PBExtensionUtilities extensionForImageFileAtPath:tPath];
                            
                            if (tExtension!=nil)*/
                            {
                                NSString * tDestinationPath;
                                
                               // tDestinationPath=[inPath stringByAppendingPathComponent:[NSString stringWithFormat:@"background.%@",tExtension]];
                                
								tDestinationPath=[inPath stringByAppendingPathComponent:@"background"];
								
                                if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                            }
                            /*else
                            {
                                [self postNotificationWithCode:kPBErrorIncorrectFileType
                                                     arguments:[NSArray arrayWithObject:tPath]];
        
                                return 1;
                            }*/
                        }
                        else
                        {
                            [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                 arguments:[NSArray arrayWithObject:tPath]];

                            return 1;
                            
                        }
                    }
                }
            }
        }
    }
    
    return 0;
}

- (unsigned long) addDocumentsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tResources;
    
    tResources=[inDictionary objectForKey:@"Documents"];
    
    if (tResources==nil)
    {
        tResources=[inDictionary objectForKey:@"Resources"];
    }
    
    if (tResources!=nil)
    {
        NSDictionary * tWelcome;
        NSDictionary * tReadMe;
        NSDictionary * tLicense;
        BOOL isDirectory;
        
        tWelcome=[tResources objectForKey:@"Welcome"];
        
        if (tWelcome!=nil)
        {
            NSEnumerator * tEnumerator = [tWelcome keyEnumerator];
            NSString * tLanguage;
            BOOL tNotificationPosted=NO;
            
            while ((tLanguage = (NSString *) [tEnumerator nextObject]))
            {
                NSDictionary * tLocalizedWelcome;
                
                tLocalizedWelcome=[tWelcome objectForKey:tLanguage];
                
                if (tLocalizedWelcome!=nil)
                {
                    NSNumber * tMode;
            
                    tMode=[tLocalizedWelcome objectForKey:@"Mode"];
                
                    if (tMode!=nil)
                    {
                        if ([tMode intValue]==1)
                        {
                            NSString * tPath;
                            NSNumber * tNumber;
                            
                            tPath=[tLocalizedWelcome objectForKey:@"Path"];
                            
                            tNumber=[tLocalizedWelcome objectForKey:@"Path Type"];
                        
                            if (tNumber!=nil)
                            {
                                if ([tNumber intValue]==kRelativeToProjectPath)
                                {
                                    tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                }
                            }
                            
                            if (tPath!=nil && [tPath length]>0)
                            {
                                if (tNotificationPosted==NO)
                                {
                                    tNotificationPosted=YES;
                                    
                                    [self postNotificationWithCode:kPBBuildingCopyWelcomeMessage
                                                         arguments:[NSArray arrayWithObject:tPath]];
                                }
                                
                                if ([fileManager_ fileExistsAtPath:tPath]==YES)
                                {
                                    NSString * tExtension;
                            
                                    tExtension=[PBExtensionUtilities extensionForTextFileAtPath:tPath];
                                    
                                    if (tExtension!=nil)
                                    {
                                        NSString * tDestinationPath;
                                        NSString * tLocalizationPath;
                            
                                        // Create the Folder if needed
                            
                                        if ([tLanguage isEqualToString:@"International"]==YES)
                                        {
                                            tLocalizationPath=inPath;
                                        }
                                        else
                                        {
                                            tLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                                        }
                                        
                                        if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                                        {
                                            if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                                            {
                                                return 1;
                                            }
                                        }
                                        
                                        if ([fileManager_ fileExistsAtPath:tPath isDirectory:&isDirectory]==YES)
                                        {
                                            tDestinationPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Welcome.%@",tExtension]];
                                            
                                            if (isDirectory==YES)
                                            {
                                                NSArray * tArray;
                                                int i,tCount;
                                                
                                                if ([self createDirectoryAtPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                                
                                                // Copy the internal files
                                                
                                                tArray=[fileManager_ directoryContentsAtPath:tPath];
                                                
                                                tCount=[tArray count];
                                                
                                                for(i=0;i<tCount;i++)
                                                {
                                                    NSString * tFileName;
                                                    
                                                    tFileName=[tArray objectAtIndex:i];
                                                    
                                                    if ([tFileName isEqualToString:@".DS_Store"]==NO)
                                                    {
                                                        NSString * tFileCompletePath;
                                                        
                                                        tFileCompletePath=[tDestinationPath stringByAppendingPathComponent:tFileName];
                                                        
                                                        if ([self copyObjectAtPath:[tPath stringByAppendingPathComponent:tFileName] toPath:tFileCompletePath]==NO)
                                                        {
                                                            return 1;
                                                        }
                                                        
                                                        if ([self setFileAttributesAtPath:tFileCompletePath]==NO)
                                                        {
                                                            return 1;
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                                
                                                if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                                 arguments:[NSArray arrayWithObject:tPath]];
        
                                            return 1;
                                        }
                                    }
                                    else
                                    {
                                        [self postNotificationWithCode:kPBErrorIncorrectFileType
                                                             arguments:[NSArray arrayWithObject:tPath]];
        
                                        return 1;
                                    }
                                }
                                else
                                {
                                    [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                         arguments:[NSArray arrayWithObject:tPath]];
    
                                    return 1;
                                    
                                }
                            }
                        }
                    }
                }
            } 
        }
        
        tReadMe=[tResources objectForKey:@"ReadMe"];
        
        if (tReadMe!=nil)
        {
            NSEnumerator * tEnumerator = [tReadMe keyEnumerator];
            NSString * tLanguage;
            BOOL tNotificationPosted=NO;
            
            while ((tLanguage = (NSString *) [tEnumerator nextObject]))
            {
                NSDictionary * tLocalizedReadMe;
                
                tLocalizedReadMe=[tReadMe objectForKey:tLanguage];
                
                if (tLocalizedReadMe!=nil)
                {
                    NSNumber * tMode;
            
                    tMode=[tLocalizedReadMe objectForKey:@"Mode"];
                
                    if (tMode!=nil)
                    {
                        if ([tMode intValue]==1)
                        {
                            NSString * tPath;
                            NSNumber * tNumber;
                            
                            tPath=[tLocalizedReadMe objectForKey:@"Path"];
                            
                            tNumber=[tLocalizedReadMe objectForKey:@"Path Type"];
                        
                            if (tNumber!=nil)
                            {
                                if ([tNumber intValue]==kRelativeToProjectPath)
                                {
                                    tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                }
                            }
                            
                            if (tPath!=nil && [tPath length]>0)
                            {
                                if (tNotificationPosted==NO)
                                {
                                    tNotificationPosted=YES;
                                    
                                    [self postNotificationWithCode:kPBBuildingCopyReadMeMessage
                                                         arguments:[NSArray arrayWithObject:tPath]];
                                }
                                
                                if ([fileManager_ fileExistsAtPath:tPath]==YES)
                                {
                                    NSString * tExtension;
                            
                                    tExtension=[PBExtensionUtilities extensionForTextFileAtPath:tPath];
                                    
                                    if (tExtension!=nil)
                                    {
                                        NSString * tDestinationPath;
                                        NSString * tLocalizationPath;
                            
                                        // Create the Folder if needed
                            
                                        if ([tLanguage isEqualToString:@"International"]==YES)
                                        {
                                            tLocalizationPath=inPath;
                                        }
                                        else
                                        {
                                            tLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                                        }
                                        
                                        if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                                        {
                                            if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                                            {
                                                return 1;
                                            }
                                        }
                                        
                                        if ([fileManager_ fileExistsAtPath:tPath isDirectory:&isDirectory]==YES)
                                        {
                                            tDestinationPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"ReadMe.%@",tExtension]];
                                            
                                            if (isDirectory==YES)
                                            {
                                                NSArray * tArray;
                                                int i,tCount;
                                                
                                                if ([self createDirectoryAtPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                                
                                                // Copy the internal files
                                                
                                                tArray=[fileManager_ directoryContentsAtPath:tPath];
                                                
                                                tCount=[tArray count];
                                                
                                                for(i=0;i<tCount;i++)
                                                {
                                                    NSString * tFileName;
                                                    
                                                    tFileName=[tArray objectAtIndex:i];
                                                    
                                                    if ([tFileName isEqualToString:@".DS_Store"]==NO)
                                                    {
                                                        NSString * tFileCompletePath;
                                                        
                                                        tFileCompletePath=[tDestinationPath stringByAppendingPathComponent:tFileName];
                                                        
                                                        if ([self copyObjectAtPath:[tPath stringByAppendingPathComponent:tFileName] toPath:tFileCompletePath]==NO)
                                                        {
                                                            return 1;
                                                        }
                                                        
                                                        if ([self setFileAttributesAtPath:tFileCompletePath]==NO)
                                                        {
                                                            return 1;
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                                
                                                if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                                 arguments:[NSArray arrayWithObject:tPath]];
        
                                            return 1;
                                        }
                                    }
                                    else
                                    {
                                        [self postNotificationWithCode:kPBErrorIncorrectFileType
                                                             arguments:[NSArray arrayWithObject:tPath]];
        
                                        return 1;
                                    }
                                }
                                else
                                {
                                    [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                         arguments:[NSArray arrayWithObject:tPath]];
    
                                    return 1;
                                    
                                }
                            }
                        }
                    }
                }
            } 
        }
        
        tLicense=[tResources objectForKey:@"License"];
        
        if (tReadMe!=nil)
        {
            NSEnumerator * tEnumerator = [tLicense keyEnumerator];
            NSString * tLanguage;
			BOOL tNotificationPosted=NO;
			
            while ((tLanguage = (NSString *) [tEnumerator nextObject]))
            {
                NSDictionary * tLocalizedLicense;
                
                tLocalizedLicense=[tLicense objectForKey:tLanguage];
                
                if (tLocalizedLicense!=nil)
                {
                    NSNumber * tMode;
            
                    tMode=[tLocalizedLicense objectForKey:@"Mode"];
                
                    if (tMode!=nil)
                    {
                        NSString * tPath=nil;
                        NSNumber * tNumber;
                        
                        switch([tMode intValue])
                        {
                            case 0:	
                                break;
                            case 1:
                                tPath=[tLocalizedLicense objectForKey:@"Path"];
                                
                                tNumber=[tLocalizedLicense objectForKey:@"Path Type"];
                        
                                if (tNumber!=nil)
                                {
                                    if ([tNumber intValue]==kRelativeToProjectPath)
                                    {
                                        tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                    }
                                }
                                
                                if (tPath!=nil && [tPath length]>0)
                                {
                                    if (tNotificationPosted==NO)
									{
										tNotificationPosted=YES;
										
										[self postNotificationWithCode:kPBBuildingCopyLicenseDocuments
															 arguments:[NSArray arrayWithObject:tPath]];
									}
									
									if ([fileManager_ fileExistsAtPath:tPath]==YES)
                                    {
                                        NSString * tExtension;
                                
                                        tExtension=[PBExtensionUtilities extensionForTextFileAtPath:tPath];
                                        
                                        if (tExtension!=nil)
                                        {
                                            NSString * tDestinationPath;
                                            NSString * tLocalizationPath;
                                
                                            // Create the Folder if needed
                                
                                            if ([tLanguage isEqualToString:@"International"]==YES)
                                            {
                                                tLocalizationPath=inPath;
                                            }
                                            else
                                            {
                                                tLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                                            }
                                            
                                            if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                                            {
                                                if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                                                {
                                                    return 1;
                                                }
                                            }
                                            
                                            if ([fileManager_ fileExistsAtPath:tPath isDirectory:&isDirectory]==YES)
                                            {
                                                tDestinationPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"License.%@",tExtension]];
                                                
                                                if (isDirectory==YES)
                                                {
                                                    NSArray * tArray;
                                                    int i,tCount;
                                                    
                                                    if ([self createDirectoryAtPath:tDestinationPath]==NO)
                                                    {
                                                        return 1;
                                                    }
                                                    
                                                    // Copy the internal files
                                                    
                                                    tArray=[fileManager_ directoryContentsAtPath:tPath];
                                                    
                                                    tCount=[tArray count];
                                                    
                                                    for(i=0;i<tCount;i++)
                                                    {
                                                        NSString * tFileName;
                                                        
                                                        tFileName=[tArray objectAtIndex:i];
                                                        
                                                        if ([tFileName isEqualToString:@".DS_Store"]==NO)
                                                        {
                                                            NSString * tFileCompletePath;
                                                            
                                                            tFileCompletePath=[tDestinationPath stringByAppendingPathComponent:tFileName];
                                                            
                                                            if ([self copyObjectAtPath:[tPath stringByAppendingPathComponent:tFileName] toPath:tFileCompletePath]==NO)
                                                            {
                                                                return 1;
                                                            }
                                                            
                                                            if ([self setFileAttributesAtPath:tFileCompletePath]==NO)
                                                            {
                                                                return 1;
                                                            }
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                                    {
                                                        return 1;
                                                    }
                                                    
                                                    if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                                                    {
                                                        return 1;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                                    arguments:[NSArray arrayWithObject:tPath]];
            
                                                return 1;
                                            }
                                        }
                                        else
                                        {
                                            [self postNotificationWithCode:kPBErrorIncorrectFileType
                                                             arguments:[NSArray arrayWithObject:tPath]];
        
                                            return 1;
                                        }
                                    }
                                    else
                                    {
                                        [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                             arguments:[NSArray arrayWithObject:tPath]];
        
                                        return 1;
                                        
                                    }
                                }
                                break;
                            case 2:
                                tPath=[[PBLicenseProvider defaultProvider] pathForLicenseWithName:[tLocalizedLicense objectForKey:@"Template"]
                                                                                         language:tLanguage];
                        
                            
                                if (tNotificationPosted==NO)
								{
									tNotificationPosted=YES;
									
									[self postNotificationWithCode:kPBBuildingCopyLicenseDocuments
														 arguments:[NSArray array]];
								}
								
								if (tPath!=nil)
                                {
                                    if ([fileManager_ fileExistsAtPath:tPath]==YES)
                                    {
                                        NSString * tExtension;
                                
                                        tExtension=[PBExtensionUtilities extensionForTextFileAtPath:tPath];
                                        
                                        if (tExtension!=nil)
                                        {
                                            NSMutableString * tMutableString;
                                    
                                            tMutableString=[[NSMutableString alloc] initWithContentsOfFile:tPath];
                                            
                                            if (tMutableString!=nil)
                                            {
                                                // Replace the keywords
                    
                                                NSDictionary * tKeywords;
                                                NSString * tDestinationPath;
                                                NSString * tLocalizationPath;
                                            
                                                tKeywords=[tLocalizedLicense objectForKey:@"Keywords"];
                                                
                                                if (tKeywords!=nil && [tKeywords count]>0)
                                                {
                                                    [PBLicenseProvider replaceKeywords:tKeywords
                                                                              inString:tMutableString];
                                                }
                                                
                                            	// Create the Folder if needed
                                
                                                if ([tLanguage isEqualToString:@"International"]==YES)
                                                {
                                                    tLocalizationPath=inPath;
                                                }
                                                else
                                                {
                                                    tLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                                                }
                                                
                                                if ([fileManager_ fileExistsAtPath:tLocalizationPath]==NO)
                                                {
                                                    if ([self createDirectoryAtPath:tLocalizationPath]==NO)
                                                    {
                                                        return 1;
                                                    }
                                                }
                                                
                                                tDestinationPath=[tLocalizationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"License.%@",tExtension]];
                                                
                                                if ([tMutableString writeToFile:tDestinationPath atomically:IS_ATOMICAL]==NO)
                                                {
                                                    [self postNotificationWithCode:kPBErrorCantCreateFile
                                                                         arguments:[NSArray arrayWithObject:tDestinationPath]];
        
                                                    return 1;
                                                }
                                                
                                                if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                                                {
                                                    return 1;

                                                }
                                            }
                                            else
                                            {
                                                [self postNotificationWithCode:kPBErrorOutOfMemory
                                                                     arguments:nil];
        
                                                return 1;
                                            }
                                        }
                                        else
                                        {
                                            // A COMPLETER
                                        }
                                    }
                                    else
                                    {
                                        // The license template was not found
                                        
                                        [self postNotificationWithCode:kPBErrorMissingLicenseTemplate
                                                             arguments:[NSArray arrayWithObjects:tPath,tLanguage,nil]];
        
                                        return 1;
                                    }
                                }
                                else
                                {
                                    // The license template was not found
                                        
                                    [self postNotificationWithCode:kPBErrorMissingLicenseTemplate
                                                         arguments:[NSArray arrayWithObjects:[tLocalizedLicense objectForKey:@"Template"],tLanguage,nil]];
        
                                    return 1;
                                }
                                
                                break;
                        }                        
                    }
                }
            } 
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Documents"]];
                
        return 1;
    }
    
    return 0;
}

- (unsigned long) addScriptsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tScripts;
    
    tScripts=[inDictionary objectForKey:@"Scripts"];
    
    if (tScripts!=nil)
    {
        NSDictionary * tInstallationScripts;
        NSDictionary * tAdditionalResources;
        NSDictionary * tDictionary;
        NSArray * tRequirements;
        
        NSNumber * tStatus;
        
        // Create the Requirements strings file if needed
        
        tRequirements=[tScripts objectForKey:@"Requirements"];
                
        if (tRequirements!=nil)
        {
            int i,tCount;
            NSDictionary * tRequirementObject;
            
            tCount=[tRequirements count];
                    
            if (tCount>0)
            {
            	NSMutableDictionary * tRequirementsStringDictionary;
                NSEnumerator * tKeyEnumerator;
                NSString * tLocationKey;
                BOOL tNotificationPosted=NO;
                
                tRequirementsStringDictionary=[NSMutableDictionary dictionary];
                
                for(i=0;i<tCount;i++)
                {
                    NSNumber * tNumber;
                    NSDictionary * tAlertDialogDictionary;
                    NSEnumerator * tLanguageEnumerator;
                    NSString * tLanguage;
                    
                    tRequirementObject=[tRequirements objectAtIndex:i];
                    
                    tNumber=[tRequirementObject objectForKey:@"Status"];
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber boolValue]==NO)
                        {
                            continue;
                        }
                    }
                    
                    if (tNotificationPosted==NO)
                    {
                        tNotificationPosted=YES;
                        
                        [self postNotificationWithCode:kPBBuildingBuildRequirements
                                             arguments:[NSArray array]];
                    }
                    
                    // TitleKey and MessageKey
                            
                    tAlertDialogDictionary=[tRequirementObject objectForKey:@"AlertDialog"];
                    
                    tLanguageEnumerator=[tAlertDialogDictionary keyEnumerator];
                    
                    while ((tLanguage=(NSString *) [tLanguageEnumerator nextObject])!=nil)
                    {
                        NSDictionary * tLocalizedAlertDialogDictionary;
                        NSString * tTitleKey;
                        NSString * tMessageKey;
                    
                        tLocalizedAlertDialogDictionary=[tAlertDialogDictionary objectForKey:tLanguage];
                        
                        tTitleKey=[tLocalizedAlertDialogDictionary objectForKey:@"TitleKey"];
                        tMessageKey=[tLocalizedAlertDialogDictionary objectForKey:@"MessageKey"];
                        
                        if ([tTitleKey length]>0 || [tMessageKey length]>0)
                        {
                            NSString * tBaseLocalizationPath;
                            NSString * tDestinationPath;
                            NSMutableString * tMutableString;
                            
                            // Create the Folder if needed
                                
                            if ([tLanguage isEqualToString:@"International"]==YES)
                            {
                                tBaseLocalizationPath=inPath;
                            }
                            else
                            {
                                tBaseLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                                // Check that the folder exists
                                
                                if ([fileManager_ fileExistsAtPath:tBaseLocalizationPath]==NO)
                                {
                                    if ([self createDirectoryAtPath:tBaseLocalizationPath]==NO)
                                    {
                                        return 1;
                                    }
                                }
                            
                            }
                            
                            tDestinationPath=[tBaseLocalizationPath stringByAppendingPathComponent:@"IFRequirement.strings"];
                            
                            tMutableString=[tRequirementsStringDictionary objectForKey:tDestinationPath];
                            
                            if (tMutableString==nil)
                            {
                                tMutableString=[NSMutableString string];
                            }
                            
                            [tMutableString appendString:[NSString stringWithFormat:@"\"titlekey%d\" = \"%@\";\n\n",i,tTitleKey]];
                            
                            [tMutableString appendString:[NSString stringWithFormat:@"\"messagekey%d\" = \"%@\";\n\n",i,tMessageKey]];
                            
                            [tRequirementsStringDictionary setObject:tMutableString forKey:tDestinationPath];
                            
                            
                        }
                    }
                }
               
                tKeyEnumerator=[tRequirementsStringDictionary keyEnumerator];
               
                while (tLocationKey=[tKeyEnumerator nextObject])
                {
                    NSMutableString * tMutableString;
                    
                    tMutableString=[tRequirementsStringDictionary objectForKey:tLocationKey];
                    
                    // 05/24/2006 (S.S): Modification to save the .strings file in Unicode Encoding
                    
                    if (tMutableString!=nil)
                    {
                        NSData * tData;
                        BOOL tWriteResult=NO;
                        
                        tData=[tMutableString dataUsingEncoding:NSUnicodeStringEncoding];
                        
                        if (tData==nil)
                        {
                            tWriteResult=[tMutableString writeToFile:tLocationKey atomically:IS_ATOMICAL];
                        }
                        else
                        {
                            tWriteResult=[tData writeToFile:tLocationKey atomically:IS_ATOMICAL];
                        }
                    
                        if (tWriteResult==NO)
                        {
                            [self postNotificationWithCode:kPBErrorCantCreateFile
                                                 arguments:[NSArray arrayWithObject:tLocationKey]];

                            return 1;
                        }
                    
                        if ([self setFileAttributesAtPath:tLocationKey]==NO)
                        {
                            return 1;
                        }
                    }
                }
            }
        }
        
        // Copy the Installation scripts
        
        tInstallationScripts=[tScripts objectForKey:@"Installation Scripts"];
        
        if (tInstallationScripts!=nil)
        {
            int i,tCount;
            BOOL tNotificationPosted=NO;
            NSArray * tArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPreflight,@"Key",
                                                                                           @"preflight",@"Name",
                                                                                           nil],
                                                       [NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPostflight,@"Key",
                                                                                           @"postflight",@"Name",
                                                                                           nil],
                                                       nil];
            NSString * tPath;
            
            // We process preflight and postflight first as they are named the same on any OS release
            
            tCount=[tArray count];
            
            for(i=0;i<tCount;i++)
            {
                tDictionary=[tInstallationScripts objectForKey:[[tArray objectAtIndex:i] objectForKey:@"Key"]];
                
                if (tDictionary!=nil)
                {
                    tStatus=[tDictionary objectForKey:@"Status"];
                    
                    if ([tStatus boolValue]==YES)
                    {
                        tPath=[tDictionary objectForKey:@"Path"];
                    
                        if ([tPath length]>0)
                        {
                            NSNumber * tNumber;
                            
                            if (tNotificationPosted==NO)
                            {
                                tNotificationPosted=YES;
                                
                                [self postNotificationWithCode:kPBBuildingCopyScripts
                                                    arguments:[NSArray array]];
                            }
                            
                            tNumber=[tDictionary objectForKey:@"Path Type"];
                            
                            if (tNumber!=nil)
                            {
                                if ([tNumber intValue]==kRelativeToProjectPath)
                                {
                                    tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                }
                            }
                            
                            if ([fileManager_ fileExistsAtPath:tPath]==YES)
                            {
                                NSString * tDestinationPath;
                                
                                tDestinationPath=[inPath stringByAppendingPathComponent:[[tArray objectAtIndex:i] objectForKey:@"Name"]];
                                
                                if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                // Set the proper file permissions (755)
                                
                                if ([self setFilePrivileges:S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH atPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                            }
                            else
                            {
                                [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                    arguments:[NSArray arrayWithObject:tPath]];
    
                                return 1;
                            }
                        }
                    }
                }
                else
                {
                    // A COMPLETER
                }
            }
            
            tArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPreinstall,@"Key",
                                                                                 @"preinstall",@"Name",
                                                                                 @"pre_install",@"Old Suffix",
                                                                                 nil],
                                             [NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPreupgrade,@"Key",
                                                                                 @"preupgrade",@"Name",
                                                                                 @"pre_upgrade",@"Old Suffix",
                                                                                 nil],
                                             [NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPostinstall,@"Key",
                                                                                 @"postinstall",@"Name",
                                                                                 @"post_install",@"Old Suffix",
                                                                                 nil],
                                             [NSDictionary dictionaryWithObjectsAndKeys:IFInstallationScriptsPostupgrade,@"Key",
                                                                                 @"postupgrade",@"Name",
                                                                                 @"post_upgrade",@"Old Suffix",
                                                                                 nil],
                                             nil];

            tCount=[tArray count];
            
            
            
            for(i=0;i<tCount;i++)
            {
                tDictionary=[tInstallationScripts objectForKey:[[tArray objectAtIndex:i] objectForKey:@"Key"]];
                
                if (tDictionary!=nil)
                {
                    tStatus=[tDictionary objectForKey:@"Status"];
                    
                    if ([tStatus boolValue]==YES)
                    {
                        tPath=[tDictionary objectForKey:@"Path"];
                        
                        if ([tPath length]>0)
                        {
                            NSNumber * tNumber;
                            
                            if (tNotificationPosted==NO)
                            {
                                tNotificationPosted=YES;
                                
                                [self postNotificationWithCode:kPBBuildingCopyScripts
                                                    arguments:[NSArray array]];
                            }
                            
                            tNumber=[tDictionary objectForKey:@"Path Type"];
                            
                            if (tNumber!=nil)
                            {
                                if ([tNumber intValue]==kRelativeToProjectPath)
                                {
                                    tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                }
                            }
                            
                            if ([fileManager_ fileExistsAtPath:tPath]==YES)
                            {
                                NSString * tDestinationPath;
                                
                                tDestinationPath=[inPath stringByAppendingPathComponent:[[tArray objectAtIndex:i] objectForKey:@"Name"]];
                                
                                if ([self copyObjectAtPath:tPath toPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                if ([self setFilePrivileges:S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH atPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                if (cheetahCompatibility_==YES)
                                {
                                    NSString * tLinkPath;
                                    NSString * tPackageName;
    
                                    tPackageName=[[[[inPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] lastPathComponent] stringByDeletingPathExtension];
    
                                    tLinkPath=[inPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",tPackageName,[[tArray objectAtIndex:i] objectForKey:@"Old Suffix"]]];
                                    
                                    if (-1==symlink([[NSString stringWithFormat:@"./%@",[tDestinationPath lastPathComponent]] fileSystemRepresentation],[tLinkPath fileSystemRepresentation]))
                                    {
                                        // A COMPLETER
                                    }
                                }
                            }
                            else
                            {
                                [self postNotificationWithCode:kPBErrorFileDoesNotExist
                                                    arguments:[NSArray arrayWithObject:tPath]];
    
                                return 1;
                            }
                        }
                    }
                }
                else
                {
                    // A COMPLETER
                }
            }
        }
        
        // Copy the Additional resources
    
        tAdditionalResources=[tScripts objectForKey:@"Additional Resources"];
        
        if (tAdditionalResources!=nil)
        {
            NSEnumerator * tEnumerator = [tAdditionalResources keyEnumerator];
            NSString * tLanguage;
            BOOL tNotificationPosted=NO;
            
            
            while ((tLanguage = (NSString *) [tEnumerator nextObject]))
            {
                NSArray * tLocalizedAdditionalResources;
                
                tLocalizedAdditionalResources=[tAdditionalResources objectForKey:tLanguage];
                
                if (tLocalizedAdditionalResources!=nil)
                {
                    int i,tCount;
                    NSDictionary * tResource;
                    BOOL needToCopyFiles=NO;
                        
                    tCount=[tLocalizedAdditionalResources count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        tResource=[tLocalizedAdditionalResources objectAtIndex:i];
                        
                        if ([[tResource objectForKey:@"Status"] boolValue]==YES)
                        {
                            needToCopyFiles=YES;
                            break;
                        }
                    }
                    
                    if (tCount>0 && needToCopyFiles==YES)
                    {
                        NSString * tBaseLocalizationPath;
                        NSString * tPath;
                        NSString * tDestinationPath;
                        BOOL tStatus;
                        BOOL tInternational=NO;
                        
                        // Create the Folder if needed
                            
                        if (tNotificationPosted==NO)
                        {
                            tNotificationPosted=YES;
                            
                            [self postNotificationWithCode:kPBBuildingCopyAdditionalResources
                                                 arguments:[NSArray array]];
                        }
                            
                        if ([tLanguage isEqualToString:@"International"]==YES)
                        {
                            tBaseLocalizationPath=inPath;
                            
                            tInternational=YES;
                        }
                        else
                        {
                            tBaseLocalizationPath=[inPath stringByAppendingPathComponent:[tLanguage stringByAppendingString:@".lproj"]];
                        }
                        
                        if ([fileManager_ fileExistsAtPath:tBaseLocalizationPath]==NO)
                        {
                            if ([self createDirectoryAtPath:tBaseLocalizationPath]==NO)
                            {
                                return 1;
                            }
                        }
                        
                        // Add the files
                        
                        for(i=0;i<tCount;i++)
                        {
                            tResource=[tLocalizedAdditionalResources objectAtIndex:i];
                            
                            tStatus=[[tResource objectForKey:@"Status"] boolValue];
                            
                            if (tStatus==YES)
                            {
                                tPath=[tResource objectForKey:@"Path"];
                                
                            	if (tPath!=nil)
                                {
                                    NSNumber * tNumber;
                                    NSString * tFileName;
                                    
                                    tNumber=[tResource objectForKey:@"Path Type"];
                            
                                    if (tNumber!=nil)
                                    {
                                        if ([tNumber intValue]==kRelativeToProjectPath)
                                        {
                                            tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                                        }
                                    }
                                    
                                    tFileName=[tPath lastPathComponent];
                                    
                                    tDestinationPath=[tBaseLocalizationPath stringByAppendingPathComponent:tFileName];
                                    
                                    //if ([fileManager_ copyPath:tPath toPath:tDestinationPath handler:nil]==NO)
                                    
                                    if ([PBProjectBuilder copyPath:tPath toPath:tBaseLocalizationPath]==NO)	// A TESTER
                                    {
                                        [self postNotificationWithCode:kPBErrorCantCopyFile
                                                            arguments:[NSArray arrayWithObjects:tPath,
                                                                                                tDestinationPath,
                                                                                                nil]];
            
                                        return 1;
                                    }
                                    
                                    // If it's the InstallationCheck or VolumeCheck file, we need to be sure the permissions are ok
                                    
                                    if ([tFileName isEqualToString:@"InstallationCheck"]==YES ||
                                        [tFileName isEqualToString:@"VolumeCheck"]==YES)
                                    {
                                        [self setFilePrivileges:S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH atPath:tDestinationPath];
                                    }
                                }
                                else
                                {
                                    // A COMPLETER (warning)
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Additional Resources"]];
                
            return 1;
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Scripts"]];
                
        return 1;
    }
    
    return 0;
}

- (unsigned long) addPluginsAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
	NSDictionary * tPlugins;
    
    tPlugins=[inDictionary objectForKey:@"Plugins"];
    
    if (tPlugins!=nil)
    {
		NSArray * tPluginsList;
		
		tPluginsList=[tPlugins objectForKey:@"PluginsList"];
		
		if (tPluginsList!=nil)
		{
			NSEnumerator * tEnumerator;
			NSDictionary * tPluginDictionary;
			NSMutableArray * tSectionOrder;
			
			tEnumerator=[tPluginsList objectEnumerator];
			
			tSectionOrder=[NSMutableArray arrayWithCapacity:6];
			
			if (tSectionOrder!=nil)
			{
				BOOL hasCustomPlugin=NO;
				NSString * tPluginsPath=nil;
				
				while (tPluginDictionary=[tEnumerator nextObject])
				{
					NSNumber * tNumber;
					
					tNumber=[tPluginDictionary objectForKey:@"Type"];
					
					if (tNumber!=nil)
					{
						NSString * tPath;
						
						switch([tNumber intValue])
						{
							case kPluginDefaultStep:
							
								tPath=[tPluginDictionary objectForKey:@"Path"];
								
								if (tPath!=nil)
								{
									if ([tPath isEqualToString:@"FinishUp"]==NO)
									{
										[tSectionOrder addObject:tPath];
									}
								}
								
								break;
							case kPluginCustomizedStep:
								
								tNumber=[tPluginDictionary objectForKey:@"Status"];
								
								if (tNumber!=nil && [tNumber boolValue]==YES)
								{
									if (hasCustomPlugin==NO)
									{
										// We need to create the Plugins folder
										
										tPluginsPath=[inPath stringByAppendingPathComponent:@"Plugins"];
										
										if ([fileManager_ fileExistsAtPath:tPluginsPath]==NO)
										{
											if ([self createDirectoryAtPath:tPluginsPath]==NO)
											{
												return 1;
											}
										}
										
										hasCustomPlugin=YES;
										
										[self postNotificationWithCode:kPBBuildingCopyingPlugins
															 arguments:nil];
									}
									
									tPath=[tPluginDictionary objectForKey:@"Path"];
									
									if (tPath!=nil)
									{
										NSNumber * tNumber;
										NSString * tFileName;
										NSString * tDestinationPath;
										
										tNumber=[tPluginDictionary objectForKey:@"Path Type"];
								
										if (tNumber!=nil)
										{
											if ([tNumber intValue]==kRelativeToProjectPath)
											{
												tPath=[tPath stringByAbsolutingWithPath:referencePath_];
											}
										}
										
										tFileName=[tPath lastPathComponent];
										
										[tSectionOrder addObject:tFileName];
										
										tDestinationPath=[tPluginsPath stringByAppendingPathComponent:tFileName];
										
										if ([PBProjectBuilder copyPath:tPath toPath:tPluginsPath]==NO)
										{
											[self postNotificationWithCode:kPBErrorCantCopyFile
																 arguments:[NSArray arrayWithObjects:tPath,
																									 tPluginsPath,
																									 nil]];
				
											return 1;
										}
										
										// Set File Permissions
										
										[self setFilePrivileges:S_IRWXU+S_IRGRP+S_IXGRP+S_IROTH+S_IXOTH atPath:tDestinationPath];
									}
									else
									{
										// A COMPLETER (warning)
									}
								}
								break;
							default:
								break;
						}
					}
					else
					{
						return 1;
					}
				}
				
				if (hasCustomPlugin==YES && tPluginsPath!=nil)
				{
					NSDictionary * tInstallerSectionsDictionary;
					
					// Create the InstallerSections.plist file
					
					tInstallerSectionsDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tSectionOrder,@"SectionOrder",nil];
					
					if (tInstallerSectionsDictionary!=nil)
					{
						NSString * tPath;
						
						tPath=[tPluginsPath stringByAppendingPathComponent:@"InstallerSections.plist"];
						
						if ([tInstallerSectionsDictionary writeToFile:tPath atomically:IS_ATOMICAL]==YES)
						{
							[self setFilePrivileges:S_IRUSR+S_IWUSR+S_IRGRP+S_IROTH atPath:tPath];
						}
						else
						{
							[self postNotificationWithCode:kPBErrorCantCreateFile
												 arguments:[NSArray arrayWithObject:tPath]];
                                                        
							return 1;
						}
					}
					else
					{
						[self postNotificationWithCode:kPBErrorOutOfMemory
											 arguments:nil];
                                                        
						return 1;
					}
					
				}
			}
			else
			{
				[self postNotificationWithCode:kPBErrorOutOfMemory
									 arguments:nil];
                                                        
				return 1;
			}
		}
	}
	
	return 0;
}

- (int) buildArchiveInfoAtPath:(NSString *) inPath
{
    int64_t tInstalledSize;
    NSString * tSizeInfoString;
    NSString * tDestinationPath;
        
    tInstalledSize=installedSize_;
    
    if (tInstalledSize==-1)
    {
        tInstalledSize=0;
    }
    
    tSizeInfoString=[NSString stringWithFormat:@"NumFiles 0\nInstalledSize %lld\nCompressedSize %lld\n",tInstalledSize,compressedSize_];    
    
    tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.sizes"];
    
    if ([tSizeInfoString writeToFile:tDestinationPath atomically:IS_ATOMICAL]==YES)
    {
        // Set File Permission (644)
        
        if ([self setFilePrivileges:S_IRUSR+S_IWUSR+S_IRGRP+S_IROTH atPath:tDestinationPath]==NO)
        {
            // A COMPLETER
        }
        
        if (cheetahCompatibility_==YES)
        {
            NSString * tPackageName;
            NSString * tArchiveCheetahPath;
            
            tPackageName=[[[[inPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] lastPathComponent] stringByDeletingPathExtension];
            
            tArchiveCheetahPath=[inPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sizes",tPackageName]];
                    
            if (-1==symlink("./Archive.sizes",[tArchiveCheetahPath fileSystemRepresentation]))
            {
                // A COMPLETER
            }
        }
    }
    else
    {
        // A COMPLETER
    }
    
    return 0;
}

- (int) buildPackageVersionAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tVersionDictionary;
    int tMinorVersion=0;
    int tMajorVersion=0;
    NSString * tString;
    
    // Package version
            
    tVersionDictionary=[inDictionary objectForKey:@"Version"];
    
    if (tVersionDictionary!=nil)
    {
        NSNumber * tNumber;
        
        tNumber=[tVersionDictionary objectForKey:IFMajorVersion];
        
        if (tNumber!=nil)
        {
            tMajorVersion=[tNumber intValue];
        }
        
        tNumber=[tVersionDictionary objectForKey:IFMinorVersion];
        
        if (tNumber!=nil)
        {
            tMinorVersion=[tNumber intValue];
        }
    }
    
    tString=[NSString stringWithFormat:@"Major:\t%d\nMinor:\t%d\n",tMajorVersion,tMinorVersion];
    
    if (tString!=nil)
    {
        NSString * tPath;
        
        tPath=[inPath stringByAppendingPathComponent:@"package_version"];
        
        if ([tString writeToFile:tPath atomically:IS_ATOMICAL]==NO)
        {
            [self postNotificationWithCode:kPBErrorCantCreateFile
                                    arguments:[NSArray arrayWithObject:tPath]];

            return 1;
        }
        else
        {
            // Set the appropriate file permissions
            
            if ([self setFilePrivileges:S_IRUSR+S_IWUSR+S_IRGRP+S_IROTH atPath:tPath]==NO)
            {
                // A COMPLETER
            }
        }
    }
    else
    {
        // A COMPLETER
    }
    
    return 0;
}

#pragma mark -

- (int) buildPaxArchiveAtPath:(NSString *) inPath withDictionary:(NSDictionary *) inDictionary
{
    NSDictionary * tFilesDictionary;
    NSString * tPackageName;
    
    tPackageName=[[[inPath stringByDeletingLastPathComponent] lastPathComponent] stringByDeletingPathExtension];
    
    tFilesDictionary=[inDictionary objectForKey:@"Files"];
    
    importedPackage_=NO;
    
    if (tFilesDictionary!=nil)
    {
        NSNumber * tNumber;
        
        tNumber=[tFilesDictionary objectForKey:@"Imported Package"];
        
        if (tNumber!=nil)
        {
            NSString * tDestinationPath=nil;
            NSString * tPaxExtension=@"";
            
            [self postNotificationWithCode:kPBBuildingArchive
                                 arguments:[NSArray arrayWithObject:[[inPath stringByDeletingLastPathComponent] lastPathComponent]]];
            
            
            if ([tNumber boolValue]==YES)
            {
                // Imported Package
                
                NSString * tPackagePath;
                NSString * tPackageName;
                NSString * tSourcePath;
                NSNumber * tPackageTypeNumber;
                
                importedPackage_=YES;
                
                tPackagePath=[tFilesDictionary objectForKey:@"Package Path"];
                
                tPackageTypeNumber=[tFilesDictionary objectForKey:@"Package Path Type"];
                        
                if (tPackageTypeNumber!=nil)
                {
                    if ([tPackageTypeNumber intValue]==kRelativeToProjectPath)
                    {
                        tPackagePath=[tPackagePath stringByAbsolutingWithPath:referencePath_];
                    }
                }
                
                tPackageName=[[tPackagePath lastPathComponent] stringByDeletingPathExtension];
                
                if (tPackagePath!=nil)
                {
                    NSString * tContentsPath;
                    BOOL tArchiveFound=NO;
                    BOOL oldFormat=NO;
                    NSString * tBeginningOfArchivePath=nil;
                    
                    tContentsPath=[tPackagePath stringByAppendingPathComponent:@"Contents"];
                    
                    // Copy the bom and .pax.gz file
                    
                    tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.bom"];
                    
                    tSourcePath=[tContentsPath stringByAppendingPathComponent:@"Archive.bom"];
                    
                    [self postNotificationWithCode:kPBBuildingCopyingBom
                                         arguments:[NSArray array]];
                    
                    if ([fileManager_ fileExistsAtPath:tSourcePath]==YES)
                    {
                        if ([self copyObjectAtPath:tSourcePath toPath:tDestinationPath]==NO)
                        {
                            return 1;
                        }
                    }
                    else
                    {
                        // Old Format
                        
                        oldFormat=YES;
                        
                        tSourcePath=[tContentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Resources/%@.bom",tPackageName]];
                        
                        if ([self copyObjectAtPath:tSourcePath toPath:tDestinationPath]==NO)
                        {
                            return 1;
                        }
                    }
                    
                    if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                    {
                        return 1;
                    }
                    
                    // 10.1 Compatibility: .bom link
            
                    if (cheetahCompatibility_==YES)
                    {
                        NSString * bomLinkPath;
                        
                        bomLinkPath=[[inPath stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bom",tPackageName]];
                        
                        if (-1==symlink([[NSString stringWithFormat:@"../%@",[tDestinationPath lastPathComponent]] fileSystemRepresentation],[bomLinkPath fileSystemRepresentation]))
                        {
                            // A COMPLETER
                            
                            return 1;
                        }
                    }
                    
                    if (oldFormat==NO)
                    {
                        tBeginningOfArchivePath=[tContentsPath stringByAppendingPathComponent:@"Archive"];
                    }
                    else
                    {
                        tBeginningOfArchivePath=[tContentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Resources/%@",tPackageName]];
                    }
                    
                    tSourcePath=[tBeginningOfArchivePath stringByAppendingString:@".pax.gz"];
                    
                    [self postNotificationWithCode:kPBBuildingCopyingPax
                                         arguments:[NSArray array]];
                    
                    if ([fileManager_ fileExistsAtPath:tSourcePath]==YES)
                    {
                        tArchiveFound=YES;
                        
                        tPaxExtension=@"pax.gz";
                        
                        tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.pax.gz"];
                        
                        if ([self copyObjectAtPath:tSourcePath toPath:tDestinationPath]==NO)
                        {
                            return 1;
                        }
                        
                        if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                        {
                            return 1;
                        }
                    }
                    else
                    {
                        tSourcePath=[tBeginningOfArchivePath stringByAppendingString:@".pax"];
                    
                        if ([fileManager_ fileExistsAtPath:tSourcePath]==YES)
                        {
                            tArchiveFound=YES;
                            
                            tPaxExtension=@"pax";
                            
                            tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.pax"];
                            
                            if ([self copyObjectAtPath:tSourcePath toPath:tDestinationPath]==NO)
                            {
                                return 1;
                            }
                            
                            if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                            {
                                return 1;
                            }
                        }
                        else
                        {
                            // Non Supported Case
                            
                            [self postNotificationWithCode:kPBErrorMissingInformation
                                                    arguments:[NSArray arrayWithObject:@"Pax Archive"]];
                            
                            return 1;
                        }
                    }
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:@"Package Path"]];
                
                    return 1;
                }
            }
            else
            {
                // Self made Package
                
                NSMutableDictionary * tHierarchyDictionary;
                BOOL tCompressArchive=YES;
                BOOL tSplitForks=YES;
                NSString * tDefaultLocation;
                
                tDefaultLocation=[tFilesDictionary objectForKey:IFPkgFlagDefaultLocation];
                
                if (tDefaultLocation==nil)
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:IFPkgFlagDefaultLocation]];
                
                    return 1;
                }
                                 
                tNumber=[tFilesDictionary objectForKey:@"Compress"];
                
                if (tNumber==nil)
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:@"Compress"]];
                
                    return 1;
                }
                else
                {
                    tCompressArchive=[tNumber boolValue];
                }
                
                tNumber=[tFilesDictionary objectForKey:@"Split Forks"];
                
                if (tNumber==nil)
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:@"Split Forks"]];
                
                    return 1;
                }
                else
                {
                    tSplitForks=[tNumber boolValue];
                }
                
                if (rootIsYouDaddy_==NO)
                {
                    seteuid(0);
                    setegid(0);
                }
                
                tHierarchyDictionary=[tFilesDictionary objectForKey:@"Hierarchy"];
                
                if (tHierarchyDictionary!=nil)
                {
                    // Create the Temporary directory
                    
                    [temporaryDirectoryPath_ release];
                    
                    temporaryDirectoryPath_=[[scratchLocation_ stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/%@",userID_,[[projectPath_ lastPathComponent] stringByDeletingPathExtension]]] retain];
                    
                    if ([fileManager_ fileExistsAtPath:temporaryDirectoryPath_]==YES)
                    {
                        // Delete the directory
                        
                        if ([fileManager_ removeFileAtPath:temporaryDirectoryPath_ handler:[PBProjectRemoverErrorHandler sharedRemoverErrorHandler]]==NO)
                        {
                            [self postNotificationWithCode:kPBErrorCantRemoveFile
                                                 arguments:[NSArray arrayWithObject:temporaryDirectoryPath_]];
                
                            return 1;
                        }
                    }
                    
                    if ([self buildPath:temporaryDirectoryPath_ fixedPermissionAfter:NO]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCreateFolder
                                             arguments:[NSArray arrayWithObject:temporaryDirectoryPath_]];
                
                        return 1;
                    }
                    else
                    {
                        NSTask * tTask;
                        NSMutableArray * tArguments;
                        NSString * tBomPath=@"/usr/bin/mkbom";
                        NSString * tPaxPath=@"/bin/pax";
                        NSString * tSplitForksPath=@"/Developer/Tools/SplitForks";
                        int returnValue;
                        NSNumber * tNumber;
                        int tUID;
                        int tGID;
                        int tPrivileges;
						
						if ([splitForksToolName_ isEqualToString:@"goldin"]==YES)
						{
							tSplitForksPath=@"/usr/local/bin/goldin";
						}
						
                        // Find the beginning of the hierarchy according to the Default Location value
                        
                        tHierarchyDictionary=[self firstItemForHierarchy:tHierarchyDictionary andDefaultLocation:tDefaultLocation];
                        
                        if (tHierarchyDictionary==nil)
                        {
                            // A COMPLETER
                        }
                        
                        
                        
                        // Optimize the Hierarchy if needed (Remove the empty branch)
                        
                        if ([self optimizeHierarchy:tHierarchyDictionary]==NO)
                        {
                            // A COMPLETER
                        }
                        
                        // Copy the file hierarchy
                    
                        if ([self buildFileHierarchyComponent:tHierarchyDictionary atPath:temporaryDirectoryPath_ rootComponent:YES]==NO)
                        {
                            return 1;
                        }
                        
                        // Remove .DSStore, .pbdevelopement and CVS if needed
                        
                        if (removeDSStore_==YES || removePbdevelopment_==YES || removeCVS_==YES)
                        {
                            if (1==PBClean([temporaryDirectoryPath_ fileSystemRepresentation],removeDSStore_,removePbdevelopment_,removeCVS_)==1)
                            {
                                // A COMPLETER
                            }
                        }
                        
                        // Create the BundleVersions.plist file if needed
                        
                        if ([self buildBundleVersionsAtPath:[inPath stringByAppendingPathComponent:@"Resources"] 
                                    withFileHierarchyAtPath:temporaryDirectoryPath_]==NO)
                        {
                            // A COMPLETER
                        }
                        
                        // Set the privileges of the Default Location to the temporaryDirectoryPath_ path
                        
                        tNumber=[tHierarchyDictionary objectForKey:@"UID"];
        
                        if (tNumber==nil)
                        {
                            [self postNotificationWithCode:kPBErrorMissingInformation
                                                arguments:[NSArray arrayWithObject:@"UID"]];
                                
                            return NO;
                        }
                        
                        tUID=[tNumber intValue];
                        
                        tNumber=[tHierarchyDictionary objectForKey:@"GID"];
                        
                        if (tNumber==nil)
                        {
                            [self postNotificationWithCode:kPBErrorMissingInformation
                                                arguments:[NSArray arrayWithObject:@"GID"]];
                                
                            return NO;
                        }
                        
                        tGID=[tNumber intValue];
                        
                        tNumber=[tHierarchyDictionary objectForKey:@"Privileges"];
                        
                        if (tNumber==nil)
                        {
                            [self postNotificationWithCode:kPBErrorMissingInformation
                                                arguments:[NSArray arrayWithObject:@"Privileges"]];
                                
                            return NO;
                        }
                        
                        tPrivileges=[tNumber intValue];
                        
                        if ([self setFileOwner:tUID group:tGID atPath:temporaryDirectoryPath_]==NO)
                        {
                            // A COMPLETER
                        }
                        
                        
                        
                        // Split Forks if needed
                        
                        if (tSplitForks==YES)
                        {
                            [self postNotificationWithCode:kPBBuildingSplittingForks
                                                        arguments:[NSArray arrayWithObject:[[inPath stringByDeletingLastPathComponent] lastPathComponent]]];
														
							if ([fileManager_ fileExistsAtPath:tSplitForksPath]==YES)
                            {
                                
                                
                                tTask=[NSTask new];
                            
                                if (tTask==nil)
                                {
                                    [self postNotificationWithCode:kPBErrorOutOfMemory
                                                        arguments:nil];
                                                        
                                    return 1;
                                }
                                
                                tArguments=[NSMutableArray arrayWithCapacity:1];
                                
                                [tArguments addObject:temporaryDirectoryPath_];
                                
                                [tTask setArguments:tArguments];
                                
                                [tTask setLaunchPath:tSplitForksPath];
                                
                                [tTask launch];
                                
                                [tTask waitUntilExit];
                                
                                returnValue = [tTask terminationStatus];
                                
                                [tTask release];
                                
                                if (0!=returnValue)
                                {
                                    switch(returnValue)
                                    {
                                        case -2:
                                            // Not a HFS or Extended HFS volume
                                            
											[self postNotificationWithCode:kPBErrorMissingSplitForksNonHFSVolume
																 arguments:[NSArray arrayWithObject:temporaryDirectoryPath_]];
                                            break;
                                        default:
                                            // A COMPLETER (Recuperer sdterr si il y a)
											
											[self postNotificationWithCode:kPBErrorMissingSplitForksError
																 arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@ error: %d",splitForksToolName_,returnValue]]];
                                            break;
                                    }
                                    
									return 1;
                                }
                            }
                            else
                            {
                                [self postNotificationWithCode:kPBErrorMissingSplitForksMissingTool
													 arguments:[NSArray arrayWithObject:splitForksToolName_]];
                            
								return 1;
							}
                        }
						 
						// Compute the installed size
                        
						installedSize_=PBFolderSize4KRounded([temporaryDirectoryPath_ fileSystemRepresentation]);
					
						if (installedSize_==-1)
						{
							// A COMPLETER
						}
                        
						
						
                        if ([self setFilePrivileges:tPrivileges atPath:temporaryDirectoryPath_]==NO)
                        {
                            // A COMPLETER
                        }
                        
                        /*if ([self setFilePrivileges:040755 atPath:temporaryDirectoryPath_]==NO)
                        {
                            // A COMPLETER
                        }*/
                        
                        // Create Archive.bom
                        
                        if ([fileManager_ fileExistsAtPath:tBomPath]==YES)
                        {
                            NSString * tLocalDestinationPath=nil;
                            
                            [self postNotificationWithCode:kPBBuildingBom
                                                        arguments:[NSArray arrayWithObject:[[inPath stringByDeletingLastPathComponent] lastPathComponent]]];
                            
                            tTask=[NSTask new];
                        
                            if (tTask==nil)
                            {
                                [self postNotificationWithCode:kPBErrorOutOfMemory
                                                     arguments:nil];
                                                     
                                return 1;
                            }
                            
                            tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.bom"];
                            
                            tArguments=[NSMutableArray arrayWithCapacity:2];
                            
                            [tArguments addObject:temporaryDirectoryPath_];
                            
                            if (rootIsYouDaddy_==NO)
                            {
                                tLocalDestinationPath=[[temporaryDirectoryPath_ stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Archive.bom"];
                                
                                [tArguments addObject:tLocalDestinationPath];
                            }
                            else
                            {
                            	[tArguments addObject:tDestinationPath];
                            }
                            
                            [tTask setArguments:tArguments];
                            
                            [tTask setLaunchPath:tBomPath];
                            
                            [tTask launch];
                            
                            [tTask waitUntilExit];
                            
                            returnValue = [tTask terminationStatus];
                            
                            [tTask release];
                            
                            if (0!=returnValue)
                            {
                            	[self postNotificationWithCode:kPBErrorBomFailed
                                                     arguments:[NSArray arrayWithObject:tDestinationPath]];
                                
                                
                                
                                return 1;
                            }
                            
                            if (rootIsYouDaddy_==NO)
                            {
                                seteuid(userID_);
                                setegid(groupID_);
                                
                                // Copy the file to the remote volume
                                
                                if ([self copyObjectAtPath:tLocalDestinationPath toPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                seteuid(0);
                                setegid(0);
                                
                                // Remove Local file
                                
                                [fileManager_ removeFileAtPath:tLocalDestinationPath handler:nil];
                                
                                seteuid(userID_);
                                setegid(groupID_);
                            }
                            
                            if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                            {
                                return 1;
                            }
                        }
                        else
                        {
                            [self postNotificationWithCode:kPBErrorBomFailed
                                                 arguments:[NSArray arrayWithObject:[[inPath stringByDeletingLastPathComponent] lastPathComponent]]];
                        }
                        
                        // 10.1 Compatibility: .bom link
            
                        if (cheetahCompatibility_==YES)
                        {
                            NSString * bomLinkPath;
                            
                            bomLinkPath=[[inPath stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bom",tPackageName]];
                            
                            if (-1==symlink([[NSString stringWithFormat:@"../%@",[tDestinationPath lastPathComponent]] fileSystemRepresentation],[bomLinkPath fileSystemRepresentation]))
                            {
                                // A COMPLETER
                                
                                return 1;
                            }
                        }
                        
                        // Create the pax archive
                        
                        if ([fileManager_ fileExistsAtPath:tPaxPath]==YES)
                        {
                            NSString * tLocalDestinationPath=nil;
                            
                            [self postNotificationWithCode:kPBBuildingPax
                                                        arguments:[NSArray arrayWithObject:[[inPath stringByDeletingLastPathComponent] lastPathComponent]]];
                            
                            tTask=[NSTask new];
                        
                            if (tTask==nil)
                            {
                                [self postNotificationWithCode:kPBErrorOutOfMemory
                                                        arguments:nil];
                                                        
                                return 1;
                            }
                            
                            if (tCompressArchive==YES)
                            {
                                tPaxExtension=@"pax.gz";
                                
                                tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.pax.gz"];
                            }
                            else
                            {
                                tPaxExtension=@"pax";
                                
                                tDestinationPath=[inPath stringByAppendingPathComponent:@"Archive.pax"];
                            }
                            
                            tArguments=[NSMutableArray arrayWithCapacity:5];
                            
                            
							if (OSVersion_>=0x1040)
							{
								// Ditto
								
								if (OSVersion_>=0x1050)
								{
									[tArguments addObject:@"--noextattr"];
							
									[tArguments addObject:@"--noqtn"];
									
									[tArguments addObject:@"--noacl"];
									
									[tArguments addObject:@"--norsrc"];
								}
								
								[tArguments addObject:@"-c"];
								
								if (tCompressArchive==YES)
								{
									[tArguments addObject:@"-z"];
								}
							
								[tArguments addObject:@"."];
							
								if (rootIsYouDaddy_==NO)
								{
									tLocalDestinationPath=[[temporaryDirectoryPath_ stringByDeletingLastPathComponent] stringByAppendingPathComponent:[tDestinationPath lastPathComponent]];
									
									[tArguments addObject:tLocalDestinationPath];
								}
								else
								{
									[tArguments addObject:tDestinationPath];
								}
                            
								[tTask setArguments:tArguments];
							
								[tTask setLaunchPath:@"/usr/bin/ditto"];
							}
							else
							{
								[tArguments addObject:@"-w"];
								
								if (tCompressArchive==YES)
								{
									[tArguments addObject:@"-z"];
								}
								
								[tArguments addObject:@"-x"];
                            
								[tArguments addObject:@"cpio"];
                            
								[tArguments addObject:@"-f"];
							
								if (rootIsYouDaddy_==NO)
								{
									tLocalDestinationPath=[[temporaryDirectoryPath_ stringByDeletingLastPathComponent] stringByAppendingPathComponent:[tDestinationPath lastPathComponent]];
									
									[tArguments addObject:tLocalDestinationPath];
								}
								else
								{
									[tArguments addObject:tDestinationPath];
								}
								
								[tArguments addObject:@"."];
                            
								[tTask setArguments:tArguments];
								
								[tTask setLaunchPath:tPaxPath];
								
								
							}
                            
                            [tTask setCurrentDirectoryPath:temporaryDirectoryPath_];
                            
                            
							/*NSPipe *pipe1,*pipe2;
							pipe1 = [NSPipe pipe];
							pipe2 = [NSPipe pipe];
							[tTask setStandardOutput: pipe1];
							[tTask setStandardError: pipe2];

							NSFileHandle *file1;
							file1 = [pipe1 fileHandleForReading];
							NSFileHandle *file2;
							file2 = [pipe2 fileHandleForReading];*/
							
							[tTask launch];
                            
							/*NSData *data;
							data = [file1 readDataToEndOfFile];
							[data writeToFile:@"/tmp/stdout.txt" atomically:YES];
                            data = [file2 readDataToEndOfFile];
							[data writeToFile:@"/tmp/stderr.txt" atomically:YES];*/
							
                            [tTask waitUntilExit];
							
							
							
                            returnValue = [tTask terminationStatus];
                            
                            [tTask release];
                            
                            if (0!=returnValue)
                            {
                                [self postNotificationWithCode:kPBDebugInfo
                         arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"Pax error: %d",returnValue]]];
                                
                                [self postNotificationWithCode:kPBErrorPaxFailed
                                                     arguments:[NSArray arrayWithObject:tDestinationPath]];
                                
                                return 1;
                            }
                            
                            if (rootIsYouDaddy_==NO)
                            {
                                seteuid(userID_);
                                setegid(groupID_);
                                
                                // Copy the file to the remote volume
                                
                                if ([self copyObjectAtPath:tLocalDestinationPath toPath:tDestinationPath]==NO)
                                {
                                    return 1;
                                }
                                
                                seteuid(0);
                                setegid(0);
                                
                                // Remove Local file
                                
                                [fileManager_ removeFileAtPath:tLocalDestinationPath handler:self];
                                                                
                                seteuid(userID_);
                                setegid(groupID_);
                            }
                            
                            if ([self setFileAttributesAtPath:tDestinationPath]==NO)
                            {
                                return 1;
                            }
                            
                            if (installedSize_!=-1)
                            {
                                struct stat tFileStat;
                                
                                compressedSize_=0;
                                
                                if (stat([tDestinationPath fileSystemRepresentation],&tFileStat)==0)
                                {
                                    compressedSize_=((((u_int64_t) tFileStat.st_size)+0xFFF)>>12)<<2;
                                }
                            }
                        }
                        else
                        {
                            // A COMPLETER
                        }
                        
                        
                    }
                    
                    // Clean the file from disk
                    
                    [self postNotificationWithCode:kPBBuildingCleaning
                                         arguments:nil];
                    
                    if (rootIsYouDaddy_==NO)
                    {
                        seteuid(0);
                        setegid(0);
                    }
                    
                    if ([fileManager_ removeFileAtPath:temporaryDirectoryPath_ handler:[PBProjectRemoverErrorHandler sharedRemoverErrorHandler]]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCleanFolder
                                            arguments:[NSArray arrayWithObject:temporaryDirectoryPath_]];
                    
                        return 1;
                    }
                    
                    if (rootIsYouDaddy_==NO)
                    {
                        seteuid(userID_);
                        setegid(groupID_);
                    }
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorMissingInformation
                                         arguments:[NSArray arrayWithObject:@"Hierarchy"]];
                
                    return 1;
                }
            }
            
            // 10.1 Compatibility: .pax/.pax.gz link
            
            if (cheetahCompatibility_==YES)
            {
                NSString * paxLinkPath;
                
                paxLinkPath=[[inPath stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",tPackageName,tPaxExtension]];
                
                if (-1==symlink([[NSString stringWithFormat:@"../%@",[tDestinationPath lastPathComponent]] fileSystemRepresentation],[paxLinkPath fileSystemRepresentation]))
                {
                    // A COMPLETER
                    
                    return 1;
                }
            }
            
            // Archive.sizes
            
            if ([self buildArchiveInfoAtPath:[inPath stringByAppendingPathComponent:@"Resources"]]!=0)
            {
                // A COMPLETER
            }
        }
        else
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Imported Package"]];
                
            return 1;
        }
    }
    else
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Files"]];
                
        return 1;
    }
    
    return 0;
}

- (BOOL) buildBundleVersionsAtPath:(NSString *) inPath withFileHierarchyAtPath:(NSString *) inFileHierarchyPath
{
    FTS * ftsp;
    FTSENT * tFile;
    char * tPath[2]={(char *)[inFileHierarchyPath fileSystemRepresentation],NULL};
    NSMutableDictionary * tMutableDictionary;
    int tLength;
    
    if ((ftsp = fts_open(tPath, FTS_PHYSICAL, 0)) == NULL)
    {
        return YES;
    }
    
    tMutableDictionary=[NSMutableDictionary dictionary];
    
    tLength=[temporaryDirectoryPath_ length];
    
    while ((tFile = fts_read(ftsp)) != NULL)
    {
        switch (tFile->fts_info)
        {
            case FTS_DNR:
            case FTS_ERR:
            case FTS_NS:
                    fts_close(ftsp);
                    
                    return 1;
            case FTS_D:
            case FTS_SL:
            case FTS_SLNONE:
                    continue;
            default:
                    break;
        }

        if (!strcmp(tFile->fts_name,"version.plist"))
        {
            NSString * tAbsolutePath;
            
            tAbsolutePath=[NSString stringWithUTF8String:tFile->fts_path];
            
            if (tAbsolutePath!=nil)
            {
                NSDictionary * tDictionary;
                
                tDictionary=[NSDictionary dictionaryWithContentsOfFile:tAbsolutePath];
                
                if (tDictionary!=nil)
                {
                    NSString * tFilePathInArchive=nil;
                    NSMutableDictionary * tFinalVersionDictionary;
                    NSString * tObject;
                    
                    tFinalVersionDictionary=[NSMutableDictionary dictionary];
                    
                    if (tFinalVersionDictionary!=nil)
                    {
                        // Mandatory keys
                        
                        // BuildVersion
                        
                        tObject=[tDictionary objectForKey:@"BuildVersion"];
                        
                        if (tObject==nil)
                        {
                            tObject=@"0";
                        }
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"BuildVersion"];
                        }
                        
                        // CFBundleShortVersionString
                        
                        tObject=[tDictionary objectForKey:@"CFBundleShortVersionString"];
                        
                        if (tObject==nil)
                        {
                            tObject=@"0.0.0";
                        }
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"CFBundleShortVersionString"];
                        }
                        
                        // SourceVersion
                        
                        tObject=[tDictionary objectForKey:@"SourceVersion"];
                        
                        if (tObject==nil)
                        {
                            tObject=@"0";
                        }
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"SourceVersion"];
                        }
                        
                        // Optional keys
                        
                        // CFBundleVersion
                        
                        tObject=[tDictionary objectForKey:@"CFBundleVersion"];
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"CFBundleVersion"];
                        }
                        
                        // ProjectName
                        
                        tObject=[tDictionary objectForKey:@"ProjectName"];
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"ProjectName"];
                        }
                        
                        // ReleaseStatus
                        
                        tObject=[tDictionary objectForKey:@"ReleaseStatus"];
                        
                        if (tObject!=nil)
                        {
                            [tFinalVersionDictionary setObject:tObject forKey:@"ReleaseStatus"];
                        }
                        
                        tFilePathInArchive=[NSString stringWithFormat:@".%@",[tAbsolutePath substringFromIndex:tLength]];
                        
                        [tMutableDictionary setObject:tFinalVersionDictionary forKey:tFilePathInArchive];
                    }
                }
            }
        }
    }
    
    fts_close(ftsp);
    
    if ([tMutableDictionary count]>0)
    {
        [tMutableDictionary writeToFile:[inPath stringByAppendingPathComponent:@"BundleVersions.plist"] atomically:NO];
    }
    
    return YES;
}

- (BOOL) buildFileHierarchyComponent:(NSDictionary *) inDictionary atPath:(NSString *) inPath rootComponent:(BOOL) inRootComponent
{
    NSNumber * tNumber;
    int tUID;
    int tGID;
    int tPrivileges;
    int tType;
    int tPathType;
    NSString * tPath;
    NSArray * tChildren;
    int i,tCount;
    NSString * tDestinationPath=nil;
    BOOL tExceptionFolder=NO;
    NSArray * tRulesArray;
    
    tPath=[inDictionary objectForKey:@"Path"];
    
    if (tPath==nil)
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Path"]];
        
        return NO;
    }
    
    tChildren=[inDictionary objectForKey:@"Children"];
    
    if (tChildren==nil)
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Children"]];
        
        return NO;
    }
    
    tCount=[tChildren count];
    
    if (inRootComponent==NO)
    {
        tNumber=[inDictionary objectForKey:@"UID"];
        
        if (tNumber==nil)
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"UID"]];
                
            return NO;
        }
        
        tUID=[tNumber intValue];
        
        tNumber=[inDictionary objectForKey:@"GID"];
        
        if (tNumber==nil)
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"GID"]];
                
            return NO;
        }
        
        tGID=[tNumber intValue];
        
        tNumber=[inDictionary objectForKey:@"Privileges"];
        
        if (tNumber==nil)
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Privileges"]];
                
            return NO;
        }
        
        tPrivileges=[tNumber intValue];
        
        tNumber=[inDictionary objectForKey:@"Type"];
        
        if (tNumber==nil)
        {
            [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Type"]];
                
            return NO;
        }
        
        tType=[tNumber intValue];
        
        switch(tType)
        {
            case kBaseNode:	// Base Node
            case kNewFolderNode:	// New Folder
                tDestinationPath=[inPath stringByAppendingPathComponent:tPath];
                
                if ([fileManager_ createDirectoryAtPath:tDestinationPath attributes:nil]==NO)
                {
                    // A COMPLETER
                    
                    return NO;
                }
                
                if ([self setFilePrivileges:tPrivileges atPath:tDestinationPath]==NO)
                {
                    return NO;
                }
                
                if ([self setFileOwner:tUID group:tGID atPath:tDestinationPath]==NO)
                {
                    return NO;
                }
                break;
            case kRealItemNode:	// Real Node Item
            
                tNumber=[inDictionary objectForKey:@"Path Type"];	// Support for relative path 09/12/04
        
                if (tNumber!=nil)
                {
                    tPathType=[tNumber intValue];
                }
                else
                {
                    tPathType=kGlobalPath;
                }
                
                if (tPathType==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByAbsolutingWithPath:referencePath_];
                }
                
                tDestinationPath=[inPath stringByAppendingPathComponent:[tPath lastPathComponent]];
                
                // We need to check the item is not expanded and empty in fact
                
                tNumber=[inDictionary objectForKey:@"Expanded"];
        
                if (tNumber!=nil)				// Bug Fix 22/03/04
                {
                    tExceptionFolder=[tNumber boolValue];
                }
                
                if (tCount==0 && tExceptionFolder==NO)
                {
                    // Copy the path
                    
                    NSDictionary * tDictionary;
                    
                    
                    if ([PBProjectBuilder copyPath:tPath toPath:inPath]==NO)
                    //if ([fileManager_ copyPath:tPath toPath:tDestinationPath handler:self]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCopyFile
                                             arguments:[NSArray arrayWithObjects:tPath,
                                                                                 tDestinationPath,
                                                                                 nil]];
                
                        return NO;
                    }
                    
                    tDictionary=[fileManager_ fileAttributesAtPath:tDestinationPath traverseLink:NO];
                    
                    if (tDictionary==nil)
                    {
                        return NO;
                    }
                    else
                    {
                        if ([[tDictionary objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]==NO)
                        {
                            if ([self setFilePrivileges:tPrivileges atPath:tDestinationPath]==NO)
                            {
                                return NO;
                            }
                        }
                        
                        // Set the owner and group recursively
                        
                        if (PBChown(tUID,tGID,[tDestinationPath fileSystemRepresentation])==1)
                        {
                            // A COMPLETER
                        
                            return NO;
                        }
                    }
                    
                    // Token Definitions and PathMappings
        
                    tRulesArray=[inDictionary objectForKey:@"Search Rules"];
                
                    if (tRulesArray!=nil)
                    {
                        return [self buildTokenDefinitionsWithRules:tRulesArray forPath:tDestinationPath];
                    }
                    else
                    {
                        return YES;
                    }
                }
                else
                {
                    CFURLRef tURLRef;
                    
                    tURLRef=CFURLCreateWithFileSystemPath(kCFAllocatorDefault,(CFStringRef) tPath,kCFURLPOSIXPathStyle,TRUE);
                    
                    if (tURLRef!=NULL)
                    {
                        FSRef tFileRef;
                        
                        if (CFURLGetFSRef(tURLRef,&tFileRef)==TRUE)
                        {
                            FSCatalogInfo tCatalogInfo;
                            OSErr tErr;
                            NSDictionary * tFileAttributes;
                            
                            tErr=FSGetCatalogInfo(&tFileRef,kFSCatInfoFinderInfo+kFSCatInfoFinderXInfo+kFSCatInfoAllDates,&tCatalogInfo,NULL,NULL,NULL);
                            
                            tFileAttributes=[fileManager_ fileAttributesAtPath:tPath traverseLink:NO];
                                
                            // Create the folder
                        
                            if ([fileManager_ createDirectoryAtPath:tDestinationPath attributes:tFileAttributes]==NO)
                            {
                               [self postNotificationWithCode:kPBErrorCantCreateFolder
                                             arguments:[NSArray arrayWithObject:tDestinationPath]];
                            
								return NO;
                            }
                            
                            if ([self setFilePrivileges:tPrivileges atPath:tDestinationPath]==NO)
                            {
                                return NO;
                            }
                            
                            if ([self setFileOwner:tUID group:tGID atPath:tDestinationPath]==NO)
                            {
                                return NO;
                            }
                            
                            if (tErr==noErr)
                            {
                                 CFURLRef tDestinationURLRef;
                    
                                tDestinationURLRef=CFURLCreateWithFileSystemPath(kCFAllocatorDefault,(CFStringRef) tDestinationPath,kCFURLPOSIXPathStyle,TRUE);
                                
                                if (tDestinationURLRef!=NULL)
                                {
                                    FSRef tDestinationFolderRef;
                                    
                                    if (CFURLGetFSRef(tDestinationURLRef,&tDestinationFolderRef)==TRUE)
                                    {
                                        tErr=FSSetCatalogInfo(&tDestinationFolderRef,kFSCatInfoFinderInfo+kFSCatInfoFinderXInfo+kFSCatInfoAllDates,&tCatalogInfo);
                                    }
                                    else
                                    {
                                        // A COMPLETER
                                    }
                                    
                                    // Release Memory
                        
                                    CFRelease(tDestinationURLRef);
                                }
                                else
                                {
                                    // A COMPLETER
                                }
                            }
                            else
                            {
                                // A COMPLETER
                            }
                        }
                        else
                        {
                            [self postNotificationWithCode:kPBErrorCantCopyFile
												 arguments:[NSArray arrayWithObjects:tPath,
																					 tDestinationPath,
																					 nil]];
                            
                            return NO;
                        }
                        
                        // Release Memory
                        
                        CFRelease(tURLRef);
                    }
                    else
                    {
                        // A COMPLETER
                        
                        return NO;
                    }
                }
                break;
            default:
                [self postNotificationWithCode:kPBErrorMissingInformation
                                 arguments:[NSArray arrayWithObject:@"Incorrect File type"]];
                
                return NO;
        }
        
        // Token Definitions and PathMappings
        
        tRulesArray=[inDictionary objectForKey:@"Search Rules"];
    
        if (tRulesArray!=nil)
        {
            if ([self buildTokenDefinitionsWithRules:tRulesArray forPath:tDestinationPath]==NO)
            {
                return NO;
            }
        }
    }
    else
    {
        tDestinationPath=[inPath stringByAppendingPathComponent:@"/"];
    }
    
    if (tCount>0)
    {
        NSDictionary * tChildDictionary;
        
        for(i=0;i<tCount;i++)
        {
            tChildDictionary=[tChildren objectAtIndex:i];
            
            if ([self buildFileHierarchyComponent:tChildDictionary atPath:tDestinationPath rootComponent:NO]==NO)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL) buildTokenDefinitionsWithRules:(NSArray *) inRulesArray forPath:(NSString *) inPath
{
    if (inRulesArray!=nil)
    {
        int tCount;
        
        tCount=[inRulesArray count];
        
        if (tCount>0)
        {
            NSEnumerator * tEnumerator;
            NSDictionary * tRule;
            NSMutableArray * tTokenAttributes;
            
            tTokenAttributes=[NSMutableArray arrayWithCapacity:tCount];
            
            tEnumerator=[inRulesArray objectEnumerator];
            
            while (tRule=[tEnumerator nextObject])
            {
                NSNumber * tStatus;
                
                tStatus=[tRule objectForKey:@"Status"];
                
                if ([tStatus boolValue]==YES)
                {
                    [tTokenAttributes addObject:[tRule objectForKey:@"Attributes"]];
                }
            }
            
            if ([tTokenAttributes count]>0)
            {
                NSString * tTokenName=nil;
                
                if (tokenDefinitions_==nil)
                {
                    tokenDefinitions_=[[NSMutableDictionary alloc] initWithCapacity:5];
                }
            
                if (tokenDefinitions_!=nil)
                {
                    tTokenName=[NSString stringWithFormat:@"%@Path",[[inPath lastPathComponent] stringByDeletingPathExtension]];
                    
                    if ([tokenDefinitions_ objectForKey:tTokenName]!=nil)
                    {
                        int i;
                        NSString * tPrefix;
                        
                        tPrefix=tTokenName;
                            
                        for(i=2;i<65535;i++)
                        {
                            tTokenName=[NSString stringWithFormat:@"%@ %d",tPrefix,i];
                                
                            if ([tokenDefinitions_ objectForKey:tTokenName]==nil)
                            {
                                break;
                            }
                        }
                    }
                    
                    [tokenDefinitions_ setObject:tTokenAttributes forKey:tTokenName];
                }
                else
                {
                    [self postNotificationWithCode:kPBErrorOutOfMemory
                                         arguments:nil];
                    
                    return NO;
                }
                
                if (tTokenName!=nil)
                {
                    if (pathMappings_==nil)
                    {
                        pathMappings_=[[NSMutableDictionary alloc] initWithCapacity:5];
                    }
                    
                    if (pathMappings_!=nil)
                    {
                        NSString * tFilePathInArchive=nil;
                        
                        tFilePathInArchive=[NSString stringWithFormat:@".%@",[inPath substringFromIndex:[temporaryDirectoryPath_ length]]];
                        
                        if (tFilePathInArchive!=nil)
                        {
                            [pathMappings_ setObject:[NSString stringWithFormat:@"{%@}",tTokenName] forKey:tFilePathInArchive];
                        }
                    }
                    else
                    {
                        [self postNotificationWithCode:kPBErrorOutOfMemory
                                             arguments:nil];
                        
                        return NO;
                    }
                }
            }
        }
    }
    
    return YES;
}

- (BOOL) optimizeHierarchy:(NSMutableDictionary *) inDictionary
{
    NSNumber * tNumber;
    int tType;
    NSMutableArray * tChildren;
    int i,tCount;
    BOOL tFound=NO;
    NSMutableDictionary * tChildDictionary;
    
    tNumber=[inDictionary objectForKey:@"Type"];
        
    if (tNumber==nil)
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                                arguments:[NSArray arrayWithObject:@"Type"]];
            
        return NO;
    }
    
    tType=[tNumber intValue];
    
    switch(tType)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            return YES;
        case 3:
            return YES;
        default:
            return NO;
    }
    
    tChildren=[inDictionary objectForKey:@"Children"];
    
    if (tChildren==nil)
    {
        [self postNotificationWithCode:kPBErrorMissingInformation
                             arguments:[NSArray arrayWithObject:@"Children"]];
        
        return NO;
    }
    
    tCount=[tChildren count];
    
    for(i=0;i<tCount;i++)
    {
        tChildDictionary=[tChildren objectAtIndex:i];
        
        if ([self optimizeHierarchy:tChildDictionary]==NO)
        {
            [tChildren removeObjectAtIndex:i];
            
            tCount--;
            i--;
        }
        else
        {
            tFound=YES;
        }
    }
    
    if (tFound==NO && tType==1)
    {
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary *) firstItemForHierarchy:(NSMutableDictionary *) inDictionary andDefaultLocation:(NSString *) inPath
{
    NSMutableDictionary * tDictionary=inDictionary;
    
    if ([inPath isEqualToString:@"/"]==NO)
    {
        NSArray * tPathComponents;
        int i,tCount;
        NSString * tComponent;
        
        tPathComponents=[inPath componentsSeparatedByString:@"/"];
        
        tCount=[tPathComponents count];
        
        for(i=0;i<tCount;i++)
        {
            NSArray * tChildArray;
            int j,tChildrenCount;
            NSMutableDictionary * tChildDictionary;
            NSString * tPathName;
            
            tComponent=[tPathComponents objectAtIndex:i];
            
            tChildArray=[tDictionary objectForKey:@"Children"];
            
            tChildrenCount=[tChildArray count];
            
            for(j=0;j<tChildrenCount;j++)
            {
                tChildDictionary=[tChildArray objectAtIndex:j];
                
                tPathName=[tChildDictionary objectForKey:@"Path"];
                
                if (tPathName==nil)
                {
                    // A COMPLETER
                }
                
                if ([tPathName isEqualToString:tComponent]==YES)
                {
                    tDictionary=tChildDictionary;
                    
                    break;
                }
            }
        }
    }
    
    return tDictionary;
}

#pragma mark -

- (BOOL) setFileAttributesAtPath:(NSString *) aPath
{
    struct stat tStat;
        
    if (lstat([aPath fileSystemRepresentation], &tStat)==0)
    {
        if ((tStat.st_mode & S_IFMT)==S_IFLNK)
        {
            return YES;
        }
    }
    
    if (chmod([aPath fileSystemRepresentation],fileAttributes_)==-1)
    {
        [self postNotificationWithCode:kPBErrorInsufficientPrivilegesSet
                             arguments:[NSArray arrayWithObject:aPath]];
        
        return NO;
    }    
    
    return YES;
}

- (BOOL) setFileOwner:(int) inOwner group:(int) inGroup atPath:(NSString *) aPath
{
    struct stat tStat;
        
    if (lstat([aPath fileSystemRepresentation], &tStat)==0)
    {
        if ((tStat.st_mode & S_IFMT)==S_IFLNK)
        {
            return YES;
        }
    }
    
    if (chown([aPath fileSystemRepresentation],inOwner,inGroup)==-1)
    {
        switch(errno)
        {
            case EPERM:
                [self postNotificationWithCode:kPBErrorInsufficientPrivilegesSet
                                     arguments:[NSArray arrayWithObject:aPath]];
                break;
            
            default:
                // A COMPLETER
                break;
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL) setFileOwnerAtPath:(NSString *) aPath traverseHierarchy:(BOOL) inTraverseHierarchy
{
    int tResult;
    
    if (inTraverseHierarchy==NO)
    {
        struct stat tStat;
        
        if (lstat([aPath fileSystemRepresentation], &tStat)==0)
        {
            if ((tStat.st_mode & S_IFMT)==S_IFLNK)
            {
                return YES;
            }
        }
                    
        tResult=chown([aPath fileSystemRepresentation],userID_,groupID_);
    }
    else
    {
        tResult=PBChown(userID_,groupID_,[aPath fileSystemRepresentation]);
    }
    
    if (tResult!=0)
    {
        switch(errno)
        {
            case EPERM:
                [self postNotificationWithCode:kPBErrorInsufficientPrivilegesSet
                                     arguments:[NSArray arrayWithObject:aPath]];
                break;
            default:
                // A COMPLETER
                break;
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL) setFilePrivileges:(int) inPrivileges atPath:(NSString *) aPath
{
    struct stat tStat;
    const char * tFilePath;
    BOOL tResult=YES;
    int tError;
    
    tFilePath=[aPath fileSystemRepresentation];
    
    tError=lstat(tFilePath, &tStat);
    
    if (tError==0 && (tStat.st_mode & S_IFMT)==S_IFLNK)
    {
        return YES;
    }
    
    if (chmod(tFilePath,inPrivileges)==-1)
    {
        tResult=NO;
        
        if (errno==EPERM && tError==0 && tStat.st_flags!=0)
        {
            if (chflags(tFilePath,0)==0)
            {
                if (chmod(tFilePath,inPrivileges)==0)
                {
                    if (chflags(tFilePath,tStat.st_flags)==-1)
                    {
                        // A COMPLETER
                    }
                    
                    tResult=YES;
                }
            }
        }
        
        if (tResult==NO)
        {
            [self postNotificationWithCode:kPBDebugInfo
                             arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"chmod error: %d",errno]]];
        
            [self postNotificationWithCode:kPBErrorInsufficientPrivilegesSet
                             arguments:[NSArray arrayWithObject:aPath]];
        }
    }
    
    return tResult;
}

#pragma mark -

+ (NSString *) fileNameWithDictionary:(NSDictionary *) inDictionary
{
    NSString * tName;
    NSNumber * tNumber;
    int tType=1;
    NSString * tSuffix=nil;
    
    tName=[inDictionary objectForKey:@"Name"];
    
    tNumber=[inDictionary objectForKey:@"Type"];
                
    if (tNumber!=nil)
    {
        tType=[tNumber intValue];
    }
    
    switch(tType)
    {
        case 0:	// Meta
            tSuffix=@".mpkg";
            break;
        case 1:
            tSuffix=@".pkg";
            break;
    }
    
    if ([tName hasSuffix:tSuffix]==NO)
    {
        tName=[tName stringByAppendingString:tSuffix];
    }
    
    return tName;
}

- (BOOL) buildPath:(NSString *) inPath fixedPermissionAfter:(BOOL) inFixedPermissionAfter
{
    BOOL isDirectory=NO;
    
    if ([fileManager_ fileExistsAtPath:inPath isDirectory:&isDirectory]==NO || isDirectory==NO)
    {
        if ([self buildPath:[inPath stringByDeletingLastPathComponent] fixedPermissionAfter:inFixedPermissionAfter]==YES)
        {
            if ([fileManager_ fileExistsAtPath:inPath]==YES)
            {
                // A File is annoying us
                
                // A COMPLETER
            }
            else
            {
                if (inFixedPermissionAfter==YES)
                {
                    if ([self createDirectoryAtPath:inPath]==NO)
                    {
                        return NO;
                    }
                }
                else
                {
                    if ([fileManager_ createDirectoryAtPath:inPath attributes:folderAttributes_]==NO)
                    {
                        [self postNotificationWithCode:kPBErrorCantCreateFolder
                                            arguments:[NSArray arrayWithObject:inPath]];
                        
                        return NO;
                    }
                    
                    
                }
                
                if ([self setFileOwnerAtPath:inPath traverseHierarchy:NO]==NO)
                {
                    return NO;
                }
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        // Check the privileges
        
        // A COMPLETER
    }
    
    return YES;
}

- (void) postNotificationWithCode:(int) inCode arguments:(NSArray *) inArguments
{
    if (distributedNotificationCenter_!=nil)
    {
        NSDictionary * tDictionary;
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:notificationPath_,@"Project Path",			// To identify the Project
                                                              [NSNumber numberWithInt:processID_],@"Process ID",	// To identify the User
                                                              [NSNumber numberWithInt:inCode],@"Code",
                                                              inArguments,@"Arguments",
                                                              nil];
                                                            
        if ([distributedNotificationCenter_ respondsToSelector:@selector(postNotificationName:object:userInfo:options:)]==YES)
        {
            [distributedNotificationCenter_ postNotificationName:@"ICEBERGBUILDERNOTIFICATION" object:nil userInfo:tDictionary options:0x2];
        }
        else
        {
            [distributedNotificationCenter_ postNotificationName:@"ICEBERGBUILDERNOTIFICATION" object:nil userInfo:tDictionary];
        }
    }
}

#pragma mark -

+ (BOOL) copyPath:(NSString *) fromPath toPath:(NSString *) toPath
{
        FSRef sourceRef, destRef;
	OSErr err;
        
        err = MyFSPathMakeRef( [fromPath UTF8String], &sourceRef );
        
	if( err == noErr)	/* Get FSRef to destination object	*/
	{
            FSRef newRef;

            /* We don't have to worry about the symlink problem (2489632) here	*/
            /* cause we would want to copy into the target of the symlink	*/
            /* anyways.  And if its not a symlink, no problems...		*/
            
            err = FSPathMakeRef( [toPath UTF8String], &destRef, NULL );
            
            if( err == noErr )					/* make sure the dest is a directory*/
            {
                err = FSCopyObject( &sourceRef,  &destRef, 0, kFSCatInfoNone, kDupeActionIgnore, true, false, NULL, NULL, &newRef, NULL);
                
                if( err == noErr )
                {
                    return YES;
                }
                else
                {
                    //NSLog(@"Error copying object: %d",err);
                }
            }
            else
            {
                //NSLog(@"Error making FSRef destination: %d",err);
            }
        }
        else
        {
            //NSLog(@"Error making FSRef source: %d",err);
        }
        
        return NO;
}

@end

static OSErr MyFSPathMakeRef( const unsigned char *path, FSRef *ref )
{
	FSRef			tmpFSRef;
	char			tmpPath[ PATH_MAX ],
					*tmpNamePtr;
	OSErr			err;
        char * tCharPtr;
					/* Get local copy of incoming path					*/
	strcpy( tmpPath, (char*)path );

					/* Get the name of the object from the given path	*/
					/* Find the last / and change it to a '\0' so		*/
					/* tmpPath is a path to the parent directory of the	*/
					/* object and tmpNamePtr is the name				*/
	tmpNamePtr = strrchr( tmpPath, '/' );
	if( *(tmpNamePtr + 1) == '\0' )
	{				/* in case the last character in the path is a /	*/
		*tmpNamePtr = '\0';
		tmpNamePtr = strrchr( tmpPath, '/' );
	}
	*tmpNamePtr = '\0';
	tmpNamePtr++;
	
        tCharPtr=tmpNamePtr;
        
        while (*tCharPtr!='\0')
        {
            if ((*tCharPtr)==':')
            {
                *tCharPtr='/';
            }
        
            tCharPtr++;
        }
        
					/* Get the FSRef to the parent directory			*/
	err = FSPathMakeRef( (unsigned char*)tmpPath, &tmpFSRef, NULL );
        
	if( err == noErr )
	{				/* Convert the name to a Unicode string and pass it	*/
					/* to FSMakeFSRefUnicode to actually get the FSRef	*/
					/* to the object (symlink)							*/
            UniChar			uniName[255];
            CFStringRef 	tmpStringRef = CFStringCreateWithCString( kCFAllocatorDefault, tmpNamePtr, kCFStringEncodingUTF8 );
            if( tmpStringRef != NULL )
            {
                    err = ( CFStringGetCString( tmpStringRef, (char*)uniName, 255 * sizeof( UniChar ), kCFStringEncodingUnicode ) )				?
                                            FSMakeFSRefUnicode( &tmpFSRef, CFStringGetLength( tmpStringRef ), uniName, kTextEncodingUnknown, &tmpFSRef )	:
                                            1;
                    CFRelease( tmpStringRef );
            }
            else
            {
                err = 1;
            }
        }
	
	if( err == noErr )
        {
            *ref = tmpFSRef;
	}
        
	return err;
}