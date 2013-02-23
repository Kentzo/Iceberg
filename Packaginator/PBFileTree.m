/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBFileTree.h"
#include <sys/stat.h>

#import "PBSharedConst.h"
#import "NSString+Iceberg.h"

@implementation PBFileNode

+ (NSImage *) cachedIconForPath:(NSString *) inPath
{
    static NSMutableDictionary * sCachedIcons=nil;
    static NSFileManager * tFileManager=nil;
    static NSWorkspace * tWorkspace=nil;
    NSString * tPathExtension;
    NSImage * tIcon=nil;
    int tLength;
    static NSSize tSize;
    static NSImage * folderIcon=nil;
    
    if (sCachedIcons==nil)
    {
        NSArray * tArray;
        int i,tCount;
        NSString * tType;
        
        tSize=NSMakeSize(16,16);
        
        sCachedIcons=[[NSMutableDictionary alloc] initWithCapacity:20];
        
        tFileManager=[NSFileManager defaultManager];
        
        tWorkspace=[NSWorkspace sharedWorkspace];
        
        // Application
        
        tIcon=[NSImage imageNamed:@"Application"];
        [sCachedIcons setObject:tIcon forKey:@"app"];
        
        tIcon=[NSImage imageNamed:@"Folder"];
        [sCachedIcons setObject:tIcon forKey:@"lproj"];
        
        tIcon=[NSImage imageNamed:@"Folder"];
        [sCachedIcons setObject:tIcon forKey:@"framework"];
        
        tIcon=[NSImage imageNamed:@"package16"];
        [sCachedIcons setObject:tIcon forKey:@"pkg"];
        
        tIcon=[NSImage imageNamed:@"metapackage16"];
        [sCachedIcons setObject:tIcon forKey:@"mpkg"];
        
        tArray=[NSArray arrayWithObjects:@"nib",@"tiff",@"tif",@"icns",@"rtd",@"rtfd",@"strings",@"plist",nil];
        
        tCount=[tArray count];
        
        for(i=0;i<tCount;i++)
        {
            tType=[tArray objectAtIndex:i];
            
            tIcon=[tWorkspace iconForFileType:tType];
            
            if (tIcon!=nil)
            {
                [tIcon setSize:tSize];
                
                [sCachedIcons setObject:tIcon forKey:tType];
            }
        }
        
        tIcon=nil;
    }
    
    tPathExtension=[[[inPath lastPathComponent] pathExtension] lowercaseString];
    
    tLength=[tPathExtension length];
    
    if (tLength>0)
    {
        tIcon=[sCachedIcons objectForKey:tPathExtension];
    }
    
    if (tIcon==nil)
    {
        if (tLength>0)
        {
            NSDictionary * tDictionary;
        
            tDictionary=[tFileManager fileAttributesAtPath:inPath traverseLink:NO];
            
            if ([[tDictionary objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]==YES)
            {
                if (folderIcon==nil)
                {
                    folderIcon=[[NSImage imageNamed:@"Folder"] retain];
                    
                    [folderIcon setSize:tSize];
                }
                
                tIcon=folderIcon;
            }
            else
            {
                tIcon=[tWorkspace iconForFileType:tPathExtension];
            }
        }
        
        if (tIcon!=nil)
        {
            [tIcon setSize:tSize];
                
            [sCachedIcons setObject:tIcon forKey:tPathExtension];
        }
        else
    	{
            NSDictionary * tDictionary;
        
            tDictionary=[tFileManager fileAttributesAtPath:inPath traverseLink:NO];
            
            if ([[tDictionary objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]==YES)
            {
                if (folderIcon==nil)
                {
                    folderIcon=[[NSImage imageNamed:@"Folder"] retain];
                    
                    [folderIcon setSize:tSize];
                }
                
                tIcon=folderIcon;
            }
            else
            {
                if ([[tDictionary objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink]==YES)
                {
                    tIcon=[tWorkspace iconForFile:inPath];
                
                    if (tIcon==nil)
                    {
                        NSLog(@"Oh Oh");
                    }
                    else
                    {
                        static NSImage *arrowImage=nil;
                        NSImage *iconWithArrow = [[[NSImage alloc] initWithSize: tSize] autorelease];
                        
                        if (arrowImage==nil)
                        {
                            arrowImage = [NSImage imageNamed: @"FSIconImage-LinkArrow"];
                            
                            [arrowImage setScalesWhenResized: YES];
                            [arrowImage setSize: tSize];
                        }
                        
                        [tIcon setSize:tSize];
                        
                        [iconWithArrow lockFocus];
                        [tIcon compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
                        [arrowImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
                        [iconWithArrow unlockFocus];
                        
                        tIcon=iconWithArrow;
                    }
                }
                else
                {
                    tIcon=[tWorkspace iconForFile:inPath];
                
                    if (tIcon==nil)
                    {
                        NSLog(@"Oh Oh");
                    }
                    else
                    {
                        [tIcon setSize:tSize];
                    }
                }
            }
        }
    }
    
    return tIcon;
}

+ (id) rootFileNode
{
    PBFileNode * nFileNode;
    
    nFileNode=[PBFileNode alloc];
    
    if (nFileNode!=nil)
    {
        nFileNode->type_=kFileRootNode;
        
        nFileNode->flags_.folder=YES;
        nFileNode->flags_.link=NO;
    }
    
    return nFileNode;
}

+ (id) baseFileNodeWithName:(NSString *) inName icon:(NSImage *) inIcon user:(int) inUID group:(int) inGID privileges:(int) inPrivileges
{
    PBFileNode * nFileNode;
    
    nFileNode=[PBFileNode alloc];
    
    if (nFileNode!=nil)
    {
        nFileNode->type_=kBaseNode;
        
        if (inName!=nil)
        {
            nFileNode->path_=[inName copy];
        }
        
        nFileNode->icon_=inIcon;
        
        nFileNode->uid_=inUID;
        
        nFileNode->gid_=inGID;
        
        nFileNode->privileges_=inPrivileges;
        
        nFileNode->pathType_=kName;
        
        nFileNode->flags_.folder=YES;
        
        nFileNode->flags_.link=NO;
    }
    
    return nFileNode;
}

+ (id) newFolderFileNodeWithName:(NSString *) inName icon:(NSImage *) inIcon user:(int) inUID group:(int) inGID privileges:(int) inPrivileges
{
    PBFileNode * nFileNode;
    
    nFileNode=[PBFileNode baseFileNodeWithName:inName
                                          icon:inIcon
                                          user:inUID
                                         group:inGID
                                    privileges:inPrivileges];
    
    if (nFileNode!=nil)
    {
        nFileNode->type_=kNewFolderNode;
    }
    
    return nFileNode;
}

+ (id) fileNodeWithType:(int) inType path:(NSString *) inPath
{
    return [[[PBFileNode alloc] initWithType:inType path:inPath pathType:kGlobalPath] autorelease];
}

+ (id) fileNodeWithType:(int) inType path:(NSString *) inPath pathType:(int) inPathType
{
    return [[[PBFileNode alloc] initWithType:inType path:inPath pathType:inPathType] autorelease];
}

+ (NSImage *) createSmallIconFromImage:(NSImage *) inImage
{
    NSImage * nImage=nil;
    NSSize tFileIconSize;
        
    tFileIconSize=[inImage size];
    
    nImage=[[NSImage alloc] initWithSize:NSMakeSize(16,16)];
    
    [nImage lockFocus];
    
    [inImage drawInRect:NSMakeRect(0,0,16,16)
                    fromRect:NSMakeRect(0,0,tFileIconSize.width,tFileIconSize.height)
                operation:NSCompositeCopy
                    fraction:1.0];
    
    [nImage unlockFocus];
    
    return nImage;
}

+ (NSImage *) createIconFromPath:(NSString *) inPath
{
    NSImage * nImage=nil;
    NSImage * tFileIcon;
    
    tFileIcon=[PBFileNode cachedIconForPath:inPath];
    
    if (tFileIcon!=nil)
    {
        NSSize tFileIconSize;
        
        tFileIconSize=[tFileIcon size];
        
        nImage=[[NSImage alloc] initWithSize:NSMakeSize(16,16)];
        
        [nImage lockFocus];
        
        [tFileIcon drawInRect:NSMakeRect(0,0,16,16)
                     fromRect:NSMakeRect(0,0,tFileIconSize.width,tFileIconSize.height)
                    operation:NSCompositeCopy
                     fraction:1.0];
        
        [nImage unlockFocus];
    }
    
    return nImage;
}

- (id) initWithType:(int) inType path:(NSString *) inPath pathType:(int) inPathType
{
    self=[super init];
    
    if (self!=NULL)
    {
        type_=inType;
        
        pathType_=inPathType;
        
        [self setPath:inPath];
        
        if (pathType_==kGlobalPath)
        {
            icon_=nil;
        }
        
        if (type_==kRealItemNode)
        {
            flags_.link=[self isLink];
        }
        
        flags_.folder=NO;
        flags_.existsOnDisk=YES;
    }
    
    return self;
}

- (BOOL) link
{
    return flags_.link;
}

- (int) type
{
    return type_;
}

- (NSString *) path
{
    return [[path_ retain] autorelease];
}

- (void) setPath:(NSString *) inPath
{
    if (path_!=inPath)
    {
        [path_ release];
        
        path_=[inPath copy];
    }
}

- (NSString *) fileName
{
    switch(type_)
    {
        case kBaseNode:
        case kNewFolderNode:
            return [[path_ retain] autorelease];
            break;
        case kRealItemNode:
            return [path_ lastPathComponent];
            break;
    }
    
    return nil;
}

- (int) pathType
{
    return pathType_;
}

- (void) setPathType:(int) inPathType
{
    pathType_=inPathType;
}

- (NSImage *) icon
{
    if (icon_==nil && kRealItemNode==type_)
    {
        icon_=[[PBFileNode cachedIconForPath:path_] retain];
    }
    
    return [[icon_ retain] autorelease];
}

- (int) uid
{
    return uid_;
}

- (void) setUid:(int) inUID
{
    uid_=inUID;
}

- (int) gid
{
    return gid_;
}

- (void) setGid:(int) inGID
{
    gid_=inGID;
}

- (int) privileges
{
    return privileges_;
}

- (void) setPrivileges:(int) inPrivileges
{
    privileges_=inPrivileges;
}

- (NSMutableArray *) searchRules
{
    return [[searchRules_ retain] autorelease];
}

- (void) setSearchRules:(NSArray *) inSearchRules
{
    if (searchRules_!=inSearchRules)
    {
        [searchRules_ release];
    
        searchRules_=[inSearchRules mutableCopy];
    }
}

#pragma mark -

- (BOOL) isLink
{
    struct stat tStat;
        
    if (lstat([path_ fileSystemRepresentation], &tStat)==0)
    {
        if ((tStat.st_mode & S_IFMT)==S_IFLNK)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSString *) privilegesStringRepresentationWithPermission:(int) inPermission mixedPermission:(int) inMixedPermission statType:(char) inType
{
    char ownerExecute,groupExecute,otherExecute;
    char tMixedChar='?';
    
    if (inType==0)
    {
        inType=tMixedChar;
    }
    
    if ((inMixedPermission & S_ISUID)==S_ISUID || (inMixedPermission & S_IXUSR)==S_IXUSR)
    {
        ownerExecute=tMixedChar;
    }
    else
    {
        if ((inPermission & S_ISUID)==S_ISUID)
        {
            ownerExecute=((inPermission & S_IXUSR)==S_IXUSR) ? 's' : 'S';
        }
        else
        {
            ownerExecute=((inPermission & S_IXUSR)==S_IXUSR) ? 'x' : '-';
        }
    }
    
    if ((inMixedPermission & S_ISGID)==S_ISGID || (inMixedPermission & S_IXGRP)==S_IXGRP)
    {
        groupExecute=tMixedChar;
    }
    else
    {
        if ((inPermission & S_ISGID)==S_ISGID)
        {
            groupExecute=((inPermission & S_IXGRP)==S_IXGRP) ? 's' : 'S';
        }
        else
        {
            groupExecute=((inPermission & S_IXGRP)==S_IXGRP) ? 'x' : '-';
        }
    }
    
    if ((inMixedPermission & S_ISTXT)==S_ISTXT || (inMixedPermission & S_IXOTH)==S_IXOTH)
    {
        otherExecute=tMixedChar;
    }
    else
    {
        if ((inPermission & S_ISTXT)==S_ISTXT)
        {
            otherExecute=((inPermission & S_IXOTH)==S_IXOTH) ? 't' : 'T';
        }
        else
        {
            otherExecute=((inPermission & S_IXOTH)==S_IXOTH) ? 'x' : '-';
        }
    }
    
    return [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c",inType,
                                                            ((inMixedPermission & S_IRUSR)==S_IRUSR) ? tMixedChar : (((inPermission & S_IRUSR)==S_IRUSR) ? 'r' : '-'),
                                                            ((inMixedPermission & S_IWUSR)==S_IWUSR) ? tMixedChar : (((inPermission & S_IWUSR)==S_IWUSR) ? 'w' : '-'),
                                                            ownerExecute,
                                                            ((inMixedPermission & S_IRGRP)==S_IRGRP) ? tMixedChar : (((inPermission & S_IRGRP)==S_IRGRP) ? 'r' : '-'),
                                                            ((inMixedPermission & S_IWGRP)==S_IWGRP) ? tMixedChar : (((inPermission & S_IWGRP)==S_IWGRP) ? 'w' : '-'),
                                                            groupExecute,
                                                            ((inMixedPermission & S_IROTH)==S_IROTH) ? tMixedChar : (((inPermission & S_IROTH)==S_IROTH) ? 'r' : '-'),
                                                            ((inMixedPermission & S_IWOTH)==S_IWOTH) ? tMixedChar : (((inPermission & S_IWOTH)==S_IWOTH) ? 'w' : '-'),
                                                            otherExecute];
}

- (NSString *) privilegesStringRepresentationForLink
{
    char ownerExecute,groupExecute,otherExecute;

    if ((privileges_ & S_ISUID)==S_ISUID)
    {
        ownerExecute=((privileges_ & S_IXUSR)==S_IXUSR) ? 's' : 'S';
    }
    else
    {
        ownerExecute=((privileges_ & S_IXUSR)==S_IXUSR) ? 'x' : '-';
    }
    
    if ((privileges_ & S_ISGID)==S_ISGID)
    {
        groupExecute=((privileges_ & S_IXGRP)==S_IXGRP) ? 's' : 'S';
    }
    else
    {
        groupExecute=((privileges_ & S_IXGRP)==S_IXGRP) ? 'x' : '-';
    }
    
    if ((privileges_ & S_ISTXT)==S_ISTXT)
    {
        otherExecute=((privileges_ & S_IXOTH)==S_IXOTH) ? 't' : 'T';
    }
    else
    {
        otherExecute=((privileges_ & S_IXOTH)==S_IXOTH) ? 'x' : '-';
    }
    
    return [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c", 'l',
                                                               ((privileges_ & S_IRUSR)==S_IRUSR) ? 'r' : '-',
                                                               ((privileges_ & S_IWUSR)==S_IWUSR) ? 'w' : '-',
                                                               ownerExecute,
                                                               ((privileges_ & S_IRGRP)==S_IRGRP) ? 'r' : '-',
                                                               ((privileges_ & S_IWGRP)==S_IWGRP) ? 'w' : '-',
                                                               groupExecute,
                                                               ((privileges_ & S_IROTH)==S_IROTH) ? 'r' : '-',
                                                               ((privileges_ & S_IWOTH)==S_IWOTH) ? 'w' : '-',
                                                               otherExecute];
}

- (char) statType
{
    char tStatType='d';
    
    if (kRealItemNode==type_)
    {
        struct stat tStat;
        
        if (lstat([path_ fileSystemRepresentation], &tStat)==0)
        {
            switch((tStat.st_mode & S_IFMT))
            {
                case S_IFDIR:
                    tStatType='d';
                    break;
                case S_IFREG:
                    tStatType='-';
                    break;
                case S_IFLNK:
                    tStatType='l';
                    break;
                case S_IFBLK:
                    tStatType='b';
                    break;
                case S_IFCHR:
                    tStatType='c';
                    break;
                case S_IFSOCK:
                    tStatType='s';
                    break;
                default:
                    tStatType='-';
                    break;
            }
        }
    }
    
    return tStatType;
}

- (NSString *) privilegesStringRepresentation
{
    char tFolder='d';
    char ownerExecute,groupExecute,otherExecute;
    
    if (kRealItemNode==type_)
    {
        struct stat tStat;
        
        flags_.link=NO;
        
        if (lstat([path_ fileSystemRepresentation], &tStat)==0)
        {
            switch((tStat.st_mode & S_IFMT))
            {
                case S_IFDIR:
                    tFolder='d';
                    break;
                case S_IFREG:
                    tFolder='-';
                    break;
                case S_IFLNK:
                    flags_.link=YES;
                    tFolder='l';
                    break;
                case S_IFBLK:
                    tFolder='b';
                    break;
                case S_IFCHR:
                    tFolder='c';
                    break;
                case S_IFSOCK:
                    tFolder='s';
                    break;
                default:
                    tFolder='-';
                    break;
            }
        }
    }

    if ((privileges_ & S_ISUID)==S_ISUID)
    {
        ownerExecute=((privileges_ & S_IXUSR)==S_IXUSR) ? 's' : 'S';
    }
    else
    {
        ownerExecute=((privileges_ & S_IXUSR)==S_IXUSR) ? 'x' : '-';
    }
    
    if ((privileges_ & S_ISGID)==S_ISGID)
    {
        groupExecute=((privileges_ & S_IXGRP)==S_IXGRP) ? 's' : 'S';
    }
    else
    {
        groupExecute=((privileges_ & S_IXGRP)==S_IXGRP) ? 'x' : '-';
    }
    
    if ((privileges_ & S_ISTXT)==S_ISTXT)
    {
        otherExecute=((privileges_ & S_IXOTH)==S_IXOTH) ? 't' : 'T';
    }
    else
    {
        otherExecute=((privileges_ & S_IXOTH)==S_IXOTH) ? 'x' : '-';
    }
    
    return [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c", tFolder,
                                                               ((privileges_ & S_IRUSR)==S_IRUSR) ? 'r' : '-',
                                                               ((privileges_ & S_IWUSR)==S_IWUSR) ? 'w' : '-',
                                                               ownerExecute,
                                                               ((privileges_ & S_IRGRP)==S_IRGRP) ? 'r' : '-',
                                                               ((privileges_ & S_IWGRP)==S_IWGRP) ? 'w' : '-',
                                                               groupExecute,
                                                               ((privileges_ & S_IROTH)==S_IROTH) ? 'r' : '-',
                                                               ((privileges_ & S_IWOTH)==S_IWOTH) ? 'w' : '-',
                                                               otherExecute];
}

- (void) setFolder:(BOOL) inFolder
{
    flags_.folder=inFolder;
}

/*- (void) setExpanded:(BOOL) inExpanded
{
    if (type_==kRealItemNode)
    {
        flags_.expanded=inExpanded;
        flags_.folder=inExpanded;
    }
}*/

- (BOOL) isLeaf
{
    return !flags_.folder;
}

- (BOOL) fileExistenceOnDiskChanged
{
    if (type_==kRealItemNode)
    {
        struct stat tStat;
		BOOL exists;
        
        exists=(lstat([path_ fileSystemRepresentation], &tStat)==0);
        
        if (exists!=flags_.existsOnDisk)
        {
            flags_.existsOnDisk=exists;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) existsOnDisk
{
    if (type_==kRealItemNode)
    {
        return flags_.existsOnDisk;
    }
    
    return YES;
}

@end

@implementation PBFileTree

+ (PBFileTree *) fileNodeWithDictionary:(NSDictionary *) inDictionary projectPath:(NSString *) inProjectPath
{
    PBFileTree * nFileTree=nil;
    NSString * tString;
    NSNumber * tNumber;
    NSArray * tArray;
    NSString * tPath;
    int tUID,tGID;
    int tPrivileges;
    int tType;
    int tPathType;
    
    if (inDictionary!=nil)
    {
        id tFileNode;
        
        tNumber=[inDictionary objectForKey:@"Type"];
        
        if (tNumber!=nil)
        {
            tType=[tNumber intValue];
        }
        else
        {
            return nil;
        }
        
        // Path
        
        tString=[inDictionary objectForKey:@"Path"];
        
        if (tString!=nil)
        {
            tPath=tString;
        }
        else
        {
            tPath=@"";
        }
        
        // Path type
        
        tNumber=[inDictionary objectForKey:@"Path Type"];
        
        if (tNumber!=nil)
        {
            tPathType=[tNumber intValue];
        }
        else
        {
            return nil;
        }
        
        // User ID
        
        tNumber=[inDictionary objectForKey:@"UID"];
        
        if (tNumber!=nil)
        {
            tUID=[tNumber intValue];
        }
        else
        {
            tUID=0;
        }
        
        // GID
        
        tNumber=[inDictionary objectForKey:@"GID"];
        
        if (tNumber!=nil)
        {
            tGID=[tNumber intValue];
        }
        else
        {
            tGID=80;
        }
        
        // Privileges
        
        tNumber=[inDictionary objectForKey:@"Privileges"];
        
        if (tNumber!=nil)
        {
            tPrivileges=[tNumber intValue];
        }
        else
        {
            tPrivileges=0775;
        }
        
        switch (tType)
        {
            case kBaseNode:
                nFileTree=[[PBFileTree alloc] initWithData:[PBFileNode baseFileNodeWithName:tPath
                                                                                       icon:nil
                                                                                       user:tUID
                                                                                      group:tGID
                                                                                 privileges:tPrivileges]
                                                    parent:nil
                                                  children:[NSArray array]];
                break;
            case kNewFolderNode:
                nFileTree=[[PBFileTree alloc] initWithData:[PBFileNode newFolderFileNodeWithName:tPath
                                                                                            icon:nil
                                                                                            user:tUID
                                                                                           group:tGID
                                                                                      privileges:tPrivileges]
                                                    parent:nil
                                                  children:[NSArray array]];
                break;
            case kRealItemNode:
                
                switch (tPathType)
                {
                    case kGlobalPath:
                        break;
                    case kRelativeToProjectPath:
                    
                        // Build the Absolute Path from the Relative to Project Path
                        
                        tPath=[tPath stringByAbsolutingWithPath:inProjectPath];
                        
                        break;
                    default:
                        break;
                }
                
                tFileNode=[PBFileNode fileNodeWithType:tType
                                                  path:tPath
                                              pathType:tPathType];
                
                tNumber=[inDictionary objectForKey:@"Expanded"];
        
                if (tNumber!=nil)
                {
                    [tFileNode setFolder:[tNumber boolValue]];
                }
                
                if (tFileNode!=nil)
                {
                    [tFileNode setUid:tUID];
                    [tFileNode setGid:tGID];
                    [tFileNode setPrivileges:tPrivileges];
                    
                    nFileTree=[[PBFileTree alloc] initWithData:tFileNode
                                                        parent:nil
                                                      children:[NSArray array]];
                }
                
                break;
        }
        
        tArray=[inDictionary objectForKey:@"Search Rules"];
        
        if (tArray!=nil && nFileTree!=nil)
        {
            [FILENODE_DATA(nFileTree) setSearchRules:tArray];
        }
        
        tArray=[inDictionary objectForKey:@"Children"];
        
        if (tArray!=nil)
        {
            int i,tCount;
            PBFileTree * tFileTree;
            
            tCount=[tArray count];
            
            for(i=0;i<tCount;i++)
            {
                NSDictionary * tDictionary;
                
                tDictionary=[tArray objectAtIndex:i];
                
                tFileTree=[PBFileTree fileNodeWithDictionary:tDictionary projectPath:inProjectPath];
            
                [nFileTree insertSortedChildReverse:tFileTree];
            }
        }
    }
    
    
    return [nFileTree autorelease];
}

+ (PBFileTree *) fileTreeWithDictionary:(NSDictionary *) inDictionary projectPath:(NSString *) inProjectPath
{
    PBFileTree * nFileTree;
    
    nFileTree=[[PBFileTree alloc] initWithData:[PBFileNode rootFileNode]
                                        parent:nil
                                      children:[NSArray array]];
    if (nFileTree!=nil)
    {
        PBFileTree * rootTree;
        
        rootTree=[PBFileTree fileNodeWithDictionary:inDictionary projectPath:inProjectPath];

        [nFileTree insertChild: rootTree
                        atIndex: 0];

    }
        
    return [nFileTree autorelease];
}

/*+ (PBFileTree *) defaultFileTree
{
    NSString * tPath;
    PBFileTree * nFileTree=nil;
    
    tPath=[[NSBundle mainBundle] pathForResource:@"DefaultTree" ofType:@"plist"];
    
    if (tPath!=nil)
    {
        NSDictionary * tDictionary;
    
        tDictionary=[NSDictionary dictionaryWithContentsOfFile:tPath];
        
        if (tDictionary!=nil)
        {
            
    
            nFileTree=[[PBFileTree alloc] initWithData:[PBFileNode rootFileNode]
                                                parent:nil
                                              children:[NSArray array]];
            if (nFileTree!=nil)
            {
                PBFileTree * rootTree;
                
                rootTree=[PBFileTree fileNodeWithDictionary:tDictionary];
    
                [nFileTree insertChild: rootTree
                               atIndex: 0];
    
            }
        }
    }
        
    return [nFileTree autorelease];
}*/

#pragma mark -

- (NSDictionary *) dictionaryWithProjectAtPath:(NSString *) inProjectPath
{
    NSMutableDictionary * nDictionary;
    NSArray * tChildren;
    NSMutableArray * tChidrenFiles;
    PBFileNode * tFileNode;
    NSNumber * tExpanded=nil;
    NSMutableArray * tSearchRules;
    int tPathType;
    NSString * tPath;
    
    tChildren=[self children];
    
    tChidrenFiles=[NSMutableArray array];
    
    if (tChildren!=nil)
    {
        int i,tCount;
        
        tCount=[tChildren count];
        
        for(i=0;i<tCount;i++)
        {
            NSDictionary * tChildDictionary;
            
            tChildDictionary=[[tChildren objectAtIndex:i] dictionaryWithProjectAtPath:inProjectPath];
            
            [tChidrenFiles addObject:tChildDictionary];
        }
    }
    
    tFileNode=FILENODE_DATA(self);
    
    if ([tFileNode type]==kRealItemNode)
    {
        if ([tFileNode isLeaf]==NO)
        {
            tExpanded=[NSNumber numberWithBool:YES];
        }
    }
    
    tPathType=[tFileNode pathType];
    tPath=[tFileNode path];
    
    if (inProjectPath!=nil && tPathType==kRelativeToProjectPath)
    {
        // Compute the Relative Path to Project
        
        tPath=[tPath stringByRelativizingToPath:inProjectPath];
    }
    else
    {
        tPathType=kGlobalPath;
    }
    
    nDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:tChidrenFiles,@"Children",
                                                           [NSNumber numberWithInt:[tFileNode type]],@"Type",
                                                           tPath,@"Path",
                                                           [NSNumber numberWithInt:tPathType],@"Path Type",
                                                           [NSNumber numberWithInt:[tFileNode uid]],@"UID",
                                                           [NSNumber numberWithInt:[tFileNode gid]],@"GID",
                                                           [NSNumber numberWithInt:[tFileNode privileges]],@"Privileges",
                                                           tExpanded,@"Expanded",	// Be prepared for tExpanded to be nil
                                                           nil];
    
    tSearchRules=[tFileNode searchRules];
    
    if (tSearchRules!=nil)
    {
        if ([tSearchRules count]>0)
        {
            [nDictionary setObject:tSearchRules forKey:@"Search Rules"];
        }
    }
    
    return nDictionary;
}

- (PBFileTree *) fileTreeAtPath:(NSString *) inPath
{
    if (inPath!=nil)
    {
        NSArray * tArray;
        int i,tCount;
        PBFileTree * tTree=(PBFileTree *) [self childAtIndex:0];
        
        tArray=[inPath componentsSeparatedByString:@"/"];
        
        tCount=[tArray count];
        
        for(i=1;i<tCount;i++)
        {
            NSString * tComponent;
            
            tComponent=[tArray objectAtIndex:i];
            
            if ([tComponent length]>0)
            {
                NSArray * tChildren;
                int j,tChildrenCount;
                
                tChildren=[tTree children];
                
                tChildrenCount=[tChildren count];
                
                for(j=0;j<tChildrenCount;j++)
                {
                    PBFileTree * tFileTree;
                    PBFileNode * tNode;
                
                    tFileTree=[tChildren objectAtIndex:j];
                    
                    tNode=FILENODE_DATA(tFileTree);
                    
                    if ([[tNode fileName] compare:tComponent]==NSOrderedSame)
                    {
                        tTree=tFileTree;
                        break;
                    }
                    
                }
                
                if (j==tChildrenCount)
                {
                    return nil;
                }
            }
            else
            {
                break;
            }
        }
        
        return tTree;
    }
    
    return nil;
}

- (NSString *) filePath
{
    NSString * tString=nil;
    NSMutableString * tMutableString;
    PBFileTree * tFileTree=self;
    
    tMutableString=[NSMutableString stringWithCapacity:1024];
    
    do
    {
        PBFileNode * tFileNode;
        NSString * tFileName;
        
        tFileNode=FILENODE_DATA(tFileTree);
        
        tFileName=[tFileNode fileName];
        
        if ([tFileName isEqualToString:@"/"]==NO)
        {
            [tMutableString insertString:[tFileNode fileName] atIndex:0];
            [tMutableString insertString:@"/" atIndex:0];
            
            tFileTree=(PBFileTree *) [tFileTree nodeParent];
        }
        else
        {
            if (tFileTree==self)
            {
                [tMutableString insertString:@"/" atIndex:0];
            }
            
            tFileTree=nil;
        }
        
        
    }
    while(tFileTree!=nil);
    
    if ([tMutableString length]>0)
    {
        tString=[tMutableString copy];
    }
    
    return [tString autorelease];
}

- (BOOL) containsTreeWithName:(NSString *) inName
{
    NSArray * tChildren;
    
    tChildren=[self children];
    
    if (tChildren!=nil)
    {
        int i,tCount;
        PBFileNode * tNode;
        NSComparisonResult tResult;
        
        tCount=[tChildren count];
        
        for(i=0;i<tCount;i++)
        {
            tNode=FILENODE_DATA([tChildren objectAtIndex:i]);
            
            tResult=[[[tNode path] lastPathComponent] compare:inName options:NSCaseInsensitiveSearch];
            
            if (tResult==NSOrderedSame)
            {
                return YES;
            }
            /*else if (tResult==NSOrderedAscending)	// TO OPTIMIZE (decommenter quand le tri sera fait)
            {
                break;
            }*/
        }
    }
    
    return NO;
}

- (void) insertSortedChildReverse:(PBFileTree *) inChild
{
    NSArray * tChildren;
    int index=-1;
    
    tChildren=[self children];
    
    if (tChildren!=nil)
    {
        unsigned int i,tCount;
        PBFileNode * tNode;
        NSComparisonResult tResult;
        NSString * tName;
        
        tName=[[FILENODE_DATA(inChild) path] lastPathComponent];
        
        tCount=[tChildren count];
        
		for(i=tCount;i>0;i--)
        {
            tNode=FILENODE_DATA([tChildren objectAtIndex:i-1]);
            
            tResult=[tName compare:[[tNode path] lastPathComponent] options:NSCaseInsensitiveSearch];
            
            if (tResult!=NSOrderedAscending)
            {
                index=i;
                break;
            }
        }
        
        if (index==-1)
        {
            index=0;
        }
    }
    else
    {
        index=0;
    }
    
    [self insertChild:inChild atIndex:index];
}

- (void) insertSortedChild:(PBFileTree *) inChild
{
    NSArray * tChildren;
    int index=-1;
    
    tChildren=[self children];
    
    if (tChildren!=nil)
    {
        int i,tCount;
        PBFileNode * tNode;
        NSComparisonResult tResult;
        NSString * tName;
        
        tName=[[FILENODE_DATA(inChild) path] lastPathComponent];
        
        tCount=[tChildren count];
        
        for(i=0;i<tCount;i++)
        {
            tNode=FILENODE_DATA([tChildren objectAtIndex:i]);
            
            tResult=[tName compare:[[tNode path] lastPathComponent] options:NSCaseInsensitiveSearch];
            
            if (tResult!=NSOrderedDescending)
            {
                index=i;
                break;
            }
        }
        
        if (index==-1)
        {
            index=tCount;
        }
    }
    else
    {
        index=0;
    }
    
    [self insertChild:inChild atIndex:index];
}

- (void) insertSortedChildren:(NSArray *) inChildren
{
}

- (BOOL) expandAll:(BOOL) inKeepOwnerAndGroup withProjectPath:(NSString *) inProjectPath
{
	int tCount;
	
	tCount=[self numberOfChildren];
        
	if (tCount>0)
	{
		BOOL tExpandedOne=NO;
		int i;
		
		for(i=0;i<tCount;i++)
		{
			PBFileTree * tChild;
			
			tChild=(PBFileTree *) [self childAtIndex:i];
			
			if ([tChild expandAll:inKeepOwnerAndGroup withProjectPath:inProjectPath]==YES)
			{
				tExpandedOne=YES;
			}
		}
		
		return tExpandedOne;
	}
	else
	{
		PBFileNode * tFileNode;
	
		tFileNode=FILENODE_DATA(self);
    
		if ([tFileNode type]==kRealItemNode)
		{
			int tPathType;
			NSString * tPath;
			NSDictionary * tDictionary;
			
			tPathType=[tFileNode pathType];
			
			tPath=[tFileNode path];
    
			if (tPath!=nil && tPathType==kRelativeToProjectPath)
			{
				// Compute the Absolute Path
        
				tPath=[tPath stringByAbsolutingWithPath:inProjectPath];
			}
			
			tDictionary=[[NSFileManager defaultManager] fileAttributesAtPath:tPath traverseLink:NO];
		
			if ([[tDictionary objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]==YES)
			{
				[self expand:inKeepOwnerAndGroup];
				
				return YES;
			}
		}
    }
	
	return NO;
}

- (void) expand:(BOOL) inKeepOwnerAndGroup
{
    NSFileManager * tFileManager;
    NSString * tPath;
    PBFileTree * tChild;
    NSArray * directoryContent;
    int i,tCount;
    PBFileNode * tTargetNode;
    NSString * tSelfPath;
    
    tTargetNode=FILENODE_DATA(self);
    
    tSelfPath=[tTargetNode path];
    
    tFileManager=[NSFileManager defaultManager];
    
    directoryContent=[tFileManager directoryContentsAtPath:tSelfPath];
    
    tCount=[directoryContent count];
    
    for(i=0;i<tCount;i++)
    {
        id tFileNode;
        
        tPath=[tSelfPath stringByAppendingPathComponent:[directoryContent objectAtIndex:i]];
        
	tFileNode=[PBFileNode fileNodeWithType:kRealItemNode
                                          path:tPath
                                      pathType:[tTargetNode pathType]];
                                                
        if (tFileNode!=nil)
        {
            NSDictionary * tFileAttributes;
            NSString * tString;
            NSNumber * tNumber;
            
            tFileAttributes=[tFileManager fileAttributesAtPath:tPath traverseLink:NO];
            
            tNumber=[tFileAttributes objectForKey:NSFilePosixPermissions];
                    
            if (tNumber!=nil)
            {
                [tFileNode setPrivileges:[tNumber intValue]];
            }
            else
            {
                // A COMPLETER
            }
            
            if (inKeepOwnerAndGroup==YES)
            {
                tNumber=[tFileAttributes objectForKey:NSFileOwnerAccountID];
                        
                if (tNumber!=nil)
                {
                    [tFileNode setUid:[tNumber intValue]];
                }
                else
                {
                    [tFileNode setUid:[tTargetNode uid]];
                }
                
                tNumber=[tFileAttributes objectForKey:NSFileGroupOwnerAccountID];
                
                if (tNumber!=nil)
                {
                    [tFileNode setGid:[tNumber intValue]];
                }
                else
                {
                    [tFileNode setGid:[tTargetNode gid]];
                }
            }
            else
            {
                [tFileNode setUid:[tTargetNode uid]];
            
                [tFileNode setGid:[tTargetNode gid]];
            }
            
            tString=[tFileAttributes objectForKey:NSFileType];
            
            if (tString!=nil && [tString isEqualToString:NSFileTypeDirectory]==YES)
            {
                tChild=[[PBFileTree alloc] initWithData:tFileNode
                                                 parent:nil
                                               children:[NSArray array]];
                
                [tChild expand:inKeepOwnerAndGroup];
            }
            else
            {
            	tChild=[[PBFileTree alloc] initWithData:tFileNode
                                                 parent:nil
                                               children:nil];

            }
            
            [self insertChild:tChild atIndex:i];
                                
            [tChild release];
        }
    }
    
    [tTargetNode setFolder:YES];
}

- (void) expandOneLevel:(BOOL) inKeepOwnerAndGroup
{
    NSFileManager * tFileManager;
    NSString * tPath;
    PBFileTree * tChild;
    NSArray * directoryContent;
    int i,tCount;
    PBFileNode * tTargetNode;
    NSString * tSelfPath;
    
    tTargetNode=FILENODE_DATA(self);
    
    tSelfPath=[tTargetNode path];
    
    tFileManager=[NSFileManager defaultManager];
    
    directoryContent=[tFileManager directoryContentsAtPath:tSelfPath];
    
    tCount=[directoryContent count];
    
    for(i=0;i<tCount;i++)
    {
        id tFileNode;
        
        tPath=[tSelfPath stringByAppendingPathComponent:[directoryContent objectAtIndex:i]];
        
	tFileNode=[PBFileNode fileNodeWithType:kRealItemNode
                                          path:tPath
                                      pathType:[tTargetNode pathType]];
                                                
        if (tFileNode!=nil)
        {
            NSDictionary * tFileAttributes;
            NSNumber * tNumber;
            
            tFileAttributes=[tFileManager fileAttributesAtPath:tPath traverseLink:NO];
            
            tNumber=[tFileAttributes objectForKey:NSFilePosixPermissions];
                    
            if (tNumber!=nil)
            {
                [tFileNode setPrivileges:[tNumber intValue]];
            }
            
            if (inKeepOwnerAndGroup==YES)
            {
                tNumber=[tFileAttributes objectForKey:NSFileOwnerAccountID];
                        
                if (tNumber!=nil)
                {
                    [tFileNode setUid:[tNumber intValue]];
                }
                else
                {
                    [tFileNode setUid:[tTargetNode uid]];
                }
                
                tNumber=[tFileAttributes objectForKey:NSFileGroupOwnerAccountID];
                
                if (tNumber!=nil)
                {
                    [tFileNode setGid:[tNumber intValue]];
                }
                else
                {
                    [tFileNode setGid:[tTargetNode gid]];
                }
            }
            else
            {
                [tFileNode setUid:[tTargetNode uid]];
            
                [tFileNode setGid:[tTargetNode gid]];
            }
            
            tChild=[[PBFileTree alloc] initWithData:tFileNode
                                             parent:nil
                                           children:nil];
            
            [self insertChild:tChild atIndex:i];
                                
            [tChild release];
        }
    }
    
    [tTargetNode setFolder:YES];
}

- (void) contract
{
    PBFileNode * tTargetNode;
    
    tTargetNode=FILENODE_DATA(self);
    
    [nodeChildren makeObjectsPerformSelector:@selector(setNodeParent:) withObject:nil];
    
    [nodeChildren release];
    
    nodeChildren=[[NSMutableArray array] retain];
    
    [tTargetNode setFolder:NO];
}

- (BOOL) hasRealChildren
{
    int tCount,i;
    
    if ([FILENODE_DATA(self) type]>kBaseNode)
    {
        return YES;
    }
    else
    {
        BOOL tResult;
        
        tCount=[self numberOfChildren];
        
        for(i=0;i<tCount;i++)
        {
            tResult=[((PBFileTree *) [self childAtIndex:i]) hasRealChildren];
            
            if (tResult==YES)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *) uniqueNameWithParentFileTree:(PBFileTree *) inParentTree
{
    int _sIndex=0;
    static NSString * tLocalizedBaseName=nil;
    int i,tCount;
    NSString * tString;
    
    if (tLocalizedBaseName==nil)
    {
        tLocalizedBaseName=[NSLocalizedString(@"Untitled Folder",@"No comment") retain];
    }
    
    tCount=[inParentTree numberOfChildren];
    
    do
    {
        PBFileTree * tFileTree;
        
        if (_sIndex>0)
        {
            tString=[[NSString alloc] initWithFormat:@"%@ %d",tLocalizedBaseName,_sIndex];
        }
        else
        {
            tString=[[NSString alloc] initWithString:tLocalizedBaseName];
        }
        
        _sIndex++;
        
        for(i=0;i<tCount;i++)
        {
            tFileTree=(PBFileTree *) [inParentTree childAtIndex:i];
            
            if ([tString isEqualToString:[FILENODE_DATA(tFileTree) fileName]]==YES)
            {
                break;
            }
        }
        
        if (i==tCount)
        {
            break;
        }
        
        [tString release];
    }
    while (_sIndex<65535);
    
    return [tString autorelease];
}

@end