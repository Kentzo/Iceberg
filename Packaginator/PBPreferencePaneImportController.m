#import "PBPreferencePaneImportController.h"
#import "PBSharedConst.h"

@implementation PBPreferencePaneImportController

- (void) awakeFromNib
{
    /*id tMenuItem;
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
    }*/
    
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
                                                     name:PBPREFERENCEPANE_IMPORT_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -

- (IBAction) changeDefaults:(id) sender
{
    [defaults_ setBool:([IBcopyComponentCheckBox_ state]==NSOnState) forKey:PBPREFERENCEPANE_IMPORT_COPY_COMPONENT];
    
    [defaults_ setBool:([IBimportSubComponentsCheckBox_ state]==NSOnState) forKey:PBPREFERENCEPANE_IMPORT_SUBCOMPONENTS];
	
	//[defaults_ setInteger:[[IBimportReferenceStylePopUpButton_ selectedItem] tag] forKey:PBPREFERENCEPANE_IMPORT_DEFAULTREFERENCESTYLE];
}

#pragma mark -

- (void) updateWithDefaults
{
	//int tDefaultReferenceStyle;

    [IBcopyComponentCheckBox_ setState:([defaults_ boolForKey:PBPREFERENCEPANE_IMPORT_COPY_COMPONENT]==YES) ? NSOnState : NSOffState];
    
    [IBimportSubComponentsCheckBox_ setState:([defaults_ boolForKey:PBPREFERENCEPANE_IMPORT_SUBCOMPONENTS]==YES) ? NSOnState : NSOffState];
	
	/*tDefaultReferenceStyle=[defaults_ integerForKey:PBPREFERENCEPANE_IMPORT_DEFAULTREFERENCESTYLE];
    
    if (tDefaultReferenceStyle==0)
    {
        tDefaultReferenceStyle=kGlobalPath;
        
        [defaults_ setInteger:tDefaultReferenceStyle forKey:PBPREFERENCEPANE_IMPORT_DEFAULTREFERENCESTYLE];
    }
    
    [IBimportReferenceStylePopUpButton_ selectItemAtIndex:[IBimportReferenceStylePopUpButton_ indexOfItemWithTag:tDefaultReferenceStyle]];*/
}

@end
