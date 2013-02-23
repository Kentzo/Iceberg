#import <Foundation/Foundation.h>

@class PB_AS_Component;

@interface PB_AS_Documents : NSObject
{
    PB_AS_Component * component_;
    
    NSMutableDictionary * resourcesDictionary_;
}

- (id) initWithComponent:(PB_AS_Component *) inComponent;

+ (id) documentsWithComponent:(PB_AS_Component *) inComponent;


- (void) notifySettingsChanged;

// Background Image

- (id) backgroundImageOptionForKey:(NSString *) inKey;

- (void) setBackgroundImageOption:(id) inObject forKey:(NSString *) inKey;

- (NSNumber *) alignment;

- (void) setAlignment:(NSNumber *) inNumber;

- (NSNumber *) scaling;

- (void) setScaling:(NSNumber *) inNumber;

- (NSString *) path;

- (void) setPath:(NSString *) inString;

- (NSNumber *) mode;

- (void) setMode:(NSNumber *) inNumber;

@end
