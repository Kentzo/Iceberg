/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBRequirementsController.h"
#import "PBScriptsController.h"

@implementation PBRequirementsController

- (void) awakeFromNib
{
    specificationControllersArray_=[[NSArray alloc] initWithObjects:bundleController_,
                                                                    fileController_,
                                                                    gestaltController_,
                                                                    IORegistryController_,
                                                                    packageController_,
                                                                    plistController_,
                                                                    sysctlController_,
                                                                    nil];
}

- (void) beginRequirementSheetForWindow:(NSWindow *) inWindow withDictionary:(NSDictionary *) inDictionary parent:(id) inParent
{
    id tMenuItem;
    NSNumber * tSpecificationType;
    
    if (IBwindow_==nil)
    {
        if ([NSBundle loadNibNamed:@"PBRequirements" owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"PBRequirements"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    parent_=inParent;
    
    // ** Init the User Interface
    
    [currentRequirementDictionary_ release];
    
    currentRequirementDictionary_=[inDictionary mutableCopy];
    
    // Information
    
    [IBlabelField_ setStringValue:[currentRequirementDictionary_ objectForKey:@"LabelKey"]];
    
    [IBlevelPopupButton_  selectItemAtIndex:[IBlevelPopupButton_ indexOfItemWithTag:[[currentRequirementDictionary_ objectForKey:@"Level"] intValue]]];
    
    // Alert dialog
    
    [currentAlertLanguage_ release];
    
    currentAlertLanguage_=nil;
    
    [self updateAlertLanguage];
    
    tMenuItem=[IBlocalizationPopupButton_ itemWithTitle:@"International"];
    
    if (tMenuItem==nil)
    {
        tMenuItem=[IBlocalizationPopupButton_ itemAtIndex:0];
    }
    
    [IBlocalizationPopupButton_ selectItem:tMenuItem];

    [self switchAlertLanguage:IBlocalizationPopupButton_];
    
    // ** Display the proper specification UI
    
    tSpecificationType=[currentRequirementDictionary_ objectForKey:@"SpecTag"];
    
    if (tSpecificationType!=nil)
    {
        NSMutableDictionary * tControllerDictionary;
        NSArray * tKeyArray;
        int i,tCount;
        
        currentSpecificationController_=[specificationControllersArray_ objectAtIndex:[tSpecificationType intValue]];
        
        if (currentSpecificationController_!=nil)
        {
            currentSpecificationView_=[currentSpecificationController_ view];
        }
        
        [[IBwindow_ contentView] addSubview:currentSpecificationView_];
        
        [currentSpecificationView_ setFrameOrigin:NSMakePoint(0,146)];
        
        // Init the controller UI
        
        tKeyArray=[NSArray arrayWithObjects:@"SpecArgument",
                                            @"SpecProperty",
                                            @"TestOperator",
                                            @"TestObject",
                                            nil];
        
        tCount=[tKeyArray count];
        
        tControllerDictionary=[NSMutableDictionary dictionary];
        
        for(i=0;i<tCount;i++)
        {
            id tObject;
            NSString * tKey;
            
            tKey=[tKeyArray objectAtIndex:i];
            
            tObject=[currentRequirementDictionary_ objectForKey:tKey];
            
            if (tObject!=nil)
            {
                [tControllerDictionary setObject:tObject forKey:tKey];
            }
        }
        
        [currentSpecificationController_ setDelegate:self];
        
        [currentSpecificationController_ initWithDictionary:tControllerDictionary tag:[tSpecificationType intValue]];
        
        [currentSpecificationController_ updateNextKeyViewChainBetween:IBlabelField_
                                                                   and:IBtitleField_];
        
        [IBwindow_ makeFirstResponder:IBlabelField_];
        
        // Show the dialog
        
        [NSApp beginSheet:IBwindow_
           modalForWindow:inWindow
            modalDelegate:nil
           didEndSelector:nil
              contextInfo:NULL];
    }
}

- (NSMutableDictionary *) dictionary
{
    return currentRequirementDictionary_;
}

- (IBAction)endDialog:(id)sender
{
    if ([sender tag]==NSOKButton)
    {
        NSDictionary * tDictionary;
        NSArray * tKeysArray;
        int i,tCount;
        
        [IBwindow_ makeFirstResponder:nil];
        
        // Update the dictionary
        
        tDictionary=[currentSpecificationController_ dictionary];
        
        if (tDictionary!=nil)
        {
            tKeysArray=[NSArray arrayWithObjects:@"SpecType",
                                            @"SpecTag",
                                            @"SpecArgument",
                                            @"SpecProperty",
                                            @"TestOperator",
                                            @"TestObject",
                                            nil];
            
            tCount=[tKeysArray count];
            
            for(i=0;i<tCount;i++)
            {
                NSString * tKey;
                id tObject;
                
                tKey=[tKeysArray objectAtIndex:i];
                
                tObject=[tDictionary objectForKey:tKey];
                
                if (tObject==nil)
                {
                    [currentRequirementDictionary_ removeObjectForKey:tKey];
                }
                else
                {
                    [currentRequirementDictionary_ setObject:tObject forKey:tKey];
                }
            }
            
            // Set the label and level
            
            [currentRequirementDictionary_ setObject:[IBlabelField_ stringValue] forKey:@"LabelKey"];
            
            [currentRequirementDictionary_ setObject:[NSNumber numberWithInt:[[IBlevelPopupButton_ selectedItem] tag]] forKey:@"Level"];
        }
        else
        {
            // An error occured
            
            return;
        }
            
    }
    
    // Clean the UI
        
    [currentSpecificationController_ controllerWillChange];
        
    [currentSpecificationView_ removeFromSuperview];
    
    [NSApp endSheet:IBwindow_];
    [IBwindow_ orderOut:nil];
    
    if ([sender tag]==NSOKButton)
    {
        [parent_ requirementDidChanged];
    }
}

#pragma mark -

- (id) parent
{
    return parent_;
}

#pragma mark -

- (void) typeDidChange:(id) sender
{
    int tIndex;
    
    tIndex=[[sender selectedItem] tag];
    
    [currentSpecificationController_ controllerWillChange];
        
    [currentSpecificationView_ removeFromSuperview];
    
    currentSpecificationController_=[specificationControllersArray_ objectAtIndex:tIndex];
        
    if (currentSpecificationController_!=nil)
    {
        currentSpecificationView_=[currentSpecificationController_ view];
    }
    
    [[IBwindow_ contentView] addSubview:currentSpecificationView_];
    
    [currentSpecificationView_ setFrameOrigin:NSMakePoint(0,146)];
    
    [currentSpecificationController_ setDelegate:self];
    
    [currentSpecificationController_ initWithDictionary:nil tag:tIndex];
    
    [currentSpecificationController_ updateNextKeyViewChainBetween:IBlabelField_
                                                               and:IBtitleField_];
}

#pragma mark -

- (void) updateAlertLanguage
{
    NSDictionary * tAlertDictionary;
    NSMutableArray * tMutableArray;
    
    tAlertDictionary=[currentRequirementDictionary_ objectForKey:@"AlertDialog"];
    
    [IBlocalizationPopupButton_ removeAllItems];
    
    tMutableArray=[[tAlertDictionary allKeys] mutableCopy];
    
    [tMutableArray sortUsingSelector:@selector(compare:)];
    
    [IBlocalizationPopupButton_ addItemsWithTitles:tMutableArray];
    
    [tMutableArray release];
    
    // Add separator
    
    [[IBlocalizationPopupButton_ menu]  addItem:[NSMenuItem separatorItem]];
    
    // Add add
    
    [IBlocalizationPopupButton_ addItemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")];
    
    [[IBlocalizationPopupButton_ itemWithTitle:NSLocalizedString(@"Add localization...",@"No comment")] setTag:-111];
    
    // Add remove
    
    [IBlocalizationPopupButton_ addItemWithTitle:NSLocalizedString(@"Remove...",@"No comment")];
    
    [[IBlocalizationPopupButton_ itemWithTitle:NSLocalizedString(@"Remove...",@"No comment")] setTag:-222];
}

- (IBAction)switchAlertLanguage:(id)sender
{
    NSDictionary * tAlertDictionary;
    NSDictionary * tLocalizedAlertDictionary;
    id tSelectedItem;
    NSString * oldLanguage;
    
    [IBwindow_ makeFirstResponder:nil];
    
    tSelectedItem=[sender selectedItem];
    
    switch([tSelectedItem tag])
    {
        case -222:
            NSBeginAlertSheet(NSLocalizedString(@"Do you really want to remove this localization?",@"No comment"),
                              NSLocalizedString(@"Remove",@"No comment"),
                              NSLocalizedString(@"Cancel",@"No comment"),
                              nil,
                              IBwindow_,
                              self,
                              @selector(removeAlertLocalizationSheetDidEnd:returnCode:contextInfo:),
                              nil,
                              NULL,
                              NSLocalizedString(@"This cannot be undone.",@"No comment"));
            return;
        case -111:
            
            [[PBLocalizationPanel localizationPanel] runModalForWindow:IBwindow_
                                                         modalDelegate:self
                                                        didEndSelector:@selector(localizationPanelDidEnd:returnCode:localization:)];
            return;
    }
    
    tAlertDictionary=[currentRequirementDictionary_ objectForKey:@"AlertDialog"];
    
    oldLanguage=currentAlertLanguage_;
    
    currentAlertLanguage_=[[IBlocalizationPopupButton_ selectedItem] title];
    
    if ([currentAlertLanguage_ isEqualToString:oldLanguage]==YES)
    {
        currentAlertLanguage_=oldLanguage;
        
        return;
    }
    else
    {
        [oldLanguage release];
    }
    
    [currentAlertLanguage_ retain];
    
    tLocalizedAlertDictionary=[tAlertDictionary objectForKey:currentAlertLanguage_];
    
    [IBtitleField_ setStringValue:[tLocalizedAlertDictionary objectForKey:@"TitleKey"]];
    
    [IBmessageField_ setStringValue:[tLocalizedAlertDictionary objectForKey:@"MessageKey"]];

    [IBwindow_ makeFirstResponder:IBtitleField_];
}

- (IBAction)updateAlert:(id)sender
{
    NSMutableDictionary * tAlertDictionary;
    NSDictionary * tLocalizedAlertDictionary;
    
    tAlertDictionary=[[currentRequirementDictionary_ objectForKey:@"AlertDialog"] mutableCopy];
    
    tLocalizedAlertDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[IBtitleField_ stringValue],@"TitleKey",
                                                                         [IBmessageField_ stringValue],@"MessageKey",
                                                                         nil];
    
    [tAlertDictionary setObject:tLocalizedAlertDictionary forKey:currentAlertLanguage_];
    
    [currentRequirementDictionary_ setObject:tAlertDictionary forKey:@"AlertDialog"];
    
    [tAlertDictionary release];
}

#pragma mark -

- (void) removeAlertLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSMutableDictionary * tAlertDictionary;
        id tMenuItem;
        
        tAlertDictionary=[[currentRequirementDictionary_ objectForKey:@"AlertDialog"] mutableCopy];
        
        [tAlertDictionary removeObjectForKey:currentAlertLanguage_];
        
        [currentRequirementDictionary_ setObject:tAlertDictionary forKey:@"AlertDialog"];
        
        [tAlertDictionary release];
        
        // Update PopupButton
        
        [IBlocalizationPopupButton_ removeItemWithTitle:currentAlertLanguage_];
        
        // Select the International Item if available
    
        tMenuItem=[IBlocalizationPopupButton_ itemWithTitle:@"International"];
        
        if (tMenuItem==nil)
        {
            tMenuItem=[IBlocalizationPopupButton_ itemAtIndex:0];
        }
        
        [IBlocalizationPopupButton_ selectItem:tMenuItem];
        
        [self switchAlertLanguage:IBlocalizationPopupButton_];
        
        [self updateAlert:IBlocalizationPopupButton_];
    }
    else
    {
        [IBlocalizationPopupButton_ selectItemWithTitle:currentAlertLanguage_];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    if ([aMenuItem action]==@selector(switchAlertLanguage:))
    {
        if ([aMenuItem tag]==-222)
        {
            if ([currentAlertLanguage_ isEqualToString:@"International"]==YES)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark -

- (BOOL) shouldAddLocalization:(NSString *) inLocalization
{
    NSDictionary * tAlertDictionary;
    NSArray * tArray;
    int i,tCount;

    tAlertDictionary=[currentRequirementDictionary_ objectForKey:@"AlertDialog"];

    tArray=[tAlertDictionary allKeys];
    
    tCount=[tArray count];
    
    // Check that the Language is not already in the list
    
    for(i=0;i<tCount;i++)
    {
        if ([[tArray objectAtIndex:i] compare:inLocalization options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void) localizationPanelDidEnd:(PBLocalizationPanel *) localizationPanel returnCode:(int) returnCode localization:(NSString *) localization
{
    if (returnCode==NSOKButton)
    {
        NSDictionary * tAlertDictionary;
        NSMutableDictionary * tMutableAlertDictionary;
    
        tAlertDictionary=[currentRequirementDictionary_ objectForKey:@"AlertDialog"];
        
        // Add the new language
        
        tMutableAlertDictionary=[tAlertDictionary mutableCopy];
        
        [tMutableAlertDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"TitleKey",
                                                                                      @"",@"MessageKey",
                                                                                      nil]
                                    forKey:localization];
        
        [currentRequirementDictionary_ setObject:tMutableAlertDictionary
                        forKey:@"AlertDialog"];
        
        [tMutableAlertDictionary release];
        
        // Update the PopupButton
        
        [self updateAlertLanguage];
        
        [self updateAlert:IBlocalizationPopupButton_];
        
        [IBlocalizationPopupButton_ selectItemWithTitle:localization];
        
        [self switchAlertLanguage:IBlocalizationPopupButton_];
        
        [IBwindow_ makeFirstResponder:IBtitleField_];
    }
    else
    {
        [IBlocalizationPopupButton_ selectItemWithTitle:currentAlertLanguage_];
    }
}

@end
