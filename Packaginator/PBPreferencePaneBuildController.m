#import "PBPreferencePaneBuildController.h"
#import "PBFileTextField.h"

@implementation PBPreferencePaneBuildController

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        // Register for Notifications
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsDidChanged:)
                                                     name:PBPREFERENCEPANE_BUILD_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -

- (IBAction) changeDefaults:(id) sender
{
    [defaults_ setObject:[IBscratchPath_ stringValue] forKey:PBPREFERENCEPANE_BUILD_SCRATCH_LOCATION];
    
    [defaults_ setInteger:[[IBunsavedProjectPopUpButton_ selectedItem] tag] forKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
    
    [defaults_ setInteger:[[IBshowBuildWindowPopUpButton_ selectedItem] tag] forKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW];
    [defaults_ setInteger:[[IBhideBuildWindowPopUpButton_ selectedItem] tag] forKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW];
    
}

#pragma mark -

- (IBAction) revealScratchInFinder:(id) sender
{
     NSWorkspace * tWorkSpace;
    
    tWorkSpace=[NSWorkspace sharedWorkspace];
    
    [tWorkSpace selectFile:[IBscratchPath_ stringValue] inFileViewerRootedAtPath:@""];
}

- (IBAction) selectScratchPath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:NO];
    [tOpenPanel setCanChooseDirectories:YES];
    
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    if ([tOpenPanel respondsToSelector:@selector(setCanCreateDirectories:)]==YES)
    {
        [tOpenPanel setCanCreateDirectories:YES];
    }
    else if ([tOpenPanel respondsToSelector:@selector(_setIncludeNewFolderButton:)]==YES)
    {
        [tOpenPanel _setIncludeNewFolderButton:YES];
    }
    
    [tOpenPanel beginSheetForDirectory:[[IBscratchPath_ stringValue] stringByExpandingTildeInPath]
                                  file:nil
                                 types:nil
                        modalForWindow:[IBview_ window]
                         modalDelegate:self
                        didEndSelector:@selector(scratchOpenPanelDidEnd:returnCode:contextInfo:)
                           contextInfo:NULL];
}

- (void) scratchOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode==NSOKButton)
    {
        [IBscratchPath_ setStringValue:[sheet filename]];
        
    	[self changeDefaults:nil];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
    if ([aMenuItem action]==@selector(revealScratchInFinder:))
    {
        NSString * tPath;
        NSFileManager * tFileManager;
        
        tPath=[IBscratchPath_ stringValue];
        
        tFileManager=[NSFileManager defaultManager];
        
        return [tFileManager fileExistsAtPath:tPath];
    }
    
    return YES;
}

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBscratchPath_)
    {
        NSFileManager * tFileManager=[NSFileManager defaultManager];
        BOOL isDirectory;
    
        return ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==YES);
    }
    
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    if (inTextField==IBscratchPath_)
    {
        [IBscratchPath_ setStringValue:inPath];
        
    	[self changeDefaults:nil];
    }
    
    return YES;
}

#pragma mark -

- (void) updateWithDefaults
{
    NSString * tPath;
    int tTag;
    id tObject;
    
    // Scratch Folder
    
    tPath=[defaults_ objectForKey:PBPREFERENCEPANE_BUILD_SCRATCH_LOCATION];
    
    if (tPath==nil)
    {
        tPath=@"/tmp";
    }
    
    [IBscratchPath_ setStringValue:tPath];
    
    // Build Window
    
    tTag=[defaults_ integerForKey:PBPREFERENCEPANE_BUILD_SHOW_WINDOW];
    
    [IBshowBuildWindowPopUpButton_ selectItemAtIndex:[IBshowBuildWindowPopUpButton_ indexOfItemWithTag:tTag]];
    
    tTag=[defaults_ integerForKey:PBPREFERENCEPANE_BUILD_HIDE_WINDOW];
    
    [IBhideBuildWindowPopUpButton_ selectItemAtIndex:[IBhideBuildWindowPopUpButton_ indexOfItemWithTag:tTag]];
    
    tObject=[defaults_ objectForKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
    
    if (tObject!=nil)
    {
        tTag=[defaults_ integerForKey:PBPREFERENCEPANE_BUILD_UNSAVED_PROJECT];
    
        [IBunsavedProjectPopUpButton_ selectItemAtIndex:[IBunsavedProjectPopUpButton_ indexOfItemWithTag:tTag]];
    }
    else
    {
        BOOL tBoolean;
        
        tBoolean=[defaults_ boolForKey:@"SaveBeforeBuild"];
        
        if (tBoolean==YES)
        {
            tTag=PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_ALWAYSSAVE;
        }
        else
        {
            tTag=PBPREFERENCEPANE_BUILD_UNSAVEDPROJECT_NEVERSAVE;
        }
        
        [IBunsavedProjectPopUpButton_ selectItemAtIndex:[IBunsavedProjectPopUpButton_ indexOfItemWithTag:tTag]];
    }
}

@end
