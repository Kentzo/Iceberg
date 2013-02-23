#import "PB_AS_Documents.h"
#import "PB_AS_Component.h"

#import "NSString+Iceberg.h"
#import "NSDocument+Iceberg.h"

static unsigned long sAlignmentAppleCode[9]={
                                                'ALI5',
                                                'ALI2',
                                                'ALI1',
                                                'ALI3',
                                                'ALI4',
                                                'ALI8',
                                                'ALI7',
                                                'ALI9',
                                                'ALI6'
                                            };

static unsigned long sScalingAppleCode[3]={
                                            'SCA1',
                                            'SCA2',
                                            'NONE'
                                            };

static unsigned long sBackgroundModeAppleCode[2]={
                                                    'DEFA',
                                                    'CUST',
                                                 };

@implementation PB_AS_Documents

- (NSScriptObjectSpecifier *) objectSpecifier
{
    NSScriptObjectSpecifier * specifier=nil;
    
    specifier=[[NSPropertySpecifier alloc] initWithContainerSpecifier:[component_ objectSpecifier] key:@"documents"];
    
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
                resourcesDictionary_=[[tNode resources] retain];
            }
        }
    }

    return self;
}

+ (id) documentsWithComponent:(PB_AS_Component *) inComponent
{
    PB_AS_Documents * nDocuments;
    
    nDocuments=[[PB_AS_Documents alloc] initWithComponent:inComponent];
    
    return [nDocuments autorelease];
}

- (void) dealloc
{
    [component_ release];
    
    [resourcesDictionary_ release];
    
    [super dealloc];
}

#pragma mark -

- (PB_AS_Component *) component
{
    return [[component_ retain] autorelease];
}

#pragma mark -

// Background Image

- (id) backgroundImageOptionForKey:(NSString *) inKey
{
    NSDictionary * tOptionsDictionary;
            
    tOptionsDictionary=[resourcesDictionary_ objectForKey:RESOURCE_BACKGROUND_KEY];
        
    if (tOptionsDictionary!=nil)
    {
        return [tOptionsDictionary objectForKey:inKey];
    }
    
    return nil;
}

- (void) setBackgroundImageOption:(id) inObject forKey:(NSString *) inKey
{
    if (resourcesDictionary_!=nil)
    {
        NSMutableDictionary * nOptionsDictionary;
        
        nOptionsDictionary=[[resourcesDictionary_ objectForKey:RESOURCE_BACKGROUND_KEY] mutableCopy];
        
        if (nOptionsDictionary!=nil)
        {
            [nOptionsDictionary setObject:inObject forKey:inKey];
            
            [resourcesDictionary_ setObject:nOptionsDictionary forKey:RESOURCE_BACKGROUND_KEY];
            
            [nOptionsDictionary release];
            
            [self notifySettingsChanged];
        }
    }
}

- (NSNumber *) alignment
{
    NSNumber * tNumber;
   
    tNumber=[self backgroundImageOptionForKey:IFPkgFlagBackgroundAlignment];
     
    if (tNumber!=nil)
    {
        int tValue;
        
        tValue=[tNumber intValue];
        
        if (tValue>=0 && tValue<=8)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sAlignmentAppleCode[[tNumber intValue]]];
        }
    }
    
    return tNumber;
}

- (void) setAlignment:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<9;i++)
        {
            if (tValue==sAlignmentAppleCode[i])
            {
                [self setBackgroundImageOption:[NSNumber numberWithInt:i] forKey:IFPkgFlagBackgroundAlignment];
                
                break;
            }
        }
    }
}

- (NSNumber *) scaling
{
    NSNumber * tNumber;
   
    tNumber=[self backgroundImageOptionForKey:IFPkgFlagBackgroundScaling];
     
    if (tNumber!=nil)
    {
        int tValue;
        
        tValue=[tNumber intValue];
        
        if (tValue>=0 && tValue<=2)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sScalingAppleCode[tValue]];
        }
    }
    
    return tNumber;
}

- (void) setScaling:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<3;i++)
        {
            if (tValue==sScalingAppleCode[i])
            {
                [self setBackgroundImageOption:[NSNumber numberWithInt:i] forKey:IFPkgFlagBackgroundScaling];
                
                break;
            }
        }
    }
}

- (NSString *) path
{
    NSNumber * tNumber;
    NSString * tPath;
    
    tPath=[self backgroundImageOptionForKey:@"Path"];
    
    tNumber=[self backgroundImageOptionForKey:@"Path Type"];
    
    if (tNumber!=nil)
    {
        if ([tNumber intValue]==kRelativeToProjectPath)
        {
            tPath=[tPath stringByAbsolutingWithPath:[[component_ document] folder]];
        }
    }
    
    return tPath;
}

- (void) setPath:(NSString *) inString
{
    if ([inString isKindOfClass:[NSString class]])
    {
        NSString * tPath;
        NSNumber * tNumber;
        
        tPath=[self backgroundImageOptionForKey:@"Path"];
        
        tNumber=[self backgroundImageOptionForKey:@"Path Type"];
        
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
            
            [self setBackgroundImageOption:inString forKey:@"Path"];
        }
    }
}

- (NSNumber *) mode
{
    NSNumber * tNumber;
   
    tNumber=[self backgroundImageOptionForKey:@"Mode"];
     
    if (tNumber!=nil)
    {
        int tValue;
        
        tValue=[tNumber intValue];
        
        if (tValue>=0 && tValue<=1)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sBackgroundModeAppleCode[[tNumber intValue]]];
        }
    }
    
    return tNumber;
}

- (void) setMode:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<2;i++)
        {
            if (tValue==sBackgroundModeAppleCode[i])
            {
                [self setBackgroundImageOption:[NSNumber numberWithInt:i] forKey:@"Mode"];
                
                break;
            }
        }
    }
}

#pragma mark -

- (void) notifySettingsChanged
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[component_ treeNode],@"ProjectTree",
                                                           @"Documents",@"Modified Section",
                                                           nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentChanged"
                                                        object:[component_ document]
                                                      userInfo:tDictionary];
}

@end