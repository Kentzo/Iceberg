/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSearchRuleEditorController.h"
#import "PBFileInspectorController.h"

@implementation PBSearchRuleEditorController

- (void) dealloc
{
    [plugInsDictionary_ release];
    
    [attributes_ release];
    
    [super dealloc];
}

#pragma mark -

- (void) awakeFromNib
{
    NSMutableArray * tMutableKeysArray;
    
    // Populate the method popupbutton
    
    plugInsDictionary_=[[NSDictionary alloc] initWithObjectsAndKeys:checkPathController_,@"CheckPath",
                                                                    commonAppSearchController_,@"CommonAppSearch",
                                                                    launchServicesLookupController_,@"LaunchServicesLookup",
                                                                    bundleIdentifierSearchController_,@"BundleIdentifierSearch",
                                                                    bundleVersionFilterController_,@"BundleVersionFilter",
                                                                    nil];
                                                                    
    tMutableKeysArray=[[plugInsDictionary_ allKeys] mutableCopy];
    
    [tMutableKeysArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [IBmethodPopupButton_ removeAllItems];
    
    [IBmethodPopupButton_ addItemsWithTitles:tMutableKeysArray];
    
    [tMutableKeysArray release];
}

#pragma mark -

- (IBAction) endDialog:(id)sender
{
    if (NSOKButton==[sender tag])
    {
        if ([currentController_ hasIncorrectValues]==NO)
        {
            NSDictionary * tDictionary;
            NSDictionary * tAttributes;
            
            tAttributes=[currentController_ dictionary];
            
            tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[IBnameField_ stringValue],@"Name",
                                                                tAttributes,@"Attributes",
                                                                nil];
            
            [NSApp stopModal];
        
            [IBwindow_ orderOut:nil];
            
            [inspector_ ruleEditionDidEndWithDictionary:tDictionary edit:edit_];
        }
        else
        {
            NSBeep();
        }
    }
    else
    {
        [NSApp stopModal];
    
        [IBwindow_ orderOut:nil];
    }
}

- (void) showSearchRulePanelForInspector:(id) inInspector dictionary:(NSDictionary *) inDictionary edit:(BOOL) inEdit
{
    NSDictionary * tAttributes;
    NSString * tName;
    PBSearchPlugInController * tController;
    
    if (IBwindow_==nil)
    {
        if ([NSBundle loadNibNamed:@"SearchRuleEditor" owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"SearchRuleEditor"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }

    inspector_=inInspector;
    
    edit_=inEdit;
    
    tName=[inDictionary objectForKey:@"Name"];
    
    if (tName==nil)
    {
        tName=@"";
    }
    
    [IBnameField_ setStringValue:tName];
    
    tAttributes=[inDictionary objectForKey:@"Attributes"];
    
    [IBmethodPopupButton_ selectItemWithTitle:[tAttributes objectForKey:@"searchPlugin"]];
    
    tController=[plugInsDictionary_ objectForKey:[tAttributes objectForKey:@"searchPlugin"]];
    
    if (currentController_!=tController)
    {
        NSRect tOldRect;
        NSRect tNewRect;
        NSRect tWindowFrame;
        NSSize tSize;
        
        if (currentView_==nil)
        {
            tOldRect=NSZeroRect;
        }
        else
        {
            tOldRect=[currentView_ bounds];
            
            [currentView_ removeFromSuperview];
        }
        
        // Set the view
        
        currentController_=tController;
        
        currentView_=[currentController_ view];
    
        tNewRect=[currentView_ bounds];
        
        tWindowFrame=[IBwindow_ frame];
        
        tWindowFrame.size.height+=NSHeight(tNewRect)-NSHeight(tOldRect);
        
        // Set Min/Max Height of the window
        
        tSize=[IBwindow_ minSize];
        
        tSize.height=tWindowFrame.size.height;
        
        [IBwindow_ setMinSize:tSize];
        
        tSize=[IBwindow_ maxSize];
        
        tSize.height=tWindowFrame.size.height;
        
        [IBwindow_ setMaxSize:tSize];
        
        [IBwindow_ setFrame:tWindowFrame display:NO];
        
        [[IBwindow_ contentView] addSubview:currentView_];
        
        tNewRect.origin=NSMakePoint(0,45);
        tNewRect.size.width=NSWidth(tWindowFrame);
        
        [currentView_ setFrame:tNewRect];
        
        [IBnameField_ setNextKeyView:[currentController_ previousKeyView]];
        
        [currentController_ setNextKeyView:IBnameField_];
    }
    
    [attributes_ release];
    
    attributes_=[tAttributes mutableCopy];
    
    [currentController_ initWithDictionary:attributes_];
    
    [NSApp runModalForWindow:IBwindow_];
}

- (IBAction)switchSearchMethod:(id)sender
{
    PBSearchPlugInController * tController;
    
    tController=[plugInsDictionary_ objectForKey:[IBmethodPopupButton_ titleOfSelectedItem]];
    
    if (currentController_!=tController)
    {
        NSRect tOldRect;
        NSRect tNewRect;
        NSRect tWindowFrame;
        NSSize tSize;
        
        tOldRect=[currentView_ bounds];
        
        [currentView_ removeFromSuperview];
        
        // Get the values
        
        [attributes_ addEntriesFromDictionary:[currentController_ dictionary]];
        
        // Set the view
        
        currentController_=tController;
        
        currentView_=[currentController_ view];
    
        tNewRect=[currentView_ bounds];
        
        tWindowFrame=[IBwindow_ frame];
        
        tWindowFrame.size.height+=NSHeight(tNewRect)-NSHeight(tOldRect);
        
        tWindowFrame.origin.y-=NSHeight(tNewRect)-NSHeight(tOldRect);
        
        if (tWindowFrame.origin.y<0)
        {
            tWindowFrame.origin.y=0;
        }
        
        // Set Min/Max Height of the window
        
        tSize=[IBwindow_ minSize];
        
        tSize.height=tWindowFrame.size.height;
        
        [IBwindow_ setMinSize:tSize];
        
        tSize=[IBwindow_ maxSize];
        
        tSize.height=tWindowFrame.size.height;
        
        [IBwindow_ setMaxSize:tSize];
        
        [[IBwindow_ contentView] addSubview:currentView_];
        
        tNewRect.origin=NSMakePoint(0,45);
        tNewRect.size.width=NSWidth(tWindowFrame);
        
        [currentView_ setFrame:tNewRect];
        
        [IBnameField_ setNextKeyView:[currentController_ previousKeyView]];
        
        [currentController_ setNextKeyView:IBnameField_];
        
        [IBwindow_ setFrame:tWindowFrame display:YES];
    }
    
    [currentController_ initWithDictionary:attributes_];
}

@end
