/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectTree.h"
#import "NSString+Karelia.h"

#import "NSDictionary+Iceberg.h"

#import "PBProjectTreeImporter.h"

NSString * const RESOURCE_BACKGROUND_KEY=@"Background Image";
NSString * const RESOURCE_WELCOME_KEY=@"Welcome";
NSString * const RESOURCE_README_KEY=@"ReadMe";
NSString * const RESOURCE_LICENSE_KEY=@"License";

NSString * const SCRIPT_REQUIREMENTS_KEY=@"Requirements";
NSString * const SCRIPT_INSTALLATION_KEY=@"Installation Scripts";
NSString * const SCRIPT_ADDITIONAL_KEY=@"Additional Resources";

NSString * const PLUGINS_LIST_KEY=@"PluginsList";

BOOL sResolveKeyWord=NO;

@implementation PBNode

+ (id) nodeWithName:(NSString *) inName type: (int) inType status:(int) inStatus
{
    return [[[PBNode alloc] initWithName:inName type:inType status:inStatus] autorelease];
}

+ (id) rootNode
{
    return [PBNode nodeWithName:nil type: kRootNode status:-1];
}

- (id) initWithName:(NSString *) inName type: (int) inType status:(int) inStatus
{
    self=[super init];
    
    if (self!=nil)
    {
        name_=[inName retain];
        
        type_=inType;
        
        status_=inStatus;
    }
    
    return self;
}

- (BOOL) isLeaf
{
    switch(type_)
    {
        case kSettingsNode:
        case kFilesNode:
        case kResourcesNode:
        case kScriptsNode:
		case kPluginsNode:
            return YES;
        default:
            break;
    }
    
    return NO;
}

- (NSString *) name
{
    return [[name_ retain] autorelease]; 
}

- (void) setName:(NSString *) inName
{
    if (name_!=inName)
    {
        [name_ release];
        
        name_=[inName copy];
    }
}

- (int) type
{
    return type_;
}

- (int) status
{
    return status_;
}

- (void) setStatus:(int) inStatus
{
    status_=inStatus;
}

@end

#pragma mark -

@implementation PBObjectNode

+ (NSDictionary *) defaultWelcomeDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                      @"",@"Path",
                                                      nil];
}

+ (NSDictionary *) defaultReadMeDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                      @"",@"Path",
                                                      nil];
}

+ (NSDictionary *) defaultLicenseDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                      @"",@"Path",
                                                      nil];
}

+ (NSDictionary *) defaultDescriptionDictionaryWithName:(NSString *) inName
{
    return [NSDictionary dictionaryWithObjectsAndKeys:inName,IFPkgDescriptionTitle,
                                                      @"1.0",IFPkgDescriptionVersion,
                                                      @"",IFPkgDescriptionDescription,
                                                      @"",IFPkgDescriptionDeleteWarning,
                                                      nil];
}

+ (NSDictionary *) defaultImageDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                      @"",@"Path",
                                                      [NSNumber numberWithInt:4],IFPkgFlagBackgroundAlignment,
                                                      [NSNumber numberWithInt:1],IFPkgFlagBackgroundScaling,
                                                      nil];
}

+ (NSDictionary *) defaultScriptsDictionary
{
    NSDictionary * nDictionary=nil;
    NSDictionary * tInstallationDictionary;
    NSDictionary * tResourcesDictionary;
    
    tResourcesDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"International",
                                                                     nil];
    
    tInstallationDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPreflight,
                                                                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPreinstall,
                                                                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPreupgrade,
                                                                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPostinstall,
                                                                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPostupgrade,
                                                                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Status",
                                                                                                                  @"",@"Path",
                                                                                                                  nil],IFInstallationScriptsPostflight,
                                                                       nil];
    
    nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],SCRIPT_REQUIREMENTS_KEY,
                                                           tInstallationDictionary,SCRIPT_INSTALLATION_KEY,
                                                           tResourcesDictionary,SCRIPT_ADDITIONAL_KEY,
                                                           nil];
    
    return nDictionary;
}

+ (NSDictionary *) defaultPluginsDictionary
{
	NSDictionary * nDictionary=nil;
	NSArray * tPluginsArray;
	
	tPluginsArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"Introduction",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"ReadMe",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"License",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"Target",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"PackageSelection",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"Install",@"Path",
																					   nil],
											[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kPluginDefaultStep],@"Type",
																					   @"FinishUp",@"Path",
																					   nil],
											nil];
											
	
	nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tPluginsArray,PLUGINS_LIST_KEY,
														   nil];
	
	return nDictionary;
}

