#import "PBPreferencesWindowController.h"
#import "PBPreferencePaneController.h"

NSString * const PBPREFERENCESWINDOW_ORDER=@"Order";
NSString * const PBPREFERENCESWINDOW_DESCRIPTIONS=@"Descriptions";

NSString * const PBPREFERENCESWINDOW_CLASSNAME=@"ClassName";
NSString * const PBPREFERENCESWINDOW_ICON=@"Icon";
NSString * const PBPREFERENCESWINDOW_NAME=@"Name";
NSString * const PBPREFERENCESWINDOW_NIB=@"Nib";

@implementation PBPreferencesWindowController

- (void) awakeFromNib
{
    NSString * tPath;
    
    tPath=[[NSBundle mainBundle] pathForResource:@"PreferencesWindowDescription" ofType:@"plist"];
    
    if (tPath!=nil)
    {
        panesDictionary_=[[NSDictionary alloc] initWithContentsOfFile:tPath];
        
        if (panesDictionary_!=nil)
        {
            // Create the required controllers
            
            NSDictionary * tDescriptionsDictionary;
            
            tDescriptionsDictionary=[panesDictionary_ objectForKey:PBPREFERENCESWINDOW_DESCRIPTIONS];
            
            if (tDescriptionsDictionary!=nil)
            {
                preferencePaneControllerDictionary_=[[NSMutableDictionary alloc] initWithCapacity:[tDescriptionsDictionary count]];
                
                if (preferencePaneControllerDictionary_!=nil)
                {
                    NSEnumerator * tKeyEnumerator;
                    NSString * tPaneIdentifier;
                    NSToolbar * tToolBar;
                     
                    tKeyEnumerator=[tDescriptionsDictionary keyEnumerator];
                    
                    while (tPaneIdentifier=[tKeyEnumerator nextObject])
                    {
                        NSDictionary * tPaneDescriptionDictionary;
                        
                        tPaneDescriptionDictionary=[tDescriptionsDictionary objectForKey:tPaneIdentifier];
                        
                        if (tPaneDescriptionDictionary!=nil)
                        {
                            NSString * tClassName;
                            NSString * tNibName;
                            
                            tClassName=[tPaneDescriptionDictionary objectForKey:PBPREFERENCESWINDOW_CLASSNAME];
                            
                            tNibName=[tPaneDescriptionDictionary objectForKey:PBPREFERENCESWINDOW_NIB];
                        
                            if (tClassName!=nil && tNibName!=nil)
                            {
                                PBPreferencePaneController * nPaneController;
                                
                                nPaneController=[NSClassFromString(tClassName) alloc];
                                
                                if (nPaneController!=nil)
                                {
                                    if ([NSBundle loadNibNamed:tNibName owner:nPaneController]==YES)
                                    {
                                        [preferencePaneControllerDictionary_ setObject:nPaneController forKey:tPaneIdentifier];
                                    }
                                    else
                                    {
                                        // A COMPLETER
                                    }
                                }
                            }
                        }
                    }
                
                    tToolBar  = [[NSToolbar alloc] initWithIdentifier: @"fr.whitebox.iceberg.preference.toolbar"];
                
                    if (tToolBar!=nil)
                    {
                        [tToolBar setAllowsUserCustomization: NO];
                    
                        [tToolBar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
                    
                        [tToolBar setDelegate: self];
                    
                        [IBwindow_ setToolbar: tToolBar];
                        
                        
                        
                        // Show the first pane
                        
                        if ([tToolBar respondsToSelector:@selector(setSelectedItemIdentifier:)]==YES)
						{
							[tToolBar setSelectedItemIdentifier:[[self toolbarDefaultItemIdentifiers:tToolBar] objectAtIndex:0]];
						}
						
						[self showPane:[[tToolBar items] objectAtIndex:0]];
						
						[tToolBar release];
					}
                }
            }
        }
        else
        {
            // A COMPLETER
        }
    }
    else
    {
        NSLog(@"Missing file: PreferencesWindowDescription.plist");
    }
    
	[IBwindow_ setShowsToolbarButton:NO];
	
    [IBwindow_ center];
}

#pragma mark -

- (NSToolbarItem *) toolbar:(NSToolbar *) toolbar itemForItemIdentifier:(NSString *) inItemIdentifier willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
    NSToolbarItem *tToolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: inItemIdentifier] autorelease];
    NSDictionary * tItemDictionary;
    
    tItemDictionary=[[panesDictionary_ objectForKey:PBPREFERENCESWINDOW_DESCRIPTIONS] objectForKey:inItemIdentifier];
    
    if (tItemDictionary!=nil)
    {
        [tToolbarItem setLabel:[tItemDictionary objectForKey:PBPREFERENCESWINDOW_NAME]];
	
        [tToolbarItem setImage:[NSImage imageNamed:[tItemDictionary objectForKey:PBPREFERENCESWINDOW_ICON]]];
        
        [tToolbarItem setTarget:self];
	
        [tToolbarItem setAction:@selector(showPane:)];
    }
    else
    {
        tToolbarItem=nil;
    }
    
    return tToolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    return [panesDictionary_ objectForKey:PBPREFERENCESWINDOW_ORDER];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [panesDictionary_ objectForKey:PBPREFERENCESWINDOW_ORDER];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [panesDictionary_ objectForKey:PBPREFERENCESWINDOW_ORDER];
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem
{
    return YES;
}

