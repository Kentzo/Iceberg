/*
Copyright (c) 2004-2005, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBJaguarPackageMakerDecoder+Iceberg.h"

#import "PBProjectTreeImporter.h"

#import "NSDictionary+Iceberg.h"

#include <sys/stat.h>

@implementation PBJaguarCorePackageDecoder (Iceberg)

- (id) initWithDictionary:(NSDictionary *) inDictionary
{
    self=[super init];
    
    return self;
}

- (NSMutableDictionary *) dictionary
{
    return nil;
}

- (NSMutableDictionary *) projectDictionary
{
    NSMutableDictionary * nProjectDictionary;
    NSMutableDictionary * nProjectSettings;
    
    nProjectDictionary=[NSMutableDictionary dictionary];
    
    // Name
    
    [nProjectDictionary setObject:@"Project" forKey:@"Name"];
    
    // Settings
    
    nProjectSettings=[NSMutableDictionary dictionary];
    
    if (nProjectSettings!=nil)
    {
        [nProjectSettings setObject:[NSNumber numberWithBool:YES] forKey:@"10.1 Compatibility"];
        
        [nProjectSettings setObject:@"build" forKey:@"Build Path"];
        
        [nProjectSettings setObject:[NSNumber numberWithInt:2] forKey:@"Build Path Type"];
        
        [nProjectSettings setObject:@"" forKey:@"Comment"];
        
        [nProjectSettings setObject:[NSNumber numberWithBool:YES] forKey:@"Remove .DS_Store"];
        
        [nProjectSettings setObject:[NSNumber numberWithBool:YES] forKey:@"Remove .pbdevelopment"];
    
        [nProjectDictionary setObject:nProjectSettings forKey:@"Settings"];
    }
    
    return nProjectDictionary;
}

- (NSMutableDictionary *) documentsDictionary
{
    NSMutableDictionary * nDocumentsDictionary;
    
    nDocumentsDictionary=[PBProjectTreeImporter importPartialDocumentsAtPath:resourcesDirectory_];
    
    if (nDocumentsDictionary!=nil)
    {
    	NSMutableDictionary * nBackgroundDictionary;
        
        // Background Image
        
        nBackgroundDictionary=[NSMutableDictionary dictionary];
        
        if (nBackgroundDictionary!=nil)
        {
            NSString * tPath=nil;
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:4] forKey:@"IFPkgFlagBackgroundAlignment"];
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:1] forKey:@"IFPkgFlagBackgroundScaling"];
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Path Type"];
            
            tPath=[PBProjectTreeImporter bagroundImageAtPath:resourcesDirectory_];
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:(tPath==nil) ? 0 : 1] forKey:@"Mode"];
            
            [nBackgroundDictionary setObject: (tPath!=nil ? tPath : @"") forKey:@"Path"];
        
            [nDocumentsDictionary setObject:nBackgroundDictionary forKey:@"Background Image"];
        }
    }
    
    return nDocumentsDictionary;
}

- (NSMutableDictionary *) scriptsDictionary
{
    NSMutableDictionary * nScriptsDictionary;
    
    nScriptsDictionary=[NSMutableDictionary dictionary];
    
    if (nScriptsDictionary!=nil)
    {
    	NSMutableDictionary * nRequirementsDictionary;
        NSMutableDictionary * nInstallationScriptsDictionary;
        NSMutableDictionary * nAdditionalResourcesDictionary;
        NSFileManager * tFileManager;
        
        tFileManager=[NSFileManager defaultManager];
        
        // Requirements
        
	nRequirementsDictionary=[NSMutableDictionary dictionary];
        
        if (nRequirementsDictionary!=nil)
        {
            [nScriptsDictionary setObject:nRequirementsDictionary forKey:@"Requirements"];
        }
        
        // Installation Scripts
        
        nInstallationScriptsDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:resourcesDirectory_];
        
        if (nInstallationScriptsDictionary!=nil)
        {
            [nScriptsDictionary setObject:nInstallationScriptsDictionary forKey:@"Installation Scripts"];
        }
        
        // Additional Resources
        
        nAdditionalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:resourcesDirectory_];
        
        if (nAdditionalResourcesDictionary!=nil)
        {
            [nScriptsDictionary setObject:nAdditionalResourcesDictionary forKey:@"Additional Resources"];
        }
    }
    
    return nScriptsDictionary;
}

- (NSMutableDictionary *) settingsDictionary
{
    NSMutableDictionary * nSettingsDictionary;
    
    nSettingsDictionary=[NSMutableDictionary dictionary];
    
    if (nSettingsDictionary!=nil)
    {
        NSEnumerator * tEnumerator;
        NSString * tKey;
        NSMutableDictionary * nDisplayInformationDictionary;
        NSMutableDictionary * nVersionDictionary;
        NSMutableDictionary * nDescriptionDictionary;
        
        // Display Information
        
	nDisplayInformationDictionary=[NSMutableDictionary dictionary];
        
        if (nDisplayInformationDictionary!=nil)
        {
            NSArray * tKeysArray=[NSArray arrayWithObjects:@"CFBundleGetInfoString",
                                                           @"CFBundleIdentifier",
                                                           @"CFBundleName",
                                                           @"CFBundleShortVersionString",
                                                           nil];
            tEnumerator=[tKeysArray objectEnumerator];
        
            while (tKey=[tEnumerator nextObject])
            {
                id tObject;
                
                tObject=[infoDictionary_ objectForKey:tKey];
                
                [nDisplayInformationDictionary setObject:(tObject!=nil ? tObject : @"") forKey:tKey];
            }
    
            [nSettingsDictionary setObject:nDisplayInformationDictionary forKey:@"Display Information"];
        }
        
        // Version
        
        nVersionDictionary=[NSMutableDictionary dictionary];
        
        if (nVersionDictionary!=nil)
        {
            NSArray * tKeysArray=[NSArray arrayWithObjects:@"IFMajorVersion",
                                                           @"IFMinorVersion",
                                                           nil];
            tEnumerator=[tKeysArray objectEnumerator];
        
            while (tKey=[tEnumerator nextObject])
            {
                id tObject;
                
                tObject=[infoDictionary_ objectForKey:tKey];
                
                [nVersionDictionary setObject:(tObject!=nil ? tObject : [NSNumber numberWithInt:0]) forKey:tKey];
            }
    
            [nSettingsDictionary setObject:nVersionDictionary forKey:@"Version"];
        }
        
        // Description
        
        nDescriptionDictionary=[NSMutableDictionary dictionary];
        
        if (nDescriptionDictionary!=nil)
        {
            
            // International
            
            [nDescriptionDictionary setObject:descriptionDictionary_ forKey:@"International"];
            
            // Other languages
            
            if ([resourcesDirectory_ length]>0)
            {
                NSFileManager * tFileManager;
                NSArray * tArray;

                tFileManager=[NSFileManager defaultManager];
                
                tArray=[tFileManager directoryContentsAtPath:resourcesDirectory_];
                
                if (tArray!=nil)
                {
                    NSEnumerator * tEnumerator;
                    NSString * tFileName;
                    
                    tEnumerator=[tArray objectEnumerator];
                    
                    while (tFileName=[tEnumerator nextObject])
                    {
                        if ([tFileName hasSuffix:@".lproj"]==YES)
                        {
                            NSString * tFilePath;
                            BOOL isDirectory;
                            
                            tFilePath=[[resourcesDirectory_ stringByAppendingPathComponent:tFileName] stringByAppendingPathComponent:@"Description.plist"];
                            
                            if ([tFileManager fileExistsAtPath:tFilePath isDirectory:&isDirectory]==YES && isDirectory==NO)
                            {
                                NSDictionary * tLocalizedDescriptionDictionary;
                                
                                tLocalizedDescriptionDictionary=[NSDictionary dictionaryWithContentsOfFile:tFilePath];
                                
                                if (tLocalizedDescriptionDictionary!=nil)
                                {
                                    [nDescriptionDictionary setObject:tLocalizedDescriptionDictionary forKey:[tFileName stringByDeletingPathExtension]];
                                }
                            }
                        }
                    }
                }
            }
            
            [nSettingsDictionary setObject:nDescriptionDictionary forKey:@"Description"];
        }
    }
    
    return nSettingsDictionary;
}

@end

@implementation PBJaguarSinglePackageDecoder (Iceberg)

+ (id) jaguarSinglePackageDecoderWithDictionary:(NSDictionary *) inDictionary
{
    PBJaguarSinglePackageDecoder * nSinglePackageDecoder;
    
    nSinglePackageDecoder=[[PBJaguarSinglePackageDecoder alloc] initWithDictionary:inDictionary];

    return nSinglePackageDecoder;
}

- (id) initWithDictionary:(NSDictionary *) inDictionary
{
    self=[super init];
    
    if (inDictionary!=nil)
    {
        // A COMPLETER
    }
    else
    {
        [self release];
        
        return nil;
    }
    
    return self;
}

- (NSMutableDictionary *) filesDictionary
{
    NSMutableDictionary * nFilesDictionary;
    
    nFilesDictionary=[NSMutableDictionary dictionary];
    
    if (nFilesDictionary!=nil)
    {
        NSString * tDefaultLocation;
        BOOL rootExists=NO;
        NSDictionary * tHierarchyDictionary=nil;
        NSString * tPath;
        NSFileManager * tFileManager;
        
    	tFileManager=[NSFileManager defaultManager];
        
        [nFilesDictionary setObject:[NSNumber numberWithBool:compressArchive_] forKey:@"Compress"];
        
        [nFilesDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"Split Forks"];
        
        [nFilesDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"Imported Package"];
        
        [nFilesDictionary setObject:@"" forKey:@"Package Path"];
        
        tDefaultLocation=[infoDictionary_ objectForKey:@"IFPkgFlagDefaultLocation"];
        
        if ([tDefaultLocation length]==0)
        {
            tDefaultLocation=@"/";
        }
        else
        {
            if ([tDefaultLocation characterAtIndex:0]!='/')
            {
                tDefaultLocation=@"/";
            }
            else
            {
                int tLength;
                
                tLength=[tDefaultLocation length];
                    
                if (tLength>1)
                {
                    if ([tDefaultLocation characterAtIndex:(tLength-1)]=='/')
                    {
                        tDefaultLocation=[tDefaultLocation substringToIndex:tLength-1];
                    }
                }
            }
        }
        
        [nFilesDictionary setObject:tDefaultLocation forKey:@"IFPkgFlagDefaultLocation"];
        
        // Hierarchy
        
        if ([rootDirectory_ length]>0)
        {
           
            BOOL isDirectory;
            
            
            
            if ([tFileManager fileExistsAtPath:rootDirectory_ isDirectory:&isDirectory]==YES &&
                isDirectory==YES)
            {
                rootExists=YES;
            }
        }
        
        tPath=[[NSBundle mainBundle] pathForResource:@"DefaultTree" ofType:@"plist"];
        
        if (tPath!=nil)
        {
            if (rootExists==YES)
            {
                // We need to merge
                
                NSMutableDictionary * tMutableDictionary;
                
                tMutableDictionary=[NSMutableDictionary mutableDictionaryWithContentsOfFile:tPath];
                
                if (tMutableDictionary!=nil)
                {
                    NSArray * tDefaultLocationComponents;
                    NSMutableArray * tChildren;
                    int i,tCount;
                    NSString * tComponent;
                    
                    tHierarchyDictionary=tMutableDictionary;
                    
                    // Travel through the default dictionary to the default location
                    
                    tDefaultLocationComponents=[tDefaultLocation componentsSeparatedByString:@"/"];
                    
                    tCount=[tDefaultLocationComponents count];
                    
                    tChildren=[tHierarchyDictionary objectForKey:@"Children"];
                    
                    for(i=1;i<tCount;i++)
                    {
                        tComponent=[tDefaultLocationComponents objectAtIndex:i];
                        
                        if ([tComponent length]>0)
                        {
                            NSEnumerator * tEnumerator;
                            NSMutableDictionary * tDictionary;
                            
                            tEnumerator=[tChildren objectEnumerator];
                            
                            while (tDictionary=[tEnumerator nextObject])
                            {
                                NSString * tFileName;
                                
                                tFileName=[[tDictionary objectForKey:@"Path"] lastPathComponent];
                                
                                if ([tFileName isEqualToString:tComponent]==YES)
                                {
                                    tChildren=[tDictionary objectForKey:@"Children"];
                                    
                                    tMutableDictionary=tDictionary;
                                    
                                    break;
                                }
                            }
                            
                            if (tDictionary==nil)
                            {
                                // We need to create the new missing item
                                
                                NSMutableDictionary * tNewChildDictionary;
                                
                                tNewChildDictionary=[NSMutableDictionary dictionary];
                                
                                if (tNewChildDictionary!=nil)
                                {
                                    int j,tSiblingsCount;
                                        
                                    [tNewChildDictionary setObject:[NSMutableArray array] forKey:@"Children"];
                                    
                                    [tNewChildDictionary setObject:[NSNumber numberWithInt:2] forKey:@"Type"];
                                    
                                    [tNewChildDictionary setObject:[NSNumber numberWithInt:0] forKey:@"Path Type"];
                                    
                                    [tNewChildDictionary setObject:tComponent forKey:@"Path"];
                                    
                                    [tNewChildDictionary setObject:[NSNumber numberWithInt:([[tMutableDictionary objectForKey:@"Privileges"] intValue] & (S_IRWXU+S_IRWXG+S_IRWXO))] forKey:@"Privileges"];
                                    
                                    [tNewChildDictionary setObject:[NSNumber numberWithInt:[[tMutableDictionary objectForKey:@"UID"] intValue]] forKey:@"UID"];
                                    
                                    [tNewChildDictionary setObject:[NSNumber numberWithInt:[[tMutableDictionary objectForKey:@"GID"] intValue]] forKey:@"GID"];
                                    
                                    // Insert the item at the appropriate location
                                    
                                    tSiblingsCount=[tChildren count];
                            
                                    for(j=0;j<tSiblingsCount;j++)
                                    {
                                        NSString * tFileName;
                                        
                                        tDictionary=[tChildren objectAtIndex:j];
                                        
                                        tFileName=[[tDictionary objectForKey:@"Path"] lastPathComponent];
                                        
                                        if ([tComponent compare:tFileName]==NSOrderedAscending)
                                        {
                                            [tChildren insertObject:tNewChildDictionary atIndex:j];
                                            break;
                                        }
                                    }
                                    
                                    if (j==tSiblingsCount)
                                    {
                                        [tChildren addObject:tNewChildDictionary];
                                    }
                                    
                                    tChildren=[tNewChildDictionary objectForKey:@"Children"];
                                    
                                    tMutableDictionary=tNewChildDictionary;
                                }
                            }
                        }
                    }
                    
                    if (tChildren!=nil)
                    {
                        NSArray * tRootDirectoryContent;
                        NSEnumerator * tRootEnumerator;
                        NSString * tFileName;
                        
                        tRootDirectoryContent=[tFileManager directoryContentsAtPath:rootDirectory_];
                        
                        tRootEnumerator=[tRootDirectoryContent objectEnumerator];
                        
                        while (tFileName=[tRootEnumerator nextObject])
                        {
                            NSEnumerator * tChildrenEnumerator;
                            NSMutableDictionary * tDictionary;
                            BOOL found=NO;
                            
                            tChildrenEnumerator=[tChildren objectEnumerator];
                            
                            while (tDictionary=[tChildrenEnumerator nextObject])
                            {
                                NSString * tObjectName;
                                
                                tObjectName=[[tDictionary objectForKey:@"Path"] lastPathComponent];
                                
                                if ([tObjectName isEqualToString:tFileName]==YES)
                                {
                                    found=YES;
                                    
                                    // We need to replace the current item with ours
                                    
                                    [tDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Path Type"];
                                    
                                    [tDictionary setObject:[rootDirectory_ stringByAppendingPathComponent:tFileName] forKey:@"Path"];
                                    
                                    [tDictionary setObject:[NSNumber numberWithInt:3] forKey:@"Type"];
                                    
                                    [tDictionary setObject:[NSMutableArray array] forKey:@"Children"];
                                }
                            }
                            
                            if (found==NO)
                            {
                                // Create new record andd add at the correct position
                                
                                tDictionary=[NSMutableDictionary dictionary];
                                
                                if (tDictionary!=nil)
                                {
                                    NSDictionary * tFileAttributes;
                                    NSNumber * tNumber;
                                    NSDictionary * tSibling;
                                    int j,tSiblingsCount;
                                    
                                    tFileAttributes=[tFileManager fileAttributesAtPath:[rootDirectory_ stringByAppendingPathComponent:tFileName] traverseLink:NO];
                    
                                    tNumber=[tFileAttributes objectForKey:NSFileOwnerAccountID];
                        
                                    if (tNumber!=nil)
                                    {
                                        [tDictionary setObject:tNumber forKey:@"UID"];
                                    }
                                    
                                    tNumber=[tFileAttributes objectForKey:NSFileGroupOwnerAccountID];
                                    
                                    if (tNumber!=nil)
                                    {
                                        [tDictionary setObject:tNumber forKey:@"GID"];
                                    }
                                    
                                    tNumber=[tFileAttributes objectForKey:NSFilePosixPermissions];
                                    
                                    if (tNumber!=nil)
                                    {
                                        [tDictionary setObject:tNumber forKey:@"Privileges"];
                                    }
                                    
                                    [tDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Path Type"];
                                    
                                    [tDictionary setObject:[rootDirectory_ stringByAppendingPathComponent:tFileName] forKey:@"Path"];
                                    
                                    [tDictionary setObject:[NSNumber numberWithInt:3] forKey:@"Type"];
                                    
                                    [tDictionary setObject:[NSMutableArray array] forKey:@"Children"];
                                    
                                    // Insert the object in the hierarchy
                                    
                                    tSiblingsCount=[tChildren count];
                                    
                                    for(j=0;j<tSiblingsCount;j++)
                                    {
                                        tSibling=[tChildren objectAtIndex:j];
                                    
                                        if (tSibling!=nil)
                                        {
                                            NSString * tObjectName;
                                        
                                            tObjectName=[[tSibling objectForKey:@"Path"] lastPathComponent];
                                        
                                            if ([tFileName compare:tObjectName]==NSOrderedAscending)
                                            {
                                                [tChildren insertObject:tDictionary atIndex:j];
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (j==tSiblingsCount)
                                    {
                                        [tChildren addObject:tDictionary];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                // Provide the default file hierarchy
                
                tHierarchyDictionary=[NSDictionary dictionaryWithContentsOfFile:tPath];
            }
        }
        
        if (tHierarchyDictionary!=nil)
        {
            [nFilesDictionary setObject:tHierarchyDictionary forKey:@"Hierarchy"];
        }
        else
        {
            // A COMPLETER
        }
    }
    
    return nFilesDictionary;
}

- (NSMutableDictionary *) settingsDictionary
{
    NSMutableDictionary * nSettingsDictionary;
    NSMutableDictionary * nOptionsDictionary;
    
    nSettingsDictionary=[super settingsDictionary];
    
    nOptionsDictionary=[NSMutableDictionary dictionary];
    
    if (nOptionsDictionary!=nil)
    {
        NSArray * tOptionsArray;
        NSEnumerator * tEnumerator;
        NSString * tKey;
        NSString * tString;
        int tIndex;
        
        tOptionsArray=[NSArray arrayWithObjects:@"IFPkgFlagAllowBackRev",
                                                @"IFPkgFlagRootVolumeOnly",
                                                @"IFPkgFlagUpdateInstalledLanguages",
                                                @"IFPkgFlagFollowLinks",
                                                @"IFPkgFlagInstallFat",
                                                @"IFPkgFlagRelocatable",
                                                @"IFPkgFlagIsRequired",
                                                @"IFPkgFlagOverwritePermissions",
                                                nil];
        
        tEnumerator=[tOptionsArray objectEnumerator];
        
        while (tKey=[tEnumerator nextObject])
        {
            NSNumber * tNumber;
            BOOL tValue=NO;
            
            tNumber=[infoDictionary_ objectForKey:tKey];
            
            if (tNumber!=nil)
            {
                tValue=[tNumber boolValue];
            }
            
            [nOptionsDictionary setObject:[NSNumber numberWithBool:tValue] forKey:tKey];
        }
        
        // IFPkgFlagAuthorizationAction
        
        tString=[infoDictionary_ objectForKey:@"IFPkgFlagAuthorizationAction"];
        
        tIndex=0;
        
        if (tString!=nil)
        {
            if ([tString isEqualToString:@"AdminAuthorization"]==YES)
            {
                tIndex=1;
            }
            else
            if ([tString isEqualToString:@"RootAuthorization"]==YES)
            {
                tIndex=2;
            }
        }
        
        [nOptionsDictionary setObject:[NSNumber numberWithInt:tIndex] forKey:@"IFPkgFlagAuthorizationAction"];
        
        // IFPkgFlagRestartAction
        
        tString=[infoDictionary_ objectForKey:@"IFPkgFlagRestartAction"];
        
        tIndex=0;
        
        if (tString!=nil)
        {
            if ([tString isEqualToString:@"RecommendedRestart"]==YES)
            {
                tIndex=1;
            }
            else
            if ([tString isEqualToString:@"RequiredRestart"]==YES)
            {
                tIndex=2;
            }
            else
            if ([tString isEqualToString:@"Shutdown"]==YES)
            {
               tIndex=3;
            }
            else
            if ([tString isEqualToString:@"RequiredLogout"]==YES)
            {
                tIndex=4;
            }
        }
        
        [nOptionsDictionary setObject:[NSNumber numberWithInt:tIndex] forKey:@"IFPkgFlagRestartAction"];
        
        [nSettingsDictionary setObject:nOptionsDictionary forKey:@"Options"];
    }
    
    return nSettingsDictionary;
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary * nProjectHierarchy;
    
    nProjectHierarchy=[NSMutableDictionary dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        NSMutableDictionary * nHierarchyAttributes;
        NSString * tName;
        
        tName=[infoDictionary_ objectForKey:@"CFBundleName"];
        
        if ([tName length]==0)
        {
            tName=[infoDictionary_ objectForKey:@"IFPkgDescriptionTitle"];
            
            if ([tName length]==0)
            {
                tName=NSLocalizedString(@"Untitled Component",@"No comment"); 
            }
        }
        
        [nProjectHierarchy setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
        
        [nProjectHierarchy setObject:tName forKey:@"Name"];
    
    	[nProjectHierarchy setObject:[NSNumber numberWithInt:0] forKey:@"IFPkgFlagPackageSelection"];
        
        [nProjectHierarchy setObject:[NSNumber numberWithInt:1] forKey:@"Status"];
        
        nHierarchyAttributes=[NSMutableDictionary dictionary];
    
        if (nHierarchyAttributes!=nil)
        {
            [nHierarchyAttributes setObject:[self filesDictionary] forKey:@"Files"];
            
            [nHierarchyAttributes setObject:[self documentsDictionary] forKey:@"Documents"];
            
            [nHierarchyAttributes setObject:[self scriptsDictionary] forKey:@"Scripts"];
            
            [nHierarchyAttributes setObject:[self settingsDictionary] forKey:@"Settings"];
        
            [nProjectHierarchy setObject:nHierarchyAttributes forKey:@"Attributes"];
        }
    }
    
    return nProjectHierarchy;
}

- (NSMutableDictionary *) projectDictionary
{
    NSMutableDictionary * nProjectDictionary;
    NSMutableDictionary * nProjectHierarchy;
    
    nProjectDictionary=[super projectDictionary];
    
    // Hierarchy
    
    nProjectHierarchy=[self dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        [nProjectDictionary setObject:nProjectHierarchy forKey:@"Hierarchy"];
    }
    
    return nProjectDictionary;
}

@end

@implementation PBJaguarMetaPackageDecoder (Iceberg)

+ (id) jaguarMetaPackageDecoderWithDictionary:(NSDictionary *) inDictionary
{
    PBJaguarMetaPackageDecoder * nMetaPackageDecoder;
    
    nMetaPackageDecoder=[[PBJaguarMetaPackageDecoder alloc] initWithDictionary:inDictionary];

    return nMetaPackageDecoder;
}

- (id) initWithDictionary:(NSDictionary *) inDictionary
{
    self=[super init];
    
    if (inDictionary!=nil)
    {
        // A COMPLETER
    }
    else
    {
        [self release];
        
        return nil;
    }
    
    return self;
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary * nProjectHierarchy;
    
    nProjectHierarchy=[NSMutableDictionary dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        NSMutableDictionary * nHierarchyAttributes;
        NSString * tName;
        
        tName=[infoDictionary_ objectForKey:@"CFBundleName"];
        
        if ([tName length]==0)
        {
            tName=[infoDictionary_ objectForKey:@"IFPkgDescriptionTitle"];
            
            if ([tName length]==0)
            {
                tName=NSLocalizedString(@"Untitled Component",@"No comment");
            }
        }
        
        [nProjectHierarchy setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
        
        [nProjectHierarchy setObject:tName forKey:@"Name"];
    
    	[nProjectHierarchy setObject:[NSNumber numberWithInt:0] forKey:@"IFPkgFlagPackageSelection"];
        
        [nProjectHierarchy setObject:[NSNumber numberWithInt:1] forKey:@"Status"];
        
        nHierarchyAttributes=[NSMutableDictionary dictionary];
    
        if (nHierarchyAttributes!=nil)
        {
            [nHierarchyAttributes setObject:[NSMutableDictionary dictionary] forKey:@"Components"];
            
            [nHierarchyAttributes setObject:[self documentsDictionary] forKey:@"Documents"];
            
            [nHierarchyAttributes setObject:[self scriptsDictionary] forKey:@"Scripts"];
            
            [nHierarchyAttributes setObject:[self settingsDictionary] forKey:@"Settings"];
        
            [nProjectHierarchy setObject:nHierarchyAttributes forKey:@"Attributes"];
        }
    }
    
    return nProjectHierarchy;
}

- (NSMutableDictionary *) projectDictionary
{
    NSMutableDictionary * nProjectDictionary;
    NSMutableDictionary * nProjectHierarchy;
    
    nProjectDictionary=[super projectDictionary];
    
    // Hierarchy
    
    nProjectHierarchy=[self dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        [nProjectDictionary setObject:nProjectHierarchy forKey:@"Hierarchy"];
    }
    
    return nProjectDictionary;
}

@end