+ (NSMutableDictionary *) defaultRequirementMutableDictionaryWithLabel:(NSString *) inLabel
{
    NSMutableDictionary * nDictionary;
    NSMutableDictionary * tAlertDictionary;
    NSDictionary * tLocalizedAlertDictionary;
    
    tLocalizedAlertDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"TitleKey",
                                                                         @"",@"MessageKey",
                                                                         nil];
    
    tAlertDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tLocalizedAlertDictionary,@"International",
                                                                       nil];
    
    nDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Status",
                                                                  [NSNumber numberWithInt:0],@"Level",
                                                                  inLabel,@"LabelKey",
                                                                  [NSNumber numberWithInt:0],@"SpecTag",
                                                                  @"bundle",@"SpecType",
                                                                  @"",@"SpecArgument",
                                                                  @"CFBundleVersion",@"SpecProperty",
                                                                  @">=",@"TestOperator",
                                                                  @"",@"TestObject",
                                                                  tAlertDictionary,@"AlertDialog",
                                                                  nil];

    return nDictionary;
}

- (int) attribute
{
    return attribute_;
}

- (void) setAttribute:(int) inAttribute
{
    attribute_=inAttribute;
}

- (NSMutableDictionary *) settings
{
    return settings_;
}

- (void) setSettings:(NSDictionary *) inSettings
{
    [settings_ release];
    
    settings_=[inSettings mutableCopy];
}

- (NSMutableDictionary *) resources
{
    return resources_;
}

- (void) setResources:(NSDictionary *) inResources
{
    [resources_ release];
    
    resources_=[inResources mutableCopy];
}


- (NSMutableDictionary *) scripts
{
    return scripts_;
}

- (void) setScripts:(NSDictionary *) inScripts
{
    [scripts_ release];
    
    scripts_=[inScripts mutableCopy];
}

- (NSMutableDictionary *) plugins
{
    return plugins_;
}

- (void) setPlugins:(NSDictionary *) inPlugins
{
    [plugins_ release];
    
    plugins_=[inPlugins mutableCopy];
}

@end

@implementation PBPackageNode

