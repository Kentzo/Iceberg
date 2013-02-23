#import "PBCheetahPackageMakerDecoder+Iceberg.h"

#import "PBProjectTreeImporter.h"

#import "NSDictionary+Iceberg.h"

#include <sys/stat.h>

@implementation PBCheetahCorePackageDecoder (Iceberg)

- (id) initWithDictionary:(NSDictionary *) inDictionary
{
    self=[super init];
    
    return self;
}

- (void) lookForPackageName
{
    // Try to find the name of the Package from the scripts
    
    NSArray * tContents;
    NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    tContents=[tFileManager directoryContentsAtPath:resourcesDirectory_];
                
    if (tContents!=nil)
    {
        NSString * tFileName;
        NSString * tExtension;
        NSEnumerator *tEnumerator;
        
        tEnumerator=[tContents objectEnumerator];
        
        while (tFileName=[tEnumerator nextObject])
        {
            tExtension=[tFileName pathExtension];
        
            if ([tExtension isEqualToString:@"lproj"]==YES)
            {
                // Try to find the name of the Package from the .info files
                
                NSArray * tLocalizedContents;
                
                
                tLocalizedContents=[tFileManager directoryContentsAtPath:[resourcesDirectory_ stringByAppendingPathComponent:tFileName]];
                
                if (tLocalizedContents!=nil)
                {
                    NSEnumerator * tLocalizedEnumerator;
                    NSString * tLocalizedFileName;
                
                    tLocalizedEnumerator=[tLocalizedContents objectEnumerator];
            
                    while (tLocalizedFileName=[tLocalizedEnumerator nextObject])
                    {
                        tExtension=[tLocalizedFileName pathExtension];
                    
                        if ([tExtension isEqualToString:@"info"]==YES)
                        {
                            if (packageName_==nil)
                            {
                                packageName_=[[tFileName stringByDeletingPathExtension] retain];
                            }
                            else
                            {
                                if ([packageName_ isEqualToString:[tFileName stringByDeletingPathExtension]]==NO)
                                {
                                    [packageName_ release];
                                    
                                    packageName_=nil;
                                    
                                    return;
                                }
                            }
                            
                            break;
                        }
                    }
                }
            }
            else if ([tExtension isEqualToString:@"pre_install"]==YES ||
                     [tExtension isEqualToString:@"pre_upgrade"]==YES ||
                     [tExtension isEqualToString:@"post_install"]==YES ||
                     [tExtension isEqualToString:@"post_upgrade"]==YES)
            {
                if (packageName_==nil)
                {
                    packageName_=[[tFileName stringByDeletingPathExtension] retain];
                }
                else
                {
                    if ([packageName_ isEqualToString:[tFileName stringByDeletingPathExtension]]==NO)
                    {
                        [packageName_ release];
                        
                        packageName_=nil;
                        
                        break;
                    }
                }
            }
        }
    }
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
        
        if (packageName_!=nil)
        {
            nInstallationScriptsDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:resourcesDirectory_
                                                                                    forOldPackage:packageName_];
        }
        else
        {
            nInstallationScriptsDictionary=[NSMutableDictionary dictionary];
            
            if (nInstallationScriptsDictionary!=nil)
            {
                NSArray * tKeys=[NSArray arrayWithObjects:@"IFInstallationScriptsPreflight",
                                                          @"IFInstallationScriptsPreinstall",
                                                          @"IFInstallationScriptsPreupgrade",
                                                          @"IFInstallationScriptsPostinstall",
                                                          @"IFInstallationScriptsPostupgrade",
                                                          @"IFInstallationScriptsPostflight",
                                                          nil];
                
                NSString * tKey;
                NSEnumerator * tEnumerator;
            
                tEnumerator=[tKeys objectEnumerator];
            
                while (tKey=[tEnumerator nextObject])
                {
            
                    [nInstallationScriptsDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                        @"",@"Path",
                                                                                                        nil]
                                                      forKey:tKey];
                }
            }
        }
        
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
        NSMutableDictionary * nDisplayInformationDictionary;
        NSMutableDictionary * nVersionDictionary;
        NSMutableDictionary * nDescriptionDictionary;
        
        // Display Information
        
	nDisplayInformationDictionary=[NSMutableDictionary dictionary];
        
        if (nDisplayInformationDictionary!=nil)
        {
            [nDisplayInformationDictionary setObject:@"" forKey:@"CFBundleGetInfoString"];
            [nDisplayInformationDictionary setObject:@"" forKey:@"CFBundleIdentifier"];
            [nDisplayInformationDictionary setObject:packageTitle_ forKey:@"CFBundleName"];
            [nDisplayInformationDictionary setObject:packageVersion_ forKey:@"CFBundleShortVersionString"];
            
            [nSettingsDictionary setObject:nDisplayInformationDictionary forKey:@"Display Information"];
        }
        
        // Version
        
        nVersionDictionary=[NSMutableDictionary dictionary];
        
        if (nVersionDictionary!=nil)
        {
            [nVersionDictionary setObject:[NSNumber numberWithInt:1] forKey:@"IFMajorVersion"];
            
            [nVersionDictionary setObject:[NSNumber numberWithInt:0] forKey:@"IFMinorVersion"];
            
            [nSettingsDictionary setObject:nVersionDictionary forKey:@"Version"];
        }
        
        // Description
        
        nDescriptionDictionary=[NSMutableDictionary dictionary];
        
        if (nDescriptionDictionary!=nil)
        {
            NSFileManager * tFileManager;
            NSArray * tArray;
            NSMutableDictionary * tLocalizedDescriptionDictionary;
            
            // International
            
            tLocalizedDescriptionDictionary=[NSMutableDictionary dictionary];
            
            if (tLocalizedDescriptionDictionary!=nil)
            {
                [tLocalizedDescriptionDictionary setObject:packageTitle_ forKey:@"IFPkgDescriptionTitle"];
                
                [tLocalizedDescriptionDictionary setObject:packageVersion_ forKey:@"IFPkgDescriptionVersion"];
                
                [tLocalizedDescriptionDictionary setObject:packageDescription_ forKey:@"IFPkgDescriptionDescription"];
                
                [tLocalizedDescriptionDictionary setObject:@"" forKey:@"IFPkgDescriptionDeleteWarning"];
            }
            
            [nDescriptionDictionary setObject:tLocalizedDescriptionDictionary forKey:@"International"];
            
            if (packageName_!=nil && [resourcesDirectory_ length]>0)
            {
                // Other languages
                
                tFileManager=[NSFileManager defaultManager];
                
                tArray=[tFileManager directoryContentsAtPath:resourcesDirectory_];
                
                if (tArray!=nil)
                {
                    NSString * tFileName;
                    
                    tEnumerator=[tArray objectEnumerator];
                    
                    while (tFileName=[tEnumerator nextObject])
                    {
                        if ([[tFileName pathExtension] isEqualToString:@"lproj"]==YES)
                        {
                            NSString * tLocalizedPath;
                
                            tLocalizedPath=[[resourcesDirectory_ stringByAppendingPathComponent:tFileName] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",packageName_]];
                            
                            if ([tFileManager fileExistsAtPath:tLocalizedPath]==YES)
                            {
                                NSDictionary * tLocalizedInfoDictionary;
                                NSString * tString;
                                tLocalizedInfoDictionary=[NSDictionary dictionaryWithContentsOfInfoFile:tLocalizedPath];
                                
                                if (tLocalizedInfoDictionary!=nil)
                                {
                                    tLocalizedDescriptionDictionary=[NSMutableDictionary dictionary];
                                
                                    tString=[tLocalizedInfoDictionary objectForKey:@"Title"];
                    
                                    if (tString==nil)
                                    {
                                        tString=@"";
                                    }
                                    
                                    [tLocalizedDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionTitle"];
                                    
                                    tString=[tLocalizedInfoDictionary objectForKey:@"Version"];
                                    
                                    if (tString==nil)
                                    {
                                        tString=@"";
                                    }
                                    
                                    [tLocalizedDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionVersion"];
                                    
                                    tString=[tLocalizedInfoDictionary objectForKey:@"Description"];
                                    
                                    if (tString==nil)
                                    {
                                        tString=@"";
                                    }
                                    
                                    [tLocalizedDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionDescription"];
                                    
                                    tString=[tLocalizedInfoDictionary objectForKey:@"DeleteWarning"];
                        
                                    if (tString==nil)
                                    {
                                        tString=@"";
                                    }
                                    
                                    [tLocalizedDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionDeleteWarning"];
                                    
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

@implementation PBCheetahSinglePackageDecoder (Iceberg)

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
        
        tDefaultLocation=defaultLocation_;
        
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
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"IFPkgFlagAllowBackRev"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"IFPkgFlagRootVolumeOnly"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"IFPkgFlagUpdateInstalledLanguages"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"IFPkgFlagFollowLinks"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:installFat_] forKey:@"IFPkgFlagInstallFat"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:relocatable_] forKey:@"IFPkgFlagRelocatable"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:required_] forKey:@"IFPkgFlagIsRequired"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:overwritePermissions_] forKey:@"IFPkgFlagOverwritePermissions"];
        
        // IFPkgFlagAuthorizationAction
        
        tIndex=0;
        
        if (needsRootAuthorization_==YES)
        {
            tIndex=2;
        }
        
        [nOptionsDictionary setObject:[NSNumber numberWithInt:tIndex] forKey:@"IFPkgFlagAuthorizationAction"];
        
        // IFPkgFlagRestartAction
        
        tIndex=0;
        
        if (requiresReboot_==YES)
        {
            tIndex=2;
        }
        
        
        [nOptionsDictionary setObject:[NSNumber numberWithInt:tIndex] forKey:@"IFPkgFlagRestartAction"];
        
        [nSettingsDictionary setObject:nOptionsDictionary forKey:@"Options"];
    }
    
    return nSettingsDictionary;
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary * nProjectHierarchy;
    
    [self lookForPackageName];
    
    nProjectHierarchy=[NSMutableDictionary dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        NSMutableDictionary * nHierarchyAttributes;
        NSString * tName;
        
        tName=packageTitle_;
        
        if ([tName length]==0)
        {
            tName=NSLocalizedString(@"Untitled Component",@"No comment");
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

#pragma mark -

@implementation PBCheetahMetaPackageDecoder (Iceberg)

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
    
    [self lookForPackageName];
    
    nProjectHierarchy=[NSMutableDictionary dictionary];
    
    if (nProjectHierarchy!=nil)
    {
        NSMutableDictionary * nHierarchyAttributes;
        NSString * tName;
        
        tName=packageTitle_;
        
        if ([tName length]==0)
        {
            tName=NSLocalizedString(@"Untitled Component",@"No comment");
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