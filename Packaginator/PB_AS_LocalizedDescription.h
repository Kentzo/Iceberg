#import <Foundation/Foundation.h>

@class PB_AS_Settings;

@interface PB_AS_LocalizedDescription : NSObject
{
    PB_AS_Settings * settings_;
    
    NSMutableDictionary * dictionary_;
    
    NSString * language_;
}

- (id) initForSettings:(PB_AS_Settings *) inSettings withLanguage:(NSString *) inLanguage;

+ (id) localizedDescriptionForSettings:(PB_AS_Settings *) inSettings withLanguage:(NSString *) inLanguage;

- (NSDictionary *) dictionary;

- (PB_AS_Settings *) settings;

- (void) setSettings:(PB_AS_Settings *) inSettings;

- (NSString *) name;

- (void) setName:(NSString *) inLanguage;


- (NSString *) descriptionObjectForKey:(NSString *) inKey;

- (void) setDescriptionObject:(NSString *) inString forKey:(NSString *) inKey;

- (NSString *) title;

- (void) setTitle:(NSString *) inString;

- (NSString *) description;

- (void) setDescription:(NSString *) inString;

- (NSString *) version;

- (void) setVersion:(NSString *) inString;

- (NSString *) deleteWarning;

- (void) setDeleteWarning:(NSString *) inString;

@end
