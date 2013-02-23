/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectAssistantController.h"

#import "PBProjectAssistantStartPaneController.h"
#import "PBProjectAssistantPaneController.h"

#import "PBProjectTree.h"

@implementation PBProjectAssistantController

+ (id) sharedProjectAssistantController
{
    static PBProjectAssistantController * sProjectAssistantController=nil;
    
    if (sProjectAssistantController==nil)
    {
        sProjectAssistantController=[PBProjectAssistantController new];
    }
    
    return sProjectAssistantController;
}

- (void) awakeFromNib
{
    fileManager_=[NSFileManager defaultManager];
}

- (void) dealloc
{
    [projectAssistantInfoArray_ release];
    
    [projectAssistantControllerArray_ release];

    [super dealloc];
}

#pragma mark -

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSArray * tSubviews;
    NSView * tTopView,* tBottomView;
    NSRect tTopFrame,tBottomFrame;
    NSRect tSplitViewFrame=[sender frame];
    
    tSubviews=[sender subviews];
    
    tTopView=[tSubviews objectAtIndex:0];
    
    tTopFrame=[tTopView frame];
    
    tBottomView=[tSubviews objectAtIndex:1];
    
    tBottomFrame=[tBottomView frame];
    
    tTopFrame.size.height=NSHeight(tSplitViewFrame)-[sender dividerThickness]-NSHeight(tBottomFrame);
    
    tTopFrame.size.width=NSWidth(tSplitViewFrame);
    
    [tTopView setFrame:tTopFrame];
    
    tBottomFrame.size.width=NSWidth(tSplitViewFrame);
    
    tBottomFrame.origin.y=NSHeight(tSplitViewFrame)-NSHeight(tBottomFrame);
    
    [tBottomView setFrame:tBottomFrame];
}

#pragma mark -

- (void) createNewProject
{
    NSRect tContentRect;
    
    if (IBwindow_==nil)
    {
        if ([NSBundle loadNibNamed:@"Project Creation Assistant" owner:self]==NO)
        {
            NSLog(@"A problem occured while loading the nib file \"Project Creation Assistant\".");
            
            NSBeep();
            
            return;
        }
    }
    
    tContentRect=[[IBwindow_ contentView] frame];

    // Create the new Process Engine
    
    [assistantEngine_ release];
    
    assistantEngine_=[PBProjectAssistantEngine new];
    
    // Initialize the Start and Stop controller
    
    [startPaneController_ setMainController:self];
    
    [stopPaneController_ setMainController:self];
    
    // Clean the UI
    
    if (currentRelativeRootView_!=nil)
    {
        [currentRelativeRootView_ removeFromSuperview];
    }
    
    [IBassistantProjectType_ setStringValue:NSLocalizedString(@"New Project",@"No comment")];
    
    [IBnextButton_ setTitle:NSLocalizedString(@"Next",@"No comment")];
    
    [IBpreviousButton_ setEnabled:NO];
    [IBnextButton_ setEnabled:NO];
    
    currentPaneIndex_=0;
    
    currentPaneController_=startPaneController_;
    
    currentRelativeRootView_=[currentPaneController_ relativeRootView];
    
    [[IBpreviousButton_ superview] addSubview:currentRelativeRootView_];
    
    [currentRelativeRootView_ setFrame:NSMakeRect(0,60,NSWidth(tContentRect),NSHeight(tContentRect)-154.0)];
    
    [startPaneController_ initPaneWithEngine:assistantEngine_];
    
    [NSApp runModalForWindow:IBwindow_];
}

#pragma mark -

- (PBProjectAssistantPaneController *) paneControllerAtIndex:(int) inIndex
{
    int tArrayCount=[projectAssistantControllerArray_ count];
    
    if (inIndex>=0 && inIndex<tArrayCount)
    {
        return [projectAssistantControllerArray_ objectAtIndex:inIndex];
    }
    
    return nil;
}

- (int) indexOfPaneControllerWithName:(NSString *) inName
{
    int tArrayCount=[projectAssistantControllerArray_ count];
    int i;
    
    for(i=0;i<tArrayCount;i++)
    {
        if ([[[projectAssistantInfoArray_ objectAtIndex:i] objectForKey:@"Name"] isEqualToString:inName]==YES)
        {
            return i;
        }
    }
    
    return -1;
}

#pragma mark -

- (IBAction) cancel:(id) sender
{
    [NSApp stopModal];
    
    [IBwindow_ orderOut:self];
}

