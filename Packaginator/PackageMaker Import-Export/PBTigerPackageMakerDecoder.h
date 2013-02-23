#import <Foundation/Foundation.h>

#define PBTIGERLOCALPATH_ABSOLUTE	0
#define PBTIGERLOCALPATH_RELATIVE	1

@interface PBTigerLocalPath : NSObject <NSCoding>
{
    NSString * path_;
    int type_;
}

- (NSString *) path;
- (int) type;
- (NSString *) absolutePathWithReference:(NSString *) inPath;

@end

@interface PBTigerResources : NSObject <NSCoding>
{
    PBTigerLocalPath * welcome_;
    
    PBTigerLocalPath * readme_;
    
    PBTigerLocalPath * license_;
    
    PBTigerLocalPath * conclusion_;	// Distribution only
    
    PBTigerLocalPath * background_;
    
    int alignment_;
    
    int scaling_;
    
    PBTigerLocalPath * extras_;
}

- (int) alignment;

- (int) scaling;

- (PBTigerLocalPath *) welcome;

- (PBTigerLocalPath *) readme;

- (PBTigerLocalPath *) license;

- (PBTigerLocalPath *) background;

- (PBTigerLocalPath *) extras;

@end

@interface PBTigerCorePackageDecoder: NSObject <NSCoding>
{
    NSString * sourcePath_;
    NSString * destinationPath_;
    
    int documentFormat;
    
    PBTigerResources * resources_;
    
    NSMutableDictionary * infoDictionary_;
    
    NSMutableDictionary * descriptionDictionary_;
    
    NSMutableArray * requirementsArray_;
}

- (void) setSourcePath:(NSString *) inPath;
- (void) setDestinationPath:(NSString *) inPath;

@end

@interface PBTigerSinglePackageDecoder: PBTigerCorePackageDecoder <NSCoding>
{
}

@end

@interface PBTigerMetaPackageDecoder: PBTigerCorePackageDecoder <NSCoding>
{
    int locationType_;
    
    NSString * location_;
}

@end