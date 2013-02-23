#import "PBSimulatorTigerLocalizer.h"
#import "PBInstallerLocator.h"

@implementation PBSimulatorTigerLocalizer

+ (PBSimulatorTigerLocalizer *) defaultLocalizer
{
    static PBSimulatorTigerLocalizer * sSimulatorTigerLocalizer=nil;
    
    if (sSimulatorTigerLocalizer==nil)
    {
        sSimulatorTigerLocalizer=[[PBSimulatorTigerLocalizer alloc] init];
    }
    
    return sSimulatorTigerLocalizer;
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        NSString * tPath;
        
        tPath=[PBInstallerLocator pathForInstaller];
        
        if (tPath!=nil)
        {
            mainBundle_=[[NSBundle bundleWithPath:tPath] retain];
            
            tPath=nil;
            
            if (mainBundle_!=nil)
            {
                NSString * tPluginPath;
                
                tPluginPath=[mainBundle_ builtInPlugInsPath];
                
                if (tPluginPath!=nil)
                {
                    NSFileManager * tFileManager;
                    NSArray * tArray;
                    NSEnumerator * tEnumerator;
                    NSString * tBundleName;
                    NSMutableDictionary * tMutableDictionary;
                    
                    tFileManager=[NSFileManager defaultManager];
                    
                    tArray=[tFileManager directoryContentsAtPath:tPluginPath];
                    
                    bundleDictionary_=[[NSMutableDictionary dictionary] retain];
                    
                    tMutableDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:mainBundle_,@"Bundle",
                                                                                           nil];
                                
                    [bundleDictionary_ setObject:tMutableDictionary forKey:@"Main"];
                    
                    [tMutableDictionary release];
                    
                    tMutableDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSBundle mainBundle],@"Bundle",
                                                                                           nil];
                                
                    [bundleDictionary_ setObject:tMutableDictionary forKey:@"self"];
                    
                    [tMutableDictionary release];
                    
                    tEnumerator=[tArray objectEnumerator];
                    
                    while (tBundleName=[tEnumerator nextObject])
                    {
                        if ([[tBundleName pathExtension] isEqualToString:@"bundle"]==YES)
                        {
                            NSBundle * tBundle;
                            
                            tBundle=[NSBundle bundleWithPath:[tPluginPath stringByAppendingPathComponent:tBundleName]];
                            
                            if (tBundle!=nil)
                            {
                                tMutableDictionary=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tBundle,@"Bundle",
                                                                                                       nil];
                                
                                [bundleDictionary_ setObject:tMutableDictionary forKey:[tBundleName stringByDeletingPathExtension]];
                                
                                [tMutableDictionary release];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return self;
}

- (NSArray *) localizations
{
    if (mainBundle_!=nil)
    {
        return [mainBundle_ localizations];
    }
    
    return nil;
}

- (NSString *) localizedString:(NSString *) inString forLanguage:(NSString *) inLanguage inBundle:(NSString *) inBundleName
{
    NSString * tString=nil;
    
    NSMutableDictionary * tBundleDictionary;
    
    tBundleDictionary=[bundleDictionary_ objectForKey:inBundleName];
    
    if (tBundleDictionary!=nil)
    {
        NSMutableDictionary * tLocalizedDictionary;
        
        tLocalizedDictionary=[tBundleDictionary objectForKey:inLanguage];
        
        if (tLocalizedDictionary==nil)
        {
            // We need to build it
            
            NSBundle * tBundle;
            
            tBundle=[tBundleDictionary objectForKey:@"Bundle"];
            
            if (tBundle!=nil)
            {
                if ([inBundleName isEqualToString:@"self"]==NO)
                {
                    NSString * tPath;
                    NSDictionary * tResourceDictionary;
                    
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
                    
                    tPath=[tBundle pathForResource:@"Localizable"
                                            ofType:@"strings"
                                    inDirectory:nil
                                forLocalization:inLanguage];
                    
                    tResourceDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
                    
                    if (tResourceDictionary!=nil)
                    {
                        [tLocalizedDictionary addEntriesFromDictionary:tResourceDictionary];
                    
                        [tResourceDictionary release];
                    }
                    
                    tPath=[tBundle pathForResource:@"InfoPlist"
                                            ofType:@"strings"
                                    inDirectory:nil
                                forLocalization:inLanguage];
                    
                    tResourceDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
                    
                    if (tResourceDictionary!=nil)
                    {
                        [tLocalizedDictionary addEntriesFromDictionary:tResourceDictionary];
                    
                        [tResourceDictionary release];
                    }
                    
                    [tBundleDictionary setObject:tLocalizedDictionary forKey:inLanguage];
                    
                    [bundleDictionary_ setObject:tBundleDictionary forKey:inBundleName];
                }
                else
                {
                    NSString * tPath;
                    NSDictionary * tResourceDictionary;
                    
                    tLocalizedDictionary=[NSMutableDictionary dictionary];
                    
                    tPath=[tBundle pathForResource:@"Simulator"
                                            ofType:@"strings"
                                    inDirectory:nil
                                forLocalization:inLanguage];
                    
                    tResourceDictionary=[[NSDictionary alloc] initWithContentsOfFile:tPath];
                    
                    if (tResourceDictionary!=nil)
                    {
                        [tLocalizedDictionary addEntriesFromDictionary:tResourceDictionary];
                    
                        [tResourceDictionary release];
                    }
                    
                    [tBundleDictionary setObject:tLocalizedDictionary forKey:inLanguage];
                    
                    [bundleDictionary_ setObject:tBundleDictionary forKey:inBundleName];
                }
            }
        }
        
        if (tLocalizedDictionary!=nil)
        {
            tString=[tLocalizedDictionary objectForKey:inString];
        }
    }
    
    return tString;
}

@end
