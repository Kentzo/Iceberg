#import "PBBuildWindowController.h"
#import "ImageAndTextCell.h"

#import "PBPreferencePaneBuildController+Constants.h"
#import "PBPreferencePaneFilesController+Constants.h"

#import "BuildingNotification+Constants.h"

#import "PBSharedConst.h"

#define SAFE_BUILDNODE(n) 	((PBBuildTreeNode*)((n!=nil)?(n):(tree_)))

static NSImage * sBuildInProgressIcon=nil;
static NSImage * sBuildSuccessIcon=nil;
static NSImage * sBuildFailureIcon=nil;

@implementation PBBuildWindowController

- (void) awakeFromNib
{
    NSTableColumn *tableColumn = nil;
    ImageAndTextCell *imageAndTextCell = nil;
    
    tableColumn = [IBoutlineView_ tableColumnWithIdentifier: @"build"];
    imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setFont:[NSFont labelFontOfSize:11.0f]];
    [imageAndTextCell setEditable:NO];
    [imageAndTextCell setWraps:NO];
    [tableColumn setDataCell:imageAndTextCell];
    
    [imageAndTextCell release];
    
    [IBoutlineView_ setAutoresizesOutlineColumn:NO];
    
    // Window Title
    
    [IBwindow_ setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ - Build Log",@"No commets"),[[[document_ fileName] lastPathComponent] stringByDeletingPathExtension]]];
    
    // Register for document Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(buildDidStart:)
                                                name:@"buildDidStart"
                                              object:document_];
    
    // Register for Builder Notifications
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(builderNotification:)
                                                            name:@"ICEBERGBUILDERNOTIFICATION"
                                                          object:nil
                                                          suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(builderNotification:)
                                                 name:@"ICEBERGBUILDERNOTIFICATION"
                                               object:nil];
    
    if (sBuildInProgressIcon==nil)
    {
        sBuildInProgressIcon=[[NSImage imageNamed:@"buildInProgress12"] copy];
        
        sBuildSuccessIcon=[[NSImage imageNamed:@"buildSuccess12"] copy];
        
        sBuildFailureIcon=[[NSImage imageNamed:@"buildFailure12"] copy];
    }
    
    defaults_=[NSUserDefaults standardUserDefaults];
    
    [IBwindow_ center];
}

#pragma mark -

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        statusAttributesDictionary_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,
                                                                               nil];
        
        explanationAttributesDictionary_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,
                                                                               nil];
    }
    
    return self;
}

