/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectTree+Import.h"

#import "PBProjectTreeImporter.h"
#import "NSDictionary+Iceberg.h"

#import "PBMetaPackageComponentsController.h"

@implementation PBProjectTree (Import)

+ (NSArray *) readOldFormatListDictionary:(NSString *) inPath
{
    NSMutableArray * nArray=nil;
    NSString * tFileData;
    
    tFileData=[NSString stringWithContentsOfFile:inPath];
    
    if (tFileData!=nil)
    {
        NSArray * tArray;
        
        tArray=[tFileData componentsSeparatedByString:@"\n"];
        
        if (tArray!=nil)
        {
            nArray=[NSMutableArray array];
            
            if (nArray!=nil)
            {
                NSEnumerator * tEnumerator;
                NSString * tLine;
                
                tEnumerator=[tArray objectEnumerator];
                
                while (tLine=[tEnumerator nextObject])
                {
                    NSArray * tTokens;
                    
                    tTokens=[tLine componentsSeparatedByString:@":"];
                    
                    if (tTokens!=nil && [tTokens count]==2)
                    {
                        [nArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[tTokens objectAtIndex:0],IFPkgFlagPackageLocation,
                                                                                     [tTokens objectAtIndex:1],IFPkgFlagPackageSelection,
                                                                                     nil]];
                    }
                }
            }
        }
    }
    
    return nArray;
}

+ (NSMutableDictionary *) optionsWithInfoDictionary:(NSDictionary *) inInfoDictionary
{
    NSMutableDictionary * tOptionsDictionary;
    NSString * tString;
    
    // Options Dictionary
        
    tOptionsDictionary=[NSMutableDictionary dictionary];
    
    // NeedsAuthorization
    
    tString=[inInfoDictionary objectForKey:@"NeedsAuthorization"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithInt:0] forKey:IFPkgFlagAuthorizationAction];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithInt:2] forKey:IFPkgFlagAuthorizationAction];
        }
    }
    
    // RequiresReboot
    
    tString=[inInfoDictionary objectForKey:@"RequiresReboot"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithInt:0] forKey:IFPkgFlagRestartAction];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithInt:2] forKey:IFPkgFlagRestartAction];
        }
    }
    
    // Required
    
    tString=[inInfoDictionary objectForKey:@"Required"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagIsRequired];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagIsRequired];
        }
    }
    
    // RootVolumeOnly
    
    tString=[inInfoDictionary objectForKey:@"RootVolumeOnly"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagRootVolumeOnly];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagRootVolumeOnly];
        }
    }
    
    // OverwritePermissions
    
    tString=[inInfoDictionary objectForKey:@"OverwritePermissions"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagOverwritePermissions];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagOverwritePermissions];
        }
    }
    
    // Relocatable
    
    tString=[inInfoDictionary objectForKey:@"Relocatable"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagRelocatable];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagRelocatable];
        }
    }
    
    // InstallFat
    
    tString=[inInfoDictionary objectForKey:@"InstallFat"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagInstallFat];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagInstallFat];
        }
    }
    
    // AllowBackRev
    
    tString=[inInfoDictionary objectForKey:@"AllowBackRev"];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagAllowBackRev];
    
    if (tString!=nil)
    {
        if ([tString isEqualToString:@"YES"]==YES)
        {
            [tOptionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:IFPkgFlagAllowBackRev];
        }
    }
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagFollowLinks];
    
    [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:IFPkgFlagUpdateInstalledLanguages];
    
    return tOptionsDictionary;
}

+ (NSDictionary *) imageDictionaryForResourcePath:(NSString *) inResourcePath infoDictionary:(NSDictionary *) inInfoDictionary
{
    NSString * tImagePath;
    NSDictionary * tImageDictionary;
    
    tImagePath=[PBProjectTreeImporter bagroundImageAtPath:inResourcePath];
                
    if (tImagePath!=nil)
    {
        NSNumber * tScaleValue;
        NSNumber * tAlignValue;
        int tIntValue;
        NSString * tString;
        
        tString=[inInfoDictionary objectForKey:IFPkgFlagBackgroundScaling];
        
        if (tString!=nil)
        {
            tIntValue=0;
            
            if ([tString isEqualToString:@"tofit"]==YES)
            {
                tIntValue=1;
            }
            else if ([tString isEqualToString:@"none"]==YES)
            {
                tIntValue=2;
            }
            
            tScaleValue=[NSNumber numberWithInt:tIntValue];
        }
        else
        {
            tScaleValue=[NSNumber numberWithInt:1];
        }
            
        tString=[inInfoDictionary objectForKey:IFPkgFlagBackgroundAlignment];
        
        if (tString!=nil)
        {
            tIntValue=0;
            
            if ([tString isEqualToString:@"left"]==YES)
            {
                tIntValue=4;
            }
            else if ([tString isEqualToString:@"right"]==YES)
            {
                tIntValue=8;
            }
            else if ([tString isEqualToString:@"top"]==YES)
            {
                tIntValue=1;
            }
            else if ([tString isEqualToString:@"bottom"]==YES)
            {
                tIntValue=5;
            }
            else if ([tString isEqualToString:@"topleft"]==YES)
            {
                tIntValue=2;
            }
            else if ([tString isEqualToString:@"topright"]==YES)
            {
                tIntValue=3;
            }
            else if ([tString isEqualToString:@"bottomleft"]==YES)
            {
                tIntValue=6;
            }
            else if ([tString isEqualToString:@"bottomright"]==YES)
            {
                tIntValue=7;
            }
            
            tAlignValue=[NSNumber numberWithInt:tIntValue];
        }
        else
        {
            tAlignValue=[NSNumber numberWithInt:4];
        }
        
        tImageDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                    tImagePath,@"Path",
                                                                    tAlignValue,IFPkgFlagBackgroundAlignment,
                                                                    tScaleValue,IFPkgFlagBackgroundScaling,
                                                                    nil];
    }
    else
    {
        tImageDictionary=[PBObjectNode defaultImageDictionary];
    }
    
    return tImageDictionary;
}

#pragma mark -

