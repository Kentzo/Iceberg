#import "PBTigerPackageMakerDecoder+Iceberg.h"

#import "PBProjectTreeImporter.h"

#import "NSDictionary+Iceberg.h"

#include <sys/stat.h>

@implementation PBTigerCorePackageDecoder (Iceberg)

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
    NSString * tResourcesPath;
    
    tResourcesPath=[[resources_ extras] absolutePathWithReference:sourcePath_];
     
    nDocumentsDictionary=[PBProjectTreeImporter importPartialDocumentsAtPath:tResourcesPath];
    
    if (nDocumentsDictionary!=nil)
    {
    	NSMutableDictionary * nBackgroundDictionary;
        PBTigerLocalPath * tTigerPath;
        NSMutableDictionary * tMutableDictionary;
        NSMutableDictionary * tInternationalMutableDictionary;
        NSString * tPath=nil;
        
        // Background Image
        
        nBackgroundDictionary=[NSMutableDictionary dictionary];
        
        if (nBackgroundDictionary!=nil)
        {
            
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:[resources_ alignment]] forKey:@"IFPkgFlagBackgroundAlignment"];
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:[resources_ scaling]] forKey:@"IFPkgFlagBackgroundScaling"];
            
            tTigerPath=[resources_ background];
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Path Type"];
            
            if (tTigerPath==nil)
            {
                tPath=[PBProjectTreeImporter bagroundImageAtPath:tResourcesPath];
            }
            else
            {
                tPath=[tTigerPath absolutePathWithReference:sourcePath_];
            }
            
            [nBackgroundDictionary setObject:[NSNumber numberWithInt:(tPath==nil) ? 0 : 1] forKey:@"Mode"];
            
            [nBackgroundDictionary setObject: (tPath!=nil ? tPath : @"") forKey:@"Path"];
        
            [nDocumentsDictionary setObject:nBackgroundDictionary forKey:@"Background Image"];
        }
        
        // Use Welcome file for International?
        
        tTigerPath=[resources_ welcome];
        
        if (tTigerPath!=nil)
        {
            tMutableDictionary=[nDocumentsDictionary objectForKey:@"Welcome"];
            
            if (tMutableDictionary!=nil)
            {
                tPath=[tTigerPath absolutePathWithReference:sourcePath_];
                
                if (tPath!=nil)
                {
                    tInternationalMutableDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                                        tPath,@"Path",
                                                                                        nil];
                
                    [tMutableDictionary setObject:tInternationalMutableDictionary forKey:@"International"];
                }
            }
        }
        
        // Use ReadMe file for International?
        
        tTigerPath=[resources_ readme];
        
        if (tTigerPath!=nil)
        {
            tMutableDictionary=[nDocumentsDictionary objectForKey:@"ReadMe"];
            
            if (tMutableDictionary!=nil)
            {
                tPath=[tTigerPath absolutePathWithReference:sourcePath_];
                
                if (tPath!=nil)
                {
                        tInternationalMutableDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                                                   tPath,@"Path",
                                                                                                   nil];
                    [tMutableDictionary setObject:tInternationalMutableDictionary forKey:@"International"];
                }
            }
        }
        
        // Use License file for International?
        
        tTigerPath=[resources_ license];
        
        if (tTigerPath!=nil)
        {
            tMutableDictionary=[nDocumentsDictionary objectForKey:@"License"];
            
            if (tMutableDictionary!=nil)
            {
                tPath=[tTigerPath absolutePathWithReference:sourcePath_];
                
                if (tPath!=nil)
                {
                    tInternationalMutableDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                                               tPath,@"Path",
                                                                                               nil];
                    [tMutableDictionary setObject:tInternationalMutableDictionary forKey:@"International"];
                }
            }
        }
    }
    
    return nDocumentsDictionary;
}