+ (id) packageNodeWithName:(NSString *) inName status:(int) inStatus settings:(NSDictionary *) inSettings resources:(NSDictionary *) inResources scripts:(NSDictionary *) inScripts plugins:(NSDictionary *) inPlugins files:(NSDictionary *) inFiles
{
    PBPackageNode * tNode;
    
    tNode=(PBPackageNode *) [[PBPackageNode alloc] initWithName:inName
                                         type:kPBPackageNode
                                       status:inStatus];
    
    if (inSettings==nil || [inSettings count]==0)
    {
        // Build the default settings
        
        NSMutableDictionary * tSettingsDictionary;
        NSDictionary * tDescriptionDictionary;
        NSDictionary * tDisplayInformationDictionary;
        NSDictionary * tVersionDictionary;
        NSDictionary * tOptionsDictionary;
        
        tDescriptionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultDescriptionDictionaryWithName:inName],
                                                                          @"International",nil];
        
        tDisplayInformationDictionary=[NSDictionary dictionaryWithObjectsAndKeys:inName,@"CFBundleName",
                                                                                 @"",@"CFBundleIdentifier",
                                                                                 @"",@"CFBundleGetInfoString",
                                                                                 @"1.0", @"CFBundleShortVersionString",
                                                                                 @"",@"CFBundleIconFile",
                                                                                 nil];
        
        tVersionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],IFMajorVersion,
                                                                      [NSNumber numberWithInt:0],IFMinorVersion,
                                                                      nil];
        
        tOptionsDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],IFPkgFlagRestartAction,
                                                                      [NSNumber numberWithInt:0],IFPkgFlagAuthorizationAction,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagIsRequired,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagRootVolumeOnly,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagOverwritePermissions,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagUpdateInstalledLanguages,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagRelocatable,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagInstallFat,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagAllowBackRev,
                                                                      [NSNumber numberWithBool:NO],IFPkgFlagFollowLinks,
                                                                      nil];
        
        tSettingsDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                         tDisplayInformationDictionary,@"Display Information",
                                                                         tVersionDictionary,@"Version",
                                                                         tOptionsDictionary,@"Options",
                                                                         nil];
        tNode->settings_=tSettingsDictionary;
    
    }
    else
    {
        tNode->settings_=[inSettings mutableCopy];
    }
    
    if (inResources==nil || [inResources count]==0)
    {
        // Build the default settings
        
        NSMutableDictionary * tResourcesDictionary;
        NSDictionary * tImageDictionary;
        NSDictionary * tWelcomeDictionary;
        NSDictionary * tReadMeDictionary;
        NSDictionary * tLicenseDictionary;
        
        tImageDictionary=[PBObjectNode defaultImageDictionary];
        
        tWelcomeDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultWelcomeDictionary],
                                                                      @"International",nil];
        
        
        tReadMeDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultReadMeDictionary],
                                                                     @"International",nil];
        
        tLicenseDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultLicenseDictionary],
                                                                      @"International",nil];
        
        tResourcesDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tImageDictionary,RESOURCE_BACKGROUND_KEY,
                                                                                 tWelcomeDictionary,RESOURCE_WELCOME_KEY,
                                                                                 tReadMeDictionary,RESOURCE_README_KEY,
                                                                                 tLicenseDictionary,RESOURCE_LICENSE_KEY,
                                                                                 nil];
        tNode->resources_=tResourcesDictionary;
    
    }
    else
    {
        tNode->resources_=[inResources mutableCopy];
    }
    
    if (inScripts==nil || [inScripts count]==0)
    {
        tNode->scripts_=[[PBObjectNode defaultScriptsDictionary] mutableCopy];
    }
    else
    {
        tNode->scripts_=[inScripts mutableCopy];
    }
    
	if (inPlugins==nil || [inPlugins count]==0)
    {
        tNode->plugins_=[[PBObjectNode defaultPluginsDictionary] mutableCopy];
    }
    else
    {
        tNode->plugins_=[inPlugins mutableCopy];
    }
	
    if (inFiles==nil || [inFiles count]==0)
    {
        NSMutableDictionary * tFilesDictionary;
        NSDictionary * tHierarchyDictionary=nil;
        NSString * tPath;
        
        tPath=[[NSBundle mainBundle] pathForResource:@"DefaultTree" ofType:@"plist"];
        
        if (tPath!=nil)
        {
            tHierarchyDictionary=[NSDictionary dictionaryWithContentsOfFile:tPath];
        }
        
        if (tHierarchyDictionary==nil)
        {
            // A COMPLETER
        }
        
        tFilesDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tHierarchyDictionary,@"Hierarchy",
                                                                             @"/",IFPkgFlagDefaultLocation,
                                                                             [NSNumber numberWithBool:NO],@"Imported Package",
                                                                             [NSNumber numberWithBool:YES],@"Compress",
                                                                             [NSNumber numberWithBool:YES],@"Split Forks",
                                                                             @"",@"Package Path",
                                                                             nil];
        
        tNode->files_=tFilesDictionary;
    }
    else
    {
         tNode->files_=[inFiles mutableCopy];
    }
    
    return [tNode autorelease];
}

- (NSMutableDictionary *) files
{
    return files_;
}

- (void) setFiles:(NSDictionary *) inFiles
{
    [files_ release];
    
    files_=[inFiles mutableCopy];
}

- (BOOL) isRequired
{
    NSDictionary * tOptionsDictionary;
    BOOL tValue=NO;
    
    if (settings_!=nil)
    {
        tOptionsDictionary=[settings_ objectForKey:@"Options"];
        
        if (tOptionsDictionary!=nil)
        {
            NSNumber * tNumber;
            
            tNumber=[tOptionsDictionary objectForKey:IFPkgFlagIsRequired];
            
            if (tNumber!=nil)
            {
                tValue=[tNumber boolValue];
            }
        }
    }
    
    return tValue;
}

- (BOOL) isImported
{
    NSNumber * tNumber;
    
    tNumber=[files_ objectForKey:@"Imported Package"];
    
    if (tNumber!=nil)
    {
        return [tNumber boolValue];
    }
    
    return NO;
}

@end

#pragma mark -

@implementation PBMetaPackageNode

