#import "PB_AS_Settings.h"
#import "PB_AS_Component.h"

#import "PB_AS_Package.h"

#import "PB_AS_LocalizedDescription.h"

#import "NSString+Iceberg.h"
#import "NSDocument+Iceberg.h"

static unsigned long sAuthorizationAppleCode[3]={
                                                    'NONE',
                                                    'AUT1',
                                                    'AUT2'
                                                };

static unsigned long sRestartActionAppleCode[5]={
                                                    'NONE',
                                                    'RES1',
                                                    'RES2',
                                                    'RES3',
                                                    'RES4'
                                                };

NSString * localizedDescriptionsKey = @"localizedDescriptions";

@implementation PB_AS_Settings

- (NSScriptObjectSpecifier *) objectSpecifier
{
    NSScriptObjectSpecifier * specifier=nil;
    
    specifier=[[NSPropertySpecifier alloc] initWithContainerSpecifier:[component_ objectSpecifier] key:@"settings"];
    
    return [specifier autorelease];
}

#pragma mark -

- (id) initWithComponent:(PB_AS_Component *) inComponent
{
    self=[super init];
    
    if (self)
    {
        PBProjectTree * tComponentTree;
        
        component_=[inComponent retain];
        
    	tComponentTree=[component_ treeNode];
    
        if (tComponentTree!=nil)
        {
            PBObjectNode * tNode;
        
            tNode=[OBJECTNODE_DATA(tComponentTree) retain];
            
            if (tNode!=nil)
            {
                NSDictionary * tDescriptionDictionary;
                
                settingsDictionary_=[[tNode settings] retain];
                
                tDescriptionDictionary=[settingsDictionary_ objectForKey:@"Description"];
                
                if (tDescriptionDictionary!=nil)
                {
                    int tCount;
                    
                    tCount=[tDescriptionDictionary count];
                    
                    if (tCount>0)
                    {
                        NSEnumerator * tEnumerator;
                        NSString * tLanguage;
                        
                        localizedDescriptions_=[[NSMutableArray alloc] initWithCapacity:tCount];
                        
                        tEnumerator=[tDescriptionDictionary keyEnumerator];
                        
                        while (tLanguage=[tEnumerator nextObject])
                        {
                            PB_AS_LocalizedDescription * tLocalizedDescription;
                            
                            tLocalizedDescription=[PB_AS_LocalizedDescription localizedDescriptionForSettings:self withLanguage:tLanguage];
                        
                            [localizedDescriptions_ addObject:tLocalizedDescription];
                        }
                    }
                }
                
                if (localizedDescriptions_==nil)
                {
                    localizedDescriptions_=[[NSMutableArray alloc] initWithCapacity:1];
                }
            }
        }
    }
    
    return self;
}

+ (id) settingsWithComponent:(PB_AS_Component *) inComponent
{
    PB_AS_Settings * nSettings;
    
    nSettings=[[PB_AS_Settings alloc] initWithComponent:inComponent];
    
    return [nSettings autorelease];
}

- (void) dealloc
{
    [component_ release];
    
    [settingsDictionary_ release];
    
    [localizedDescriptions_ release];
    
    [super dealloc];
}

#pragma mark -

- (PB_AS_Component *) component
{
    return [[component_ retain] autorelease];
}

#pragma mark -

- (NSDictionary *) descriptionDictionaryForLanguage:(NSString *) inLanguage
{
    NSDictionary * tDictionary;
    
    tDictionary=[settingsDictionary_ objectForKey:@"Description"];
    
    return [tDictionary objectForKey:inLanguage];
}

- (void) setDescriptionDictionary:(NSDictionary *) inDictionary forLanguage:(NSString *) inLanguage
{
    NSMutableDictionary * tDictionary;
    
    tDictionary=[[settingsDictionary_ objectForKey:@"Description"] mutableCopy];
    
    if (tDictionary!=nil)
    {
        [tDictionary setObject:inDictionary forKey:inLanguage];
    
        [settingsDictionary_ setObject:tDictionary forKey:@"Description"];
    
        [tDictionary release];
    
        [self notifySettingsChanged];	// A VOIR
    }
}

