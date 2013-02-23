#import "PB_AS_LocalizedDescription.h"
#import "PBSharedConst.h"

#import "PB_AS_Settings.h"

@implementation PB_AS_LocalizedDescription

- (NSScriptObjectSpecifier *) objectSpecifier
{
    NSScriptObjectSpecifier * specifier = nil;
    
    NSScriptObjectSpecifier *containerRef = [settings_  objectSpecifier];
    NSScriptClassDescription *containerClassDescription = [containerRef keyClassDescription];
        
    specifier = [[NSNameSpecifier allocWithZone: [self zone]] initWithContainerClassDescription: containerClassDescription
                                                                                 containerSpecifier: containerRef
                                                                                                key: @"localizedDescriptions" 
                                                                                               name: language_];
    
    return [specifier autorelease];
}

#pragma mark -

- (id) init
{
    self=[super init];
    
    if (self)
    {
        // A COMPLETER
    }
    
    return self;
}

- (id) initForSettings:(PB_AS_Settings *) inSettings withLanguage:(NSString *) inLanguage
{
    self=[super init];
    
    if (self)
    {
        settings_=[inSettings retain];
        
        dictionary_=[[settings_ descriptionDictionaryForLanguage: inLanguage] mutableCopy];
        
        language_=[inLanguage retain];
    }
    
    return self;
}

+ (id) localizedDescriptionForSettings:(PB_AS_Settings *) inSettings withLanguage:(NSString *) inLanguage
{
    PB_AS_LocalizedDescription * tLocalizedDescription;

    tLocalizedDescription= [[PB_AS_LocalizedDescription alloc] initForSettings:inSettings withLanguage:inLanguage];
    
    return [tLocalizedDescription autorelease];
}

- (void) dealloc
{
    [settings_ release];
    
    [language_ release];
    
    [dictionary_ release];
    
    [super dealloc];
}

- (PB_AS_Settings *) settings
{
    return [[settings_ retain] autorelease];
}

- (void) setSettings:(PB_AS_Settings *) inSettings
{
    if (inSettings!=settings_)
    {
        [settings_ release];
        
        settings_=[inSettings copy];
    }
}

- (NSDictionary *) dictionary
{
    return [[dictionary_ retain] autorelease];
}

- (NSString *) name
{
    return [[language_ retain] autorelease];
}

- (void) setName:(NSString *) inLanguage
{
    if (language_!=inLanguage)
    {
        [language_ release];
        
        language_=[inLanguage copy];
        
        // A COMPLETER
    }
}

#pragma mark -

- (NSString *) descriptionObjectForKey:(NSString *) inKey
{
    NSString * tObject=nil;
    
    if (dictionary_!=nil)
    {
        tObject=[dictionary_ objectForKey:inKey];
    }
    
    if (tObject==nil)
    {
        tObject=[NSString stringWithString:@""];
    }
    
    return tObject;
}

- (void) setDescriptionObject:(NSString *) inString forKey:(NSString *) inKey
{
    if ([inString isKindOfClass:[NSString class]]==YES)
    {
        if (dictionary_==nil)
        {
            dictionary_=[[NSMutableDictionary alloc] initWithCapacity:4];
        }
        
        [dictionary_ setObject:inString forKey:inKey];
    
        if (settings_!=nil)
        {
            [settings_ setDescriptionDictionary:dictionary_ forLanguage:language_];
        }
    }
}

- (NSString *) title
{
    return [self descriptionObjectForKey:IFPkgDescriptionTitle];
}

- (void) setTitle:(NSString *) inString
{
    [self setDescriptionObject:inString forKey:IFPkgDescriptionTitle];
}

- (NSString *) description
{
    return [self descriptionObjectForKey:IFPkgDescriptionDescription];
}

- (void) setDescription:(NSString *) inString
{
    [self setDescriptionObject:inString forKey:IFPkgDescriptionDescription];
}

- (NSString *) version
{
    return [self descriptionObjectForKey:IFPkgDescriptionVersion];
}

- (void) setVersion:(NSString *) inString
{
    [self setDescriptionObject:inString forKey:IFPkgDescriptionVersion];
}

- (NSString *) deleteWarning
{
    return [self descriptionObjectForKey:IFPkgDescriptionDeleteWarning];
}

- (void) setDeleteWarning:(NSString *) inString
{
    [self setDescriptionObject:inString forKey:IFPkgDescriptionDeleteWarning];
}

@end
