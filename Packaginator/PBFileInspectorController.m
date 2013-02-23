/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBFileInspectorController.h"
#include <sys/stat.h>
#import "PBTableView.h"

#import <MOKit/MOKit.h>
#import "PBViewListLabelView.h"
#import "NSString+Iceberg.h"
#import "NSDocument+Iceberg.h"

#import "PBSharedConst.h"

#import "PBDirectoryServicesManager.h"

#define PBSearchRulePBoardType	@"PBSearchRulePBoardType"

NSString * PBInspectorSaveFrameName=@"Frame Inspector SC";

BOOL _awakeFromNibEnded=NO;

@interface NSDictionary(PBGroupAndUser) 

- (NSComparisonResult) compareName:(NSDictionary *) other;

@end

@implementation NSDictionary(PBGroupAndUser) 

- (NSComparisonResult) compareName:(NSDictionary *) other
{
    return [((NSString *)[self objectForKey:@"Name"]) compare:[other objectForKey:@"Name"]];
}

@end

@implementation PBFileInspectorController

- (void) awakeFromNib
{
    id tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    NSMutableArray * tPasswordArray;
    NSMutableArray * tGroupArray;
    int i,tCount;
    NSUserDefaults * tDefaults;
    NSString * tSavedWindowFrame;
    PBDirectoryServicesManager * tDSManager;
    id tMenuItem;
    NSImage * tImage;
    
    tDSManager=[PBDirectoryServicesManager defaultManager];
    
    // Set the icon for the Reference Style popup menu
    
    tMenuItem=[IBpathType_ itemAtIndex:[IBpathType_ indexOfItemWithTag:kRelativeToProjectPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative13" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tMenuItem=[IBpathType_ itemAtIndex:[IBpathType_ indexOfItemWithTag:kGlobalPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute13" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    // Permission Array
    
    [IBpermissionsArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    tPrototypeCell = [[NSButtonCell alloc] initTextCell: @""];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setAllowsMixedState:YES];
    [tPrototypeCell setImagePosition: NSImageOnly];
    
    
    tableColumn = [IBpermissionsArray_ tableColumnWithIdentifier: @"Read"];
    [tableColumn setDataCell:tPrototypeCell];
    
    tableColumn = [IBpermissionsArray_ tableColumnWithIdentifier: @"Write"];
    [tableColumn setDataCell:tPrototypeCell];
    
    tableColumn = [IBpermissionsArray_ tableColumnWithIdentifier: @"Search"];
    [tableColumn setDataCell:tPrototypeCell];
    
    [tPrototypeCell release];
    
    tableColumn = [IBpermissionsArray_ tableColumnWithIdentifier: @"Owner"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:11.0]];
    
    [IBpermissionsArray_ setAcceptFirstClick:YES];
    
    // Special Bits Array
    
    [IBspecialBitsArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    tPrototypeCell = [[NSButtonCell alloc] initTextCell: @""];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setAllowsMixedState:YES];
    [tPrototypeCell setImagePosition: NSImageOnly];
    
    
    tableColumn = [IBspecialBitsArray_ tableColumnWithIdentifier: @"Bit"];
    [tableColumn setDataCell:tPrototypeCell];
    
    [tPrototypeCell release];
    
    tableColumn = [IBspecialBitsArray_ tableColumnWithIdentifier: @"Name"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:11.0]];
    
    [IBspecialBitsArray_ setAcceptFirstClick:YES];
    
    [IBspecialBitsArray_ setStripesColor:[NSColor colorWithDeviceRed:1.0f
                                                               green:213.0/255 blue:202.0/255.0 alpha:1.0f]];
    
    // Rules Array
    
    [IBrulesArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    tPrototypeCell = [[NSButtonCell alloc] initTextCell: @""];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    
    tableColumn = [IBrulesArray_ tableColumnWithIdentifier: @"Status"];
    [tableColumn setDataCell:tPrototypeCell];
    
    [tPrototypeCell release];
    
    tableColumn = [IBrulesArray_ tableColumnWithIdentifier: @"Name"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:11.0]];
    
    [IBrulesArray_ setAcceptFirstClick:YES];
    
    [IBrulesArray_ setDoubleAction:@selector(editRule:)];
    [IBrulesArray_ setTarget:self];
    
    // Build the owner and group popups
    
    // Owner
    
    [IBowner_ removeAllItems];
    
    tPasswordArray=[tDSManager usersArray];
    
    [tPasswordArray sortUsingSelector:@selector(compareName:)];
    
    tCount=[tPasswordArray count];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tDictionary;
        NSString * tKey;
        
        tDictionary=[tPasswordArray objectAtIndex:i];
        
        tKey=[tDictionary objectForKey:@"Name"];
        
        [IBowner_ addItemWithTitle:tKey];
        
        [[IBowner_ itemWithTitle:tKey] setTag:[[tDictionary objectForKey:@"ID"] intValue]];
    }
    
    // Group
    
    [IBgroup_ removeAllItems];
    
    tGroupArray=[tDSManager groupsArray];
    
    [tGroupArray sortUsingSelector:@selector(compareName:)];
    
    tCount=[tGroupArray count];
    
    for(i=0;i<tCount;i++)
    {
        NSDictionary * tDictionary;
        NSString * tKey;
        
        tDictionary=[tGroupArray objectAtIndex:i];
        
        tKey=[tDictionary objectForKey:@"Name"];
        
        [IBgroup_ addItemWithTitle:tKey];
        
        [[IBgroup_ itemWithTitle:tKey] setTag:[[tDictionary objectForKey:@"ID"] intValue]];
    }
    
    currentView_=IBcenteredView_;
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    tSavedWindowFrame=[tDefaults stringForKey:PBInspectorSaveFrameName];
    
    if (tSavedWindowFrame!=nil)
    {
    	[IBwindow_ setFrame:NSRectFromString(tSavedWindowFrame) display:NO];
    }
    
    [[IBwindow_ contentView] addSubview:IBcenteredView_];
    
    {
        NSRect tViewFrame;
        NSRect tWindowFrame;
        float tOffsetV;
        NSRect tNewWindowFrame;
        
        tWindowFrame=[IBwindow_ frame];
        
        tViewFrame=[currentView_ bounds];
        
        tWindowFrame=[IBwindow_ frame];
        
        tNewWindowFrame=[NSWindow frameRectForContentRect:tViewFrame styleMask:NSTitledWindowMask|NSClosableWindowMask|NSUtilityWindowMask];
        
        tOffsetV=NSHeight(tWindowFrame)-NSHeight(tNewWindowFrame);
        
        tNewWindowFrame.origin.x=NSMinX(tWindowFrame);
        tNewWindowFrame.origin.y=NSMinY(tWindowFrame)+tOffsetV;
        
        [IBwindow_ setFrame:tNewWindowFrame display:YES];
        
        tViewFrame.origin=NSZeroPoint;
        
        [currentView_ setFrame:tViewFrame];
    }
    
    [IBcenteredView_ setTitle:NSLocalizedString(@"Empty selection",@"No comment")];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileSelectionDidChange:)
                                                 name:@"PBFileSelectionDidChange"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showInspector:)
                                                 name:@"PBShowFileInspector"
                                               object:nil];
    
    [IBwindow_ setBecomesKeyOnlyIfNeeded:YES];
    
    // Prepare the Info View hierarchy
    
    [IBviewListView_ setViewListLabelViewClass:[PBViewListLabelView class]];
    
    [IBviewListView_ setLabelBarAppearance:MOViewListViewFinderLabelBars];
    
    [MOViewListView setUsesAnimation:NO];
    
    [IBviewListView_ disableLayout];
    
    [IBviewListView_ addStackedView:IBgeneralInfoView_ withLabel:NSLocalizedString(@"General:",@"No comment")];
    
    [IBviewListView_ expandStackedViewAtIndex:0];
    
    [IBviewListView_ addStackedView:IBsearchRulesInfoView_ withLabel:NSLocalizedString(@"Search Rules:",@"No comment")];
    
    [IBviewListView_ enableLayout];
    
    _awakeFromNibEnded=YES;

    searchRuleEditorController_=[PBSearchRuleEditorController alloc];
    
    [IBrulesArray_ registerForDraggedTypes:[NSArray arrayWithObject:PBSearchRulePBoardType]];
}

