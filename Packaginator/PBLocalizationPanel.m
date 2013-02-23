/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBLocalizationPanel.h"

#import "PBLanguageProvider.h"

@implementation NSObject (PBLocalizationPanelDelegate)

- (BOOL) shouldAddLocalization:(NSString *) inLocalization
{
    return YES;
}

@end

@implementation PBLocalizationPanel

+ (id) localizationPanel
{
    static NSMutableArray * sPanelArray=nil;
    int i,tCount;
    PBLocalizationPanel * nLocalizationPanel;
    if (sPanelArray==nil)
    {
        sPanelArray=[[NSMutableArray alloc] initWithCapacity:10];
    }
    
    tCount=[sPanelArray count];
    
    for(i=0;i<tCount;i++)
    {
        PBLocalizationPanel * tLocalizationPanel;
        
        tLocalizationPanel=(PBLocalizationPanel *) [sPanelArray objectAtIndex:i];
        
        if ([tLocalizationPanel isFree]==YES)
        {
            return tLocalizationPanel;
        }
    }
    
    nLocalizationPanel=[PBLocalizationPanel alloc];
    
    [sPanelArray addObject:nLocalizationPanel];
    
    return nLocalizationPanel;
}

- (void) awakeFromNib
{
}

- (BOOL) isFree
{
    return free_;
}

- (void) setFree:(BOOL) inFree
{
    free_=inFree;
}

- (void) beginSheetModalForWindow:(id) window modalDelegate:(id) delegate didEndSelector:(SEL) didEndSelector
{
    delegate_=delegate;
    didEndSelector_=didEndSelector;
    
    runAsSheet_=YES;
    
    if (IBwindow_==nil)
    {
        // We need to load the nib
        
        if ([NSBundle loadNibNamed:@"LocalizationPanel" owner:self]==NO)
        {
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"LocalizationPanel"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    [self setFree:NO];
    
    // Clean everything
    
    [IBaddButton_ setEnabled:NO];
    
    [IBcomboBox_ setStringValue:@""];
    
    [NSApp beginSheet:IBwindow_
       modalForWindow:window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:NULL];
}

- (void) runModalForWindow:(id) window modalDelegate:(id) delegate didEndSelector:(SEL) didEndSelector
{
    delegate_=delegate;
    didEndSelector_=didEndSelector;
    
    runAsSheet_=NO;
    
    if (IBwindow_==nil)
    {
        // We need to load the nib
        
        if ([NSBundle loadNibNamed:@"LocalizationPanel" owner:self]==NO)
        {
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"LocalizationPanel"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    [self setFree:NO];
    
    // Clean everything
    
    [IBaddButton_ setEnabled:NO];
    
    [IBcomboBox_ setStringValue:@""];
    
    [NSApp runModalForWindow:IBwindow_];
}

- (IBAction) setLanguage:(id) sender
{
    [self controlTextDidChange:nil];
}

- (IBAction)endDialog:(id)sender
{
    NSInvocation * tInvocation;
    int tTag=[sender tag];
    NSString * tLanguage;
    
    if (tTag==NSOKButton)
    {
        tLanguage=[IBcomboBox_ stringValue];
        
        if ([delegate_ respondsToSelector:@selector(shouldAddLocalization:)]==YES)
        {
            if ([delegate_ shouldAddLocalization:tLanguage]==NO)
            {
                NSBeep();
                
                NSRunAlertPanel([NSString stringWithFormat:NSLocalizedString(@"The \"%@\" localization already exists",@"No comment"),tLanguage],
                                NSLocalizedString(@"Please enter a different name.",@"No comment"),
                                nil,nil,nil);
                
                return;
            }
        }
    }
    
    if (delegate_!=nil && didEndSelector_!=nil)
    {
        //- (void) localizationPanelDidEnd:(PBLocalizationPanel *) localizationPanel returnCode:(int) returnCode localization:(NSString *) localization;
        
        tInvocation=[NSInvocation invocationWithMethodSignature:[delegate_ methodSignatureForSelector:didEndSelector_]];
    
        [tInvocation setSelector:didEndSelector_];
        
        [tInvocation setArgument:&self atIndex:2];
        [tInvocation setArgument:&tTag atIndex:3];
        [tInvocation setArgument:&tLanguage atIndex:4];
        
        [tInvocation invokeWithTarget:delegate_];
    }
       
    if (runAsSheet_==YES)
    {
        [NSApp endSheet:IBwindow_];
    }
    else
    {
        [NSApp stopModal];
    }
    
    [IBwindow_ orderOut:self];
    
    free_=YES;
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSString * tLanguage;
    
    tLanguage=[IBcomboBox_ stringValue];
    
    if ([tLanguage length]<2)
    {
        if ([IBaddButton_ isEnabled]==YES)
        {
            [IBaddButton_ setEnabled:NO];
        }
    }
    else
    {
        if ([IBaddButton_ isEnabled]==NO)
        {
            [IBaddButton_ setEnabled:YES];
        }
    }
}

#pragma mark -

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
    return [[[PBLanguageProvider sharedLanguageProvider] languageArray] objectAtIndex:index];
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [[PBLanguageProvider sharedLanguageProvider] count];
}


@end