+ (id) projectTreeWithContentsOfComponent:(NSString *) inComponentPath recursive:(BOOL) inRecursive delegate:(id) inDelegate missingComponents:(NSMutableArray **) inOutMissingComponents
{
    NSString * tExtension;
    NSString * tFinalPath;
    NSFileManager * tFileManager;
    PBProjectTree * tProjectTree=nil;
    
    tExtension=[inComponentPath pathExtension];
    
    tFinalPath=[inDelegate finalPathForImportedComponentAtPath:inComponentPath];
        
    if (tFinalPath==nil)
    {
        if (*inOutMissingComponents==nil)
        {
            *inOutMissingComponents=[NSMutableArray array];
        }
        
        [(*inOutMissingComponents) addObject:[NSDictionary dictionaryWithObjectsAndKeys:inComponentPath,@"Path",
                                                                                        [NSNumber numberWithInt:0],@"Reason",
                                                                                        nil]];
        
        return nil;
    }
    
    tFileManager=[NSFileManager defaultManager];
    
    if ([tExtension isEqualToString:@"mpkg"]==YES)	// .mpkg
    {
        if ([tFileManager fileExistsAtPath:[tFinalPath stringByAppendingPathComponent:@"Contents/Info.plist"]]==YES)
        {
            tProjectTree=[PBProjectTree projectTreeWithContentsOfMetaPackage:tFinalPath
                                                                     oldPath:inComponentPath
                                                                   recursive:inRecursive
                                                                    delegate:inDelegate
                                                           missingComponents:inOutMissingComponents];
        }
        else
        {
            tProjectTree=[PBProjectTree projectTreeWithContentsOfMetaPackageOldFormat:tFinalPath
                                                                              oldPath:inComponentPath
                                                                            recursive:inRecursive
                                                                             delegate:inDelegate
                                                                    missingComponents:inOutMissingComponents];
        }
    }
    else if ([tExtension isEqualToString:@"pkg"]==YES)	// .pkg
    {
        if ([tFileManager fileExistsAtPath:[tFinalPath stringByAppendingPathComponent:@"Contents/Info.plist"]]==YES)
        {
            tProjectTree=[PBProjectTree projectTreeWithContentsOfPackage:tFinalPath];
        }
        else
        {
            tProjectTree=[PBProjectTree projectTreeWithContentsOfPackageOldFormat:tFinalPath];
        }
    }
    
    if (tProjectTree==nil)
    {
        if (*inOutMissingComponents==nil)
        {
            *inOutMissingComponents=[NSMutableArray array];
        }
        
        [(*inOutMissingComponents) addObject:[NSDictionary dictionaryWithObjectsAndKeys:inComponentPath,@"Path",
                                                                                        [NSNumber numberWithInt:2],@"Reason",
                                                                                        nil]];
    }
    
    return tProjectTree;
}

#pragma mark -

+ (id) projectTreeWithContentsOfPackageOldFormat:(NSString *) inFilePath
{
    PBProjectTree * newTree=nil;
    PBProjectTree * settingsNode=nil;
    PBProjectTree * filesNode=nil;
    PBProjectTree * resourcesNode=nil;
    PBProjectTree * scriptsNode=nil;
	PBProjectTree * pluginsNode=nil;
    NSString * tName;
    NSString * tInfoPlistPath;
    NSDictionary * tInfoDictionary;
    
    NSMutableDictionary * tSettings;
    NSMutableDictionary * tResources;
    NSMutableDictionary * tFiles;
    NSMutableDictionary * tScripts;
    
    NSMutableDictionary * tOptionsDictionary=nil;
    NSMutableDictionary * tVersionDictionary;
    
    NSString * tResourcePath;
    
    NSMutableDictionary * tDisplayInformationDictionary;
    
    NSString * tString;
    int i,tCount;
    NSMutableDictionary * tDescriptionDictionary;
    NSMutableDictionary * tLocalizedDictionary;
    NSFileManager * tFileManager;
    NSArray * tResourcesContent;
    NSDictionary * tImageDictionary=nil;
    
    NSMutableDictionary * tInstallationDictionary;
    NSMutableDictionary * tAdditonalResourcesDictionary;
    
    NSString * tDefaultLocation=@"/";
    
    tName=[[inFilePath lastPathComponent] stringByDeletingPathExtension];
    
    tInfoPlistPath=[inFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Contents/Resources/%@.info",tName]];
    
    // Description
        
    tDescriptionDictionary=[NSMutableDictionary dictionary];
    
    tLocalizedDictionary=[NSMutableDictionary dictionary];
    
    tInfoDictionary=[NSDictionary dictionaryWithContentsOfInfoFile:tInfoPlistPath];
    
    if (tInfoDictionary!=nil)
    {
        tDefaultLocation=[tInfoDictionary objectForKey:@"DefaultLocation"];
        
        tOptionsDictionary=[PBProjectTree optionsWithInfoDictionary:tInfoDictionary];
        
        tString=[tInfoDictionary objectForKey:@"Title"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionTitle];
        
        tString=[tInfoDictionary objectForKey:@"Version"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionVersion];
        
        tString=[tInfoDictionary objectForKey:@"Description"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDescription];
        
        tString=[tInfoDictionary objectForKey:@"DeleteWarning"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDeleteWarning];
        
        [tDescriptionDictionary setObject:tLocalizedDictionary forKey:@"International"];
    }
    else
    {
        [tDescriptionDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",IFPkgDescriptionTitle,
                                                                                     @"",IFPkgDescriptionDescription,
                                                                                     @"",IFPkgDescriptionVersion,
                                                                                     @"",IFPkgDescriptionDeleteWarning,
                                                                                     nil]
                                   forKey:@"International"];
    }
        
    // Version Dictionary (we create it from scratch)
    
    tVersionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],IFMajorVersion,
                                                                  [NSNumber numberWithInt:0],IFMinorVersion,
                                                                  nil];
        
        
    // ==========================================
        
    tResourcePath=[inFilePath stringByAppendingPathComponent:@"Contents/Resources"];
        
    // Display Information
        
    tDisplayInformationDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tName,@"CFBundleName",
                                                                                        @"",@"CFBundleIdentifier",
                                                                                        @"",@"CFBundleGetInfoString",
                                                                                        @"1.0",@"CFBundleShortVersionString",
                                                                                        nil];

    // Localized Description
        
    tFileManager=[NSFileManager defaultManager];
        
    tResourcesContent=[tFileManager directoryContentsAtPath:tResourcePath];
    
    tCount=[tResourcesContent count];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tComponent;
        
        tComponent=[tResourcesContent objectAtIndex:i];
        
        if ([[tComponent pathExtension] isEqualToString:@"lproj"]==YES)
        {
            NSString * tLocalizedPath;
            
            tLocalizedPath=[[tResourcePath stringByAppendingPathComponent:tComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",tName]];
            
            if ([tFileManager fileExistsAtPath:tLocalizedPath]==YES)
            {
                NSDictionary * tLocalizedInfoDictionary;
                
                tLocalizedInfoDictionary=[NSDictionary dictionaryWithContentsOfInfoFile:tLocalizedPath];
                
                if (tLocalizedInfoDictionary!=nil)
                {
                    if (tOptionsDictionary==nil)
                    {
                        tDefaultLocation=[tLocalizedInfoDictionary objectForKey:@"DefaultLocation"];
                        
                        tOptionsDictionary=[PBProjectTree optionsWithInfoDictionary:tLocalizedInfoDictionary];
                    }
                    
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
                
                    tString=[tLocalizedInfoDictionary objectForKey:@"Title"];
    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionTitle];
                    
                    tString=[tLocalizedInfoDictionary objectForKey:@"Version"];
                    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionVersion];
                    
                    tString=[tLocalizedInfoDictionary objectForKey:@"Description"];
                    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDescription];
                    
                    tString=[tInfoDictionary objectForKey:@"DeleteWarning"];
        
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDeleteWarning];
                    
                    [tDescriptionDictionary setObject:tLocalizedDictionary forKey:[tComponent stringByDeletingPathExtension]];
                }
            }
        }
    }
        
    if ([tDescriptionDictionary count]==0)
    {
        [tDescriptionDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:tName,IFPkgDescriptionTitle,
                                                                                        @"",IFPkgDescriptionDescription,
                                                                                        @"1.0",IFPkgDescriptionVersion,
                                                                                        @"",IFPkgDescriptionDeleteWarning,
                                                                                        nil]
                                    forKey:@"International"];
    }
    
    if (tOptionsDictionary!=nil)
    {
        NSString * tImagePath;
        
        tSettings=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                        tDisplayInformationDictionary,@"Display Information",
                                                                        tVersionDictionary,@"Version",
                                                                        tOptionsDictionary,@"Options",
                                                                        nil];
        
        // Documents
        
        // Background Picture
            
        tImagePath=[PBProjectTreeImporter bagroundImageAtPath:tResourcePath];
        
        if (tImagePath!=nil)
        {
            tImageDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                        tImagePath,@"Path",
                                                                        [NSNumber numberWithInt:4],IFPkgFlagBackgroundAlignment,
                                                                        [NSNumber numberWithInt:1],IFPkgFlagBackgroundScaling,
                                                                        nil];
        }
    	else
        {
            tImageDictionary=[PBObjectNode defaultImageDictionary];
        }
            
        // Welcome, ReadMe, License
            
        tResources=[PBProjectTreeImporter importPartialDocumentsAtPath:tResourcePath];
        
        if (tResources!=nil)
        {
            [tResources setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
        }
        
        // Scripts
        
        tInstallationDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:tResourcePath forOldPackage:tName];
        
        tAdditonalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:tResourcePath];
        
        tScripts=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tInstallationDictionary,SCRIPT_INSTALLATION_KEY,
                                                                    [NSArray array],SCRIPT_REQUIREMENTS_KEY,
                                                                    tAdditonalResourcesDictionary,SCRIPT_ADDITIONAL_KEY,
                                                                    nil];
        
        // Files
        
        
        tFiles=[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionary],@"Hierarchy",
                                                                tDefaultLocation,IFPkgFlagDefaultLocation,
                                                                [NSNumber numberWithBool:YES],@"Imported Package",
                                                                inFilePath,@"Package Path",
                                                                [NSNumber numberWithInt:kGlobalPath],@"Package Path Type",
                                                                nil];
        
        newTree=[[PBProjectTree alloc] initWithData:[PBPackageNode packageNodeWithName:tName
                                                                                status:1
                                                                                settings:tSettings
                                                                                resources:tResources
                                                                                scripts:tScripts
																				plugins:nil
                                                                                    files:tFiles]
                                            parent:nil
                                            children:[NSArray array]];
        
        [tScripts release];
        
        [tFiles release];
        
        [tSettings release];
        
        settingsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Settings",@"No comment")
                                                                            type:kSettingsNode
                                                                        status:-1]
                                                parent:newTree
                                                children:nil];
        
        
        [newTree insertChild: settingsNode atIndex: PBPROJECTTREE_SETTINGS_INDEX];
        
        [settingsNode release];
    
        resourcesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Documents",@"No comment")
                                                                        type:kResourcesNode
                                                                        status:-1]
                                                parent:newTree
                                                children:[NSArray array]];
        
        [newTree insertChild: resourcesNode atIndex: PBPROJECTTREE_DOCUMENTS_INDEX];
        
        [resourcesNode release];
        
        scriptsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Scripts",@"No comment")
                                                                            type:kScriptsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:scriptsNode atIndex: PBPROJECTTREE_SCRIPTS_INDEX];
        
        [scriptsNode release];
		
		pluginsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Plugins",@"No comment")
                                                                            type:kScriptsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:pluginsNode atIndex: PBPROJECTTREE_PLUGINS_INDEX];
        
        [pluginsNode release];
		
		
    
        filesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Files",@"No comment")
                                                                        type:kFilesNode
                                                                        status:-1]
                                                parent:newTree
                                                children:[NSArray array]];
        
        
        [newTree insertChild: filesNode atIndex: PBPROJECTTREE_FILES_INDEX];
        
        [filesNode release];
    }
    
    return [newTree autorelease];
}