- (void) setFileType
{
    PBFileNode * tFileNode;
    NSString * tType=@"";
    
    tFileNode=FILENODE_DATA(selectedFile_);
                    
    switch([tFileNode type])
    {
        case kBaseNode:
            tType=NSLocalizedString(@"Standard folder",@"No comment");
            break;
        case kNewFolderNode:
            tType=NSLocalizedString(@"Custom folder",@"No comment");
            break;
        case kRealItemNode:
            {
                struct stat tStat;
                
                if (lstat([[tFileNode path] fileSystemRepresentation], &tStat)==0)
                {
                    switch((tStat.st_mode & S_IFMT))
                    {
                        case S_IFDIR:
                            tType=NSLocalizedString(@"Folder",@"No comment");
                            break;
                        case S_IFLNK:
                            tType=NSLocalizedString(@"Symbolic link",@"No comment");
                            break;
                        default:
                            tType=NSLocalizedString(@"File",@"No comment");
                            break;
                    }
                }
                else
                {
                    tType=NSLocalizedString(@"N/A",@"No comment");
                }
            }
            break;
    }
    
    [IBtype_ setStringValue:tType];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    if ([aNotification object]==IBwindow_)
    {
        NSRect tFrame;
        NSUserDefaults * tDefaults;
        NSString * tSavedWindowFrame;
        
        tDefaults=[NSUserDefaults standardUserDefaults];
    
        tFrame=[IBwindow_ frame];
    
        tSavedWindowFrame=NSStringFromRect(tFrame);
    
        if (tSavedWindowFrame!=nil)
        {
            [tDefaults setObject:tSavedWindowFrame forKey:PBInspectorSaveFrameName];
            
            [tDefaults synchronize];
        }
    }
}