- (IBAction) next:(id) sender
{
    if ([currentPaneController_ checkPaneValuesWithEngine:assistantEngine_]==YES)
    {
        NSRect tContentRect;
    
        tContentRect=[[IBwindow_ contentView] frame];
        
        if (currentPaneIndex_==([projectAssistantControllerArray_ count]-1))
        {
            // This is the last pane
                
            [self finishSetUp:nil];
        }
        else
        {
            PBProjectAssistantPaneController * tPaneController;
            int tIndex;
            NSString * tNextPaneName;
            
            if (currentPaneIndex_==0)
            {
                // Look for the Plugin.bundle bundle
            
                NSString * tTemplateFolderPath;
                NSString * tPlugInPath;
                BOOL isDirectory;
                NSDictionary * tDictionary;
                
                // Release memory
                
                [projectAssistantInfoArray_ release];
                [projectAssistantControllerArray_ release];
                
                // Initialize projectAssistantInfoArray_
                
                projectAssistantInfoArray_=[[NSMutableArray alloc] initWithCapacity:2];
                
                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"Class Name",
                                                                    @"",@"Nib Name",
                                                                    @"Start",@"Name",
                                                                    nil];
                
                [projectAssistantInfoArray_ addObject:tDictionary];
                
                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"Class Name",
                                                                    @"",@"Nib Name",
                                                                    @"Stop",@"Name",
                                                                    nil];
                
                [projectAssistantInfoArray_ addObject:tDictionary];
                
                // Initialize projectAssistantControllerArray_
                
                projectAssistantControllerArray_=[[NSMutableArray alloc] initWithCapacity:2];
                
                [projectAssistantControllerArray_ addObject:startPaneController_];
                [projectAssistantControllerArray_ addObject:stopPaneController_];
                
                tTemplateFolderPath=[assistantEngine_ templateFolderPath];
                
                tPlugInPath=[tTemplateFolderPath stringByAppendingPathComponent:@"Plugin.bundle"];
                
                if ([fileManager_ fileExistsAtPath:tPlugInPath isDirectory:&isDirectory]==YES && isDirectory==YES)
                {
                    pluginBundle_=[NSBundle bundleWithPath:tPlugInPath];
                    
                    if (pluginBundle_!=nil)
                    {
                        NSString * tPaneListPath;
                        
                        if ([pluginBundle_ load]==YES)
                        {
                            tPaneListPath=[pluginBundle_ pathForResource:@"PaneList" ofType:@"plist"];
                        
                            if (tPaneListPath!=nil)
                            {
                                NSArray * tArray;
                                
                                tArray=[NSArray arrayWithContentsOfFile:tPaneListPath];
                                
                                if (tArray!=nil)
                                {
                                    int i,tCount;
                                    int tLast;
                                    
                                    tCount=[tArray count];
                                    
                                    tLast=[projectAssistantInfoArray_ count]-1;
                                    
                                    // Complete projectAssistantInfoArray_ and projectAssistantControllerArray_
                                    
                                    for(i=0;i<tCount;i++)
                                    {
                                        tDictionary=[tArray objectAtIndex:i];
                                        
                                        if (tDictionary!=nil)
                                        {
                                            id tPaneController;
                                            
                                            [projectAssistantInfoArray_ insertObject:tDictionary atIndex:tLast];
                                            
                                            tPaneController=[NSClassFromString([tDictionary objectForKey:@"Class Name"]) alloc];
                                            
                                            [tPaneController loadPaneNib:[tDictionary objectForKey:@"Nib Name"] withMainController:self];
                                            
                                            [projectAssistantControllerArray_ insertObject:tPaneController atIndex:tLast];
                                            
                                            tLast++;
                                        }
                                    }
                                }
                                else
                                {
                                    NSLog(@"PaneList can't be read");
                                    
                                    // A COMPLETER
                                }
                            }
                            else
                            {
                                NSLog(@"PaneList not found");
                                
                                // A COMPLETER
                            }
                        }
                        else
                        {
                            NSLog(@"Bundle can't be loaded");
                                
                            // A COMPLETER
                        }
                    }
                    else
                    {
                        NSLog(@"bundle can't be initialized");
                        
                        // A COMPLETER
                    }
                }
                else
                {
                    // A COMPLETER
                }
            }
            
            // Set next Pane for the first pane
            
            [startPaneController_ setNextPaneName:[[projectAssistantInfoArray_ objectAtIndex:1] objectForKey:@"Name"]];
            
            tNextPaneName=[currentPaneController_ nextPaneName];
            
            if (tNextPaneName!=nil)
            {
                tIndex=[self indexOfPaneControllerWithName:tNextPaneName];
            }
            else
            {
                tIndex=currentPaneIndex_+1;
            }
            
            tPaneController = [self paneControllerAtIndex:tIndex];
            
            if (tPaneController!=nil)
            {
                // Set up the new content of the box
                
                [currentRelativeRootView_ removeFromSuperview];
                
                [[IBpreviousButton_ superview]  addSubview:[tPaneController relativeRootView]];
                
                currentRelativeRootView_=[tPaneController relativeRootView];
                
                [currentRelativeRootView_ setFrame:NSMakeRect(0,60,NSWidth(tContentRect),NSHeight(tContentRect)-154.0)];
            }
            else
            {
                NSLog(@"The next pane was not found");
                return;
            }
            
            if (currentPaneIndex_==0)
            {
                BOOL needSuffix;
                
                [IBpreviousButton_ setEnabled:YES];
                
                needSuffix=!([[assistantEngine_ templateName] hasSuffix:@"Package"] ||
                             [[assistantEngine_ templateName] hasSuffix:@"Metapackage"]);
                
                if (needSuffix==NO)
                {
                    [IBassistantProjectType_ setStringValue:[NSString stringWithFormat:NSLocalizedString(@"New %@",@"No comment"),[assistantEngine_ templateName]]];
                }
                else
                {
                    [IBassistantProjectType_ setStringValue:[NSString stringWithFormat:NSLocalizedString(@"New %@ Package",@"No comment"),[assistantEngine_ templateName]]];
                }
            }
            
            [tPaneController setPreviousPaneIndex:currentPaneIndex_];
            
            currentPaneIndex_=tIndex;
            currentPaneController_=tPaneController;
            
            if (currentPaneIndex_==([projectAssistantInfoArray_ count] -1))
            {
                [IBnextButton_ setEnabled:NO];
                
                [IBnextButton_ setTitle:NSLocalizedString(@"Finish",@"No comment")];
            }
            else
            {
                [IBnextButton_ setEnabled:YES];
            }
            
            [currentPaneController_ initPaneWithEngine:assistantEngine_];
        }
    }
}

