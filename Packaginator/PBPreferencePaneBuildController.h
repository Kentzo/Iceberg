#import "PBPreferencePaneController.h"
#import "PBPreferencePaneBuildController+Constants.h"

@interface PBPreferencePaneBuildController : PBPreferencePaneController
{
    IBOutlet id IBscratchPath_;
    
    IBOutlet id IBunsavedProjectPopUpButton_;
    
    IBOutlet id IBshowBuildWindowPopUpButton_;
    
    IBOutlet id IBhideBuildWindowPopUpButton_;
    
    
}

- (IBAction) selectScratchPath:(id) sender;

- (void) scratchOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (IBAction) revealScratchInFinder:(id) sender;

@end