- (void) fileSelectionDidChange:(NSNotification *)notification
{
    BOOL currentViewDidChange=NO;
    NSDictionary * tUserInfo;
    
    canEditPermission_=NO;
    
    tUserInfo=[notification userInfo];
    
    [[IBwindow_ contentView] setAutoresizesSubviews:NO];
    
    [rulesArray_ release];
    
    rulesArray_=nil;
    
    if (tUserInfo!=nil)
    {
        NSNumber * tNumber;
        
        tNumber=[tUserInfo objectForKey:@"Count"];
        
        if (tNumber==nil)
        {
            if (selectedFile_!=nil)
            {
                [selectedFile_ release];
                
                selectedFile_=nil;
            }
            
            if (selectedFiles_!=nil)
            {
                [selectedFiles_ release];
                
                selectedFiles_=nil;
            }
            
            if (currentView_!=IBcenteredView_)
            {
                [currentView_ removeFromSuperview];
                
                currentView_=IBcenteredView_;
                
                [[IBwindow_ contentView] addSubview:currentView_];
                
                currentViewDidChange=YES;
            }
            
            [IBcenteredView_ setTitle:NSLocalizedString(@"Empty selection",@"No comment")];
        }
        else
        {
            PBFileTree * tSelection;
            int tSelectionCount;
            PBFileNode * tFileNode,* tPermissionMode;
            BOOL isEnabled=YES;
            NSString * tPath;
            BOOL isLink=NO;
            
            tSelectionCount=[tNumber intValue];
        
            // Clean PopupButton menus
            
            if ([[IBowner_ itemTitleAtIndex:0] isEqualToString:NSLocalizedString(@"Mixed",@"No comment")]==YES)
            {
                [IBowner_ removeItemAtIndex:0];
            }
            
            if ([[IBgroup_ itemTitleAtIndex:0] isEqualToString:NSLocalizedString(@"Mixed",@"No comment")]==YES)
            {
                [IBgroup_ removeItemAtIndex:0];
            }
            
            if ([[IBpathType_ itemTitleAtIndex:0] isEqualToString:NSLocalizedString(@"Mixed",@"No comment")]==YES)
            {
                [IBpathType_ removeItemAtIndex:0];
            }
            
            if (selectedFile_!=nil)
            {
                [selectedFile_ release];
            
                selectedFile_=nil;
            }
            
            if (selectedFiles_!=nil)
            {
                [selectedFiles_ release];
                
                selectedFiles_=nil;
            }
            
            switch(tSelectionCount)
            {
                case 0:
                    
                    if (currentView_!=IBcenteredView_)
                    {
                        [currentView_ removeFromSuperview];
                        
                        currentView_=IBcenteredView_;
                        
                        [[IBwindow_ contentView] addSubview:currentView_];
                
                        currentViewDidChange=YES;
                    }
                    
                    [IBcenteredView_ setTitle:NSLocalizedString(@"Empty selection",@"No comment")];
                    
                    break;
                case 1:
                    fileController_=[tUserInfo objectForKey:@"File Controller"];
                    
                    tSelection=[tUserInfo objectForKey:@"File"];
                    
                    selectedFile_=[tSelection retain];
                    
                    if (currentView_!=IBfileInfoView_)
                    {
                        [currentView_ removeFromSuperview];
                        
                        currentView_=IBfileInfoView_;
                        
                        [[IBwindow_ contentView] addSubview:currentView_];
                
                        currentViewDidChange=YES;
                    }
                    
                    tFileNode=FILENODE_DATA(selectedFile_);
                    
                    [IBrulesArray_ deselectAll:nil];
                    
                    [IBname_ setTextColor:[NSColor blackColor]];
                    [IBsource_ setTextColor:[NSColor blackColor]];
                    [IBdestination_ setTextColor:[NSColor blackColor]];
                    [IBtype_ setTextColor:[NSColor blackColor]];
                    
                    switch([tFileNode type])
                    {
                        case kBaseNode:
                            [IBsource_ setStringValue:@"-"];
                            
                            [IBwindow_ makeFirstResponder:nil];
                            [IBname_ setEditable:NO];
                            
                            [IBpathType_ setEnabled:NO];
                            
                            [IBowner_ setEnabled:NO];
                            [IBgroup_ setEnabled:NO];
                            
                            
                            isEnabled=NO;
                            
                            [IBaddRuleButton_ setEnabled:NO];
                            
                            break;
                        case kNewFolderNode:
                            [IBsource_ setStringValue:@"-"];
                            
                            [IBname_ setEditable:YES];
                            
                            [IBpathType_ setEnabled:NO];
                            
                            [IBowner_ setEnabled:YES];
                            [IBgroup_ setEnabled:YES];
                            
                            [IBaddRuleButton_ setEnabled:YES];
                            
                            canEditPermission_=YES;
                            
                            break;
                        case kRealItemNode:
                            
                            [IBpathType_ setEnabled:YES];
                            
                            pathTypeIndex_=[IBpathType_ indexOfItemWithTag:[tFileNode pathType]];
                            
                            [IBpathType_ selectItemAtIndex:pathTypeIndex_];
                            
                            tPath=[tFileNode path];
                            
                            if ([tFileNode pathType]==kRelativeToProjectPath)
                            {
                                tPath=[tPath stringByRelativizingToPath:[[fileController_ document] folder]];
                            }
                            
                            if (tPath!=nil)
                            {
                                [IBsource_ setStringValue:tPath];
                            }
                            
                            [IBwindow_ makeFirstResponder:nil];
                            [IBname_ setEditable:NO];
                            
                            [IBowner_ setEnabled:YES];
                            [IBgroup_ setEnabled:YES];
                            
                            [IBaddRuleButton_ setEnabled:YES];
                            
                            break;
                        
                    }
                    
                    [IBeditRuleButton_ setEnabled:NO];
                    [IBremoveRuleButton_ setEnabled:NO];
                    
                    [IBdestination_ setStringValue:[selectedFile_ filePath]];
                    
                    [self setFileType];
                    
                    [IBname_ setStringValue:[tFileNode fileName]];
                    
                    tPermissionMode=tFileNode;
                    
                    if (isEnabled==YES)
                    {
                        isLink=[tFileNode link];
                        
                        [IBowner_ setEnabled:!isLink];
                        [IBgroup_ setEnabled:!isLink];
                        
                        if (isLink==YES)
                        {
                            PBFileTree * tParentTree;
                        
                            tParentTree=(PBFileTree *) [selectedFile_ nodeParent];
                            
                            if (tParentTree!=nil)
                            {
                                tPermissionMode=FILENODE_DATA(tParentTree);
                            }
                        }
                        else
                        {
                            canEditPermission_=YES;
                        }
                    }
                    
                    ownerIndex_=[IBowner_ indexOfItemWithTag:[tPermissionMode uid]];
                    
                    if (ownerIndex_==-1)
                    {
                        NSLog(@"Unknown user ID");
                    }
                    else
                    {
                        [IBowner_ selectItemAtIndex:ownerIndex_];
                    }
                    
                    groupIndex_=[IBgroup_ indexOfItemWithTag:[tPermissionMode gid]];
                    
                    if (groupIndex_==-1)
                    {
                        NSLog(@"Unknown group ID");
                    }
                    else
                    {
                        [IBgroup_ selectItemAtIndex:groupIndex_];
                    }
                    
                    if (isLink==NO)
                    {
                        [IBpermissions_ setStringValue:[tFileNode privilegesStringRepresentation]];
                    }
                    else
                    {
                        [IBpermissions_ setStringValue:[tPermissionMode privilegesStringRepresentationForLink]];
                    }
                    
                    [IBpermissionsArray_ deselectAll:self];
                    [IBpermissionsArray_ reloadData];
                    
                    [IBspecialBitsArray_ deselectAll:self];
                    [IBspecialBitsArray_ reloadData];
                    
                    [IBrulesArray_ deselectAll:self];
                    [IBrulesArray_ reloadData];
                    
                    rulesArray_=[[tFileNode searchRules] retain];
                    
                    break;
                default:
                    cachedPermission_=0;
                    mixedPermission_=0;
                    
                    fileController_=[tUserInfo objectForKey:@"File Controller"];
                    
                    selectedFiles_=[[tUserInfo objectForKey:@"Files"] retain];
                    
                    if (currentView_!=IBfileInfoView_)
                    {
                        [currentView_ removeFromSuperview];
                        
                        currentView_=IBfileInfoView_;
                        
                        [[IBwindow_ contentView] addSubview:currentView_];
                
                        currentViewDidChange=YES;
                    }
                    
                    [IBname_ setEditable:NO];
                    [IBname_ setStringValue:NSLocalizedString(@"Multiple Selection",@"No comment")];
                    [IBname_ setTextColor:[NSColor grayColor]];
                    
                    [IBwindow_ makeFirstResponder:nil];
                    
                    [IBtype_ setStringValue:NSLocalizedString(@"Multiple Selection",@"No comment")];
                    [IBtype_ setTextColor:[NSColor grayColor]];
                    
                    [IBsource_ setStringValue:NSLocalizedString(@"Multiple Selection",@"No comment")];
                    [IBsource_ setTextColor:[NSColor grayColor]];
                    
                    [IBdestination_ setStringValue:NSLocalizedString(@"Multiple Selection",@"No comment")];
                    [IBdestination_ setTextColor:[NSColor grayColor]];
                    
                    
                    [IBaddRuleButton_ setEnabled:NO];
                    [IBeditRuleButton_ setEnabled:NO];
                    [IBremoveRuleButton_ setEnabled:NO];
                    
                    {
                        int tGroup=-1;
                        int tOwner=-1;
                        int tPathType=-1;
                        BOOL canEdit=YES;
                        BOOL canEditReferenceStyle=YES;
                        BOOL canEditOwnerAndGroup=YES;
                        
                        BOOL isMixedOwner=NO;
                        BOOL isMixedGroup=NO;
                        BOOL isMixedReference=NO;
                        int i,tCount;
                        PBFileNode * tFileNode;
                        
                        cachedStatType_=0;
                        
                        canEditPermission_=YES;
                        
                        tFileNode=FILENODE_DATA([selectedFiles_ objectAtIndex:0]);
                        
                        switch([tFileNode type])
                        {
                            case kBaseNode:
                                canEdit=NO;
                                break;
                                
                            case kNewFolderNode:
                                tOwner=[tFileNode uid];
                                tGroup=[tFileNode gid];
                                
                                canEditReferenceStyle=NO;
                                
                                cachedPermission_=[tFileNode privileges];
                                
                                break;
                            case kRealItemNode:
                                
                                canEditPermission_=canEditOwnerAndGroup=![tFileNode link];
                                
                                if (canEditOwnerAndGroup==YES)
                                {
                                    tOwner=[tFileNode uid];
                                    tGroup=[tFileNode gid];
                                }
                                
                                if (canEditPermission_==YES)
                                {
                                    cachedPermission_=[tFileNode privileges];
                                }
                                
                                tPathType=[tFileNode pathType];
                                
                                break;
                        }
                        
                        cachedStatType_=[tFileNode statType];
                        
                        tCount=[selectedFiles_ count];
                            
                        for(i=1;i<tCount && canEdit==YES;i++)
                        {
                            tFileNode=FILENODE_DATA([selectedFiles_ objectAtIndex:i]);
                            
                            switch([tFileNode type])
                            {
                                case kBaseNode:
                                    canEdit=NO;
                                    break;
                                    
                                case kNewFolderNode:
                                    canEditReferenceStyle=NO;
                                    
                                    if (canEditOwnerAndGroup==YES)
                                    {
                                        if (isMixedOwner==NO)
                                        {
                                            isMixedOwner=(tOwner!=[tFileNode uid]);
                                        }
                                        
                                        if (isMixedGroup==NO)
                                        {
                                            isMixedGroup=(tGroup!=[tFileNode gid]);
                                        }
                                    }
                                    break;
                                case kRealItemNode:
                                    if (canEditOwnerAndGroup==YES)
                                    {
                                        canEditOwnerAndGroup=![tFileNode link];
                                        
                                        if (canEditOwnerAndGroup==YES)
                                        {
                                            if (isMixedOwner==NO)
                                            {
                                                isMixedOwner=(tOwner!=[tFileNode uid]);
                                            }
                                            
                                            if (isMixedGroup==NO)
                                            {
                                                isMixedGroup=(tGroup!=[tFileNode gid]);
                                            }
                                        }
                                    }
                                    
                                    if (canEditPermission_==YES)
                                    {
                                        canEditPermission_=![tFileNode link];
                                        
                                        if (canEditPermission_==YES)
                                        {
                                            int tXoredPermissions;
                                            
                                            tXoredPermissions=cachedPermission_^[tFileNode privileges];
                                            
                                            mixedPermission_=mixedPermission_|tXoredPermissions;
                                        }
                                    }
                                    
                                    if (canEditReferenceStyle==YES)
                                    {
                                        if (isMixedReference==NO)
                                        {
                                            isMixedReference=(tPathType!=[tFileNode pathType]);
                                        }
                                    }
                                    
                                    break;
                            }
                            
                            if (canEditOwnerAndGroup==NO && canEditReferenceStyle==NO && canEditPermission_==NO)
                            {
                                canEdit=NO;
                            }
                            else if (canEditPermission_==YES && cachedStatType_!=0)
                            {
                                if (cachedStatType_!=[tFileNode statType])
                                {
                                    cachedStatType_=0;
                                }
                            }
                        }
                        
                        if (canEdit==NO)
                        {
                            canEditPermission_=NO;
                        }
                        
                        // Permissions
                        
                        [IBpermissionsArray_ deselectAll:self];
                        [IBpermissionsArray_ reloadData];
                                
                        [IBspecialBitsArray_ deselectAll:self];
                        [IBspecialBitsArray_ reloadData];
                                
                        if (canEdit==YES)
                        {
                            // Owner and Group
                            
                            if (canEditOwnerAndGroup==NO)
                            {
                                [IBowner_ setEnabled:NO];
                                [IBgroup_ setEnabled:NO];
                            }
                            else
                            {
                                [IBowner_ setEnabled:YES];
                                [IBgroup_ setEnabled:YES];
                                
                                if (isMixedOwner==NO)
                                {
                                    ownerIndex_=[IBowner_ indexOfItemWithTag:tOwner];
                    
                                    if (ownerIndex_==-1)
                                    {
                                        NSLog(@"Unknown user ID");
                                    }
                                    else
                                    {
                                        [IBowner_ selectItemAtIndex:ownerIndex_];
                                    }
                                }
                                else
                                {
                                    ownerIndex_=0;
                                    
                                    [IBowner_ insertItemWithTitle:NSLocalizedString(@"Mixed",@"No comment")
                                                          atIndex:0];
                                    
                                    [[IBowner_ itemAtIndex:0] setTarget:nil];
                                    [[IBowner_ itemAtIndex:0] setEnabled:NO];
                                    [IBowner_ selectItemAtIndex:0];
                                    [IBowner_ setNeedsDisplay:YES];
                                }
                                
                                if (isMixedGroup==NO)
                                {
                                    groupIndex_=[IBgroup_ indexOfItemWithTag:tGroup];
                    
                                    if (groupIndex_==-1)
                                    {
                                        NSLog(@"Unknown group ID");
                                    }
                                    else
                                    {
                                        [IBgroup_ selectItemAtIndex:groupIndex_];
                                    }
                                }
                                else
                                {
                                    groupIndex_=0;
                                    
                                    [IBgroup_ insertItemWithTitle:NSLocalizedString(@"Mixed",@"No comment")
                                                          atIndex:0];
                                    
                                    [[IBgroup_ itemAtIndex:0] setTarget:nil];
                                    [[IBgroup_ itemAtIndex:0] setEnabled:NO];
                                    [IBgroup_ selectItemAtIndex:0];
                                    [IBgroup_ setNeedsDisplay:YES];
                                }
                            }
                            
                            // Reference Style
                            
                            if (canEditReferenceStyle==NO)
                            {
                                [IBpathType_ setEnabled:NO];
                            }
                            else
                            {
                                [IBpathType_ setEnabled:YES];
                                
                                if (isMixedReference==NO)
                                {
                                    pathTypeIndex_=[IBpathType_ indexOfItemWithTag:tPathType];
                    
                                    if (pathTypeIndex_==-1)
                                    {
                                        NSLog(@"Unknown Path Type");
                                    }
                                    else
                                    {
                                        [IBpathType_ selectItemAtIndex:pathTypeIndex_];
                                    }
                                }
                                else
                                {
                                    pathTypeIndex_=0;
                                    
                                    [IBpathType_ insertItemWithTitle:NSLocalizedString(@"Mixed",@"No comment")
                                                          atIndex:0];
                                    
                                    
                                    
                                    [[IBpathType_ itemAtIndex:0] setTarget:nil];
                                    [[IBpathType_ itemAtIndex:0] setEnabled:NO];
                                    [IBpathType_ selectItemAtIndex:0];
                                    [IBpathType_ setNeedsDisplay:YES];
                                }
                            }
                            
                            // Permissions
                            
                            if (canEditPermission_==YES)
                            {
                                [IBpermissions_ setStringValue:[PBFileNode privilegesStringRepresentationWithPermission:cachedPermission_ mixedPermission:mixedPermission_ statType:cachedStatType_]];
                            }
                            else
                            {
                                [IBpermissions_ setStringValue:@"--"];
                            }
                        }
                        else
                        {
                            [IBpermissions_ setStringValue:@"--"];
                            
                            [IBpathType_ setEnabled:NO];
                            [IBowner_ setEnabled:NO];
                            [IBgroup_ setEnabled:NO];
                        }
                    }
                    
                    break;
            }
        }
        
        // Resize the window accordingly
        
        if (currentViewDidChange==YES)
        {
            NSRect tViewFrame;
            NSRect tWindowFrame;
            float tOffsetV;
            NSRect tNewWindowFrame;
            
            tViewFrame=[currentView_ bounds];
            
            tWindowFrame=[IBwindow_ frame];
            
            tNewWindowFrame=[NSWindow frameRectForContentRect:tViewFrame styleMask:NSTitledWindowMask|NSClosableWindowMask|NSUtilityWindowMask];
            
            tOffsetV=NSHeight(tWindowFrame)-NSHeight(tNewWindowFrame);
            
            tNewWindowFrame.origin.x=NSMinX(tWindowFrame);
            tNewWindowFrame.origin.y=NSMinY(tWindowFrame)+tOffsetV;
            
            [IBwindow_ setFrame:tNewWindowFrame display:YES];
            
            tViewFrame.origin=NSZeroPoint;
            
            [currentView_ setFrame:tViewFrame];
        }
    }
    
    [[IBwindow_ contentView] setAutoresizesSubviews:YES];
}

