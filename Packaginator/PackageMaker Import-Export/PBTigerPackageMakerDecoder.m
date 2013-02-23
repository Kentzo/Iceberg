#import "PBTigerPackageMakerDecoder.h"

#import "NSString+Iceberg.h"

@implementation PBTigerLocalPath

- (id) initWithCoder:(NSCoder *) inCoder
{
    path_=[[inCoder decodeObjectForKey:@"path"] retain];
    
    type_=[inCoder decodeIntForKey:@"type"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:path_ forKey:@"path"];
    
    [aCoder encodeInt:type_ forKey:@"type"];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Path: %@\nType: %d",path_,type_];
}

- (NSString *) path
{
    return [[path_ retain] autorelease];
}

- (int) type
{
    return type_;
}

- (NSString *) absolutePathWithReference:(NSString *) inPath
{
    switch(type_)
    {
        case PBTIGERLOCALPATH_ABSOLUTE:
            return [self path];
    	case PBTIGERLOCALPATH_RELATIVE:
            return [path_ stringByAbsolutingWithPath:inPath];
    }
    
    return nil;
}

@end

#pragma mark -

@implementation PBTigerResources

- (id) initWithCoder:(NSCoder *) inCoder
{
    welcome_=[[inCoder decodeObjectForKey:@"welcome"] retain];
    
    readme_=[[inCoder decodeObjectForKey:@"readme"] retain];
    
    license_=[[inCoder decodeObjectForKey:@"license"] retain];
    
    conclusion_=[[inCoder decodeObjectForKey:@"conclusion"] retain];
    
    background_=[[inCoder decodeObjectForKey:@"background"] retain];
    
    alignment_=[inCoder decodeIntForKey:@"alignment"];
    
    scaling_=[inCoder decodeIntForKey:@"scaling"];
    
    extras_=[[inCoder decodeObjectForKey:@"extras"] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (welcome_!=nil)
    {
        [aCoder encodeObject:welcome_ forKey:@"welcome"];
    }
    
    if (readme_!=nil)
    {
        [aCoder encodeObject:readme_ forKey:@"readme"];
    }
    
    if (license_!=nil)
    {
        [aCoder encodeObject:license_ forKey:@"license"];
    }
    
    if (conclusion_!=nil)
    {
        [aCoder encodeObject:conclusion_ forKey:@"conclusion"];
    }
    
    if (background_!=nil)
    {
        [aCoder encodeObject:background_ forKey:@"background"];
    }
    
    if (extras_!=nil)
    {
        [aCoder encodeObject:extras_ forKey:@"extras"];
    }
    
    [aCoder encodeInt:alignment_ forKey:@"alignment"];
    
    [aCoder encodeInt:scaling_ forKey:@"scaling"];
}

- (PBTigerLocalPath *) welcome
{
    return [[welcome_ retain] autorelease];
}

- (PBTigerLocalPath *) readme
{
    return [[readme_ retain] autorelease];
}

- (PBTigerLocalPath *) license
{
    return [[license_ retain] autorelease];
}

- (PBTigerLocalPath *) background
{
    return [[background_ retain] autorelease]; 
}

- (int) alignment
{
    return alignment_;
}

- (int) scaling
{
    return scaling_;
}

- (PBTigerLocalPath *) extras
{
    return [[extras_ retain] autorelease]; 
}

@end

#pragma mark -

@implementation PBTigerCorePackageDecoder

- (id) initWithCoder:(NSCoder *) inCoder
{
    documentFormat=[inCoder decodeIntForKey:@"documentFormat"];
    
    resources_=[[inCoder decodeObjectForKey:@"resources"] retain];
    
    infoDictionary_=[[inCoder decodeObjectForKey:@"info"] retain];
    
    descriptionDictionary_=[[inCoder decodeObjectForKey:@"desc"] retain];
    
    requirementsArray_=[[inCoder decodeObjectForKey:@"requirementsPlist"] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // A COMPLETER
}

- (void) setSourcePath:(NSString *) inPath
{
    if (sourcePath_!=inPath)
    {
        [sourcePath_ release];
        
        sourcePath_=[inPath copy];
    }
}

- (void) setDestinationPath:(NSString *) inPath
{
    if (destinationPath_!=inPath)
    {
        [destinationPath_ release];
        
        destinationPath_=[inPath copy];
    }
}

@end

#pragma mark -

@implementation PBTigerSinglePackageDecoder

- (id) initWithCoder:(NSCoder *) inCoder
{
    self=[super initWithCoder:inCoder];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

@end

@implementation PBTigerMetaPackageDecoder

- (id) initWithCoder:(NSCoder *) inCoder
{
    self=[super initWithCoder:inCoder];
    
    locationType_=[inCoder decodeIntForKey:@"locationType"];
    
    location_=[[inCoder decodeObjectForKey:@"location"] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

@end