- (NSArray *) localizedDescriptions
{
    return [[localizedDescriptions_ retain] autorelease];
}

- (void) setLocalizedDescriptions:(NSArray *) inArray
{
    // A COMPLETER
}

- (id) valueWithName:(NSString *)name inPropertyWithKey:(NSString *) inKey
{
    id tResult=nil;
    
    if( [localizedDescriptionsKey isEqualToString: inKey] )
    {
        NSDictionary * tDictionary;
        NSDictionary * tLocalizedDictionary;
        
        tDictionary=[settingsDictionary_ objectForKey:@"Description"];
    
        tLocalizedDictionary= [tDictionary objectForKey:name];
        
        if (tLocalizedDictionary!=nil)
        {
            return [PB_AS_LocalizedDescription localizedDescriptionForSettings:self withLanguage:name];
        }
        
        // A MODIFIER
    }
    
    return tResult;
}

- (id) valueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey
{
    // A COMPLETER
    
    return nil;
}

- (void) replaceValueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey withValue:(id)value
{
    // A COMPLETER
}

- (void) insertValue:(id)value atIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey
{
    // A COMPLETER
}

- (void) removeValueAtIndex:(unsigned)index fromPropertyWithKey:(NSString *) inKey
{
    // A COMPLETER
}

- (void) insertValue:(id)value inPropertyWithKey:(NSString *) inKey
{
    if( [localizedDescriptionsKey isEqualToString: inKey] )
    {
        if ([value isKindOfClass:[PB_AS_LocalizedDescription class]])
        {
            NSString * tLanguage;
            
            tLanguage=[value language];
            
            if (tLanguage!=nil && [tLanguage length]>0)
            {
                [(PB_AS_LocalizedDescription *) value setSettings:self];
                
                [self setDescriptionDictionary:[value dictionary] forLanguage:tLanguage];
            }
        }
    }
}

#pragma mark -

- (id) displayInformationForKey:(NSString *) inKey
{
    if (settingsDictionary_!=nil)
    {
        NSDictionary * tDisplayInformationDictionary;
            
        tDisplayInformationDictionary=[settingsDictionary_ objectForKey:@"Display Information"];
        
        if (tDisplayInformationDictionary!=nil)
        {
            return [tDisplayInformationDictionary objectForKey:inKey];
        }
    }
    
    return nil;
}

- (void) setDisplayInformation:(NSString *) inString forKey:(NSString *) inKey
{
    if (settingsDictionary_!=nil && [inString isKindOfClass:[NSString class]])
    {
        NSMutableDictionary * nDisplayInformationDictionary;
        
        nDisplayInformationDictionary=[[settingsDictionary_ objectForKey:@"Display Information"] mutableCopy];
        
        if (nDisplayInformationDictionary!=nil)
        {
            [nDisplayInformationDictionary setObject:inString forKey:inKey];
            
            [settingsDictionary_ setObject:nDisplayInformationDictionary forKey:@"Display Information"];
            
            [nDisplayInformationDictionary release];
            
            [self notifySettingsChanged];
        }
    }
}

- (NSString *) displayName
{
    return [self displayInformationForKey:@"CFBundleName"];
}

- (void) setDisplayName:(NSString *) inString
{
    [self setDisplayInformation:inString forKey:@"CFBundleName"];
}

- (NSString *) identifier
{
    return [self displayInformationForKey:@"CFBundleIdentifier"];
}

- (void) setIdentifier:(NSString *) inString
{
    [self setDisplayInformation:inString forKey:@"CFBundleIdentifier"];
}

- (NSString *) getInfoString
{
    return [self displayInformationForKey:@"CFBundleGetInfoString"];
}

- (void) setGetInfoString:(NSString *) inString
{
    [self setDisplayInformation:inString forKey:@"CFBundleGetInfoString"];
}

- (NSString *) shortVersion
{
    return [self displayInformationForKey:@"CFBundleShortVersionString"];
}

- (void) setShortVersion:(NSString *) inString
{
    [self setDisplayInformation:inString forKey:@"CFBundleShortVersionString"];
}