#pragma mark -

- (IBAction) switchPathType:(id) sender
{
    if (pathTypeIndex_!=[IBpathType_ indexOfSelectedItem])
    {
        NSString * tPath;
        PBFileNode * tFileNode;
        NSString * tReferencePath;
    
        pathTypeIndex_=[IBpathType_ indexOfSelectedItem];
    
        tReferencePath=[[fileController_ document] folder];
        
        if (selectedFile_!=nil)
        {
            tFileNode=FILENODE_DATA(selectedFile_);
            
            [tFileNode setPathType:[[IBpathType_ selectedItem] tag]];
            
            // Update File Path drawing
            
            tPath=[tFileNode path];
                                    
            if ([tFileNode pathType]==kRelativeToProjectPath)
            {
                tPath=[tPath stringByRelativizingToPath:tReferencePath];
            }
            
            if (tPath!=nil)
            {
                [IBsource_ setStringValue:tPath];
            }
        }
        else
        {
            NSEnumerator * tEnumerator;
            
            tEnumerator=[selectedFiles_ objectEnumerator];
            
            while (tFileNode=FILENODE_DATA([tEnumerator nextObject]))
            {
                [tFileNode setPathType:[[IBpathType_ selectedItem] tag]];
            
                // Update File Path drawing
                
                tPath=[tFileNode path];
                                        
                if ([tFileNode pathType]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByRelativizingToPath:tReferencePath];
                }
            }
        }
        
        [self postFileAttributesNotification:NO];
    }
}