+ (id) projectTreeWithContentsOfPackage:(NSString *) inFilePath
{
    PBProjectTree * newTree=nil;
    PBProjectTree * settingsNode=nil;
    PBProjectTree * filesNode=nil;
    PBProjectTree * resourcesNode=nil;
    PBProjectTree * scriptsNode=nil;
	PBProjectTree * pluginsNode=nil;
    NSString * tName;
    NSString * tInfoPlistPath;
    NSDictionary * tInfoDictionary;
    
    NSMutableDictionary * tSettings;
    NSMutableDictionary * tResources;
    NSMutableDictionary * tFiles;
    NSMutableDictionary * tScripts;
    
    tName=[[inFilePath lastPathComponent] stringByDeletingPathExtension];
    
    tInfoPlistPath=[inFilePath stringByAppendingPathComponent:@"Contents/Info.plist"];
    
    tInfoDictionary=[NSDictionary dictionaryWithContentsOfFile:tInfoPlistPath];
    
    if (tInfoDictionary!=nil)
    {
        NSString * tResourcePath;
        NSArray * tVersionArray;
        NSMutableDictionary * tVersionDictionary;
        NSMutableDictionary * tDisplayInformationDictionary;
        NSMutableDictionary * tOptionsDictionary;
        NSString * tString;
        NSNumber * tValue;
        NSArray * tDisplayInformationArray;
        NSArray * tOptionsArray;
        NSArray * tDescriptionArray;
        int i,tCount;
        NSMutableDictionary * tDescriptionDictionary;
        NSMutableDictionary * tLocalizedDictionary=nil;
        NSString * tDescriptionPath;
        NSFileManager * tFileManager;
        NSArray * tResourcesContent;
        NSDictionary * tImageDictionary=nil;
        
        NSMutableDictionary * tInstallationDictionary;
        NSMutableDictionary * tAdditonalResourcesDictionary;
        
        tResourcePath=[inFilePath stringByAppendingPathComponent:@"Contents/Resources"];
        
        // Display Information
        
        tDisplayInformationDictionary=[NSMutableDictionary dictionary];
        
        tDisplayInformationArray=[NSArray arrayWithObjects:@"CFBundleName",
                                                           @"CFBundleIdentifier",
                                                           @"CFBundleGetInfoString",
                                                           @"CFBundleShortVersionString",
                                                           nil];
        
        tCount=[tDisplayInformationArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tDisplayInformationArray objectAtIndex:i];
            
            tString=[tInfoDictionary objectForKey:tKey];
            
            if (tString!=nil)
            {
                [tDisplayInformationDictionary setObject:tString forKey:tKey];
            }
            else
            {
                [tDisplayInformationDictionary setObject:@"" forKey:tKey];
            }
        }
        
        // Version
        
        tVersionDictionary=[NSMutableDictionary dictionary];
        
        tVersionArray=[NSArray arrayWithObjects:IFMajorVersion,
                                                IFMinorVersion,
                                                nil];
        
        tCount=[tVersionArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tVersionArray objectAtIndex:i];
            
            tValue=[tInfoDictionary objectForKey:tKey];
            
            if (tValue!=nil)
            {
                [tVersionDictionary setObject:[NSNumber numberWithInt:[tValue intValue]] forKey:tKey];
            }
            else
            {
                [tVersionDictionary setObject:[NSNumber numberWithInt:0] forKey:tKey];
            }
        }
        
        // Options
        
        tOptionsDictionary=[NSMutableDictionary dictionary];
        
        tOptionsArray=[NSArray arrayWithObjects:IFPkgFlagIsRequired,
                                                IFPkgFlagRootVolumeOnly,
                                                IFPkgFlagOverwritePermissions,
                                                IFPkgFlagUpdateInstalledLanguages,
                                                IFPkgFlagRelocatable,
                                                IFPkgFlagInstallFat,
                                                IFPkgFlagAllowBackRev,
                                                IFPkgFlagFollowLinks,
                                                nil];
        
        tCount=[tOptionsArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            
            tKey=[tOptionsArray objectAtIndex:i];
            
            tValue=[tInfoDictionary objectForKey:tKey];
            
            if (tValue!=nil)
            {
                [tOptionsDictionary setObject:tValue forKey:tKey];
            }
            else
            {
                [tOptionsDictionary setObject:[NSNumber numberWithBool:NO] forKey:tKey];
            }
        }
        
        tString=[tInfoDictionary objectForKey:IFPkgFlagAuthorizationAction];
        
        if ([tString isEqualToString:@"AdminAuthorization"]==YES)
        {
            tValue=[NSNumber numberWithInt:1];
        }
        else
        if ([tString isEqualToString:@"RootAuthorization"]==YES)
        {
            tValue=[NSNumber numberWithInt:2];
        }
        else
        {
            // No Authorization
            
            tValue=[NSNumber numberWithInt:0];
        }
        
        [tOptionsDictionary setObject:tValue forKey:IFPkgFlagAuthorizationAction];
        
        tString=[tInfoDictionary objectForKey:IFPkgFlagRestartAction];
        
        if ([tString isEqualToString:@"RecommendedRestart"]==YES)
        {
            tValue=[NSNumber numberWithInt:1];
        }
        else
        if ([tString isEqualToString:@"RequiredRestart"]==YES)
        {
            tValue=[NSNumber numberWithInt:2];
        }
        else
        if ([tString isEqualToString:@"Shutdown"]==YES)
        {
            tValue=[NSNumber numberWithInt:3];
        }
        else
        if ([tString isEqualToString:@"RequiredLogout"]==YES)
        {
            tValue=[NSNumber numberWithInt:4];
        }
        else
        {
            // No Authorization
            
            tValue=[NSNumber numberWithInt:0];
        }
        
        [tOptionsDictionary setObject:tValue forKey:IFPkgFlagRestartAction];
        
        // Description
        
        tDescriptionDictionary=[NSMutableDictionary dictionary];
        
        tDescriptionPath=[tResourcePath stringByAppendingPathComponent:@"Description.plist"];
        
        tFileManager=[NSFileManager defaultManager];
        
        tLocalizedDictionary=[NSMutableDictionary dictionary];
        
        if ([tFileManager fileExistsAtPath:tDescriptionPath]==YES)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[NSDictionary dictionaryWithContentsOfFile:tDescriptionPath];
            
            if (tDictionary!=nil)
            {
                [tLocalizedDictionary addEntriesFromDictionary:tDictionary];
            }
        }
        
        tDescriptionArray=[NSArray arrayWithObjects:IFPkgDescriptionTitle,
                                                    IFPkgDescriptionVersion,
                                                    IFPkgDescriptionDescription,
                                                    IFPkgDescriptionDeleteWarning,
                                                    nil];
        
        tCount=[tDescriptionArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tDescriptionArray objectAtIndex:i];
            
            tValue=[tLocalizedDictionary objectForKey:tKey];
            
            if (tValue==nil)
            {
                [tLocalizedDictionary setObject:@"" forKey:tKey];
            }
        }
        
        if (tLocalizedDictionary!=nil)
        {
            [tDescriptionDictionary setObject:tLocalizedDictionary forKey:@"International"];
        }
        
        
        tResourcesContent=[tFileManager directoryContentsAtPath:tResourcePath];
        
        tCount=[tResourcesContent count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tComponent;
            
            tComponent=[tResourcesContent objectAtIndex:i];
            
            if ([[tComponent pathExtension] isEqualToString:@"lproj"]==YES)
            {
                NSString * tLocalizedPath;
                
                tLocalizedPath=[[tResourcePath stringByAppendingPathComponent:tComponent] stringByAppendingPathComponent:@"Description.plist"];
                
                if ([tFileManager fileExistsAtPath:tLocalizedPath]==YES)
                {
                    NSDictionary * tDictionary;
                    int tCount2,j;
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
        
                    tDictionary=[NSDictionary dictionaryWithContentsOfFile:tLocalizedPath];
                        
                    if (tDictionary!=nil)
                    {
                        [tLocalizedDictionary addEntriesFromDictionary:tDictionary];
                    }
                    
                    tCount2=[tDescriptionArray count];
                    
                    for(j=0;j<tCount2;j++)
                    {
                        NSString * tKey;
                        
                        tKey=[tDescriptionArray objectAtIndex:j];
                        
                        tValue=[tLocalizedDictionary objectForKey:tKey];
                        
                        if (tValue==nil)
                        {
                            [tLocalizedDictionary setObject:@"" forKey:tKey];
                        }
                    }
            
                    if (tLocalizedDictionary!=nil)
                    {
                        [tDescriptionDictionary setObject:tLocalizedDictionary forKey:[tComponent stringByDeletingPathExtension]];
                    }
                }
            }
        }
        
        // Background Picture
        
        tImageDictionary=[PBProjectTree imageDictionaryForResourcePath:tResourcePath infoDictionary:tInfoDictionary];
        
        tSettings=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                      tDisplayInformationDictionary,@"Display Information",
                                                                      tVersionDictionary,@"Version",
                                                                      tOptionsDictionary,@"Options",
                                                                      nil];
        
        // Welcome, ReadMe, License
        
        tResources=[PBProjectTreeImporter importPartialDocumentsAtPath:tResourcePath];
        
        if (tResources!=nil)
        {
            [tResources setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
        }
        
        // Scripts
        
        tInstallationDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:tResourcePath];
        
        tAdditonalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:tResourcePath];
        
        tScripts=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tInstallationDictionary,SCRIPT_INSTALLATION_KEY,
                                                                     [NSArray array],SCRIPT_REQUIREMENTS_KEY,
                                                                     tAdditonalResourcesDictionary,SCRIPT_ADDITIONAL_KEY,
                                                                     nil];
                                                                     
        
        // A COMPLETER (gestion de l'import des requirements)
        
        // Files
        
        
        
        tFiles=[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionary],@"Hierarchy",
                                                                   [tInfoDictionary objectForKey:IFPkgFlagDefaultLocation],IFPkgFlagDefaultLocation,
                                                                   [NSNumber numberWithBool:YES],@"Imported Package",
                                                                   inFilePath,@"Package Path",
                                                                   nil];
        if (tFiles!=nil)
        {
            // Look for optional Information
            
            NSMutableDictionary * tOptionalDictionary;
            id tObject;
            
            tOptionalDictionary=[NSMutableDictionary dictionary];
            
            // IFPkgFlagInstalledSize
            
            tObject=[tInfoDictionary objectForKey:IFPkgFlagInstalledSize];
            
            if (tObject!=nil)
            {
                [tOptionalDictionary setObject:tObject forKey:IFPkgFlagInstalledSize];
            }
            
            // IFPkgPathMappings
            
            tObject=[tInfoDictionary objectForKey:IFPkgPathMappings];
            
            if (tObject!=nil)
            {
                [tOptionalDictionary setObject:tObject forKey:IFPkgPathMappings];
            }
            
            if ([tOptionalDictionary count]>0)
            {
                [tFiles setObject:tOptionalDictionary forKey:@"Imported Options"];
            }
        }
        
        
        newTree=[[PBProjectTree alloc] initWithData:[PBPackageNode packageNodeWithName:tName
                                                                                status:1
                                                                              settings:tSettings
                                                                             resources:tResources
                                                                               scripts:tScripts
																			   plugins:nil
                                                                                 files:tFiles]
                                             parent:nil
                                           children:[NSArray array]];
        
        [tScripts release];
        
        [tFiles release];
        
        [tSettings release];
        
        settingsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Settings",@"No comment")
                                                                            type:kSettingsNode
                                                                        status:-1]
                                                  parent:newTree
                                                children:nil];
        
        
        [newTree insertChild: settingsNode atIndex: 0];
        
        [settingsNode release];
    
        resourcesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Documents",@"No comment")
                                                                        type:kResourcesNode
                                                                        status:-1]
                                                parent:newTree
                                                children:[NSArray array]];
        
        [newTree insertChild: resourcesNode atIndex: 1];
        
        [resourcesNode release];
        
        scriptsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Scripts",@"No comment")
                                                                            type:kScriptsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:scriptsNode atIndex: 2];
        
        [scriptsNode release];
		
		pluginsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Plugins",@"No comment")
                                                                            type:kScriptsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:pluginsNode atIndex: 3];
        
        [pluginsNode release];
    
        filesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Files",@"No comment")
                                                                        type:kFilesNode
                                                                        status:-1]
                                                parent:newTree
                                                children:[NSArray array]];
        
        
        [newTree insertChild: filesNode atIndex: 4];
        
        [filesNode release];
    }
    
    return [newTree autorelease];
}