+ (id) metaPackageNodeWithName:(NSString *) inName status:(int) inStatus settings:(NSDictionary *) inSettings resources:(NSDictionary *) inResources scripts:(NSDictionary *) inScripts plugins:(NSDictionary *) inPlugins
{
    PBMetaPackageNode * tNode;
    
    tNode=[[PBMetaPackageNode alloc] initWithName:inName
                                         type:kPBMetaPackageNode
                                       status:inStatus];
    
    
    
    if (inSettings==nil || [inSettings count]==0)
    {
        // Build the default settings
        
        NSMutableDictionary * tSettingsDictionary;
        NSDictionary * tDescriptionDictionary;
        NSDictionary * tDisplayInformationDictionary;
        NSDictionary * tVersionDictionary;
        
        tDescriptionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultDescriptionDictionaryWithName:inName],
                                                                          @"International",nil];
        
        tDisplayInformationDictionary=[NSDictionary dictionaryWithObjectsAndKeys:inName,@"CFBundleName",
                                                                                 @"",@"CFBundleIdentifier",
                                                                                 @"",@"CFBundleGetInfoString",
                                                                                 @"1.0",@"CFBundleShortVersionString",
                                                                                 @"",@"CFBundleIconFile",
                                                                                 nil];
        
        tVersionDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],IFMajorVersion,
                                                                      [NSNumber numberWithInt:0],IFMinorVersion,
                                                                      nil];
        
        tSettingsDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tDescriptionDictionary,@"Description",
                                                                         tDisplayInformationDictionary,@"Display Information",
                                                                         tVersionDictionary,@"Version",
                                                                         nil];
        tNode->settings_=tSettingsDictionary;
    
    }
    else
    {
        tNode->settings_=[inSettings mutableCopy];
    }
    
    if (inResources==nil || [inResources count]==0)
    {
        // Build the default settings
        
        NSMutableDictionary * tResourcesDictionary;
        NSDictionary * tImageDictionary;
        NSDictionary * tWelcomeDictionary;
        NSDictionary * tReadMeDictionary;
        NSDictionary * tLicenseDictionary;
        
        tImageDictionary=[PBObjectNode defaultImageDictionary];
        
        tWelcomeDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultWelcomeDictionary],
                                                                      @"International",nil];
        
        
        tReadMeDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultReadMeDictionary],
                                                                     @"International",nil];
        
        tLicenseDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[PBObjectNode defaultLicenseDictionary],
                                                                      @"International",nil];
        
        tResourcesDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tImageDictionary,RESOURCE_BACKGROUND_KEY,
                                                                                 tWelcomeDictionary,RESOURCE_WELCOME_KEY,
                                                                                 tReadMeDictionary,RESOURCE_README_KEY,
                                                                                 tLicenseDictionary,RESOURCE_LICENSE_KEY,
                                                                                 nil];
        tNode->resources_=tResourcesDictionary;
    
    }
    else
    {
        tNode->resources_=[inResources mutableCopy];
    }
    
    if (inScripts==nil || [inScripts count]==0)
    {
        tNode->scripts_=[[PBObjectNode defaultScriptsDictionary] mutableCopy];
    }
    else
    {
        tNode->scripts_=[inScripts mutableCopy];
    }
	
	if (inPlugins==nil || [inPlugins count]==0)
    {
        tNode->plugins_=[[PBObjectNode defaultPluginsDictionary] mutableCopy];
    }
    else
    {
        tNode->plugins_=[inPlugins mutableCopy];
    }
    
    return [tNode autorelease];
}



- (NSString *) componentsDirectory
{
    return [[componentsDirectory_ retain] autorelease]; 
}

- (void) setComponentsDirectory:(NSString *) inDirectory
{
    if (componentsDirectory_!=inDirectory)
    {
        [componentsDirectory_ release];
        
        componentsDirectory_=[inDirectory copy];
    }
}

@end

#pragma mark -

@implementation PBProjectNode

+ (id) projectNodeWithSettings:(NSDictionary *) inSettings
{
    PBProjectNode * tNode;
    
    tNode=[[PBProjectNode alloc] initWithName:NSLocalizedString(@"Project",@"No comment")
                                         type:kProjectNode
                                       status:-1];
    
    if (inSettings==nil || [inSettings count]==0)
    {
        // Build the default settings
        
        NSMutableDictionary * tSettingsDictionary;
        
        tSettingsDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"",@"Build Path",
                                                                         @"",@"Comment",
                                                                         [NSNumber numberWithBool:YES],@"Remove .DS_Store",
                                                                         [NSNumber numberWithBool:YES],@"Remove .pbdevelopment",
                                                                         [NSNumber numberWithBool:YES],@"10.1 Compatibility",
                                                                         nil];
        tNode->settings_=tSettingsDictionary;
    
    }
    else
    {
        tNode->settings_=[inSettings mutableCopy];
    }
    
    return [tNode autorelease];
}

- (NSMutableDictionary *) settings
{
    return settings_;
}

@end

#pragma mark -

@implementation PBProjectTree



/*+ (void) setResolveKeyWords:(BOOL) aBool
{
    sResolveKeyWord=aBool;
}

+ (BOOL) isResolvingKeyWords
{
    return sResolveKeyWord;
}*/

+ (id) projectTreeWithContentsOfFile:(NSString *) inFilePath andKeywordDictionary:(NSDictionary *) inKWDictionary
{
    return [PBProjectTree projectTreeWithContentsOfURL:[NSURL fileURLWithPath:inFilePath]
                                  andKeywordDictionary:inKWDictionary];
}