- (IBAction) switchOwner:(id) sender
{
    if (ownerIndex_!=[IBowner_ indexOfSelectedItem])
    {
        PBFileNode * tFileNode;
        int tTag;
        
        ownerIndex_=[IBowner_ indexOfSelectedItem];
        
        tTag=[[IBowner_ selectedItem] tag];
        
        if (selectedFile_!=nil)
        {
            tFileNode=FILENODE_DATA(selectedFile_);
            
            [tFileNode setUid:tTag];
        }
        else
        {
            NSEnumerator * tEnumerator;
            
            tEnumerator=[selectedFiles_ objectEnumerator];
            
            while (tFileNode=FILENODE_DATA([tEnumerator nextObject]))
            {
                [tFileNode setUid:tTag];
            }
        }
        
        [self postFileAttributesNotification:NO];
    }
}

- (IBAction) switchGroup:(id) sender
{
    if (groupIndex_!=[IBgroup_ indexOfSelectedItem])
    {
        PBFileNode * tFileNode;
        int tTag;
    
        groupIndex_=[IBgroup_ indexOfSelectedItem];
    
        tTag=[[IBgroup_ selectedItem] tag];
        
        if (selectedFile_!=nil)
        {
            tFileNode=FILENODE_DATA(selectedFile_);
            
            [tFileNode setGid:tTag];
        }
        else
        {
            NSEnumerator * tEnumerator;
            
            
            tEnumerator=[selectedFiles_ objectEnumerator];
            
            while (tFileNode=FILENODE_DATA([tEnumerator nextObject]))
            {
                [tFileNode setGid:tTag];
            }
        }
     
        [self postFileAttributesNotification:NO];
    }
}