- (NSString *) iconFile
{
    NSNumber * tNumber;
    NSString * tPath;
    
    tPath=[self displayInformationForKey:@"CFBundleIconFile"];
    
    tNumber=[self displayInformationForKey:@"CFBundleIconFile Path Type"];
    
    if (tNumber!=nil)
    {
        if ([tNumber intValue]==kRelativeToProjectPath)
        {
            tPath=[tPath stringByAbsolutingWithPath:[[component_ document] folder]];
        }
    }
    
    if (tPath==nil)
    {
        tPath=[NSString stringWithString:@""];
    }
    
    return tPath;
}

- (void) setIconFile:(NSString *) inString
{
    if ([inString isKindOfClass:[NSString class]])
    {
        NSString * tPath;
        NSNumber * tNumber;
        
        tPath=[self displayInformationForKey:@"CFBundleIconFile"];
        
        tNumber=[self displayInformationForKey:@"CFBundleIconFile Path Type"];
        
        if (tNumber!=nil)
        {
            if ([tNumber intValue]==kRelativeToProjectPath)
            {
                tPath=[tPath stringByAbsolutingWithPath:[[component_ document] folder]];
            }
        }
        
        if ([tPath isEqualToString:inString]==NO)
        {
            if (tNumber!=nil)
            {
                if ([tNumber intValue]==kRelativeToProjectPath)
                {
                    inString=[inString stringByRelativizingToPath:[[component_ document] folder]];
                }
            }
            
            [self setDisplayInformation:inString forKey:@"CFBundleIconFile"];
        }
    }

}

#pragma mark -

- (NSNumber *) majorVersion
{
    if (settingsDictionary_!=nil)
    {
        NSDictionary * tVersionDictionary;
            
        tVersionDictionary=[settingsDictionary_ objectForKey:@"Version"];
        
        if (tVersionDictionary!=nil)
        {
            return [tVersionDictionary objectForKey:IFMajorVersion];
        }
    }
    
    return nil;
}

- (void) setMajorVersion:(NSNumber *) inMajorVersion
{
    if (settingsDictionary_!=nil && [inMajorVersion isKindOfClass:[NSNumber class]])
    {
        NSMutableDictionary * nVersionDictionary;
        
        nVersionDictionary=[[settingsDictionary_ objectForKey:@"Version"] mutableCopy];
        
        if (nVersionDictionary!=nil)
        {
            [nVersionDictionary setObject:inMajorVersion forKey:IFMajorVersion];
            
            [settingsDictionary_ setObject:nVersionDictionary forKey:@"Version"];
            
            [nVersionDictionary release];
            
            [self notifySettingsChanged];
        }
    }
    
}

- (NSNumber *) minorVersion
{
    if (settingsDictionary_!=nil)
    {
        NSDictionary * tVersionDictionary;
            
        tVersionDictionary=[settingsDictionary_ objectForKey:@"Version"];
        
        if (tVersionDictionary!=nil)
        {
            return [tVersionDictionary objectForKey:IFMinorVersion];
        }
    }
    
    return nil;
}

- (void) setMinorVersion:(NSNumber *) inMinorVersion
{
    if (settingsDictionary_!=nil && [inMinorVersion isKindOfClass:[NSNumber class]])
    {
        NSMutableDictionary * nVersionDictionary;
        
        nVersionDictionary=[[settingsDictionary_ objectForKey:@"Version"] mutableCopy];
        
        if (nVersionDictionary!=nil)
        {
            [nVersionDictionary setObject:inMinorVersion forKey:IFMinorVersion];
            
            [settingsDictionary_ setObject:nVersionDictionary forKey:@"Version"];
            
            [nVersionDictionary release];
            
            [self notifySettingsChanged];
        }
    }
}

#pragma mark -

- (NSNumber *) restart
{
    NSNumber * tNumber;
   
    tNumber=[self optionForKey:IFPkgFlagRestartAction];
     
    if (tNumber!=nil)
    {
        int tValue;
        
        tValue=[tNumber intValue];
        
        if (tValue>=0 && tValue<=4)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sRestartActionAppleCode[tValue]];
        }
    }
    
    return tNumber;
}

