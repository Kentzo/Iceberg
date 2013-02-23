/*
Copyright (c) 2004-2006, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "TreeNode.h"
#import "PBSharedConst.h"

#define NODE(n)					((PBProjectTree*)n)
#define NODE_DATA(n) 			((PBNode *)[NODE((n)) nodeData])
#define PROJECTNODE_DATA(n) 	((PBProjectNode *)[NODE((n)) nodeData])
#define OBJECTNODE_DATA(n) 	((PBObjectNode *)[NODE((n)) nodeData])

#define PLUGINS_DEFAULT_COUNT		7

#define PBPROJECTTREE_SETTINGS_INDEX	0
#define PBPROJECTTREE_DOCUMENTS_INDEX	1
#define PBPROJECTTREE_SCRIPTS_INDEX		2
#define PBPROJECTTREE_PLUGINS_INDEX		3
#define PBPROJECTTREE_FILES_INDEX		4
#define PBPROJECTTREE_COMPONENTS_INDEX	4

extern NSString * const RESOURCE_BACKGROUND_KEY;
extern NSString * const RESOURCE_WELCOME_KEY;
extern NSString * const RESOURCE_README_KEY;
extern NSString * const RESOURCE_LICENSE_KEY;

extern NSString * const SCRIPT_REQUIREMENTS_KEY;
extern NSString * const SCRIPT_INSTALLATION_KEY;
extern NSString * const SCRIPT_ADDITIONAL_KEY;

extern NSString * const PLUGINS_LIST_KEY;

@interface PBNode: NSObject
{
    NSString * name_;
    int type_;
    int status_;
}

+ (id) nodeWithName:(NSString *) inName type: (int) inType status:(int) inStatus;

- (id) initWithName:(NSString *) inName type: (int) inType status:(int) inStatus;

+ (id) rootNode;

- (BOOL) isLeaf;

- (NSString *) name;

- (void) setName:(NSString *) inName;

- (int) type;

- (int) status;

- (void) setStatus:(int) inStatus;

@end

@interface PBObjectNode: PBNode
{
    int attribute_;
    
    NSMutableDictionary *	settings_;
    NSMutableDictionary * 	resources_;
    NSMutableDictionary *	scripts_;
	NSMutableDictionary *	plugins_;
}

+ (NSDictionary *) defaultWelcomeDictionary;
+ (NSDictionary *) defaultReadMeDictionary;
+ (NSDictionary *) defaultLicenseDictionary;

+ (NSDictionary *) defaultImageDictionary;

+ (NSDictionary *) defaultScriptsDictionary;

+ (NSDictionary *) defaultPluginsDictionary;

+ (NSMutableDictionary *) defaultRequirementMutableDictionaryWithLabel:(NSString *) inLabel;

+ (NSDictionary *) defaultDescriptionDictionaryWithName:(NSString *) inName;

- (int) attribute;
- (void) setAttribute:(int) inAttribute;

- (NSMutableDictionary *) settings;

- (void) setSettings:(NSDictionary *) inSettings;

- (NSMutableDictionary *) resources;

- (void) setResources:(NSDictionary *) inResources;

- (NSMutableDictionary *) scripts;

- (void) setScripts:(NSDictionary *) inScripts;

- (NSMutableDictionary *) plugins;

- (void) setPlugins:(NSDictionary *) inPlugins;

@end

@interface PBMetaPackageNode: PBObjectNode
{
    NSString * componentsDirectory_;
}

+ (id) metaPackageNodeWithName:(NSString *) inName status:(int) inStatus settings:(NSDictionary *) inSettings resources:(NSDictionary *) inResources scripts:(NSDictionary *) inScripts plugins:(NSDictionary *) inPlugins;



- (NSString *) componentsDirectory;

- (void) setComponentsDirectory:(NSString *) inDirectory;

@end

@interface PBPackageNode: PBObjectNode
{
    NSMutableDictionary * files_;
}

+ (id) packageNodeWithName:(NSString *) inName status:(int) inStatus settings:(NSDictionary *) inSettings  resources:(NSDictionary *) inResources scripts:(NSDictionary *) inScripts plugins:(NSDictionary *) inPlugins files:(NSDictionary *) inFiles;

- (NSMutableDictionary *) files;

- (void) setFiles:(NSDictionary *) inFiles;

- (BOOL) isRequired;

- (BOOL) isImported;

@end

@interface PBProjectNode: PBNode
{
    NSMutableDictionary * 	settings_;
}

+ (id) projectNodeWithSettings:(NSDictionary *) inSettings;

- (NSMutableDictionary *) settings;

@end

@interface PBProjectTree : TreeNode
{

}

+ (NSString *) uniqueNameWithComponentTree:(PBProjectTree *) inComponentTree;

+ (id) projectTree;

+ (id) projectTreeWithContentsOfFile:(NSString *) inFilePath  andKeywordDictionary:(NSDictionary *) inKWDictionary;
+ (id) projectTreeWithContentsOfURL:(NSURL *) inURL andKeywordDictionary:(NSDictionary *) inKWDictionary;

+ (id) projectTreeWithDictionary:(NSDictionary *) inDictionary;

/*+ (void) setResolveKeyWords:(BOOL) aBool;

+ (BOOL) isResolvingKeyWords;*/

- (NSDictionary *) dictionary;

- (BOOL) writeToFile:(NSString *) inFilePath atomically:(BOOL) flag;
- (BOOL) writeToURL:(NSURL *) inURL atomically:(BOOL) flag;

+ (id) resolveHierarchy:(id) inHierarchy withKeywordDictionary:(NSDictionary *) inKWDictionary;

+ (NSMutableArray *) resolveArray:(NSArray *) inArray withKeywordDictionary:(NSDictionary *) inKWDictionary;

+ (NSMutableDictionary *) resolveDictionary:(NSDictionary *) inDictionary withKeywordDictionary:(NSDictionary *) inKWDictionary;

@end