- (void) dealloc
{
    [statusAttributesDictionary_ release];
    
    [explanationAttributesDictionary_ release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
        
    if (tree_!=nil)
    {
        [tree_ release];
    }
    
    [super dealloc];
}

#pragma mark -

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSArray * tSubviews;
    NSView * tViewTop,* tViewBottom;
    NSRect tTopFrame,tBottomFrame;
    NSRect tSplitViewFrame=[sender frame];
    
    tSubviews=[sender subviews];
    
    tViewTop=[tSubviews objectAtIndex:0];
    
    tTopFrame=[tViewTop frame];
    
    tViewBottom=[tSubviews objectAtIndex:1];
    
    tBottomFrame=[tViewBottom frame];
        
    tTopFrame.size.height=NSHeight(tSplitViewFrame)-[sender dividerThickness]-NSHeight(tBottomFrame);
    
    
    tTopFrame.origin.y=NSHeight(tBottomFrame)+[sender dividerThickness];
    
    [tViewTop setFrame:tTopFrame];
    
    
    tBottomFrame.size.height=NSHeight(tBottomFrame);
        
    tBottomFrame.origin.y=0;
        
    [tViewBottom setFrame:tBottomFrame];
    
    [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
    return (NSHeight([sender frame])-[sender dividerThickness]-5.0f);
}

#pragma mark -

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
    if (tree_!=nil)
    {
        return [SAFE_BUILDNODE(item) childAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
    return ![PBBUILDNODE_DATA(item) isLeaf];
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
    if (tree_!=nil)
    {
        return [SAFE_BUILDNODE(item) numberOfChildren];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if([[tableColumn identifier] isEqualToString: @"build"])
    {
        return [PBBUILDNODE_DATA(item) title];
    }
    
    return nil;
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([[tableColumn identifier] isEqualToString: @"build"])
    {
        NSImage * tImage=nil;
        int tType;
        
        tType=[PBBUILDNODE_DATA(item) type];
        
        switch([PBBUILDNODE_DATA(item) status])
        {
            case PBBUILDTREE_STATUS_RUNNING:
                tImage=sBuildInProgressIcon;
        	break;
            case PBBUILDTREE_STATUS_SUCCESS:
                tImage=sBuildSuccessIcon;
                break;
            case PBBUILDTREE_STATUS_FAILURE:
                tImage=sBuildFailureIcon;
                break;
        }
        
        [(ImageAndTextCell*)cell setImage: tImage];
        
        if (tType==PBBUILDTREE_TYPE_STEP_FAILED ||
            tType==PBBUILDTREE_TYPE_STEP)
        {
            [(ImageAndTextCell*)cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        }
        else
        {
            [(ImageAndTextCell*)cell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
        }
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int tSelectionCount;
    
    tSelectionCount=[IBoutlineView_ numberOfSelectedRows];

    if (tSelectionCount==1)
    {
        NSTextStorage * tTextStorage;
        NSAttributedString * tStatusAttributedString;
        NSAttributedString * tExplanationAttributedString=nil;
        NSString * tExplanationString;
        int tSelectedRow;
        int tType;
        id tObject;
        
        tSelectedRow=[IBoutlineView_ selectedRow];
        
        tObject=[IBoutlineView_ itemAtRow:tSelectedRow];
        
        tType=[PBBUILDNODE_DATA(tObject) buildType];
        
        tStatusAttributedString=[[NSAttributedString alloc] initWithString:[PBBUILDNODE_DATA(tObject) title] attributes:statusAttributesDictionary_];
        
        if (tType>=kPBErrorUnknown)
        {
            NSString * tString;
            
            tString=[NSString stringWithFormat:@"Detail %d",tType];
            
            tExplanationString=[NSString stringWithFormat:@"\n\n%@",NSLocalizedStringFromTable(tString,@"BuildDetails",@"No comment")];
            
            tExplanationAttributedString=[[NSAttributedString alloc] initWithString:tExplanationString attributes:explanationAttributesDictionary_];
        }
        
        tTextStorage=[IBdetailView_ textStorage];
        
        [tTextStorage beginEditing];
                   
        [tTextStorage setAttributedString:tStatusAttributedString];
        
        //[tStatusAttributedString release];
        
        if (tExplanationAttributedString!=nil)
        {
            [tTextStorage appendAttributedString:tExplanationAttributedString];
            
            [tExplanationAttributedString release];
        }
        
        [tTextStorage endEditing];
    }
    else
    {
        // Clean the text view
        
        [IBdetailView_ setString:@""];
    }
}

#pragma mark -

- (NSWindow *) window
{
    return IBwindow_;
}

- (BOOL) validateMenuItem:(NSMenuItem *)aMenuItem
{    
    SEL tAction=[aMenuItem action];
    
    if (tAction==@selector(showHideBuildWindow:))
    {
        [aMenuItem setTitle:NSLocalizedString(@"Hide Build Log Window",@"No comment")];
        
        return YES;
    }
    
    return YES;
}

#pragma mark -

- (IBAction) showHideBuildWindow:(id) sender
{
    [IBwindow_ orderOut:nil];
}

- (IBAction) build:(id) sender
{
    if (document_!=nil)
    {
        [document_ build:sender];
    }
}

- (IBAction) buildAndRun:(id) sender
{
    if (document_!=nil)
    {
        [document_ buildAndRun:sender];
    }
}

- (IBAction) preview:(id) sender
{
    if (document_!=nil)
    {
        [document_ preview:sender];
    }
}

- (IBAction) clean:(id) sender
{
    if (document_!=nil)
    {
        [document_ clean:sender];
    }
}

- (IBAction) hideWindow:(id)sender
{
    [IBwindow_ orderOut:sender];
}

- (IBAction) showWindow:(id)sender cleanWindow:(BOOL) inCleanWindow
{
	if (inCleanWindow==YES)
	{
		[IBstatusLabel_ setStringValue:@""];
	}

    [IBwindow_ makeKeyAndOrderFront:sender];
}

#pragma mark -

- (void) buildDidStart:(NSNotification *)notification
{
    if (tree_!=nil)
    {
        [tree_ release];
        tree_=nil;
    }
    
    tree_=[[PBBuildTreeNode buildTree] retain];
    
    if (tree_!=nil)
    {
        PBBuildNodeData * tProjectNodeData;
        NSString * tProjectNodeTitle;
    
        tProjectNodeTitle=[NSString stringWithFormat:NSLocalizedString(@"Building project \"%@\"",@"No comment"),[[[document_ fileName] lastPathComponent] stringByDeletingPathExtension]];
    
        tProjectNodeData=[PBBuildNodeData nodeWithTitle:tProjectNodeTitle
                                                type:PBBUILDTREE_TYPE_PROJECT
                                                buildType:0
                                                status:-1];
        
        currentBuildNode_=[[PBBuildTreeNode alloc] initWithData:tProjectNodeData
                                                parent:nil
                                            children:[NSArray array]];
        
        
        
        [tree_ insertChild: currentBuildNode_
                atIndex: 0];
				
		[currentBuildNode_ release];
                
        // Disclose the content of the project tree
    }
                
    [IBoutlineView_ reloadData];
    
    [IBoutlineView_ expandItem:currentBuildNode_];
}

- (void) updateBuildTreeWithCode:(int) inStatusCode arguments:(NSArray *) inArguments
{
    PBBuildTreeNode * tBuildTreeNode;
    PBBuildNodeData * tProjectNodeData;
    int tStatus=PBBUILDTREE_STATUS_RUNNING;
    int tType=PBBUILDTREE_TYPE_STEP;
    NSString * tTitle=nil;
    BOOL needsToDiscloseCurrentBuildNode=NO;
    id tFirstArgument=nil;
    
    if (inArguments!=nil &&[inArguments count]>0)
    {
        tFirstArgument=[inArguments objectAtIndex:0];
    }
    
    
    switch(inStatusCode)
    {
        case kPBBuildingPackage:
        case kPBBuildingMetapackage:
            tBuildTreeNode=(PBBuildTreeNode *) [currentBuildNode_ lastChild];
        
            if (tBuildTreeNode!=nil)
            {
                if ([PBBUILDNODE_DATA(tBuildTreeNode) type]==PBBUILDTREE_TYPE_STEP)
                {
                    [PBBUILDNODE_DATA(tBuildTreeNode) setStatus:PBBUILDTREE_STATUS_SUCCESS];
                }
            }
            
            if (inStatusCode==kPBBuildingPackage)
            {
                tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_PACKAGE,@"No comment"),tFirstArgument];
            }
            else
            {
                tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_METAPACKAGE,@"No comment"),tFirstArgument];
            }
            
            tProjectNodeData=[PBBuildNodeData nodeWithTitle:tTitle
                                                       type:PBBUILDTREE_TYPE_COMPONENT
                                                  buildType:inStatusCode
                                                     status:tStatus];
    
            tBuildTreeNode=[[PBBuildTreeNode alloc] initWithData:tProjectNodeData
                                                          parent:nil
                                                        children:[NSArray array]];
            [currentBuildNode_ insertChild: tBuildTreeNode
                           atIndex: [currentBuildNode_ numberOfChildren]];
            
            currentBuildNode_=tBuildTreeNode;
            
            [IBoutlineView_ reloadData];
            
            [IBoutlineView_ expandItem:currentBuildNode_];
            
            return;
            
        case kPBBuildingComponentSucceeded:
            
            tBuildTreeNode=(PBBuildTreeNode *) [currentBuildNode_ lastChild];
        
            if (tBuildTreeNode!=nil)
            {
                [PBBUILDNODE_DATA(tBuildTreeNode) setStatus:PBBUILDTREE_STATUS_SUCCESS];
            }
            
            [PBBUILDNODE_DATA(currentBuildNode_) setStatus:PBBUILDTREE_STATUS_SUCCESS];
            
            tBuildTreeNode=currentBuildNode_;

            currentBuildNode_=(PBBuildTreeNode *) [currentBuildNode_ nodeParent];
           
            [IBoutlineView_ reloadData];
            
            [IBoutlineView_ collapseItem:tBuildTreeNode];
            
            return;
            
        case kPBBuildingArchive:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_ARCHIVE,@"No comment");
            break;
        case kPBBuildingSplittingForks:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_SPLITTING_FORKS,@"No comment");
            break;
        case kPBBuildingBom:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_BOM,@"No comment");
            break;			
        case kPBBuildingPax:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_PAX,@"No comment");
            break;			
        case kPBBuildingCleaning:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_CLEANING,@"No comment");
            break;		
        
        case kPBDebugInfo:
            NSLog(@"%d %@",inStatusCode,[inArguments description]);
            return;
        
        case kPBBuildingPreparingBuildFolder:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_PREPARING_BUILD_FOLDER,@"No comment");
            break;
        case kPBBuildingCreateInfoPlist:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_CREATING_INFOPLIST,@"No comment");
            break;
        case kPBBuildingCreateDescriptionPlist:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_CREATING_DESCRIPTIONPLIST,@"No comment");
            break;
        case kPBBuildingCopyBackgroundImage:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_BACKGROUNDIMAGE,@"No comment"),[tFirstArgument lastPathComponent]];
            break;
        case kPBBuildingCopyWelcomeMessage:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_WELCOMEMESSAGE,@"No comment");
            break;
        case kPBBuildingCopyReadMeMessage:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_READMEMESSAGE,@"No comment");
            break;
        case kPBBuildingCopyLicenseDocuments:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_LICENSEDOCUMENTS,@"No comment");
            break;
		
		case kPBBuildingBuildRequirements:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_REQUIREMENTS,@"No comment");
            break;
        case kPBBuildingCopyScripts:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_SCRIPTS,@"No comment");
            break;
		 case kPBBuildingCopyingPlugins:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_PLUGINS,@"No comment");
            break;
        case kPBBuildingCopyAdditionalResources:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_ADDITIONALRESOURCES,@"No comment");
            break;
        case kPBBuildingCreatePackageVersion:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_CREATING_PACKAGEVERSION,@"No comment");
            break;
        case kPBBuildingCreateTokenDefinitionsPlist:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_CREATING_TOKENDEFINITIONSPLIST,@"No comment");
            break;
        case kPBBuildingCopyingBom:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_BOM,@"No comment");
            break;
        case kPBBuildingCopyingPax:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_PAX,@"No comment");
            break;
        
        case kPBErrorUnknown:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_UNKNOWNERROR,@"No comment"),tFirstArgument];
            break;
        case kPBErrorCantCreateFolder:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_CREATEFOLDER,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
            break;
        case kPBErrorCantCreateFile:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_CREATEFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
            break;
        case kPBErrorCantCopyFile:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_COPYFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent],[[inArguments objectAtIndex:1] stringByDeletingLastPathComponent]];
            break;
        case kPBErrorCantRemoveFile:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_REMOVEFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
            break;
        case kPBErrorFileDoesNotExist:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_FILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
            break;
        case kPBErrorIncorrectFileType:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_INCORRECT_FILE_TYPE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
            break;
        case kPBErrorInsufficientPrivileges:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_INSUFFICIENT_PRIVILEGES,@"No comment"),tFirstArgument];
            break;
        case kPBErrorInsufficientPrivilegesSet:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SET_INSUFFICIENT_PRIVILEGES,@"No comment"),tFirstArgument];
            break;
        case kPBErrorMissingInformation:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_INFORMATION,@"No comment"),tFirstArgument];
            break;
        case kPBErrorOutOfMemory:
            tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_OUT_OF_MEMORY,@"No comment");
            break;
        case kPBErrorPackageSameNames:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_TWIN_COMPONENTS,@"No comment"),tFirstArgument];
            break;
        case kPBErrorPaxFailed:
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setStatus:PBBUILDTREE_STATUS_FAILURE];
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setTitle:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_PAX_FAILED,@"No comment")];
            break;
        case kPBErrorBomFailed:
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setStatus:PBBUILDTREE_STATUS_FAILURE];
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setTitle:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_BOM_FAILED,@"No comment")];
            break;
        case kPBErrorCantCleanFolder:
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setStatus:PBBUILDTREE_STATUS_FAILURE];
            [PBBUILDNODE_DATA([currentBuildNode_ lastChild]) setTitle:NSLocalizedString(PB_BUILDNOTIFICATION_CLEANING_FAILED,@"No comment")];
            break;
        case kPBErrorScratchDoesNotExist:
            tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_SCRATCH_FOLDER,@"No comment"),tFirstArgument];
            break;
        case kPBErrorMissingLicenseTemplate:
            if ([inArguments count]>1)
			{
				tTitle=[NSString stringWithFormat:NSLocalizedString(@"License template (%@): %@ localization is missing.",@"No comment"),tFirstArgument,[inArguments objectAtIndex:1]];
			}
			else
			{
				if (tFirstArgument==nil)
				{
					tFirstArgument=@"";
				}
				
				tTitle=[NSString stringWithFormat:NSLocalizedString(@"License template (%@): Missing Template",@"No comment"),tFirstArgument];
			}
            break;
			
		case kPBErrorFolderDoesNotExist:
			tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_FOLDER_DOES_NOT_EXIST,@"No comment"),tFirstArgument];
            break;
		
		case kPBErrorMissingSplitForksMissingTool:
			{
				NSString * tToolPath=nil;
				
				if ([tFirstArgument isEqualToString:SPLITFORKSTOOL_GOLDIN]==YES)
				{
					tToolPath=@"/usr/local/bin/goldin";
				}
				else if ([tFirstArgument isEqualToString:SPLITFORKSTOOL_SPLITFORKS]==YES)
				{
					tToolPath=@"/Developer/Tools/SplitForks";
				}
				
				tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_MISSINGTOOL,@"No comment"),tFirstArgument,tToolPath];
			}
			break;
		case kPBErrorMissingSplitForksNonHFSVolume:
			tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_NONHFSVOLUME,@"No comment"),tFirstArgument];
			break;
		case kPBErrorMissingSplitForksError:
			tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_ERROR,@"No comment"),tFirstArgument];
			break;
    }
    
    if (tTitle==nil)
    {
        tTitle=@"Description forthcoming";
    }
    
    if (inStatusCode<kPBErrorUnknown)
    {
        tBuildTreeNode=(PBBuildTreeNode *) [currentBuildNode_ lastChild];
        
        if (tBuildTreeNode!=nil)
        {
            [PBBUILDNODE_DATA(tBuildTreeNode) setStatus:PBBUILDTREE_STATUS_SUCCESS];
        }
    }
    else
    {
        PBBuildTreeNode * tTreeNode;
        
        tStatus=PBBUILDTREE_STATUS_FAILURE;
        
        // We need to retrofeed the failure status to all the direct parent
        
        tTreeNode=currentBuildNode_;
        
        while (tTreeNode!=nil && [PBBUILDNODE_DATA(tTreeNode) type]!=PBBUILDTREE_TYPE_PROJECT)
        {
            [PBBUILDNODE_DATA(tTreeNode) setStatus:PBBUILDTREE_STATUS_FAILURE];
            
            tTreeNode=(PBBuildTreeNode *) [tTreeNode nodeParent];
        }
        
        // If the previous item is a step, we need to switch it to a step failed
        
        tBuildTreeNode=(PBBuildTreeNode *) [currentBuildNode_ lastChild];
        
        if (tBuildTreeNode!=nil)
        {
            [PBBUILDNODE_DATA(tBuildTreeNode) setType:PBBUILDTREE_TYPE_STEP_FAILED];
            
            [PBBUILDNODE_DATA(tBuildTreeNode) setStatus:PBBUILDTREE_STATUS_FAILURE];
            
            currentBuildNode_=tBuildTreeNode;
            
            needsToDiscloseCurrentBuildNode=YES;
        }
    }
    
    tProjectNodeData=[PBBuildNodeData nodeWithTitle:tTitle
                                               type:tType
                                            buildType:inStatusCode
                                             status:tStatus];
    
    if (tProjectNodeData!=nil)
    {
        tBuildTreeNode=[[PBBuildTreeNode alloc] initWithData:tProjectNodeData
                                                  parent:nil
                                                children:[NSArray array]];
        
        if (tBuildTreeNode!=nil)
        {
            [currentBuildNode_ insertChild: tBuildTreeNode
                                atIndex: [currentBuildNode_ numberOfChildren]];
        
            [tBuildTreeNode release];
			
			[IBoutlineView_ reloadData];
            
            if (needsToDiscloseCurrentBuildNode==YES)
            {
                [IBoutlineView_ expandItem:currentBuildNode_];
            }
        }
    }
}