- (IBAction) setFolderName:(id) sender
{
    if (selectedFile_!=nil)
    {
        PBFileNode * tFileNode;
        
        tFileNode=FILENODE_DATA(selectedFile_);
        
        if ([tFileNode type]==kNewFolderNode)
        {
            NSString * tName;
            
            tName=[IBname_ stringValue];
        
            if ([tName isEqualToString:[tFileNode path]]==NO)
            {
                [tFileNode setPath:tName];
        
                [self postFileAttributesNotification:YES];
                
                [IBdestination_ setStringValue:[selectedFile_ filePath]];
            }
        }
    }
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (IBrulesArray_==aTableView)
    {
        return [rulesArray_ count];
    }
    else
    {
        return 3;
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if (IBrulesArray_==aTableView)
    {
        NSDictionary * tDictionary;
        
        tDictionary=[rulesArray_ objectAtIndex:rowIndex];
    
        return [tDictionary objectForKey:[aTableColumn identifier]];
    }
    else if (IBspecialBitsArray_==aTableView)
    {
        if ([[aTableColumn identifier] isEqualToString: @"Name"])
        {
            switch(rowIndex)
            {
                case 0:
                    return @"SetUID";
                case 1:
                    return @"SetGID";
                case 2:
                    return @"Sticky";
            }
        }
        else
        {
            if ([[aTableColumn identifier] isEqualToString: @"Bit"])
            {
                int tValue=NSOffState;
            
                if (selectedFile_!=nil)
                {
                    int tPermissions;
                
                    tPermissions=[FILENODE_DATA(selectedFile_) privileges];
                
                    switch(rowIndex)
                    {
                        case 0:
                            tValue=((tPermissions & S_ISUID)==S_ISUID);
                            break;
                        case 1:
                            tValue=((tPermissions & S_ISGID)==S_ISGID);
                            break;
                        case 2:
                            tValue=((tPermissions & S_ISTXT)==S_ISTXT);
                            break;
                    }
                }
                else if (canEditPermission_==YES)
                {
                    int tFlag=-1;
                
                    switch(rowIndex)
                    {
                        case 0:
                            tFlag=S_ISUID;
                            break;
                        case 1:
                            tFlag=S_ISGID;
                            break;
                        case 2:
                            tFlag=S_ISTXT;
                            break;
                    }
                    
                    if ((mixedPermission_ & tFlag)==tFlag)
                    {
                        tValue=NSMixedState;
                    }
                    else
                    {
                        tValue=((cachedPermission_ & tFlag)==tFlag);
                    }
                }
            
                return [NSNumber numberWithInt:tValue];
            }
        }
    }
    else if (IBpermissionsArray_==aTableView)
    {
        if ([[aTableColumn identifier] isEqualToString: @"Owner"])
        {
            switch(rowIndex)
            {
                case 0:
                    return @"Owner";
                case 1:
                    return @"Group";
                case 2:
                    return @"Others";
            }
        }
        else
        {
            int tValue=NSOffState;
            
            if (selectedFile_!=nil)
            {
                int tPermissions;
                
                tPermissions=[FILENODE_DATA(selectedFile_) privileges];
                
                if ([[aTableColumn identifier] isEqualToString: @"Read"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tValue=((tPermissions & S_IRUSR)==S_IRUSR);
                            break;
                        case 1:
                            tValue=((tPermissions & S_IRGRP)==S_IRGRP);
                            break;
                        case 2:
                            tValue=((tPermissions & S_IROTH)==S_IROTH);
                            break;
                    }
                }
                else
                if ([[aTableColumn identifier] isEqualToString: @"Write"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tValue=((tPermissions & S_IWUSR)==S_IWUSR);
                            break;
                        case 1:
                            tValue=((tPermissions & S_IWGRP)==S_IWGRP);
                            break;
                        case 2:
                            tValue=((tPermissions & S_IWOTH)==S_IWOTH);
                            break;
                    }
                }
                else
                if ([[aTableColumn identifier] isEqualToString: @"Search"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tValue=((tPermissions & S_IXUSR)==S_IXUSR);
                            break;
                        case 1:
                            tValue=((tPermissions & S_IXGRP)==S_IXGRP);
                            break;
                        case 2:
                            tValue=((tPermissions & S_IXOTH)==S_IXOTH);
                            break;
                    }
                }
                
                return [NSNumber numberWithBool:tValue];
            }
            else if (canEditPermission_==YES)
            {
                int tFlag=-1;
                
                if ([[aTableColumn identifier] isEqualToString: @"Read"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tFlag=S_IRUSR;
                            break;
                        case 1:
                            tFlag=S_IRGRP;
                            break;
                        case 2:
                            tFlag=S_IROTH;
                            break;
                    }
                }
                else
                if ([[aTableColumn identifier] isEqualToString: @"Write"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tFlag=S_IWUSR;
                            break;
                        case 1:
                            tFlag=S_IWGRP;
                            break;
                        case 2:
                            tFlag=S_IWOTH;
                            break;
                    }
                }
                else
                if ([[aTableColumn identifier] isEqualToString: @"Search"])
                {
                    switch(rowIndex)
                    {
                        case 0:
                            tFlag=S_IXUSR;
                            break;
                        case 1:
                            tFlag=S_IXGRP;
                            break;
                        case 2:
                            tFlag=S_IXOTH;
                            break;
                    }
                }
                
                if ((mixedPermission_ & tFlag)==tFlag)
                {
                    tValue=NSMixedState;
                }
                else
                {
                    tValue=((cachedPermission_ & tFlag)==tFlag);
                }
            }
            
            return [NSNumber numberWithInt:tValue];
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    if (IBrulesArray_==tableView)
    {
        if ([[tableColumn identifier] isEqualToString: @"Status"])
        {
            NSDictionary * tDictionary;
            NSDictionary * nDictionary;
            
            tDictionary=[rulesArray_ objectAtIndex:rowIndex];
        
            nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:object,@"Status",
                                                                   [tDictionary objectForKey:@"Name"],@"Name",
                                                                   [tDictionary objectForKey:@"Attributes"],@"Attributes",
                                                                   nil];
            if (nDictionary!=nil)
            {
                [rulesArray_ replaceObjectAtIndex:rowIndex withObject:nDictionary];
            
                [self postFileAttributesNotification:NO];
            }
        }
    }
    else
    {
        int tPermissions;
        PBFileNode * tFileNode=nil;
        
        if (selectedFile_!=nil)
        {
            tFileNode=FILENODE_DATA(selectedFile_);
            
            tPermissions=[tFileNode privileges];
        }
        else
        {
            tPermissions=cachedPermission_;
        }
            
        if (IBpermissionsArray_==tableView)
        {
            int tMask=-1;
            
            if ([[tableColumn identifier] isEqualToString: @"Read"])
            {
                switch(rowIndex)
                {
                    case 0:
                        tMask=S_IRUSR;
                        break;
                    case 1:
                        tMask=S_IRGRP;
                        break;
                    case 2:
                        tMask=S_IROTH;
                        break;
                }
            }
            else
            if ([[tableColumn identifier] isEqualToString: @"Write"])
            {
                switch(rowIndex)
                {
                    case 0:
                        tMask=S_IWUSR;
                        break;
                    case 1:
                        tMask=S_IWGRP;
                        break;
                    case 2:
                        tMask=S_IWOTH;
                        break;
                }
            }
            else
            if ([[tableColumn identifier] isEqualToString: @"Search"])
            {
                switch(rowIndex)
                {
                    case 0:
                        tMask=S_IXUSR;
                        break;
                    case 1:
                        tMask=S_IXGRP;
                        break;
                    case 2:
                        tMask=S_IXOTH;
                        break;
                }
            }
            
            if ([object intValue]!=NSOffState)
            {
                tPermissions|=tMask;
            }
            else
            {
                tPermissions&=~tMask;
            }
            
            mixedPermission_&=~tMask;
        }
        else if (IBspecialBitsArray_==tableView)
        {
            if ([[tableColumn identifier] isEqualToString: @"Bit"])
            {
                int tMask=-1;
                
                switch(rowIndex)
                {
                    case 0:
                        tMask=S_ISUID;
                        break;
                    case 1:
                        tMask=S_ISGID;
                        break;
                    case 2:
                        tMask=S_ISTXT;
                        
                        break;
                }
                
                if ([object intValue]!=NSOffState)
                {
                    tPermissions|=tMask;
                }
                else
                {
                    tPermissions&=~tMask;
                }
                
                mixedPermission_&=~tMask;
            }
        }
        
        if (selectedFile_!=nil)
        {
            [tFileNode setPrivileges:tPermissions];
            
            [IBpermissions_ setStringValue:[tFileNode privilegesStringRepresentation]];
        }
        else
        {
            NSEnumerator * tEnumerator;
            
            cachedPermission_=tPermissions;
            
            tEnumerator=[selectedFiles_ objectEnumerator];
            
            while (tFileNode=FILENODE_DATA([tEnumerator nextObject]))
            {
                [tFileNode setPrivileges:(cachedPermission_ & ~mixedPermission_)|([tFileNode privileges]&mixedPermission_)];
            }
            
            [IBpermissions_ setStringValue:[PBFileNode privilegesStringRepresentationWithPermission:cachedPermission_ mixedPermission:mixedPermission_ statType:cachedStatType_]];
        }
        
        [self postFileAttributesNotification:NO];
    }
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (IBpermissionsArray_==aTableView)
    {
        [aCell setEnabled:canEditPermission_];
        
    }
    else if (IBspecialBitsArray_==aTableView)
    {
        BOOL tEnabledCell=canEditPermission_;
        
        if (selectedFile_!=nil)
        {
            PBFileNode * tFileNode;
            
            tFileNode=FILENODE_DATA(selectedFile_);
            
            if (([tFileNode type]==kRealItemNode && [tFileNode link]==NO))
            {
                struct stat tStat;
                
                if (lstat([[tFileNode path] fileSystemRepresentation], &tStat)==0)
                {
                    if (rowIndex==2 && (tStat.st_mode & S_IFMT)!=S_IFDIR)
                    {
                        tEnabledCell=NO;
                    }
                }
            }
        }
        else
        {
            if (rowIndex==2 && cachedStatType_!='d')
            {
                tEnabledCell=NO;
            }
        }
        
        [aCell setEnabled:tEnabledCell];
    }
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    if (IBrulesArray_==aTableView)
    {
        if (selectedFile_!=nil)
        {
            PBFileNode * tFileNode;
            
            tFileNode=FILENODE_DATA(selectedFile_);
            
            if ([tFileNode type]==kBaseNode)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBrulesArray_)
    {
        int tSelectedCount;
        
        tSelectedCount=[IBrulesArray_ numberOfSelectedRows];
        
        [IBeditRuleButton_ setEnabled:tSelectedCount==1];
        
        [IBremoveRuleButton_ setEnabled:tSelectedCount>=1];
    }
}

#pragma mark -

- (IBAction) showHideInspector:(id) sender
{
    if ([IBwindow_ isVisible]==NO)
    {
        [IBwindow_ orderFront:self];
    }
}

- (IBAction) showInspector:(NSNotification *)notification
{
    if ([IBwindow_ isVisible]==NO)
    {
        [IBwindow_ orderFront:self];
    }
}

#pragma mark -

- (void) postFileAttributesNotification:(BOOL) fileNameDidChange
{
    NSDictionary * tUserInfo=nil;
    
    if (fileNameDidChange==NO)
    {
        if (selectedFile_!=nil)
        {
            tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:selectedFile_,@"File",nil];
        }
        else if (selectedFiles_!=nil)
        {
            tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:selectedFiles_,@"Files",nil];
        }
    }
    else
    {
        tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:selectedFile_,@"File",
                                                             [NSNumber numberWithBool:YES],@"NameDidChange",
                                                             nil];
    }
    
    // Post notification
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PBFileAttributesDidChange"
                                                        object:fileController_
                                                      userInfo:tUserInfo];
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
    SEL tAction=[aMenuItem action];
    PBFileNode * tFileNode;
        
    tFileNode=FILENODE_DATA(selectedFile_);
        
    if (tAction==@selector(switchOwner:) ||
        tAction==@selector(switchGroup:))
    {
        if ([aMenuItem tag]<0 || [aMenuItem tag]>UINT16_MAX)
        {
            return NO;
        }
    }
    else
    if (tAction==@selector(revealSourceInFinder:))
    {
        return (selectedFile_!=nil &&
                [[IBsource_ stringValue] isEqualTo:@"-"]==NO &&
                [tFileNode type]==kRealItemNode);
    }
    else if (tAction==@selector(switchPermissions:))
    {
        /*if (selectedFile_!=nil)
        {
            return (([tFileNode type]==kRealItemNode && [tFileNode link]==NO) || [tFileNode type]==kNewFolderNode);
        }
        else*/
        {
            return canEditPermission_;
        }
    }
    
    return YES;
}

