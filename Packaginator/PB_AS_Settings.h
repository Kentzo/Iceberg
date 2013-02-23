#import <Foundation/Foundation.h>

@class PB_AS_Component;
@class PB_AS_LocalizedDescription;

@interface PB_AS_Settings : NSObject
{
    PB_AS_Component * component_;
    
    NSMutableDictionary * settingsDictionary_;
    
    NSMutableArray * localizedDescriptions_;
}

- (id) initWithComponent:(PB_AS_Component *) inComponent;

+ (id) settingsWithComponent:(PB_AS_Component *) inComponent;


- (void) notifySettingsChanged;

- (NSDictionary *) descriptionDictionaryForLanguage:(NSString *) inLanguage;

- (void) setDescriptionDictionary:(NSDictionary *) inDictionary forLanguage:(NSString *) inLanguage;


// Display Information

- (id) displayInformationForKey:(NSString *) inKey;

- (void) setDisplayInformation:(NSString *) inString forKey:(NSString *) inKey;

- (NSString *) displayName;

- (void) setDisplayName:(NSString *) inString;

- (NSString *) identifier;

- (void) setIdentifier:(NSString *) inString;

- (NSString *) getInfoString;

- (void) setGetInfoString:(NSString *) inString;

- (NSString *) shortVersion;

- (void) setShortVersion:(NSString *) inString;

- (NSString *) iconFile;

- (void) setIconFile:(NSString *) inString;

// Version

- (NSNumber *) majorVersion;

- (void) setMajorVersion:(NSNumber *) inMajorVersion;

- (NSNumber *) minorVersion;

- (void) setMinorVersion:(NSNumber *) inMinorVersion;

// Attributes Specific to Packages

- (NSNumber *) optionForKey:(NSString *) inKey;

- (void) setOption:(NSNumber *) inNumber forKey:(NSString *) inKey;

- (NSNumber *) restart;

- (void) setRestart:(NSNumber *) inNumber;

- (NSNumber *) authorization;

- (void) setAuthorization:(NSNumber *) inNumber;

- (NSNumber *) optionForKey:(NSString *) inKey;

- (void) setOption:(NSNumber *) inNumber forKey:(NSString *) inKey;

- (NSNumber *) required;

- (void) setRequired:(NSNumber *) inNumber;

- (NSNumber *) rootVolumeOnly;

- (void) setRootVolumeOnly:(NSNumber *) inNumber;

- (NSNumber *) overwriteDirectoryPermissions;

- (void) setOverwriteDirectoryPermissions:(NSNumber *) inNumber;

- (NSNumber *) updateInstalledLanguagesOnly;

- (void) setUpdateInstalledLanguagesOnly:(NSNumber *) inNumber;

- (NSNumber *) relocatable;

- (void) setRelocatable:(NSNumber *) inNumber;

- (NSNumber *) installFatBinaries;

- (void) setInstallFatBinaries:(NSNumber *) inNumber;

- (NSNumber *) allowRevertToPreviousVersions;

- (void) setAllowRevertToPreviousVersions:(NSNumber *) inNumber;

- (NSNumber *) followSymbolicLinks;

- (void) setFollowSymbolicLinks:(NSNumber *) inNumber;

// Localized Descriptions

- (NSArray *) localizedDescriptions;

- (void) setLocalizedDescriptions: (NSArray *) inLocalizations;

- (id) valueWithName:(NSString *)name inPropertyWithKey:(NSString *) inKey;

- (id) valueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey;

- (void) replaceValueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey withValue:(id)value;

- (void) insertValue:(id)value atIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey;

- (void) removeValueAtIndex:(unsigned)index fromPropertyWithKey:(NSString *) inKey;

- (void) insertValue:(id)value inPropertyWithKey:(NSString *) inKey;

@end
