/*
Copyright (c) 2004-2008, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "TreeNode.h"

#define FILETREE(n)			((PBFileTree*)n)
#define FILENODE_DATA(n) 		((PBFileNode *)[FILETREE((n)) nodeData])



typedef struct __FTFlags
{
#ifdef __BIG_ENDIAN__
    unsigned int		link:1;
    unsigned int		folder:1;
    unsigned int		existsOnDisk:1;
#else
    unsigned int 		existsOnDisk:1;
    unsigned int		folder:1;
    unsigned int		link:1;
#endif
} _FTFlags; 

@interface PBFileNode: NSObject
{
    int type_;
    NSString * path_;
    int pathType_;
    NSImage * icon_;
    int uid_,gid_;
    int privileges_;
    
    _FTFlags flags_;
    
    NSMutableArray * searchRules_;
}

+ (id) rootFileNode;

+ (id) baseFileNodeWithName:(NSString *) inName icon:(NSImage *) inIcon user:(int) inUID group:(int) inGID privileges:(int) inPrivileges;

+ (id) newFolderFileNodeWithName:(NSString *) inName icon:(NSImage *) inIcon user:(int) inUID group:(int) inGID privileges:(int) inPrivileges;

+ (id) fileNodeWithType:(int) inType path:(NSString *) inPath;
+ (id) fileNodeWithType:(int) inType path:(NSString *) inPath pathType:(int) inPathType;

+ (NSImage *) cachedIconForPath:(NSString *) tPath;

+ (NSImage *) createSmallIconFromImage:(NSImage *) inImage;
+ (NSImage *) createIconFromPath:(NSString *) inPath;

- (id) initWithType:(int) inType path:(NSString *) inPath pathType:(int) inPathType;

- (BOOL) link;

- (char) statType;

- (int) type;

- (NSString *) path;

- (void) setPath:(NSString *) inPath;

- (int) pathType;

- (void) setPathType:(int) inPathType;

- (NSString *) fileName;

- (NSImage *) icon;

- (int) uid;
- (void) setUid:(int) inUID;

- (int) gid;
- (void) setGid:(int) inGID;

- (int) privileges;
- (void) setPrivileges:(int) inPrivileges;

- (NSMutableArray *) searchRules;
- (void) setSearchRules:(NSArray *) inSearchRules;

+ (NSString *) privilegesStringRepresentationWithPermission:(int) inPermission mixedPermission:(int) inMixedPermission statType:(char) inType;

- (NSString *) privilegesStringRepresentationForLink;

- (NSString *) privilegesStringRepresentation;

- (void) setFolder:(BOOL) inFolder;

- (BOOL) isLeaf;

- (BOOL) isLink;

- (BOOL) fileExistenceOnDiskChanged;

- (BOOL) existsOnDisk;

@end


@interface PBFileTree : TreeNode
{
}

+ (PBFileTree *) fileTreeWithDictionary:(NSDictionary *) inDictionary projectPath:(NSString *) inProjectPath;

+ (PBFileTree *) fileNodeWithDictionary:(NSDictionary *) inDictionary projectPath:(NSString *) inProjectPath;

/*+ (PBFileTree *) defaultFileTree;*/

- (PBFileTree *) fileTreeAtPath:(NSString *) inPath;

- (NSString *) filePath;

- (NSDictionary *) dictionaryWithProjectAtPath:(NSString *) inProjectPath;

- (BOOL) containsTreeWithName:(NSString *) inName;

- (void) insertSortedChildReverse:(PBFileTree *) inChild;

- (void) insertSortedChild:(PBFileTree *) inChild;

- (void) insertSortedChildren:(NSArray *) inChildren;

- (BOOL) expandAll:(BOOL) inKeepOwnerAndGroup withProjectPath:(NSString *) inProjectPath;

- (void) expand:(BOOL) inKeepOwnerAndGroup;
- (void) expandOneLevel:(BOOL) inKeepOwnerAndGroup;
- (void) contract;

- (BOOL) hasRealChildren;

+ (NSString *) uniqueNameWithParentFileTree:(PBFileTree *) inParentTree;

@end