- (IBAction) revealSourceInFinder:(id) sender
{
    NSWorkspace * tWorkSpace;
    PBFileNode * tFileNode;
        
    tFileNode=FILENODE_DATA(selectedFile_);
        
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[tFileNode path] inFileViewerRootedAtPath:@""];
}

- (IBAction) switchPermissions:(id) sender
{
    int tPermissions;
    
    tPermissions=[[sender selectedItem] tag];
    
    if (selectedFile_!=nil)
    {
        if (tPermissions!=[FILENODE_DATA(selectedFile_) privileges])
        {
            [FILENODE_DATA(selectedFile_) setPrivileges:tPermissions];
            
            [IBpermissions_ setStringValue:[FILENODE_DATA(selectedFile_) privilegesStringRepresentation]];
            
            [IBpermissionsArray_ reloadData];
            
            [IBspecialBitsArray_ reloadData];
            
            [self postFileAttributesNotification:NO];
        }
    }
    else
    {
        if (tPermissions!=(cachedPermission_ & ~mixedPermission_))
        {
            NSEnumerator * tEnumerator;
            PBFileNode * tFileNode;
            
            cachedPermission_=tPermissions;
            
            mixedPermission_=0;
            
            tEnumerator=[selectedFiles_ objectEnumerator];
            
            while (tFileNode=FILENODE_DATA([tEnumerator nextObject]))
            {
                [tFileNode setPrivileges:cachedPermission_];
            }
            
            [IBpermissions_ setStringValue:[PBFileNode privilegesStringRepresentationWithPermission:cachedPermission_ mixedPermission:mixedPermission_ statType:cachedStatType_]];
            
            [IBpermissionsArray_ reloadData];
            
            [IBspecialBitsArray_ reloadData];
            
            [self postFileAttributesNotification:NO];
        }
    }
}

#pragma mark -

- (void)viewListView:(MOViewListView *)viewListView didExpandViewListViewItem:(MOViewListViewItem *)viewListViewItem
{
    NSRect tWindowFrame;
    
    tWindowFrame=[IBwindow_ frame];
    
    tWindowFrame.size.height+=NSHeight([[viewListViewItem view] frame]);
    
    tWindowFrame.origin.y-=NSHeight([[viewListViewItem view] frame]);
    
    if (tWindowFrame.origin.y<0)
    {
        tWindowFrame.origin.y=0;
    }
    
    if (_awakeFromNibEnded==YES)
    {
        [IBwindow_ setFrame:tWindowFrame display:YES];
    }
}

- (void)viewListView:(MOViewListView *)viewListView didCollapseViewListViewItem:(MOViewListViewItem *)viewListViewItem
{
    NSRect tWindowFrame;
    
    tWindowFrame=[IBwindow_ frame];
    
    tWindowFrame.size.height-=NSHeight([[viewListViewItem view] frame]);
    
    tWindowFrame.origin.y+=NSHeight([[viewListViewItem view] frame]);
    
    if (_awakeFromNibEnded==YES)
    {
        [IBwindow_ setFrame:tWindowFrame display:YES];
    }
}

#pragma mark -

- (void) ruleEditionDidEndWithDictionary:(NSDictionary *) inDictionary edit:(BOOL) inEdit
{
    if (inEdit==YES)
    {
        NSDictionary * nDictionary;
        NSNumber * tStatus;
        int tSelectedRow;
        
        tSelectedRow=[IBrulesArray_ selectedRow];
        
        tStatus=[[rulesArray_ objectAtIndex:tSelectedRow] objectForKey:@"Status"];
        
        nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[inDictionary objectForKey:@"Name"],@"Name",
                                                               tStatus,@"Status",
                                                               [inDictionary objectForKey:@"Attributes"],@"Attributes",
                                                               nil];
    
        [rulesArray_ replaceObjectAtIndex:tSelectedRow
                               withObject:nDictionary];
    }
    else
    {
        NSDictionary * nDictionary;
        
        nDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[inDictionary objectForKey:@"Name"],@"Name",
                                                               [NSNumber numberWithBool:YES],@"Status",
                                                               [inDictionary objectForKey:@"Attributes"],@"Attributes",
                                                               nil];
    
        if (rulesArray_==nil)
        {
            rulesArray_=[NSMutableArray arrayWithCapacity:5];
            
            [FILENODE_DATA(selectedFile_) setSearchRules:rulesArray_];
            
            rulesArray_=[FILENODE_DATA(selectedFile_) searchRules];
        }
         
        [rulesArray_ addObject:nDictionary];
    }

    [IBrulesArray_ reloadData];

    if (inEdit==NO)
    {
        [IBrulesArray_ selectRow:([rulesArray_ count]-1) byExtendingSelection:NO];
    }
    
    [self postFileAttributesNotification:NO];
}

