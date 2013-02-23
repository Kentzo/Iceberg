#import "PBPreferencePaneFilesController.h"
#import "PBSharedConst.h"

@implementation PBPreferencePaneFilesController

- (void) awakeFromNib
{
    id tMenuItem;
    NSImage * tImage;
    
    tMenuItem=[IBdefaultReferenceStylePopUpButton_ itemAtIndex:[IBdefaultReferenceStylePopUpButton_ indexOfItemWithTag:kRelativeToProjectPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    tMenuItem=[IBdefaultReferenceStylePopUpButton_ itemAtIndex:[IBdefaultReferenceStylePopUpButton_ indexOfItemWithTag:kGlobalPath]];
    
    if (tMenuItem!=nil)
    {
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
    }
    
    [super awakeFromNib];
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        // Register for Notifications
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsDidChanged:)
                                                     name:PBPREFERENCEPANE_FILES_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -

- (IBAction) changeDefaults:(id) sender
{
    [defaults_ setBool:([IBdefaultKeepPermissionsMode_ state]==NSOnState) forKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
	
	[defaults_ setInteger:[[IBdefaultReferenceStylePopUpButton_ selectedItem] tag] forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
	
	[defaults_ setBool:([IBshowCustomizationDialog_ state]==NSOnState) forKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	
	switch([[IBsplitForksToolName_ selectedCell] tag])
	{
		case SPLITFORKSTOOL_GOLDIN_ID:
			[defaults_ setObject:SPLITFORKSTOOL_GOLDIN forKey:PBPREFERENCEPANE_FILES_SPLITFORKSTOOLNAME];
			break;
		case SPLITFORKSTOOL_SPLITFORKS_ID:
			[defaults_ setObject:SPLITFORKSTOOL_SPLITFORKS forKey:PBPREFERENCEPANE_FILES_SPLITFORKSTOOLNAME];
			break;
	}
	
	
}

#pragma mark -

- (void) updateWithDefaults
{
    int tDefaultReferenceStyle;
    BOOL tDefaultKeepPermissionsMode;
	BOOL tShowCustomizationDialog;
	id tObject;
	NSString * tSplitForksToolName;
	NSFileManager * tFileManager;
    BOOL tSplitForksInstalled;
	
    tFileManager=[NSFileManager defaultManager];
	
	tSplitForksInstalled=[tFileManager fileExistsAtPath:@"/Developer/Tools/SplitForks"];
	
    tDefaultKeepPermissionsMode=[defaults_ boolForKey:PBPREFERENCEPANE_FILES_DEFAULPERMISSIONSMODE];
	
	[IBdefaultKeepPermissionsMode_ setState:(tDefaultKeepPermissionsMode==YES) ? NSOnState : NSOffState];
	
	tDefaultReferenceStyle=[defaults_ integerForKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    
    if (tDefaultReferenceStyle==0)
    {
        tDefaultReferenceStyle=kGlobalPath;
        
        [defaults_ setInteger:tDefaultReferenceStyle forKey:PBPREFERENCEPANE_FILES_DEFAULTREFERENCESTYLE];
    }
    
    [IBdefaultReferenceStylePopUpButton_ selectItemAtIndex:[IBdefaultReferenceStylePopUpButton_ indexOfItemWithTag:tDefaultReferenceStyle]];
	
	tObject=[defaults_ objectForKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	
	if (tObject==nil)
	{
		tShowCustomizationDialog=YES;
		
		[defaults_ setBool:tShowCustomizationDialog forKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	}
	else
	{
		tShowCustomizationDialog=[defaults_ boolForKey:PBPREFERENCEPANE_FILES_SHOWCUSTOMIZATIONDIALOG];
	}
	
	[IBshowCustomizationDialog_ setState:(tShowCustomizationDialog==YES) ? NSOnState : NSOffState];
	
	if (tSplitForksInstalled==NO)
    {
		// SPlitForks is MIA
		
		[[IBsplitForksToolName_ cellWithTag:SPLITFORKSTOOL_SPLITFORKS_ID] setEnabled:NO];
	}
	
	tSplitForksToolName=[defaults_ objectForKey:PBPREFERENCEPANE_FILES_SPLITFORKSTOOLNAME];
	
	if (tSplitForksToolName==nil || tSplitForksInstalled==NO)
	{
		tSplitForksToolName=SPLITFORKSTOOL_GOLDIN;
		
		[defaults_ setObject:SPLITFORKSTOOL_GOLDIN forKey:PBPREFERENCEPANE_FILES_SPLITFORKSTOOLNAME];
	}
	
	if ([tSplitForksToolName isEqualToString:SPLITFORKSTOOL_GOLDIN]==YES)
	{
		[IBsplitForksToolName_ selectCellWithTag:SPLITFORKSTOOL_GOLDIN_ID];
	}
	else
	{
		[IBsplitForksToolName_ selectCellWithTag:SPLITFORKSTOOL_SPLITFORKS_ID];
	}
}

@end