- (NSMutableArray *) requirementsArray
{
    NSMutableArray * nRequirementsArray=nil;
    
    if (requirementsArray_!=nil)
    {
        nRequirementsArray=[NSMutableArray arrayWithCapacity:[requirementsArray_ count]];
        
        if (nRequirementsArray!=nil)
        {
            NSEnumerator * tEnumerator;
            NSDictionary * tRequirementDictionary;
            int tRequirementIndex=0;
            
            tEnumerator=[requirementsArray_ objectEnumerator];
            
            while (tRequirementDictionary=[tEnumerator nextObject])
            {
                NSMutableDictionary * nRequirementDictionary;
                
                nRequirementDictionary=[NSMutableDictionary dictionary];
                
                if (nRequirementDictionary!=nil)
                {
                    NSString * tString;
                    NSMutableDictionary * tAlertDialogDictionary;
                    id tObject;
                    
                    // Status
                
                    [nRequirementDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
                    
                    // Label Key
                    
                    tString=[tRequirementDictionary objectForKey:@"LabelKey"];
                    
                    if (tString==nil)
                    {
                        if (tRequirementIndex==0)
                        {
                            tString=@"untitled requirement";
                        }
                        else
                        {
                            tString=[NSString stringWithFormat:@"untitled requirement %d",tRequirementIndex];
                        }
                        
                        tRequirementIndex++;
                    }
                    
                    [nRequirementDictionary setObject:tString forKey:@"LabelKey"];
                    
                    // Alert Dialog
                    
                    tAlertDialogDictionary=[NSMutableDictionary dictionary];
                    
                    if (tAlertDialogDictionary!=nil)
                    {
                        NSString * tTitleKey;
                        NSString * tMessageKey;
                        NSMutableDictionary * tInternationalDictionary;
                        
                        tTitleKey=[tRequirementDictionary objectForKey:@"TitleKey"];
                        
                        if (tTitleKey==nil)
                        {
                            tTitleKey=@"";
                        }
                        
                        tMessageKey=[tRequirementDictionary objectForKey:@"MessageKey"];
                        
                        if (tMessageKey==nil)
                        {
                            tMessageKey=@"";
                        }
                        
                        tInternationalDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tMessageKey,@"MessageKey",
                                                                                                   tTitleKey,@"TitleKey",
                                                                                                   nil];
                        
                        if (tInternationalDictionary!=nil)
                        {
                            [tAlertDialogDictionary setObject:tInternationalDictionary forKey:@"International"];
                            
                            [nRequirementDictionary setObject:tAlertDialogDictionary forKey:@"AlertDialog"];
                        }
                    }
                    
                    // Level
                    
                    tString=[tRequirementDictionary objectForKey:@"Level"];
                    
                    if (tString==nil)
                    {
                        [nRequirementDictionary setObject:[NSNumber numberWithInt:0] forKey:@"Level"];
                    }
                    else
                    {
                        if ([tString isEqualToString:@"requires"]==YES)
                        {
                            [nRequirementDictionary setObject:[NSNumber numberWithInt:0] forKey:@"Level"];
                        }
                        else
                        {
                            [nRequirementDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Level"];
                        }
                    }
                    
                    // SpecType
                    
                    tString=[tRequirementDictionary objectForKey:@"SpecType"];
                    
                    if (tString==nil)
                    {
                        continue;
                    }
                    else
                    {
                        int tSpecTag=0;
                        
                        [nRequirementDictionary setObject:tString forKey:@"SpecType"];
                        
                        if ([tString isEqualToString:@"package"]==YES)
                        {
                            tSpecTag=4;
                        }
                        else if ([tString isEqualToString:@"gestalt"]==YES)
                        {
                            tSpecTag=2;
                        }
                        else if ([tString isEqualToString:@"bundle"]==YES)
                        {
                            tSpecTag=0;
                        }
                        else if ([tString isEqualToString:@"plist"]==YES)
                        {
                            tSpecTag=5;
                        }
                        else if ([tString isEqualToString:@"file"]==YES)
                        {
                            tSpecTag=1;
                        }
                        else if ([tString isEqualToString:@"sysctl"]==YES)
                        {
                            tSpecTag=6;
                        }
                        else
                        {
                            // We don't handle I/O Kit right now
                        
                            NSLog(@"[PBTigerCorePackageDecoder(Iceberg) requirementsArray]: Unsupported SpecType: %@",tString);
                        
                            continue;
                        }
                        
                        [nRequirementDictionary setObject:[NSNumber numberWithInt:tSpecTag] forKey:@"SpecTag"];
                    }
                    
                    // SpecArgument
                    
                    tObject=[tRequirementDictionary objectForKey:@"SpecArgument"];
                    
                    if (tObject!=nil)
                    {
                        [nRequirementDictionary setObject:tObject forKey:@"SpecArgument"];
                    }
                    
                    // TestOperator
                    
                    tObject=[tRequirementDictionary objectForKey:@"TestOperator"];
                    
                    if (tObject!=nil)
                    {
                        [nRequirementDictionary setObject:tObject forKey:@"TestOperator"];
                    }
                    
                    // TestObject
                    
                    tObject=[tRequirementDictionary objectForKey:@"TestObject"];
                    
                    if (tObject!=nil)
                    {
                        [nRequirementDictionary setObject:tObject forKey:@"TestObject"];
                    }
                    
                    // SpecProperty
                    
                    tObject=[tRequirementDictionary objectForKey:@"SpecProperty"];
                    
                    if (tObject!=nil)
                    {
                        [nRequirementDictionary setObject:tObject forKey:@"SpecProperty"];
                    }
                    
                    [nRequirementsArray addObject:nRequirementDictionary];
                }
                else
                {
                     NSLog(@"[PBTigerCorePackageDecoder(Iceberg) requirementsArray]: Not enough memory");
                }
            }
        }
        else
        {
            NSLog(@"[PBTigerCorePackageDecoder(Iceberg) requirementsArray]: Not enough memory");
        }
    }
    
    return nRequirementsArray;
}

- (NSMutableDictionary *) scriptsDictionary
{
    NSMutableDictionary * nScriptsDictionary;
    
    nScriptsDictionary=[NSMutableDictionary dictionary];
    
    if (nScriptsDictionary!=nil)
    {
    	NSMutableArray * nRequirementsArray;
        NSMutableDictionary * nInstallationScriptsDictionary;
        NSMutableDictionary * nAdditionalResourcesDictionary;
        NSFileManager * tFileManager;
        NSString * tResourcesPath;
        
        tFileManager=[NSFileManager defaultManager];
        
        // Requirements
        
        if (requirementsArray_!=nil)
        {
            nRequirementsArray=[self requirementsArray];
        }
        else
        {
            nRequirementsArray=[NSMutableArray array];
        }
        
        if (nRequirementsArray!=nil)
        {
            [nScriptsDictionary setObject:nRequirementsArray forKey:@"Requirements"];
        }
        
        // Installation Scripts
        
        tResourcesPath=[[resources_ extras] absolutePathWithReference:sourcePath_];
        
        nInstallationScriptsDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:tResourcesPath];
        
        if (nInstallationScriptsDictionary!=nil)
        {
            [nScriptsDictionary setObject:nInstallationScriptsDictionary forKey:@"Installation Scripts"];
        }
        
        // Additional Resources
        
       nAdditionalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:tResourcesPath];
        
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
        NSMutableDictionary * nDisplayInformationDictionary;
        NSMutableDictionary * nVersionDictionary;
        NSMutableDictionary * nDescriptionDictionary;
        
        // Display Information
        
	nDisplayInformationDictionary=[NSMutableDictionary dictionary];
        
        if (nDisplayInformationDictionary!=nil)
        {
            NSString * tString;
            
            tString=[infoDictionary_ objectForKey:@"getInfo"];
            
            if (tString==nil)
            {
                tString=@"";
            }
            
            [nDisplayInformationDictionary setObject:tString forKey:@"CFBundleGetInfoString"];
            
            tString=[infoDictionary_ objectForKey:@"identifier"];
            
            if (tString==nil)
            {
                tString=@"";
            }
            
            [nDisplayInformationDictionary setObject:tString forKey:@"CFBundleIdentifier"];
            
            tString=[infoDictionary_ objectForKey:@"name"];
            
            if (tString==nil)
            {
                tString=@"";
            }
            
            [nDisplayInformationDictionary setObject:tString forKey:@"CFBundleName"];
            
            tString=[infoDictionary_ objectForKey:@"shortVersion"];
            
            if (tString==nil)
            {
                tString=@"";
            }
            
            [nDisplayInformationDictionary setObject:tString forKey:@"CFBundleShortVersionString"];
    
            [nSettingsDictionary setObject:nDisplayInformationDictionary forKey:@"Display Information"];
        }
        
        // Version
        
        nVersionDictionary=[NSMutableDictionary dictionary];
        
        if (nVersionDictionary!=nil)
        {
            NSNumber * tNumber;
            
            tNumber=[infoDictionary_ objectForKey:@"majorVersion"];
            
            if (tNumber==nil)
            {
                tNumber=[NSNumber numberWithInt:1];
            }
            
            [nVersionDictionary setObject:tNumber forKey:@"IFMajorVersion"];
            
            tNumber=[infoDictionary_ objectForKey:@"minorVersion"];
            
            if (tNumber==nil)
            {
                tNumber=[NSNumber numberWithInt:0];
            }
            
            [nVersionDictionary setObject:tNumber forKey:@"IFMinorVersion"];
            
            [nSettingsDictionary setObject:nVersionDictionary forKey:@"Version"];
        }
        
        // Description
        
        nDescriptionDictionary=[NSMutableDictionary dictionary];
        
        if (nDescriptionDictionary!=nil)
        {
            NSMutableDictionary * tInternationalDescriptionDictionary;
            NSString * tResourcesPath;
            
            // International
            
            tInternationalDescriptionDictionary=[NSMutableDictionary dictionary];
        
            if (tInternationalDescriptionDictionary!=nil)
            {
                NSString * tString;
                
                tString=[descriptionDictionary_ objectForKey:@"title"];
                
                if (tString==nil)
                {
                    tString=@"";
                }
                
                [tInternationalDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionTitle"];
                
                tString=[descriptionDictionary_ objectForKey:@"version"];
                
                if (tString==nil)
                {
                    tString=@"";
                }
                
                [tInternationalDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionVersion"];
                
                tString=[descriptionDictionary_ objectForKey:@"deleteWarning"];
                
                if (tString==nil)
                {
                    tString=@"";
                }
                
                [tInternationalDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionDeleteWarning"];
                
                tString=[descriptionDictionary_ objectForKey:@"description"];
                
                if (tString==nil)
                {
                    tString=@"";
                }
                
                [tInternationalDescriptionDictionary setObject:tString forKey:@"IFPkgDescriptionDescription"];
                
                [nDescriptionDictionary setObject:tInternationalDescriptionDictionary forKey:@"International"];
            }
            
            // Other languages
            
            tResourcesPath=[[resources_ extras] absolutePathWithReference:sourcePath_];
            
            if ([tResourcesPath length]>0)
            {
                NSFileManager * tFileManager;
                NSArray * tArray=nil;

                tFileManager=[NSFileManager defaultManager];
                
                tArray=[tFileManager directoryContentsAtPath:tResourcesPath];
                
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
                            
                            tFilePath=[[tResourcesPath stringByAppendingPathComponent:tFileName] stringByAppendingPathComponent:@"Description.plist"];
                            
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

@implementation PBTigerSinglePackageDecoder (Iceberg)

+ (id) tigerSinglePackageDecoderWithDictionary:(NSDictionary *) inDictionary;
{
    PBTigerSinglePackageDecoder * nSinglePackageDecoder;
    
    nSinglePackageDecoder=[[PBTigerSinglePackageDecoder alloc] initWithDictionary:inDictionary];

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
        NSString * tRootPath;
        
    	tFileManager=[NSFileManager defaultManager];
        
        [nFilesDictionary setObject:[infoDictionary_ objectForKey:@"compress"] forKey:@"Compress"];
        
        [nFilesDictionary setObject:[infoDictionary_ objectForKey:@"preserveForks"] forKey:@"Split Forks"];
        
        [nFilesDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"Imported Package"];
        
        [nFilesDictionary setObject:@"" forKey:@"Package Path"];
        
        tDefaultLocation=[[infoDictionary_ objectForKey:@"installLocation"] absolutePathWithReference:sourcePath_];
        
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
        
        tRootPath=[[infoDictionary_ objectForKey:@"contents"] absolutePathWithReference:sourcePath_];
        
        if ([tRootPath length]>0)
        {
            BOOL isDirectory;
            
            if ([tFileManager fileExistsAtPath:tRootPath isDirectory:&isDirectory]==YES &&
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
                        
                        tRootDirectoryContent=[tFileManager directoryContentsAtPath:tRootPath];
                        
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
                                    
                                    [tDictionary setObject:[tRootPath stringByAppendingPathComponent:tFileName] forKey:@"Path"];
                                    
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
                                    
                                    tFileAttributes=[tFileManager fileAttributesAtPath:[tRootPath stringByAppendingPathComponent:tFileName] traverseLink:NO];
                    
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
                                    
                                    [tDictionary setObject:[tRootPath stringByAppendingPathComponent:tFileName] forKey:@"Path"];
                                    
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
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"allowBackRev"] forKey:@"IFPkgFlagAllowBackRev"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"rootVolumeOnly"] forKey:@"IFPkgFlagRootVolumeOnly"];
        
        [nOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"IFPkgFlagUpdateInstalledLanguages"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"followLinks"] forKey:@"IFPkgFlagFollowLinks"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"installFat"] forKey:@"IFPkgFlagInstallFat"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"relocatable"] forKey:@"IFPkgFlagRelocatable"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"required"] forKey:@"IFPkgFlagIsRequired"];
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"overwritePermissions"] forKey:@"IFPkgFlagOverwritePermissions"];
        
        // IFPkgFlagAuthorizationAction
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"authorization"] forKey:@"IFPkgFlagAuthorizationAction"];
        
        // IFPkgFlagRestartAction
        
        [nOptionsDictionary setObject:[infoDictionary_ objectForKey:@"onFinished"] forKey:@"IFPkgFlagRestartAction"];
        
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
        
        tName=[infoDictionary_ objectForKey:@"name"];
        
        if ([tName length]==0)
        {
            tName=[descriptionDictionary_ objectForKey:@"title"];
            
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
        [[nProjectDictionary objectForKey:@"Settings"] setObject:[infoDictionary_ objectForKey:@"removeDSStore"] forKey:@"Remove .DS_Store"];
        
        [nProjectDictionary setObject:nProjectHierarchy forKey:@"Hierarchy"];
    }
    
    return nProjectDictionary;
}

@end

@implementation PBTigerMetaPackageDecoder (Iceberg)

+ (id) tigerMetaPackageDecoderWithDictionary:(NSDictionary *) inDictionary
{
    PBTigerMetaPackageDecoder * nMetaPackageDecoder;
    
    nMetaPackageDecoder=[[PBTigerMetaPackageDecoder alloc] initWithDictionary:inDictionary];

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
        
        tName=[infoDictionary_ objectForKey:@"name"];
        
        if ([tName length]==0)
        {
            tName=[descriptionDictionary_ objectForKey:@"title"];
            
            if ([tName length]==0)
            {
                tName=NSLocalizedString(@"Untitled Component",@"No comment");
            }
        }
        
        [nProjectHierarchy setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
        
        [nProjectHierarchy setObject:tName forKey:@"Name"];
    
    	[nProjectHierarchy setObject:[NSNumber numberWithInt:0] forKey:@"IFPkgFlagPackageSelection"];
        
        [nProjectHierarchy setObject:location_ forKey:@"IFPkgFlagComponentDirectory"];
        
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