+ (id) projectTree
{
    PBProjectTree * newProjectTree=nil;
    PBProjectTree * rootNode=nil;
    
    rootNode=[[PBProjectTree alloc] initWithData:[PBNode rootNode]
                                          parent:nil
                                        children:[NSArray array]];
        
    newProjectTree=[[PBProjectTree alloc] initWithData:[PBProjectNode projectNodeWithSettings:nil]
                                                parent:rootNode
                                              children:[NSArray array]];
        
    [rootNode insertChild: newProjectTree
                  atIndex: 0];
    
    [newProjectTree release];
    
    return [rootNode autorelease];
}

+ (id) projectTreeWithContentsOfURL:(NSURL *) inURL andKeywordDictionary:(NSDictionary *) inKWDictionary
{
    NSDictionary * tProjectDictionary;
    PBProjectTree * newProjectTree=nil;
    PBProjectTree * rootNode=nil;
    
    tProjectDictionary=[NSDictionary dictionaryWithContentsOfURL:inURL];
    
    if (tProjectDictionary!=nil && sResolveKeyWord==YES)
    {
        tProjectDictionary=[PBProjectTree resolveDictionary:tProjectDictionary
                                      withKeywordDictionary:inKWDictionary];
    }
    
    if (tProjectDictionary!=nil)
    {
        NSDictionary * tHierarchyDictionary;
        PBProjectTree * tChild=nil;
        
        rootNode=[[PBProjectTree alloc] initWithData:[PBNode rootNode]
                                              parent:nil
                                            children:[NSArray array]];
        
        newProjectTree=[[PBProjectTree alloc] initWithData:[PBProjectNode projectNodeWithSettings:[tProjectDictionary objectForKey:@"Settings"]]
                                                    parent:rootNode
                                                  children:[NSArray array]];
        
        [rootNode insertChild: newProjectTree
                      atIndex: 0];
        
        [newProjectTree release];
        
        tHierarchyDictionary=[tProjectDictionary objectForKey:@"Hierarchy"];
        
        tChild=[PBProjectTree projectTreeWithDictionary:tHierarchyDictionary];
            
        if (tChild!=nil)
        {
            [newProjectTree insertChild: tChild atIndex: 0];
        }
    }
    
    sResolveKeyWord=NO;
    
    return [rootNode autorelease];
}

