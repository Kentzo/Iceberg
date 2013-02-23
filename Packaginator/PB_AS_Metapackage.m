#import "PB_AS_Metapackage.h"
#import "PB_AS_Project.h"

#import "PB_AS_Package.h"

NSString * componentsKey = @"orderedComponents";

@implementation PB_AS_Metapackage

#pragma mark -

- (id) init
{
    self=[super init];
    
    if (self)
    {
        components_=[[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

- (id) initWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode
{
    self=[super initWithDocument:inDocument andTreeNode:inNode];
    
    if (self)
    {
        PBProjectTree * tComponentsNode;
        
        tComponentsNode=(PBProjectTree *) [treeNode_ childAtIndex:3];
        
        if (tComponentsNode!=nil)
        {
            int tCapacity;
            
            tCapacity=[tComponentsNode numberOfChildren];
            
            components_=[[NSMutableArray alloc] initWithCapacity:tCapacity];
            
            if (components_!=nil && tCapacity>0)
            {
                int i;
                PBProjectTree * tProjectTree;
                
                for(i=0;i<tCapacity;i++)
                {
                    tProjectTree=(PBProjectTree *) [tComponentsNode childAtIndex:i];
                    
                    if (tProjectTree!=nil)
                    {
                        PB_AS_Component * tComponent=nil;
                        
                        switch([OBJECTNODE_DATA(tProjectTree) type])
                        {
                            case kPBPackageNode:
                                tComponent=[[PB_AS_Package alloc] initWithDocument:document_ andTreeNode:tProjectTree];
                                break;
                            case kPBMetaPackageNode:
                                tComponent=[[PB_AS_Metapackage alloc] initWithDocument:document_ andTreeNode:tProjectTree];
                                break;
                        }
        
                        [tComponent setParent:self];
                        
                        [components_ addObject:tComponent];
                        
                        [tComponent release];
                    }
                }
            }
        }
    }
    
    return self;
}

+ (id) metapackageWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode
{
    PB_AS_Metapackage * nMetapackage;
    
    nMetapackage=[[PB_AS_Metapackage alloc] initWithDocument:inDocument andTreeNode:inNode];
    
    return [nMetapackage autorelease];
}

- (void) dealloc
{
    [components_ release];
    
    [super dealloc];
}

#pragma mark -

- (NSString *) componentsLocation
{
    PBMetaPackageNode * tObjectNode;
    
    tObjectNode=(PBMetaPackageNode *) [treeNode_ nodeData];
    
    if (tObjectNode!=nil)
    {
        return [tObjectNode componentsDirectory];
    }
    
    return nil;
}

- (void) setComponentsLocation:(NSString *) inComponentsLocation
{
    if ([inComponentsLocation isKindOfClass:[NSString class]] && inComponentsLocation!=nil)
    {
    	PBMetaPackageNode * tObjectNode;
    
        tObjectNode=(PBMetaPackageNode *) [treeNode_ nodeData];
        
        if (tObjectNode!=nil)
        {
            if ([inComponentsLocation isEqualToString:[tObjectNode componentsDirectory]]==NO)
            {
                [tObjectNode setComponentsDirectory:inComponentsLocation];
                
                // Notify the document
            
                [self notifyComponentsChanged];
            }
        }
    }
}

#pragma mark -

- (NSMutableArray *) orderedComponents
{
    return [[components_ retain] autorelease];
}

- (void) setOrderedComponents:(NSMutableArray *) inArray
{
    // Operation not supported
    
    [NSException raise:NSOperationNotSupportedForKeyException format:@"Setting 'orderedComponents' key is not supported."];
}

#pragma mark -

- (id) valueWithName:(NSString *)name inPropertyWithKey:(NSString *) inKey
{
    if( [componentsKey isEqualToString: inKey] && components_!=nil && name!=nil)
    {
        int tCapacity;
    
        tCapacity=[components_ count];
        
        if (tCapacity>0)
        {
            int i;
            PB_AS_Component * tComponent;
            
            for (i=0;i<tCapacity;i++)
            {
                tComponent=[components_ objectAtIndex:i];
                
                if ([[tComponent name] isEqualToString:name])
                {
                    return tComponent;
                }
            }
        }
    }
    
    return nil;
}

- (id) valueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey
{
    if( [componentsKey isEqualToString: inKey] && components_!=nil)
    {
        int tCapacity;
    
        tCapacity=[components_ count];
        
        if (tCapacity>index)
        {
            return [components_ objectAtIndex:index];
        }
    }
    
    return nil;
}

- (void) replaceValueAtIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey withValue:(id)value
{
    if( [componentsKey isEqualToString: inKey] )
    {
        if (value!=nil)
        {
            // Check the value is a PB_AS_Package or PB_AS_Metapackage (we don't accept PB_AS_Component)
            
            if ([value isMemberOfClass:[PB_AS_Package class]] || [value isMemberOfClass:[PB_AS_Metapackage class]])
            {
                
                
                // A COMPLETER
            }
        }
    }
}

/*- (id) handleMoveScriptCommand:(NSScriptCommand *)command
{
    NSLog(@"toto");
}*/

- (void) insertValue:(id)value atIndex:(unsigned)index inPropertyWithKey:(NSString *) inKey
{
    if( [componentsKey isEqualToString: inKey] )
    {
        if (value!=nil)
        {
            PB_AS_Component * tComponent;
            
            tComponent=(PB_AS_Component *) value;
            
            // Check the value is a PB_AS_Package or PB_AS_Metapackage (we don't accept PB_AS_Component)
            
            if ([tComponent isMemberOfClass:[PB_AS_Package class]] || [tComponent isMemberOfClass:[PB_AS_Metapackage class]])
            {
                PBProjectTree * tComponentsNode;
                int tCapacity;
                
                tComponentsNode=(PBProjectTree *) [treeNode_ childAtIndex:3];
                
                tCapacity=[tComponentsNode numberOfChildren];
                
                if (tCapacity>=index)
                {
                    if ([tComponent treeNode]==nil)
                    {
                        // Brand new component
                        
                        // A COMPLETER
                    }
                    else
                    {
                        [tComponentsNode insertChild:[tComponent treeNode] atIndex:index];
                        
                        [tComponent setParent:self];
                        
                        [components_ insertObject:tComponent atIndex:index];
                    }
                    
                    // Update the User Interface
                
                    [self notifyComponentsChanged];
                    
                    [self notifyComponentHierarchyChanged];
                }
            }
        }
    }
}

- (void) removeValueAtIndex:(unsigned)index fromPropertyWithKey:(NSString *) inKey
{
    if( [componentsKey isEqualToString: inKey] )
    {
        int tCapacity;
        PBProjectTree * tComponentsNode;
    
        tComponentsNode=(PBProjectTree *) [treeNode_ childAtIndex:3];
    
        tCapacity=[components_ count];
        
        if (tCapacity>index)
        {
            [components_ removeObjectAtIndex:index];
            
            // Remove the item from the hierarchy of components
            
            [[tComponentsNode childAtIndex:index] removeFromParent];
            
            // Update the User Interface
                
            [self notifyComponentsChanged];
            
            [self notifyComponentHierarchyChanged];
        }
    }
}

- (void) insertValue:(id)value inPropertyWithKey:(NSString *) inKey
{
    NSLog(@"toto:%@", inKey);
    
    if( [componentsKey isEqualToString: inKey] )
    {
        if (value!=nil)
        {
            // Check the value is a PB_AS_Package or PB_AS_Metapackage (we don't accept PB_AS_Component)
            
            if ([value isMemberOfClass:[PB_AS_Package class]] || [value isMemberOfClass:[PB_AS_Metapackage class]])
            {
                
                
                // A COMPLETER
            }
        }
    }
}

@end
