#import "PB_AS_Component.h"

#import "PB_AS_Settings.h"
#import "PB_AS_Documents.h"
#import "PB_AS_Project.h"

#import "PB_AS_Metapackage.h"

static unsigned long sAttributeAppleCode[3]={
                                                'AUNS',
                                                'ASEL',
                                                'AREQ'
                                            };

@implementation PB_AS_Component

- (NSScriptObjectSpecifier *) objectSpecifier
{
    NSScriptObjectSpecifier * specifier=nil;
    
    if (parent_==nil && project_!=nil)
    {
        specifier=[[NSPropertySpecifier alloc] initWithContainerSpecifier:[project_ objectSpecifier] key:@"rootComponent"];
    }
    else
    {
        if (parent_!=nil)
        {
            int tIndex;
        
            tIndex=[[treeNode_ nodeParent] indexOfChild:treeNode_];
            
            if (NSNotFound!=tIndex)
            {
                NSScriptObjectSpecifier * tContainerSpecifier = [parent_ objectSpecifier];
                NSScriptClassDescription * tContainerClassDescription = (NSScriptClassDescription *)[parent_ classDescription];
                
                specifier = [[NSIndexSpecifier alloc] initWithContainerClassDescription:tContainerClassDescription
                                                                     containerSpecifier:tContainerSpecifier
                                                                                    key:@"orderedComponents"
                                                                                  index:tIndex];
            }
        }
    }
    
    return [specifier autorelease];
}

#pragma mark -

- (id) init
{
    self=[super init];
    
    if (self)
    {
    }
    
    return self;
}

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

+ (id) componentWithDocument:(PBDocument *) inDocument andTreeNode:(PBProjectTree *) inNode
{
    PB_AS_Component * nComponent;
    
    nComponent=[[PB_AS_Component alloc] initWithDocument:inDocument andTreeNode:inNode];
    
    return [nComponent autorelease];
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

- (NSString *) name
{
    PBObjectNode * tObjectNode;
    
    tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
    
    if (tObjectNode!=nil)
    {
        return [tObjectNode name];
    }
    
    return nil;
}

- (void) setName:(NSString *) inName
{
    PBObjectNode * tObjectNode;
    
    tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
    
    if (tObjectNode!=nil)
    {
        if ([tObjectNode name]!=inName)
        {
            // Change the name
            
            [tObjectNode setName:inName];
            
            // Notify the document
            
            [self notifyComponentsChanged];
            
            [self notifyComponentHierarchyChanged];
        }
    }
}

- (NSNumber *) state
{
    PBObjectNode * tObjectNode;
    
    tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
    
    if (tObjectNode!=nil)
    {
        return [NSNumber numberWithBool:[tObjectNode status]];
    }
    
    return nil;
}

- (void) setState:(NSNumber *) inState
{
    if (parent_!=nil)
    {
        PBObjectNode * tObjectNode;
    
        tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
        
        if (tObjectNode!=nil)
        {
            if ([tObjectNode status]!=[inState boolValue])
            {
                // Change the name
                
                [tObjectNode setStatus:[inState boolValue]];
                
                // Notify the document
            
                [self notifyComponentsChanged];
                
                [self notifyComponentHierarchyChanged];
            }
        }
    }
}

- (NSNumber *) attribute
{
    PBObjectNode * tObjectNode;
    NSNumber * tNumber=nil;
    
    tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
    
    if (tObjectNode!=nil)
    {
        int tValue;
        
        tValue=[tObjectNode attribute];
        
        if (tValue>=-1 && tValue<=1)
        {
            tNumber=[NSNumber numberWithUnsignedLong:sAttributeAppleCode[tValue+1]];
        }
    }
    
    return tNumber;
}

- (void) setAttribute:(NSNumber *) inNumber
{
    if (parent_!=nil && [inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<3;i++)
        {
            if (tValue==sAttributeAppleCode[i])
            {
                PBObjectNode * tObjectNode;
                
                tObjectNode=(PBObjectNode *) [treeNode_ nodeData];
                
                [tObjectNode setAttribute:i-1];
                
                [self notifyComponentsChanged];
                
                [self notifyComponentHierarchyChanged];
                
                break;
            }
        }
    }
}

- (void) setParent:(PB_AS_Component *) inParent
{
    parent_=inParent;
}

- (void) setProject:(PB_AS_Project *) inProject
{
    project_=inProject;
}

- (PBProjectTree *) treeNode
{
    return treeNode_;
}

#pragma mark -

- (PB_AS_Settings *) settings
{
    PB_AS_Settings * tSettings=nil;
    
    tSettings=[PB_AS_Settings settingsWithComponent:self];
        
    return tSettings;
}

- (PB_AS_Documents *) documents
{
    PB_AS_Documents * tDocuments=nil;
    
    tDocuments=[PB_AS_Documents documentsWithComponent:self];
        
    return tDocuments;
}

#pragma mark -

- (void) notifyComponentHierarchyChanged
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:treeNode_,@"ProjectTree",
                                                           @"Hierarchy",@"Modified Section",
                                                           nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentChanged"
                                                        object:document_
                                                      userInfo:tDictionary];
}

- (void) notifyComponentsChanged
{
    NSDictionary * tDictionary;
            
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:treeNode_,@"ProjectTree",
                                                           @"Components",@"Modified Section",
                                                           nil];
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentChanged"
                                                        object:document_
                                                      userInfo:tDictionary];
}

@end