+ (id) projectTreeWithDictionary:(NSDictionary *) inDictionary
{
    PBProjectTree * newTree=nil;
    NSNumber * tNumber;
    
    tNumber=[inDictionary objectForKey:@"Type"];
    
    if (tNumber!=nil)
    {
        NSDictionary * tAttributes;
        NSString * tName;
        int tType;
        NSDictionary * tSettings;
        NSDictionary * tResources;
        NSDictionary * tScripts;
		NSDictionary * tPlugins;
        
        tType=[tNumber intValue];
        
        tNumber=[inDictionary objectForKey:@"Status"];
        
        tName=[inDictionary objectForKey:@"Name"];
        
        tAttributes=[inDictionary objectForKey:@"Attributes"];
        
        switch(tType)
        {
            case kPBMetaPackageNode:
                {
                    NSArray * tComponents;
                    int i,tCount;
                    PBProjectTree * settingsNode=nil;
                    PBProjectTree * componentsNode=nil;
                    PBProjectTree * resourcesNode=nil;
                    PBProjectTree * scriptsNode=nil;
                    PBProjectTree * pluginsNode=nil;
					
                    tSettings=[tAttributes objectForKey:@"Settings"];
                    
                    tResources=[tAttributes objectForKey:@"Documents"];
                    
                    if (tResources==nil)
                    {
                        tResources=[tAttributes objectForKey:@"Resources"];
                    }
                    
                    tScripts=[tAttributes objectForKey:@"Scripts"];
					
					tPlugins=[tAttributes objectForKey:@"Plugins"];
                    
                    newTree=[[PBProjectTree alloc] initWithData:[PBMetaPackageNode metaPackageNodeWithName:tName
                                                                                                    status:[tNumber intValue]
                                                                                                  settings:tSettings
                                                                                                 resources:tResources
                                                                                                   scripts:tScripts
																								   plugins:tPlugins]
                                                         parent:nil
                                                       children:[NSArray array]];
                    
                    if (newTree!=nil)
                    {
                        NSString * tComponentDirectory;
                        
                        tComponentDirectory=[inDictionary objectForKey:IFPkgFlagComponentDirectory];
                        
                        if (tComponentDirectory!=nil)
                        {
                            [((PBMetaPackageNode *) NODE_DATA(newTree)) setComponentsDirectory:tComponentDirectory];
                        }
                        else
                        {
                            [((PBMetaPackageNode *) NODE_DATA(newTree)) setComponentsDirectory:[NSString stringWithString:@".."]];
                        }
                    }
                    
                    settingsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Settings",@"No comment")
                                                                                      type:kSettingsNode
                                                                                    status:-1]
                                                               parent:newTree
                                                             children:nil];
                    
                    
                    [newTree insertChild:settingsNode atIndex: PBPROJECTTREE_SETTINGS_INDEX];
                    
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
                    
                    
                    tComponents=[tAttributes objectForKey:@"Components"];
                
                    componentsNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Components",@"No comment")
                                                                                        type:kComponentsNode
                                                                                      status:-1]
                                                                 parent:newTree
                                                               children:[NSArray array]];
                    
                    
                    [newTree insertChild:componentsNode atIndex: PBPROJECTTREE_FILES_INDEX];
                    
                    [componentsNode release];
                    
                    tCount=[tComponents count];
                    
                    for(i=0;i<tCount;i++)
                    {
                        NSDictionary * tDictionary;
                        PBProjectTree * tTree=nil;
                        
                        tDictionary=[tComponents objectAtIndex:i];
                        
                        tTree=[PBProjectTree projectTreeWithDictionary:tDictionary];
                        
                        [componentsNode insertChild: tTree atIndex: i];
                    }
                }
                break;
            case kPBPackageNode:
                {
                    PBProjectTree * settingsNode=nil;
                    PBProjectTree * filesNode=nil;
                    PBProjectTree * resourcesNode=nil;
                    PBProjectTree * scriptsNode=nil;
					PBProjectTree * pluginsNode=nil;
                    NSDictionary * tFiles;
                    
                    tSettings=[tAttributes objectForKey:@"Settings"];
                    
                    tResources=[tAttributes objectForKey:@"Documents"];
                    
                    if (tResources==nil)
                    {
                        tResources=[tAttributes objectForKey:@"Resources"];
                    }
                    
                    tScripts=[tAttributes objectForKey:@"Scripts"];
					
					tPlugins=[tAttributes objectForKey:@"Plugins"];
                    
                    tFiles=[tAttributes objectForKey:@"Files"];
                    
                    newTree=[[PBProjectTree alloc] initWithData:[PBPackageNode packageNodeWithName:tName
                                                                                            status:[tNumber intValue]
                                                                                          settings:tSettings
                                                                                         resources:tResources
                                                                                           scripts:tScripts
																						   plugins:tPlugins
                                                                                             files:tFiles]
                                                         parent:nil
                                                       children:[NSArray array]];
                    
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
					
					filesNode=[[PBProjectTree alloc] initWithData:[PBNode nodeWithName:NSLocalizedString(@"Files",@"No comment")
                                                                                   type:kFilesNode
                                                                                 status:-1]
                                                            parent:newTree
                                                          children:[NSArray array]];
                    
                    [newTree insertChild: filesNode atIndex: PBPROJECTTREE_FILES_INDEX];
                    
                    [filesNode release];
                }
                break;
            default:
                break;
        }
        
        if (newTree!=nil && [inDictionary objectForKey:IFPkgFlagPackageSelection]!=nil)
        {
            [((PBObjectNode *) NODE_DATA(newTree)) setAttribute:[[inDictionary objectForKey:IFPkgFlagPackageSelection] intValue]];
        }
    }
    
    return [newTree autorelease];
    
}

#pragma mark -

- (BOOL) writeToFile:(NSString *) inFilePath atomically:(BOOL) flag
{
    return [self writeToURL:[NSURL fileURLWithPath:inFilePath] atomically:flag];
}

- (BOOL) writeToURL:(NSURL *) inURL atomically:(BOOL) flag
{
    NSDictionary * tProjectDictionary;
    PBProjectTree * tProjectTree;
    PBProjectTree * tPackageNode;
    NSDictionary * tHierarchyDictionary;
    
    tProjectTree=(PBProjectTree *) [self childAtIndex:0];
    
    if ([tProjectTree numberOfChildren]==1)
    {
        tPackageNode=(PBProjectTree *) [tProjectTree childAtIndex:0];
        
        tHierarchyDictionary=[tPackageNode dictionary];
    }
    else
    {
        tHierarchyDictionary=[NSDictionary dictionary];
    }
    
    if (tHierarchyDictionary!=nil)
    {
        tProjectDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"Project",@"Name",
                                                                  [PROJECTNODE_DATA(tProjectTree) settings],@"Settings",
                                                                  tHierarchyDictionary,@"Hierarchy",
                                                                  nil];
    
        return [tProjectDictionary writeToURL:inURL atomically:YES];
    }
    
    return NO;
}

