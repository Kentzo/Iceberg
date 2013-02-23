/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBPackageSettingsController.h"
#import "PBLanguageProvider.h"

@implementation PBPackageSettingsController

+ (PBPackageSettingsController *) packageSettingsController
{
    PBPackageSettingsController * nController=nil;
    
    nController=[PBPackageSettingsController alloc];
    
    if (nController!=nil)
    {
        if ([NSBundle loadNibNamed:@"PSettings" owner:nController]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"PSettings"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    return nController;
}

- (void) awakeFromNib
{
    NSButtonCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    NSCell * tTextFieldCell;
    
    [IBoptionsFlagsArray_ setIntercellSpacing:NSMakeSize(3,1)];
    
    tableColumn = [IBoptionsFlagsArray_ tableColumnWithIdentifier: @"Status"];
    tPrototypeCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [tPrototypeCell setControlSize:NSSmallControlSize];
    [tPrototypeCell setEditable:YES];
    [tPrototypeCell setButtonType: NSSwitchButton];
    [tPrototypeCell setImagePosition: NSImageOnly];
    [tableColumn setDataCell:tPrototypeCell];
    
    tableColumn = [IBoptionsFlagsArray_ tableColumnWithIdentifier: @"Name"];
    tTextFieldCell = [tableColumn dataCell];
    [tTextFieldCell setFont:[NSFont systemFontOfSize:11.0]];
    
    optionsKeysArray_=[[NSArray alloc] initWithObjects:IFPkgFlagIsRequired,
                                                       IFPkgFlagRootVolumeOnly,
                                                       IFPkgFlagOverwritePermissions,
                                                       IFPkgFlagUpdateInstalledLanguages,
                                                       IFPkgFlagRelocatable,
                                                       //IFPkgFlagInstallFat,	// Not used by Installer.app
                                                       IFPkgFlagAllowBackRev,
                                                       IFPkgFlagFollowLinks,
                                                       nil];
}

- (void) initWithProjectTree:(PBProjectTree *) inProjectTree forDocument:(id) inDocument
{
    NSDictionary * tDictionary;
    NSDictionary * tOptionsDictionary;
    NSNumber * tNumber;
    int i,tCount;
    
    [super initWithProjectTree:inProjectTree forDocument:inDocument];
    
    tDictionary=[objectNode_ settings];
    
    tOptionsDictionary=[tDictionary objectForKey:@"Options"];
    
    tNumber=[tOptionsDictionary objectForKey:IFPkgFlagRestartAction];
    
    if (tNumber!=nil)
    {
        [IBoptionsRestartPopupButton_ selectItemAtIndex:[IBoptionsRestartPopupButton_ indexOfItemWithTag:[tNumber intValue]]];
    }
    else
    {
        [IBoptionsRestartPopupButton_ selectItemAtIndex:[IBoptionsRestartPopupButton_ indexOfItemWithTag:0]];
    }
    
    tNumber=[tOptionsDictionary objectForKey:IFPkgFlagAuthorizationAction];
    
    if (tNumber!=nil)
    {
        [IBoptionsAuthorizationPopupButton_ selectItemAtIndex:[IBoptionsAuthorizationPopupButton_ indexOfItemWithTag:[tNumber intValue]]];
    }
    else
    {
        [IBoptionsAuthorizationPopupButton_ selectItemAtIndex:[IBoptionsAuthorizationPopupButton_ indexOfItemWithTag:0]];
    }
    
    [optionsValuesArray_ release];
    
    tCount=[optionsKeysArray_ count];
    
    optionsValuesArray_=[[NSMutableArray alloc] initWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        tNumber=[tOptionsDictionary objectForKey:[optionsKeysArray_ objectAtIndex:i]];
    
        if (tNumber!=nil)
        {
            [optionsValuesArray_ addObject:tNumber];
        }
        else
        {
            [optionsValuesArray_ addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [IBoptionsFlagsArray_ deselectAll:self];
    
    [IBoptionsFlagsArray_ reloadData];
}

- (void) treeWillChange
{
    [self updateOptions:nil];
    
    [super treeWillChange];
}

- (IBAction) updateOptions:(id) sender
{
    NSMutableDictionary * tDictionary;
    NSMutableDictionary * tSettingsDictionary;
    int i,tCount;
    
    tDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[IBoptionsRestartPopupButton_ selectedItem] tag]],IFPkgFlagRestartAction,
                                                                  [NSNumber numberWithInt:[[IBoptionsAuthorizationPopupButton_ selectedItem] tag]],IFPkgFlagAuthorizationAction,
                                                                  nil];
    
    tCount=[optionsKeysArray_ count];
    
    for(i=0;i<tCount;i++)
    {
        [tDictionary setObject:[optionsValuesArray_ objectAtIndex:i]
                        forKey:[optionsKeysArray_ objectAtIndex:i]];
    }
    
    tSettingsDictionary=[objectNode_ settings];
    
    [tSettingsDictionary setObject:tDictionary
                            forKey:@"Options"];
                            
    if (sender==IBoptionsFlagsArray_)
    {
        [self postNotificationChange];
    }
    
    if (sender!=nil)
    {
        [self setDocumentNeedsUpdate:YES];
    }
}

#pragma mark -

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBoptionsFlagsArray_)
    {
        if ([IBoptionsFlagsArray_ numberOfSelectedRows]==0)
        {
            [IBoptionsFlagsDescription_ setStringValue:@""];
        }
        else
        {
            int tSelectedRow;
            
            tSelectedRow=[IBoptionsFlagsArray_ selectedRow];
            
            [IBoptionsFlagsDescription_ setStringValue:NSLocalizedStringFromTable([optionsKeysArray_ objectAtIndex:tSelectedRow],@"Flags Description",@"No comment")];
        }
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [optionsKeysArray_ count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString: @"Status"])
    {
        return [optionsValuesArray_ objectAtIndex:rowIndex];
    }
    else
    if ([[aTableColumn identifier] isEqualToString: @"Name"])
    {
        return NSLocalizedString([optionsKeysArray_ objectAtIndex:rowIndex],@"No comment");
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if ([[tableColumn identifier] isEqualToString: @"Status"])
    {
        [optionsValuesArray_ replaceObjectAtIndex:row withObject:object];
        [self updateOptions:IBoptionsFlagsArray_];
    }
}

@end