- (IBAction) previous:(id) sender
{
    PBProjectAssistantPaneController * tPaneController;
    int tIndex;
    NSRect tContentRect;
    
    tContentRect=[[IBwindow_ contentView] frame];
    
    tIndex=[currentPaneController_ previousPaneIndex];
    
    if (tIndex==-1)
    {
        NSLog(@"No previous pane is defined for this pane");
        return;
    }
    
    tPaneController = [self paneControllerAtIndex:tIndex];
    
    if (tPaneController!=nil)
    {
        // Set up the new content of the box
        
        [currentRelativeRootView_ removeFromSuperview];
        
        [[IBnextButton_ superview]  addSubview:[tPaneController relativeRootView]];
        
        currentRelativeRootView_=[tPaneController relativeRootView];
        
        [currentRelativeRootView_ setFrame:NSMakeRect(0,60,NSWidth(tContentRect),NSHeight(tContentRect)-154.0)];
    }
    else
    {
        NSLog(@"The previous pane was not found");
        return;
    }
    
    currentPaneIndex_=tIndex;
    
    if (currentPaneIndex_!=([projectAssistantControllerArray_ count] -1))
    {
        [IBnextButton_ setEnabled:YES];
    
        [IBnextButton_ setTitle:NSLocalizedString(@"Next",@"No comment")];
    }
    
    currentPaneController_=tPaneController;
    
    if (currentPaneIndex_==0)
    {
        [IBpreviousButton_ setEnabled:NO];
        
        [IBassistantProjectType_ setStringValue:NSLocalizedString(@"New Project",@"No comment")];
    }
}

- (void) processPaneController:(PBProjectAssistantPaneController *) inPaneController withEngine:(id) inEngine
{
    PBProjectAssistantPaneController * tPaneController;
    unsigned long tIndex;
    
    tIndex=[inPaneController previousPaneIndex];
    
    if (tIndex>0)
    {
        tPaneController = [self paneControllerAtIndex:tIndex];
        
        if (tPaneController!=nil)
        {
            [self processPaneController:tPaneController withEngine:inEngine];
        }
    }

    [inPaneController processWithEngine:inEngine];
}