- (NSDictionary *) dictionary
{
    NSDictionary * tDictionary=nil;
    
    switch([NODE_DATA(self) type])
    {
        case kPBMetaPackageNode:
            {
                PBMetaPackageNode * tMetaPackageNode;
                NSDictionary * tAttributesDictionary;
                PBProjectTree * tComponentsNode;
                int tCount,i;
                NSMutableArray * tComponentsArray;
                
                tComponentsNode=(PBProjectTree *) [self childAtIndex:PBPROJECTTREE_COMPONENTS_INDEX];
                
                tMetaPackageNode=(PBMetaPackageNode *) NODE_DATA(self);
                
                tCount=[tComponentsNode numberOfChildren];
                
                tComponentsArray=[NSMutableArray arrayWithCapacity:tCount];
                
                for(i=0;i<tCount;i++)
                {
                    NSDictionary * tSubPackageDictionary;
                    
                    tSubPackageDictionary=[((PBProjectTree *) [tComponentsNode childAtIndex:i]) dictionary];
                    
                    [tComponentsArray addObject:tSubPackageDictionary];
                }
                
                tAttributesDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tMetaPackageNode settings],@"Settings",
                                                                                [tMetaPackageNode resources],@"Documents",
                                                                                [tMetaPackageNode scripts],@"Scripts",
																				[tMetaPackageNode plugins],@"Plugins",
                                                                                tComponentsArray,@"Components",
                                                                                nil];
                
                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tMetaPackageNode name],@"Name",
                                                                       [NSNumber numberWithInt:[tMetaPackageNode type]],@"Type",
                                                                       [NSNumber numberWithInt:[tMetaPackageNode status]],@"Status",
                                                                       [NSNumber numberWithInt:[tMetaPackageNode attribute]],IFPkgFlagPackageSelection,
                                                                       [tMetaPackageNode componentsDirectory],IFPkgFlagComponentDirectory,
                                                                       tAttributesDictionary,@"Attributes",
                                                                       nil];
            }
            break;
        case kPBPackageNode:
            {
                PBPackageNode * tPackageNode;
                NSDictionary * tAttributesDictionary;
                NSMutableDictionary * tFilesDictionary;
                NSArray * tArray=nil;
                
                tPackageNode=(PBPackageNode *) NODE_DATA(self);
                
                tFilesDictionary=[tPackageNode files];
                
                tArray=[tFilesDictionary objectForKey:@"ExpandedRows"];
                
                if (tArray!=nil)
                {
                    tFilesDictionary=[[tPackageNode files] mutableCopy];
                    
                    [tFilesDictionary removeObjectForKey:@"ExpandedRows"];
                }
                
                tAttributesDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tPackageNode settings],@"Settings",
                                                                                [tPackageNode resources],@"Documents",
                                                                                [tPackageNode scripts],@"Scripts",
																				[tPackageNode plugins],@"Plugins",
                                                                                tFilesDictionary,@"Files",
                                                                                nil];
                
                if (tArray!=nil)
                {
                    [tFilesDictionary release];
                }
                
                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[tPackageNode name],@"Name",
                                                                       [NSNumber numberWithInt:[tPackageNode type]],@"Type",
                                                                       [NSNumber numberWithInt:[tPackageNode status]],@"Status",
                                                                       [NSNumber numberWithInt:[tPackageNode attribute]],IFPkgFlagPackageSelection,
                                                                       tAttributesDictionary,@"Attributes",
                                                                       nil];
            }
            break;
        case kSettingsNode:
            tDictionary=[[[OBJECTNODE_DATA([self nodeParent]) settings] copy] autorelease];
            break;
        case kResourcesNode:
            tDictionary=[[[OBJECTNODE_DATA([self nodeParent]) resources] copy] autorelease];
            break;
        case kScriptsNode:
            tDictionary=[[[OBJECTNODE_DATA([self nodeParent]) scripts] copy] autorelease];
            break;
		case kPluginsNode:
            tDictionary=[[[OBJECTNODE_DATA([self nodeParent]) plugins] copy] autorelease];
            break;
        case kFilesNode:
            tDictionary=[[[((PBPackageNode *) NODE_DATA([self nodeParent])) files] copy] autorelease];
            break;
        
    }
    
    return tDictionary;
}