#pragma mark -

- (void) showPane:(id) sender
{
    if (sender!=nil)
    {
        PBPreferencePaneController * tPreferencePaneController;
    
        if (currentView_!=nil)
        {
            [currentView_ removeFromSuperview];
            
            currentView_=nil;
        }
        
        tPreferencePaneController=[preferencePaneControllerDictionary_ objectForKey:[sender itemIdentifier]];
        
        if (tPreferencePaneController!=nil)
        {
            NSRect tNewContentRect;
			NSRect tOldWindowFrame;
			NSRect tWindowFrame;
			
			tOldWindowFrame=[IBwindow_ frame];
			
			currentView_=[tPreferencePaneController view];
			
			tNewContentRect=[[IBwindow_ contentView] bounds];
			
			tNewContentRect.size=[currentView_ frame].size;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
			
			tWindowFrame=(NSRect) [IBwindow_ frameRectForContentRect:tNewContentRect];

#else
			{
				NSRect tOldContentRect;
				
				tOldContentRect=[[IBwindow_ contentView] bounds];
				
				tWindowFrame=tOldWindowFrame;
				
				tWindowFrame.size.height=tOldWindowFrame.size.height+tNewContentRect.size.height-tOldContentRect.size.height;
				
			}
#endif

			tWindowFrame.origin.x=NSMinX(tOldWindowFrame);
			
			tWindowFrame.origin.y=NSMaxY(tOldWindowFrame)-NSHeight(tWindowFrame);
			
			[IBwindow_ setTitle:[sender label]];
            
            [IBwindow_ setFrame:tWindowFrame display:YES animate:YES];
            
            [[IBwindow_ contentView] addSubview:currentView_];
        }
    }
}

+ (void) showPreferenceWindow
{
    static PBPreferencesWindowController * sPreferenceWindowController=nil;
    
    if (sPreferenceWindowController==nil)
    {
        sPreferenceWindowController=[PBPreferencesWindowController alloc];
        
        if (sPreferenceWindowController!=nil)
        {
            if ([NSBundle loadNibNamed:@"PBPreferencesWindow" owner:sPreferenceWindowController]==NO)
            {
                NSLog(@"Loading of PBPreferenceWindow.nib failed");
            
                return;
            }
        }
    }
    
    if (sPreferenceWindowController!=nil)
    {
        [sPreferenceWindowController->IBwindow_ makeKeyAndOrderFront:nil];
    }
}

@end