-(void) finishSetUp:(id) sender
{
    NSString * tProjectDirectory;
    NSString * tProjectName;
    NSString * tSourcePath;
    NSString * tNewPath;
    
    tProjectName=[assistantEngine_ projectName];
    
    tProjectDirectory=[assistantEngine_ projectDirectory];
    
    tNewPath=[tProjectDirectory stringByAppendingPathComponent:tProjectName];
    
    // Create the Project Folder
                
    tSourcePath=[assistantEngine_ templateFolderPath];
                
    if (NO==[fileManager_ copyPath:tSourcePath
                            toPath:tNewPath
                           handler:nil])
    {
        NSBeep();
        
        NSBeginAlertSheet(NSLocalizedString(@"Iceberg is not able to duplicate the template.",@"No comment"),
                        nil,
                        nil,
                        nil,
                        IBwindow_,
                        nil,
                        nil,
                        nil,
                        NULL,
                        [NSString stringWithFormat:NSLocalizedString(@"Check that you have write privileges for \"%@\".",@"No comment"),[tProjectDirectory stringByDeletingLastPathComponent]]);
    }
    else
    {
        NSDate * tCurrentDate=[NSDate date];
        NSString * tDescriptionFile;
        NSString * tTemplateProject;
        NSString * tFinalProjectPath;
        NSDictionary * tProjectDictionary;
        NSDictionary * tKeywordsDictionary;
        NSMutableDictionary * tFileAttributesDictionary;
        NSUserDefaults * tDefaults;
        NSString * tCompanyName;
        NSString * tCompanyPackageIdentifier;
        NSArray * tFolderContent;
        int i,tCount;
        
        [assistantEngine_ setFinalProjectPath:tNewPath];
        
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        tCompanyPackageIdentifier=[[tDefaults dictionaryForKey:@"Keywords"] objectForKey:@"COMPANY_PACKAGE_IDENTIFIER"];
        
        if (tCompanyPackageIdentifier==nil)
        {
            tCompanyPackageIdentifier=@"com.mygreatcompany.pkg";
        }

        
        tCompanyName=[[tDefaults dictionaryForKey:@"Keywords"] objectForKey:@"COMPANY_NAME"];
        
        if (tCompanyName==nil)
        {
            tCompanyName=@"My Great Company";
        }
        
        // Change the attribute of the folder
        
        [fileManager_ changeFileAttributes:[NSDictionary dictionaryWithObjectsAndKeys:tCurrentDate,NSFileCreationDate,
                                                                                        tCurrentDate,NSFileModificationDate,
                                                                                        nil]
                                    atPath:tNewPath];
        
        // Remove the eventual description file
        
        tDescriptionFile=[tNewPath stringByAppendingPathComponent:@"description.txt"];
        
        [fileManager_ removeFileAtPath:tDescriptionFile handler:nil];
        
        // Remove the eventual localized description file or the eventual Plugin
        
        tFolderContent=[fileManager_ directoryContentsAtPath:tNewPath];
        
        tCount=[tFolderContent count];
        
        for(i=0;i<tCount;i++)
        {
            if ([[tFolderContent objectAtIndex:i] hasSuffix:@".desc"]==YES)
            {
                [fileManager_ removeFileAtPath:[tNewPath stringByAppendingPathComponent:[tFolderContent objectAtIndex:i]] handler:nil];
            }
            else if ([[tFolderContent objectAtIndex:i] isEqualToString:@"Plugin.bundle"])
            {
                [fileManager_ removeFileAtPath:[tNewPath stringByAppendingPathComponent:[tFolderContent objectAtIndex:i]] handler:nil];
            }
        }
        
        
        // Rename the template project file
        
        tTemplateProject=[tNewPath stringByAppendingPathComponent:@"template.packproj"];
        
        tFinalProjectPath=[tNewPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.packproj",tProjectName]];
        
        [fileManager_ movePath:tTemplateProject
                        toPath:tFinalProjectPath
                        handler:nil];
        
        
        tKeywordsDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[[tFinalProjectPath lastPathComponent] stringByDeletingPathExtension],@"PROJECT_NAME",
                                                tCompanyName,@"COMPANY_NAME",
                                                tCompanyPackageIdentifier,@"COMPANY_PACKAGE_IDENTIFIER",
                                                [NSString stringWithFormat:@"%d",[[NSCalendarDate calendarDate] yearOfCommonEra]],@"YEAR",
                                                [tFinalProjectPath stringByDeletingLastPathComponent],@"PROJECT_PATH",
                                                nil];
            
        tProjectDictionary=[NSDictionary dictionaryWithContentsOfFile:tFinalProjectPath];
        
        tProjectDictionary=[PBProjectTree resolveDictionary:tProjectDictionary
                                        withKeywordDictionary:tKeywordsDictionary];
            
            
        [assistantEngine_ startProcessWithProjectDictionary:(NSMutableDictionary *) tProjectDictionary];
        
        [self processPaneController:currentPaneController_ withEngine:assistantEngine_];
        
        [assistantEngine_ endProcess];
        
        [tProjectDictionary writeToFile:tFinalProjectPath atomically:YES];
        
        tFileAttributesDictionary=[[fileManager_ fileAttributesAtPath:tFinalProjectPath traverseLink:NO] mutableCopy];
        
        [tFileAttributesDictionary setObject:[NSNumber numberWithBool:YES] forKey:NSFileExtensionHidden];

        [fileManager_ changeFileAttributes:tFileAttributesDictionary
                                    atPath:tFinalProjectPath];
                                
        [tFileAttributesDictionary release];
		
		[NSApp stopModal];

        [IBwindow_ orderOut:self];
        
        // Open the new project
        
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfFile:tFinalProjectPath
                                                                                display:YES];
    }
}

- (void) setEnableNextButton:(BOOL) aBool
{
    if ([IBnextButton_ isEnabled]!=aBool)
    {
        [IBnextButton_ setEnabled:aBool];
    }
}

@end