+ (NSString *) uniqueNameWithComponentTree:(PBProjectTree *) inComponentTree
{
    int _sIndex=0;
    static NSString * tLocalizedBaseName=nil;
    int i,tCount;
    NSString * tString;
    
    if (tLocalizedBaseName==nil)
    {
        tLocalizedBaseName=[[NSString alloc] initWithString:NSLocalizedString(@"Untitled Component",@"No comment")];
    }
    
    tCount=[inComponentTree numberOfChildren];
    
    do
    {
        PBProjectTree * tTreeNode;
        
        if (_sIndex>0)
        {
            tString=[[NSString alloc] initWithFormat:@"%@ %d",tLocalizedBaseName,_sIndex];
        }
        else
        {
            tString=[[NSString alloc] initWithString:tLocalizedBaseName];
        }
        
        _sIndex++;
        
        for(i=0;i<tCount;i++)
        {
            tTreeNode=(PBProjectTree *) [inComponentTree childAtIndex:i];
            
            if ([tString isEqualToString:[NODE_DATA(tTreeNode) name]]==YES)
            {
                break;
            }
        }
        
        if (i==tCount)
        {
            break;
        }
        
        [tString release];
    }
    while (_sIndex<65535);
    
    return [tString autorelease];
}

+ (id) resolveHierarchy:(id) inHierarchy withKeywordDictionary:(NSDictionary *) inKWDictionary
{
    if ([inHierarchy isKindOfClass:[NSArray class]]==YES)
    {
        return [PBProjectTree resolveArray:inHierarchy withKeywordDictionary:inKWDictionary];
    }
    else
    if ([inHierarchy isKindOfClass:[NSDictionary class]]==YES)
    {
        return [PBProjectTree resolveDictionary:inHierarchy withKeywordDictionary:inKWDictionary];
    }
    
    return NULL;
}

+ (NSMutableArray *) resolveArray:(NSArray *) inArray withKeywordDictionary:(NSDictionary *) inKWDictionary
{
    NSMutableArray * tMutableArray;
    int i,tCount;
    
    tMutableArray=[[inArray mutableCopy] autorelease];
    
    tCount=[tMutableArray count];
    
    for(i=0;i<tCount;i++)
    {
        id tObject;
        
        tObject=[tMutableArray objectAtIndex:i];
        
        if ([tObject isKindOfClass:[NSArray class]]==YES)
        {
            [tMutableArray replaceObjectAtIndex:i
                                     withObject:[PBProjectTree resolveArray:tObject withKeywordDictionary:inKWDictionary]];
        }
        else
        if ([tObject isKindOfClass:[NSDictionary class]]==YES)
        {
            [tMutableArray replaceObjectAtIndex:i
                                     withObject:[PBProjectTree resolveDictionary:tObject withKeywordDictionary:inKWDictionary]];
        }
        else
        if ([tObject isKindOfClass:[NSString class]]==YES)
        {
            [tMutableArray replaceObjectAtIndex:i
                                     withObject:[tObject replaceAllTextBetweenString:@"%%"
                                                                           andString:@"%%"
                                                                      fromDictionary:inKWDictionary]];
        }
    }
    
    return tMutableArray;
}

+ (NSMutableDictionary *) resolveDictionary:(NSDictionary *) inDictionary withKeywordDictionary:(NSDictionary *) inKWDictionary
{
    NSMutableDictionary * tMutableDictionary;
    NSArray * tKeysArray;
    int i,tCount;
    
    tMutableDictionary=[inDictionary mutableCopy];
    
    tKeysArray=[tMutableDictionary allKeys];
    
    tCount=[tKeysArray count];
    
    for(i=0;i<tCount;i++)
    {
        id tObject;
        id tKey;
        
        tKey=[tKeysArray objectAtIndex:i];
        
        tObject=[tMutableDictionary objectForKey:tKey];
        
        if ([tObject isKindOfClass:[NSArray class]]==YES)
        {
            [tMutableDictionary setObject:[PBProjectTree resolveArray:tObject withKeywordDictionary:inKWDictionary]
                                  forKey:tKey];
        }
        else
        if ([tObject isKindOfClass:[NSDictionary class]]==YES)
        {
            [tMutableDictionary setObject:[PBProjectTree resolveDictionary:tObject withKeywordDictionary:inKWDictionary]
                                  forKey:tKey];
        }
        else
        if ([tObject isKindOfClass:[NSString class]]==YES)
        {
            [tMutableDictionary setObject:[tObject replaceAllTextBetweenString:@"%%"
                                                                     andString:@"%%"
                                                                fromDictionary:inKWDictionary]
                                   forKey:tKey];
        }
    }
    
    return tMutableDictionary;
}

@end
