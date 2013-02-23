#import "PB_AS_Project.h"
#import "NSDocument+Iceberg.h"
#import "NSString+Iceberg.h"
#import "PBDocument.h"

#import "PB_AS_Component.h"
#import "PB_AS_Package.h"
#import "PB_AS_Metapackage.h"

@implementation PB_AS_Project

- (NSScriptObjectSpecifier *) objectSpecifier
{
    NSScriptObjectSpecifier * specifier=nil;
    
    specifier=[[NSPropertySpecifier alloc] initWithContainerSpecifier:[document_ objectSpecifier] key:@"project"];
    
    return [specifier autorelease];
}

#pragma mark -

- (id) initWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode
{
    self=[super init];
    
    if (self)
    {
        document_=[inDocument retain];
        
        treeNode_=[inNode retain];
    }
    
    return self;
}

+ (id) projectWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode
{
    PB_AS_Project * nProject;
    
    nProject=[[PB_AS_Project alloc] initWithDocument:inDocument andTreeNode:inNode];
    
    return [nProject autorelease];
}

- (void) dealloc
{
    [document_ release];
    
    [treeNode_ release];
    
    [super dealloc];
}

#pragma mark -

- (PBDocument *) document
{
    return document_;
}

- (PB_AS_Component *) rootComponent
{
    PB_AS_Component * tComponent=nil;
    
    if (treeNode_!=nil)
    {
        PBProjectTree * tProjectTree;
    
        tProjectTree=(PBProjectTree *) [treeNode_ childAtIndex:0];
        
        switch([OBJECTNODE_DATA(tProjectTree) type])
        {
            case kPBPackageNode:
                tComponent=[[PB_AS_Package alloc] initWithDocument:document_ andTreeNode:tProjectTree];
                break;
            case kPBMetaPackageNode:
                tComponent=[[PB_AS_Metapackage alloc] initWithDocument:document_ andTreeNode:tProjectTree];
                break;
        }
        
        [tComponent setProject:self];
    }
    
    return tComponent;
}

#pragma mark -

- (id) projectOptionForKey:(NSString *) inKey
{
    PBProjectNode * tProjectNode;
    
    tProjectNode=PROJECTNODE_DATA(treeNode_);
    
    if (tProjectNode!=nil)
    {
        NSDictionary * tSettings;
        
        tSettings=[tProjectNode settings];
    
	return [tSettings objectForKey:inKey];
    }
    
    return nil;
}

- (void) setProjectOption:(id) inOption forKey:(NSString *) inKey
{
    PBProjectNode * tProjectNode;
    
    tProjectNode=PROJECTNODE_DATA(treeNode_);
    
    if (tProjectNode!=nil)
    {
        NSMutableDictionary * tSettings;
        
        tSettings=[tProjectNode settings];
    
	[tSettings setObject:inOption forKey:inKey];
        
        // Update the UI if needed
        
        [self notifySettingsChanged];
    }
}

- (NSString *) buildLocation
{
    NSNumber * tNumber;
    NSString * tPath;
    
    tPath=[self projectOptionForKey:@"Build Path"];
    
    tNumber=[self projectOptionForKey:@"Build Path Type"];
    
    if (tNumber!=nil)
    {
        if ([tNumber intValue]==kRelativeToProjectPath)
        {
            tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
        }
    }
    
    return tPath;
}

- (void) setBuildLocation:(NSString *) aString
{
    if ([aString isKindOfClass:[NSString class]])
    {
        NSString * tPath;
        NSNumber * tNumber;
        
        tPath=[self projectOptionForKey:@"Build Path"];
        
        tNumber=[self projectOptionForKey:@"Build Path Type"];
        
        if (tNumber!=nil)
        {
            if ([tNumber intValue]==kRelativeToProjectPath)
            {
                tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
            }
        }
        
        if ([tPath isEqualToString:aString]==NO)
        {
            if (tNumber!=nil)
            {
                if ([tNumber intValue]==kRelativeToProjectPath)
                {
                    aString=[aString stringByRelativizingToPath:[document_ folder]];
                }
            }
            
            [self setProjectOption:aString forKey:@"Build Path"];
        }
    }
}

- (NSNumber *) removeDSStore
{
    return [self projectOptionForKey:@"Remove .DS_Store"];
}

- (void) setRemoveDSStore:(NSNumber *) aNumber
{
    NSNumber * tNumber;
    
    tNumber=[self projectOptionForKey:@"Remove .DS_Store"];
    
    if ([tNumber isEqualToNumber:aNumber]==NO)
    {
        [self setProjectOption:aNumber forKey:@"Remove .DS_Store"];
    }
}

- (NSNumber *) removePBDevelopement
{
    return [self projectOptionForKey:@"Remove .pbdevelopment"];
}

- (void) setRemovePBDevelopement:(NSNumber *) aNumber
{
    NSNumber * tNumber;
    
    tNumber=[self projectOptionForKey:@"Remove .pbdevelopment"];
    
    if ([tNumber isEqualToNumber:aNumber]==NO)
    {
        [self setProjectOption:aNumber forKey:@"Remove .pbdevelopment"];
    }
}

- (NSNumber *) removeCVSFolder
{
    return [self projectOptionForKey:@"Remove CVS"];
}

- (void) setRemoveCVSFolder:(NSNumber *) aNumber
{
    NSNumber * tNumber;
    
    tNumber=[self projectOptionForKey:@"Remove CVS"];
    
    if ([tNumber isEqualToNumber:aNumber]==NO)
    {
        [self setProjectOption:aNumber forKey:@"Remove CVS"];
    }
}

- (NSNumber *) buildPumaCompatible
{
    return [self projectOptionForKey:@"10.1 Compatibility"];
}

- (void) setBuildPumaCompatible:(NSNumber *) aNumber
{
    NSNumber * tNumber;
    
    tNumber=[self projectOptionForKey:@"10.1 Compatibility"];
    
    if ([tNumber isEqualToNumber:aNumber]==NO)
    {
        [self setProjectOption:aNumber forKey:@"10.1 Compatibility"];
    }
}

- (NSString *) comments
{
    return [self projectOptionForKey:@"Comment"];
}

- (void) setComments:(NSString *) aString
{
    NSString * tString;
    
    tString=[self projectOptionForKey:@"Comment"];
    
    if ([tString isEqualToString:aString]==NO)
    {
        [self setProjectOption:aString forKey:@"Comment"];
    }
}

#pragma mark -

- (void) notifySettingsChanged
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:treeNode_,@"ProjectTree",
                                                           @"Project",@"Modified Section",
                                                           nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentChanged"
                                                        object:document_
                                                      userInfo:tDictionary];
}

@end