- (void) setRestart:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<5;i++)
        {
            if (tValue==sRestartActionAppleCode[i])
            {
                [self setOption:[NSNumber numberWithInt:i] forKey:IFPkgFlagRestartAction];
                
                break;
            }
        }
    }
}

- (NSNumber *) authorization
{
    NSNumber * tNumber;
   
    tNumber=[self optionForKey:IFPkgFlagAuthorizationAction];
     
    if (tNumber!=nil)
    {
        int tValue;
        
        tValue=[tNumber intValue];
        
        if (tValue>=0 && tValue<=2)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sAuthorizationAppleCode[tValue]];
        }
    }
    
    return tNumber;
}

- (void) setAuthorization:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<3;i++)
        {
            if (tValue==sAuthorizationAppleCode[i])
            {
                [self setOption:[NSNumber numberWithInt:i] forKey:IFPkgFlagAuthorizationAction];
               
                break;
            }
        }
    }
}

#pragma mark -

- (NSNumber *) optionForKey:(NSString *) inKey
{
    if ([component_ isMemberOfClass:[PB_AS_Package class]]==YES)
    {
        NSDictionary * tOptionsDictionary;
            
        tOptionsDictionary=[settingsDictionary_ objectForKey:@"Options"];
        
        if (tOptionsDictionary!=nil)
        {
            return [tOptionsDictionary objectForKey:inKey];
        }
    }
    
    return nil;
}

- (void) setOption:(NSNumber *) inNumber forKey:(NSString *) inKey
{
    if ([component_ isMemberOfClass:[PB_AS_Package class]]==YES)
    {
        if (settingsDictionary_!=nil && [inNumber isKindOfClass:[NSNumber class]])
        {
            NSMutableDictionary * nOptionsDictionary;
            
            nOptionsDictionary=[[settingsDictionary_ objectForKey:@"Options"] mutableCopy];
            
            if (nOptionsDictionary!=nil)
            {
                [nOptionsDictionary setObject:inNumber forKey:inKey];
                
                [settingsDictionary_ setObject:nOptionsDictionary forKey:@"Options"];
                
                [nOptionsDictionary release];
                
                [self notifySettingsChanged];
            }
        }
    }
}

- (NSNumber *) required
{
    return [self optionForKey:IFPkgFlagIsRequired];
}

- (void) setRequired:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagIsRequired];
}

- (NSNumber *) rootVolumeOnly
{
    return [self optionForKey:IFPkgFlagRootVolumeOnly];
}

- (void) setRootVolumeOnly:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagRootVolumeOnly];
}

- (NSNumber *) overwriteDirectoryPermissions
{
    return [self optionForKey:IFPkgFlagOverwritePermissions];
}

- (void) setOverwriteDirectoryPermissions:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagOverwritePermissions];
}

- (NSNumber *) updateInstalledLanguagesOnly
{
    return [self optionForKey:IFPkgFlagUpdateInstalledLanguages];
}

- (void) setUpdateInstalledLanguagesOnly:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagUpdateInstalledLanguages];
}

- (NSNumber *) relocatable
{
    return [self optionForKey:IFPkgFlagRelocatable];
}

- (void) setRelocatable:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagRelocatable];
}


- (NSNumber *) installFatBinaries
{
    return [self optionForKey:IFPkgFlagInstallFat];
}

- (void) setInstallFatBinaries:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagInstallFat];
}


- (NSNumber *) allowRevertToPreviousVersions
{
    return [self optionForKey:IFPkgFlagAllowBackRev];
}

- (void) setAllowRevertToPreviousVersions:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagAllowBackRev];
}

- (NSNumber *) followSymbolicLinks
{
    return [self optionForKey:IFPkgFlagFollowLinks];
}

- (void) setFollowSymbolicLinks:(NSNumber *) inNumber
{
    [self setOption:inNumber forKey:IFPkgFlagFollowLinks];
}

#pragma mark -

- (void) notifySettingsChanged
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[component_ treeNode],@"ProjectTree",
                                                           @"Settings",@"Modified Section",
                                                           nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentChanged"
                                                        object:[component_ document]
                                                      userInfo:tDictionary];
}

@end