#pragma mark -

+ (id) projectTreeWithContentsOfMetaPackageOldFormat:(NSString *) inFilePath oldPath:(NSString *) inOldPath recursive:(BOOL) inRecursive delegate:(id) delegate missingComponents:(NSMutableArray **) inOutMissingComponents
{
    PBProjectTree * newTree=nil;
    PBProjectTree * settingsNode=nil;
    PBProjectTree * resourcesNode=nil;
    PBProjectTree * scriptsNode=nil;
	PBProjectTree * pluginsNode=nil;
    PBProjectTree * componentsNode=nil;
    NSString * tName;
    NSString * tInfoPlistPath;
    NSDictionary * tInfoDictionary;
    id tMetaPackageNode=nil;
    NSMutableDictionary * tSettings;
    NSMutableDictionary * tResources;
    NSMutableDictionary * tScripts;
    NSString * tPackageLocation=nil;
    NSMutableDictionary * tVersionDictionary;
    NSString * tImagePath;
    
    NSString * tResourcePath;
    
    NSMutableDictionary * tDisplayInformationDictionary;
    
    NSString * tString;
    int i,tCount;
    NSMutableDictionary * tDescriptionDictionary;
    NSMutableDictionary * tLocalizedDictionary;
    NSFileManager * tFileManager;
    NSArray * tResourcesContent;
    NSDictionary * tImageDictionary=nil;
    
    NSMutableDictionary * tInstallationDictionary;
    NSMutableDictionary * tAdditonalResourcesDictionary;
    
    tName=[[inFilePath lastPathComponent] stringByDeletingPathExtension];
    
    tInfoPlistPath=[inFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Contents/Resources/%@.info",tName]];
    
    // Description
        
    tDescriptionDictionary=[NSMutableDictionary dictionary];
    
    tLocalizedDictionary=[NSMutableDictionary dictionary];
    
    tInfoDictionary=[NSDictionary dictionaryWithContentsOfInfoFile:tInfoPlistPath];
    
    if (tInfoDictionary!=nil)
    {
        tPackageLocation=[tInfoDictionary objectForKey:@"PackageLocation"];
        
        tString=[tInfoDictionary objectForKey:@"Title"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionTitle];
        
        tString=[tInfoDictionary objectForKey:@"Version"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionVersion];
        
        tString=[tInfoDictionary objectForKey:@"Description"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDescription];
        
        tString=[tInfoDictionary objectForKey:@"DeleteWarning"];
        
        if (tString==nil)
        {
            tString=@"";
        }
        
        [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDeleteWarning];
        
        [tDescriptionDictionary setObject:tLocalizedDictionary forKey:@"International"];
    }
    else
    {
        [tDescriptionDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",IFPkgDescriptionTitle,
                                                                                     @"",IFPkgDescriptionDescription,
                                                                                     @"",IFPkgDescriptionVersion,
                                                                                     @"",IFPkgDescriptionDeleteWarning,
                                                                                     nil]
                                   forKey:@"International"];
    }
        
    // Version Dictionary (we create it from scratch)
    
    tVersionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],IFMajorVersion,
                                                                  [NSNumber numberWithInt:0],IFMinorVersion,
                                                                  nil];
        
        
    // ==========================================
        
    tResourcePath=[inFilePath stringByAppendingPathComponent:@"Contents/Resources"];
        
    // Display Information
        
    tDisplayInformationDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tName,@"CFBundleName",
                                                                                        @"",@"CFBundleIdentifier",
                                                                                        @"",@"CFBundleGetInfoString",
                                                                                        @"1.0",@"CFBundleShortVersionString",
                                                                                        nil];

    // Localized Description
        
    tFileManager=[NSFileManager defaultManager];
        
    tResourcesContent=[tFileManager directoryContentsAtPath:tResourcePath];
    
    tCount=[tResourcesContent count];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tComponent;
        
        tComponent=[tResourcesContent objectAtIndex:i];
        
        if ([[tComponent pathExtension] isEqualToString:@"lproj"]==YES)
        {
            NSString * tLocalizedPath;
            
            tLocalizedPath=[[tResourcePath stringByAppendingPathComponent:tComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",tName]];
            
            if ([tFileManager fileExistsAtPath:tLocalizedPath]==YES)
            {
                NSDictionary * tLocalizedInfoDictionary;
                
                tLocalizedInfoDictionary=[NSDictionary dictionaryWithContentsOfInfoFile:tLocalizedPath];
                
                if (tLocalizedInfoDictionary!=nil)
                {
                    if (tPackageLocation==nil)
                    {
                        tPackageLocation=[tLocalizedInfoDictionary objectForKey:@"PackageLocation"];;
                    }
                        
                    
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
                
                    tString=[tLocalizedInfoDictionary objectForKey:@"Title"];
    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionTitle];
                    
                    tString=[tLocalizedInfoDictionary objectForKey:@"Version"];
                    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionVersion];
                    
                    tString=[tLocalizedInfoDictionary objectForKey:@"Description"];
                    
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDescription];
                    
                    tString=[tInfoDictionary objectForKey:@"DeleteWarning"];
        
                    if (tString==nil)
                    {
                        tString=@"";
                    }
                    
                    [tLocalizedDictionary setObject:tString forKey:IFPkgDescriptionDeleteWarning];
                    
                    [tDescriptionDictionary setObject:tLocalizedDictionary forKey:[tComponent stringByDeletingPathExtension]];
                }
            }
        }
    }
        
    if ([tDescriptionDictionary count]==0)
    {
        [tDescriptionDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:tName,IFPkgDescriptionTitle,
                                                                                        @"",IFPkgDescriptionDescription,
                                                                                        @"1.0",IFPkgDescriptionVersion,
                                                                                        @"",IFPkgDescriptionDeleteWarning,
                                                                                        nil]
                                    forKey:@"International"];
    }
        
        
    tSettings=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                    tDisplayInformationDictionary,@"Display Information",
                                                                    tVersionDictionary,@"Version",
                                                                    nil];
    
    // Documents
    
    // Background Picture
        
    tImagePath=[PBProjectTreeImporter bagroundImageAtPath:tResourcePath];
    
    if (tImagePath!=nil)
    {
        tImageDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"Mode",
                                                                    tImagePath,@"Path",
                                                                    [NSNumber numberWithInt:4],IFPkgFlagBackgroundAlignment,
                                                                    [NSNumber numberWithInt:1],IFPkgFlagBackgroundScaling,
                                                                    nil];
    }
    else
    {
        tImageDictionary=[PBObjectNode defaultImageDictionary];
    }
        
    // Welcome, ReadMe, License
        
    tResources=[PBProjectTreeImporter importPartialDocumentsAtPath:tResourcePath];
    
    if (tResources!=nil)
    {
        [tResources setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
    }
    
    // Scripts
    
    tInstallationDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:tResourcePath forOldPackage:tName];
    
    tAdditonalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:tResourcePath];
    
    tScripts=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tInstallationDictionary,SCRIPT_INSTALLATION_KEY,
                                                                [NSArray array],SCRIPT_REQUIREMENTS_KEY,
                                                                tAdditonalResourcesDictionary,SCRIPT_ADDITIONAL_KEY,
                                                                nil];
    
    tMetaPackageNode=[PBMetaPackageNode metaPackageNodeWithName:tName
                                                         status:1
                                                       settings:tSettings
                                                      resources:tResources
                                                        scripts:tScripts
														plugins:nil];
    
    if (tMetaPackageNode!=nil)
    {
        BOOL lookForPackages=NO;
        
        if (tPackageLocation!=nil)
        {
            // We can look for the packages
            
            lookForPackages=YES;
        }
        else
        {
            tPackageLocation=@"..";	// Same level
        }
        
        [tMetaPackageNode setComponentsDirectory:tPackageLocation];
        
        newTree=[[PBProjectTree alloc] initWithData:tMetaPackageNode
                                            parent:nil
                                        children:[NSArray array]];
        
        [tScripts release];
        
        [tSettings release];
        
        settingsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Settings",@"No comment")
                                                                            type:kSettingsNode
                                                                        status:-1]
                                                parent:newTree
                                                children:nil];
        
        
        [newTree insertChild: settingsNode atIndex: PBPROJECTTREE_SETTINGS_INDEX];
        
        [settingsNode release];
    
        resourcesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Documents",@"No comment")
                                                                        type:kResourcesNode
                                                                        status:-1]
                                                parent:newTree
                                                children:[NSArray array]];
        
        [newTree insertChild: resourcesNode atIndex: PBPROJECTTREE_DOCUMENTS_INDEX];
        
        [resourcesNode release];
        
        scriptsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Scripts",@"No comment")
                                                                            type:kScriptsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:scriptsNode atIndex: PBPROJECTTREE_SCRIPTS_INDEX];
        
        [scriptsNode release];
        
        pluginsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Plugins",@"No comment")
                                                                            type:kPluginsNode
                                                                        status:-1]
                                                    parent:newTree
                                                    children:nil];
        
        
        [newTree insertChild:pluginsNode atIndex: PBPROJECTTREE_PLUGINS_INDEX];
        
        [pluginsNode release];
		
        componentsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Components",@"No comment")
                                                                                        type:kComponentsNode
                                                                                      status:-1]
                                                                 parent:newTree
                                                               children:[NSArray array]];
                    
                    
        [newTree insertChild:componentsNode atIndex: PBPROJECTTREE_COMPONENTS_INDEX];
                    
        [componentsNode release];
                    
        if (lookForPackages==YES && inRecursive==YES)
        {
            NSArray * tArray;
            NSString * tListPath;
            
            tListPath=[inFilePath stringByAppendingString:[NSString stringWithFormat:@"/Contents/Resources/%@.list",tName]];
            
            tArray=[PBProjectTree readOldFormatListDictionary:tListPath];
            
            if (tArray!=nil)
            {
                NSDictionary * tDictionary;
                NSEnumerator * tEnumerator;
                
                i=0;
                
                tEnumerator=[tArray objectEnumerator];
                
                while (tDictionary=[tEnumerator nextObject])
                {
                    NSString * tComponentName;
                    
                    tComponentName=[tDictionary objectForKey:IFPkgFlagPackageLocation];
                    
                    if (tComponentName!=nil)
                    {
                        NSString * tComponentPath;
                        
                        tComponentPath=[[[inOldPath stringByAppendingPathComponent:tPackageLocation] stringByAppendingPathComponent:tComponentName] stringByStandardizingPath];
                        
                        if ([tFileManager fileExistsAtPath:tComponentPath]==YES)
                        {
                            PBProjectTree * tTree=nil;
                            
                            tTree=[PBProjectTree projectTreeWithContentsOfComponent:tComponentPath
                                                                          recursive:inRecursive
                                                                           delegate:delegate
                                                                  missingComponents:inOutMissingComponents];
                        
                            if (tTree!=nil)
                            {
                                NSString * tAttribute;
                            
                                // Set the Selection Mode
                                
                                tAttribute=[tDictionary objectForKey:IFPkgFlagPackageSelection];
                                
                                if (tAttribute!=nil)
                                {
                                    int tAttributeInt=kObjectUnselected;
                                    
                                    if ([tAttribute caseInsensitiveCompare:@"required"]==NSOrderedSame)
                                    {
                                        tAttributeInt=kObjectRequired;
                                    }
                                    else if ([tAttribute caseInsensitiveCompare:@"selected"]==NSOrderedSame)
                                    {
                                        tAttributeInt=kObjectSelected;
                                    }
                                    
                                    [((PBObjectNode *) NODE_DATA(tTree)) setAttribute:tAttributeInt];
                                }
                                
                                [componentsNode insertChild: tTree atIndex: i];
                                
                                i++;
                            }
                        }
                        else
                        {
                            if (*inOutMissingComponents==nil)
                            {
                                *inOutMissingComponents=[NSMutableArray array];
                            }
                            
                            [(*inOutMissingComponents) addObject:[NSDictionary dictionaryWithObjectsAndKeys:tComponentPath,@"Path",
                                                                                                            [NSNumber numberWithInt:1],@"Reason",
                                                                                                            nil]];
                        }
                    }
                }
            }
        }
    }
    
    return [newTree autorelease];
}