- (void) builderNotification:(NSNotification *)notification
{
    NSDictionary * tUserInfo;
    static int sProcessID=-1;
    
    if (sProcessID==-1)
    {
        sProcessID=[[NSProcessInfo processInfo] processIdentifier];
    }
    
    tUserInfo=[notification userInfo];
    
    if (tUserInfo!=nil)
    {
        NSNumber * tNumber;
        
        tNumber=[tUserInfo objectForKey:@"Process ID"];
        
        if (tNumber!=nil)
        {
            if ([tNumber intValue]==sProcessID)
            {
                NSString * tPath;
                
                tPath=[tUserInfo objectForKey:@"Project Path"];
                
                if (tPath!=nil)
                {
                    if ([tPath isEqualToString:[document_ fileName]]==YES)
                    {
                        int tStatusCode;
                        NSArray * tArguments;
                        
                        tStatusCode=[[tUserInfo objectForKey:@"Code"] intValue];
                        
                        // This is the document concerned by the Notification
                        
                        tArguments=[tUserInfo objectForKey:@"Arguments"];
                        
                        // Display the Build Status
                        
                        switch(tStatusCode)
                        {
                            case kPBBuildingStart:
                                [IBstatusLabel_ setStringValue:NSLocalizedString(@"Building...",@"No comment")];
                                return;
                            case kPBBuildingComplete:
                                [IBstatusLabel_ setStringValue:NSLocalizedString(@"Build succeeded",@"No comment")];
                                
                                if ([defaults_ integerForKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW]!=PBPREFERENCEPANE_BUILD_HIDEWINDOW_NEVER)
                                {
                                    [IBwindow_ orderOut:nil];
                                }
                                
                                return;
							case kPBNotificationBuildCancelledUnsavedFile:
								[IBstatusLabel_ setStringValue:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDCANCELLED_UNSAVEDFILE,@"No comment")];
								
								if (tree_!=nil)
								{
									[tree_ release];
									tree_=nil;
								}
								
								[IBoutlineView_ reloadData];
								
								if ([defaults_ integerForKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW]==PBPREFERENCEPANE_BUILD_HIDEWINDOW_ALWAYS)
                                {
                                    [IBwindow_ orderOut:nil];
                                }
								
								return;
								
							case kPBNotificationCleanBuildSuccess:
								
								[IBstatusLabel_ setStringValue:NSLocalizedString(@"Clean Succeeded",@"No comment")];
								
								if (tree_!=nil)
								{
									[tree_ release];
									tree_=nil;
								}
								
								[IBoutlineView_ reloadData];
								
								return;
								
                            default:
                                if (tStatusCode>=kPBErrorUnknown)
                                {
                                    [IBstatusLabel_ setStringValue:NSLocalizedString(@"Build failed",@"No comment")];
                                    
                                    if ([defaults_ integerForKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW]==PBPREFERENCEPANE_BUILD_HIDEWINDOW_ALWAYS)
                                    {
                                        [IBwindow_ orderOut:nil];
                                    }
                                    else
                                    if ([defaults_ integerForKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW]==PBPREFERENCEPANE_BUILD_SHOWWINDOW_ONERRORS)
                                    {
                                        [IBwindow_ makeKeyAndOrderFront:nil];
                                    }
                                }
                                break;
                        }
                        
                        [self updateBuildTreeWithCode:tStatusCode arguments:tArguments];
                    }
                }
            }
        }
    }
}

@end