- (IBAction) addRule:(id) sender
{
    NSDictionary * tDictionary;
    NSDictionary * tAttributes;
    NSBundle * tBundle=nil;
    NSString * tBundleIdentifier=nil;
    NSString * tOSCreator=nil;
    PBFileNode * tFileNode;
        
    tFileNode=FILENODE_DATA(selectedFile_);
        
    // Check whether the file is a bundle or not
    
    if ([tFileNode type]==kRealItemNode)
    {
	tBundle=[NSBundle bundleWithPath:[tFileNode path]];
    }
    
    if (tBundle!=nil)
    {
        NSDictionary * tInfoDictionary;
        
        tInfoDictionary=[tBundle infoDictionary];
        
        tBundleIdentifier=[tInfoDictionary objectForKey:@"CFBundleIdentifier"];
        
        tOSCreator=[tInfoDictionary objectForKey:@"CFBundleSignature"];
        
    }
    
    tAttributes=[NSDictionary dictionaryWithObjectsAndKeys:@"CheckPath",@"searchPlugin",
                                                           [selectedFile_ filePath],@"path",
                                                           @"/",@"startingPoint",
                                                           @"findOne",@"successCase",
                                                           [NSNumber numberWithInt:6],@"maxDepth",
                                                           [NSArray arrayWithObjects:@"/System",@"/Developer",@"/AppleInternal",nil],@"excludedDirs",
                                                           @"",@"minVersion",	// To be completed
                                                           @"",@"maxVersion",	// To be completed
                                                           tBundleIdentifier,@"identifier",	// Can be nil
                                                           tOSCreator,@"creator",	// Can be nil
                                                           nil];
    
    // Get an unique name
    
    tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[self uniqueNameForRule],@"Name",
                                                           [NSNumber numberWithBool:YES],@"Status",
                                                           tAttributes,@"Attributes",
                                                           nil];
    
    [searchRuleEditorController_ showSearchRulePanelForInspector:self dictionary:tDictionary edit:NO];
}

- (IBAction) editRule:(id) sender
{
    if ([IBrulesArray_ numberOfSelectedRows]==1)
    {
        NSDictionary * tDictionary;
    
        tDictionary=[rulesArray_ objectAtIndex:[IBrulesArray_ selectedRow]];
    
        [searchRuleEditorController_ showSearchRulePanelForInspector:self dictionary:tDictionary edit:YES];
    }
}

- (IBAction) removeRule:(id) sender
{
    int tResult;
    NSString * tAlertTitle;
    
    if ([IBrulesArray_ numberOfSelectedRows]==1)
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove this rule?",@"No comment");
    }
    else
    {
        tAlertTitle=NSLocalizedString(@"Do you really want to remove these rules?",@"No comment");
    }
    
    tResult=NSRunAlertPanel(tAlertTitle, 
                            NSLocalizedString(@"This cannot be undone.",@"No comment"),
                            NSLocalizedString(@"Remove",@"No comment"),
                            NSLocalizedString(@"Cancel",@"No comment"),
                            nil);
    
    if (NSAlertDefaultReturn==tResult)
    {
        NSEnumerator * tEnumerator;
        NSArray * tArray;
        int i,tCount;
        
        tEnumerator=[IBrulesArray_ selectedRowEnumerator];
        
        tArray=[tEnumerator allObjects];
        
        tCount=[tArray count];
        
        for(i=tCount-1;i>=0;i--)
        {
            [rulesArray_ removeObjectAtIndex:[[tArray objectAtIndex:i] intValue]];
        }
        
        [IBrulesArray_ deselectAll:nil];
        
        [IBrulesArray_ reloadData];
        
        [self postFileAttributesNotification:NO];
    }
}

#pragma mark -

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    [pboard declareTypes:[NSArray arrayWithObject: PBSearchRulePBoardType] owner:self];
    
    [pboard setData:[NSData data] forType:PBSearchRulePBoardType]; 

    internalDragData_=rows;
        
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if (op==NSTableViewDropAbove)
    {
        NSPasteboard * tPasteBoard;
        
        tPasteBoard=[info draggingPasteboard];
    
    	if ([info draggingSource]==IBrulesArray_)
        {
            if ([internalDragData_ count]==1)
            {
                int tOriginalRow=[[internalDragData_ objectAtIndex:0] intValue];
            
                if (tOriginalRow!=row && row!=(tOriginalRow+1))
                {
                    return NSDragOperationMove;
                }
            }
            else
            {
                return NSDragOperationMove;
            }
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard * tPasteBoard;
    int i,tCount;
    int tRowIndex;
    int tOriginalRow=row;
    NSMutableArray * tTemporaryArray;
    NSDictionary * tRule;
    
    tPasteBoard=[info draggingPasteboard];
    
    tCount=[internalDragData_ count];
    
    [IBrulesArray_ deselectAll:nil];
    
    tTemporaryArray=[NSMutableArray array];
    
    for(i=tCount-1;i>=0;i--)
    {
        tRowIndex=[[internalDragData_ objectAtIndex:i] intValue];
        
        tRule=[rulesArray_ objectAtIndex:tRowIndex];
        
        [tTemporaryArray insertObject:tRule atIndex:0];
        
        [rulesArray_ removeObjectAtIndex:tRowIndex];
        
        if (tRowIndex<tOriginalRow)
        {
            row--;
        }
    }
    
    for(i=tCount-1;i>=0;i--)
    {
        tRule=[tTemporaryArray objectAtIndex:i];
        
        [rulesArray_ insertObject:tRule atIndex:row];
    }
    
    [IBrulesArray_ reloadData];
    
    for(i=0;i<tCount;i++)
    {
        [IBrulesArray_ selectRow:row++ byExtendingSelection:YES];
    }
    
    [self postFileAttributesNotification:NO];
    
    return YES;
}

- (NSString *) uniqueNameForRule
{
    int _sIndex=0;
    static NSString * tLocalizedBaseName=nil;
    int i,tCount;
    NSString * tString;
    
    if (tLocalizedBaseName==nil)
    {
        tLocalizedBaseName=[[NSString alloc] initWithString:NSLocalizedString(@"Untitled Rule",@"No comment")];
    }
    
    tCount=[rulesArray_ count];
    
    do
    {
        NSDictionary * tDictionary;
        
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
            tDictionary=[rulesArray_ objectAtIndex:i];
            
            if ([[tDictionary objectForKey:@"Name"] isEqualToString:tString]==YES)
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