+ (id) projectTreeWithContentsOfMetaPackage:(NSString *) inFilePath oldPath:(NSString *) inOldPath recursive:(BOOL) inRecursive delegate:(id) delegate missingComponents:(NSMutableArray **) inOutMissingComponents
{
    PBProjectTree * newTree=nil;
    NSString * tName;
    NSString * tInfoPlistPath;
    NSArray * tDescriptionArray;
    NSDictionary * tInfoDictionary;
    NSString * tPackageLocation=nil;
    NSMutableDictionary * tSettings;
    NSMutableDictionary * tResources;
    NSMutableDictionary * tScripts;
    
    tName=[[inFilePath lastPathComponent] stringByDeletingPathExtension];
    
    tInfoPlistPath=[inFilePath stringByAppendingPathComponent:@"Contents/Info.plist"];
    
    tInfoDictionary=[NSDictionary dictionaryWithContentsOfFile:tInfoPlistPath];
    
    if (tInfoDictionary!=nil)
    {
        id tMetaPackageNode=nil;
        NSString * tResourcePath;
        NSArray * tVersionArray;
        NSMutableDictionary * tVersionDictionary;
        NSMutableDictionary * tDisplayInformationDictionary;
        NSString * tString;
        NSNumber * tValue;
        NSArray * tDisplayInformationArray;
        int i,tCount;
        NSMutableDictionary * tDescriptionDictionary;
        NSMutableDictionary * tLocalizedDictionary=nil;
        NSString * tDescriptionPath;
        NSFileManager * tFileManager;
        NSArray * tResourcesContent;
        NSDictionary * tImageDictionary;
        
        NSMutableDictionary * tInstallationDictionary;
        NSMutableDictionary * tAdditonalResourcesDictionary;
        
        tPackageLocation=[tInfoDictionary objectForKey:@"IFPkgFlagComponentDirectory"];
        
        tResourcePath=[inFilePath stringByAppendingPathComponent:@"Contents/Resources"];
        
        // Display Information
        
        tDisplayInformationDictionary=[NSMutableDictionary dictionary];
        
        tDisplayInformationArray=[NSArray arrayWithObjects:@"CFBundleName",
                                                           @"CFBundleIdentifier",
                                                           @"CFBundleGetInfoString",
                                                           @"CFBundleShortVersionString",
                                                           nil];
        
        tCount=[tDisplayInformationArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tDisplayInformationArray objectAtIndex:i];
            
            tString=[tInfoDictionary objectForKey:tKey];
            
            if (tString!=nil)
            {
                [tDisplayInformationDictionary setObject:tString forKey:tKey];
            }
            else
            {
                [tDisplayInformationDictionary setObject:@"" forKey:tKey];
            }
        }
        
        // Version
        
        tVersionDictionary=[NSMutableDictionary dictionary];
        
        tVersionArray=[NSArray arrayWithObjects:IFMajorVersion,
                                                IFMinorVersion,
                                                nil];
        
        tCount=[tVersionArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tVersionArray objectAtIndex:i];
            
            tValue=[tInfoDictionary objectForKey:tKey];
            
            if (tValue!=nil)
            {
                [tVersionDictionary setObject:[NSNumber numberWithInt:[tValue intValue]] forKey:tKey];
            }
            else
            {
                [tVersionDictionary setObject:[NSNumber numberWithInt:0] forKey:tKey];
            }
        }
        
        // Description
        
        tDescriptionDictionary=[NSMutableDictionary dictionary];
        
        tDescriptionPath=[tResourcePath stringByAppendingPathComponent:@"Description.plist"];
        
        tFileManager=[NSFileManager defaultManager];
        
        tLocalizedDictionary=[NSMutableDictionary dictionary];
        
        if ([tFileManager fileExistsAtPath:tDescriptionPath]==YES)
        {
            NSDictionary * tDictionary;
            
            tDictionary=[NSDictionary dictionaryWithContentsOfFile:tDescriptionPath];
            
            if (tDictionary!=nil)
            {
                [tLocalizedDictionary addEntriesFromDictionary:tDictionary];
            }
        }
        
        tDescriptionArray=[NSArray arrayWithObjects:IFPkgDescriptionTitle,
                                                    IFPkgDescriptionVersion,
                                                    IFPkgDescriptionDescription,
                                                    IFPkgDescriptionDeleteWarning,
                                                    nil];
        
        tCount=[tDescriptionArray count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tKey;
            
            tKey=[tDescriptionArray objectAtIndex:i];
            
            tValue=[tLocalizedDictionary objectForKey:tKey];
            
            if (tValue==nil)
            {
                [tLocalizedDictionary setObject:@"" forKey:tKey];
            }
        }
        
        if (tLocalizedDictionary!=nil)
        {
            [tDescriptionDictionary setObject:tLocalizedDictionary forKey:@"International"];
        }
    
        tResourcesContent=[tFileManager directoryContentsAtPath:tResourcePath];
        
        tCount=[tResourcesContent count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tComponent;
            
            tComponent=[tResourcesContent objectAtIndex:i];
            
            if ([[tComponent pathExtension] isEqualToString:@"lproj"]==YES)
            {
                NSString * tLocalizedPath;
                
                tLocalizedPath=[[tResourcePath stringByAppendingPathComponent:tComponent] stringByAppendingPathComponent:@"Description.plist"];
                
                if ([tFileManager fileExistsAtPath:tLocalizedPath]==YES)
                {
                    NSDictionary * tDictionary;
                    int tCount2,j;
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
        
                    tDictionary=[NSDictionary dictionaryWithContentsOfFile:tLocalizedPath];
                        
                    if (tDictionary!=nil)
                    {
                        [tLocalizedDictionary addEntriesFromDictionary:tDictionary];
                    }
                    
                    tCount2=[tDescriptionArray count];
                    
                    for(j=0;j<tCount2;j++)
                    {
                        NSString * tKey;
                        
                        tKey=[tDescriptionArray objectAtIndex:j];
                        
                        tValue=[tLocalizedDictionary objectForKey:tKey];
                        
                        if (tValue==nil)
                        {
                            [tLocalizedDictionary setObject:@"" forKey:tKey];
                        }
                    }
            
                    if (tLocalizedDictionary!=nil)
                    {
                        [tDescriptionDictionary setObject:tLocalizedDictionary forKey:[tComponent stringByDeletingPathExtension]];
                    }
                }
            }
        }
        
        // Background Picture
        
        tImageDictionary=[PBProjectTree imageDictionaryForResourcePath:tResourcePath infoDictionary:tInfoDictionary];
        
        tSettings=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                      tDisplayInformationDictionary,@"Display Information",
                                                                      tVersionDictionary,@"Version",
                                                                      nil];
        
        // Welcome, ReadMe, License
        
        tResources=[PBProjectTreeImporter importPartialDocumentsAtPath:tResourcePath];
        
        if (tResources!=nil)
        {
            [tResources setObject:tImageDictionary forKey:RESOURCE_BACKGROUND_KEY];
        }
        
        // Scripts
        
        tInstallationDictionary=[PBProjectTreeImporter importInstallationScriptsAtPath:tResourcePath];
        
        tAdditonalResourcesDictionary=[PBProjectTreeImporter importAdditionalResourcesAtPath:tResourcePath];
        
        tScripts=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tInstallationDictionary,SCRIPT_INSTALLATION_KEY,
                                                                     [NSArray array],SCRIPT_REQUIREMENTS_KEY,
                                                                     tAdditonalResourcesDictionary,SCRIPT_ADDITIONAL_KEY,
                                                                     nil];
                                                                     
        
        // A COMPLETER (gestion de l'import des requirements)
        
        tMetaPackageNode=[PBMetaPackageNode metaPackageNodeWithName:tName
                                                         status:1
                                                       settings:tSettings
                                                      resources:tResources
                                                        scripts:tScripts
														plugins:nil];
        
        if (tMetaPackageNode!=nil)
        {
            BOOL lookForPackages=NO;
            PBProjectTree * settingsNode=nil;
            PBProjectTree * resourcesNode=nil;
            PBProjectTree * scriptsNode=nil;
			PBProjectTree * pluginsNode=nil;
            PBProjectTree * componentsNode=nil;
    
            if (tPackageLocation!=nil)
            {
                // We can look for the packages
                
                lookForPackages=YES;
            }
            else
            {
                tPackageLocation=@"..";	// Same level
            }
            
            [tMetaPackageNode setComponentsDirectory:tPackageLocation];
            
            newTree=[[PBProjectTree alloc] initWithData:tMetaPackageNode
                                                parent:nil
                                            children:[NSArray array]];
        
            [tScripts release];
            
            [tSettings release];
            
            settingsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Settings",@"No comment")
                                                                                type:kSettingsNode
                                                                            status:-1]
                                                    parent:newTree
                                                    children:nil];
            
            
            [newTree insertChild: settingsNode atIndex: 0];
            
            [settingsNode release];
        
            resourcesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Documents",@"No comment")
                                                                            type:kResourcesNode
                                                                            status:-1]
                                                    parent:newTree
                                                    children:[NSArray array]];
            
            [newTree insertChild: resourcesNode atIndex: 1];
            
            [resourcesNode release];
            
            scriptsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Scripts",@"No comment")
                                                                                type:kScriptsNode
                                                                            status:-1]
                                                        parent:newTree
                                                        children:nil];
            
            
            [newTree insertChild:scriptsNode atIndex: 2];
            
            [scriptsNode release];
			
			pluginsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Plugins",@"No comment")
                                                                                type:kPluginsNode
                                                                            status:-1]
                                                        parent:newTree
                                                        children:nil];
            
            
            [newTree insertChild:pluginsNode atIndex: 3];
            
            [pluginsNode release];
        
            componentsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Components",@"No comment")
                                                                                            type:kComponentsNode
                                                                                        status:-1]
                                                                    parent:newTree
                                                                children:[NSArray array]];
                        
                        
            [newTree insertChild:componentsNode atIndex: 4];
                        
            [componentsNode release];
            
            if (lookForPackages==YES && inRecursive==YES)
            {
                NSArray * tArray;
                
                tArray=[tInfoDictionary objectForKey:IFPkgFlagPackageList];
                
                if (tArray!=nil)
                {
                    NSDictionary * tDictionary;
                    NSEnumerator * tEnumerator;
                    
                    i=0;
                    
                    tEnumerator=[tArray objectEnumerator];
                    
                    while (tDictionary=[tEnumerator nextObject])
                    {
                        NSString * tComponentName;
                        
                        tComponentName=[tDictionary objectForKey:IFPkgFlagPackageLocation];
                        
                        if (tComponentName!=nil)
                        {
                            NSString * tComponentPath;
                            
                            tComponentPath=[[[inOldPath stringByAppendingPathComponent:tPackageLocation] stringByAppendingPathComponent:tComponentName] stringByStandardizingPath];
                            
                            if ([tFileManager fileExistsAtPath:tComponentPath]==YES)
                            {
                                PBProjectTree * tTree=nil;
                                
                                tTree=[PBProjectTree projectTreeWithContentsOfComponent:tComponentPath
                                                                              recursive:inRecursive
                                                                               delegate:delegate
                                                                      missingComponents:inOutMissingComponents];
                            
                                if (tTree!=nil)
                                {
                                    NSString * tAttribute;
                                
                                    // Set the Selection Mode
                                    
                                    tAttribute=[tDictionary objectForKey:IFPkgFlagPackageSelection];
                                    
                                    if (tAttribute!=nil)
                                    {
                                        int tAttributeInt=kObjectUnselected;
                                        
                                        if ([tAttribute isEqualToString:@"required"]==YES)
                                        {
                                            tAttributeInt=kObjectRequired;
                                        }
                                        else if ([tAttribute isEqualToString:@"selected"]==YES)
                                        {
                                            tAttributeInt=kObjectSelected;
                                        }
                                        
                                        [((PBObjectNode *) NODE_DATA(tTree)) setAttribute:tAttributeInt];
                                    }
                                    
                                    [componentsNode insertChild: tTree atIndex: i];
                                    
                                    i++;
                                }
                            }
                            else
                            {
                                if (*inOutMissingComponents==nil)
                                {
                                    *inOutMissingComponents=[NSMutableArray array];
                                }
                                
                                [(*inOutMissingComponents) addObject:[NSDictionary dictionaryWithObjectsAndKeys:tComponentPath,@"Path",
                                                                                                                [NSNumber numberWithInt:1],@"Reason",
                                                                                                                nil]];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return [newTree autorelease];
}

@end
