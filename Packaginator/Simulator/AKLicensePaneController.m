/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AKLicensePaneController.h"
#import "PBLanguageConverter.h"
#import "PBLicenseProvider.h"
#import "NSString+Karelia.h"
#import "PBSimulatorController.h"

@implementation AKLicensePaneController

- (void) awakeFromNib
{
    [IBtextView_ setDrawsBackground:NO];
    
    [IBtextView_ setTextContainerInset:NSMakeSize(7,7)];
}

- (void) initPaneWithDictionary:(NSDictionary *) inDictionary document:(NSDocument *) inDocument
{
    int tCount;
    NSRect tScrollFrame;
    
    tScrollFrame=[IBscrollView_ frame];
    
    [super initPaneWithDictionary:inDictionary document:inDocument];
    
    tCount=[dictionary_ count];
    
    if (tCount==1 && [dictionary_ objectForKey:@"International"]!=nil)
    {
        // Only One Language Available
        
        if (removedFromSuperview_==NO)
        {
            // Remove the Popup
            
            [IBpopupLanguages_ removeFromSuperview];
            
            removedFromSuperview_=YES;
            
            // Resize the text view
            
            tScrollFrame.size.height=329;
            
            [IBscrollView_ setFrame:tScrollFrame];
        }
    }
    else
    {
        NSArray * tArray;
        int i;
        NSMutableArray * tLanguagesArray;
        
        // Multiple Languages available
        
        if (removedFromSuperview_==YES)
        {
            // Put Back the Popup
            
            [relativeRootView_ addSubview:IBpopupLanguages_];
            
            removedFromSuperview_=NO;
            
            // Resize the Text View
            
            tScrollFrame.size.height=271;
            
            [IBscrollView_ setFrame:tScrollFrame];
        }
        
        // Build the Languages popup
        
        [languagesTranslator_ release];
        
        [IBpopupLanguages_ removeAllItems];
        
        tArray=[dictionary_ allKeys];
        
        tLanguagesArray=[NSMutableArray arrayWithCapacity:tCount];
        
        languagesTranslator_=[[NSMutableDictionary dictionaryWithCapacity:tCount] retain];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tLanguage;
            NSString * tLanguageLocalized;
            
            tLanguage=[tArray objectAtIndex:i];
            
            if ([tLanguage isEqualToString:@"International"]==NO)
            {
                tLanguageLocalized=[[PBLanguageConverter defaultConverter] nativeForEnglish:tLanguage];
            
                [languagesTranslator_ setObject:tLanguage forKey:tLanguageLocalized];
            
                [tLanguagesArray addObject:tLanguageLocalized];
            }
        }
        
        [tLanguagesArray sortUsingSelector:@selector(compare:)];
        
        [IBpopupLanguages_ addItemsWithTitles:tLanguagesArray];
    }
}

- (void) setLanguage:(NSString *) inString
{
    NSString * tLanguage;
   
    if (removedFromSuperview_==NO)
    {
        id tMenuItem;
        NSArray * tResultArray=nil;
        
        // Select the best default language for the Popup
        
        tLanguage=inString;
        
        tMenuItem=[IBpopupLanguages_ itemWithTitle:[[PBLanguageConverter defaultConverter] nativeForEnglish:inString]];
        
        if (tMenuItem==nil)
        {
            NSArray * tLanguageArray;
            
            
            tLanguageArray=[dictionary_ allKeys];
            
            tResultArray=(NSArray *) CFBundleCopyPreferredLocalizationsFromArray((CFArrayRef) tLanguageArray);
            
            tLanguage=[[tResultArray objectAtIndex:0] copy];
            
            [tResultArray release];
            
            [tLanguage autorelease];
        }
        
        [IBpopupLanguages_ selectItemWithTitle:[[PBLanguageConverter defaultConverter] nativeForEnglish:tLanguage]];
        
        
    }
    else
    {
        // Just one file, not too complex
        
        if ([dictionary_ objectForKey:@"International"]!=nil)
        {
            if ([dictionary_ objectForKey:inString]!=nil)
            {
                tLanguage=inString;
            }
            else
            {
                tLanguage=@"International";
            }
        }
        else
        {
            tLanguage=[[dictionary_ allKeys] objectAtIndex:0];
        }
    }
    
    [self setInternalLanguage:tLanguage];
}
    
- (void) setInternalLanguage:(NSString *) inLanguage
{
    NSTextStorage * tTextStorage;
    NSString * tPath=nil;
    NSDictionary * tDictionary;
    int tMode;
    BOOL success;
    
    [mainController_ setLicenseInterfaceForLanguage:inLanguage];
    
    tDictionary=[dictionary_ objectForKey:inLanguage];
    
    if (tDictionary!=nil)
    {
        tMode=[[tDictionary objectForKey:@"Mode"] intValue];
        
        switch(tMode)
        {
            case 1:
                {
                    NSNumber * tNumber;
                    
                    tPath=[tDictionary objectForKey:@"Path"];
                    
                    tNumber=[tDictionary objectForKey:@"Path Type"];
                    
                    if (tNumber!=nil)
                    {
                        if ([tNumber intValue]==kRelativeToProjectPath)
                        {
                            tPath=[tPath stringByAbsolutingWithPath:[document_ folder]];
                        }
                    }
                }
                break;
            case 2:
                tPath=[[PBLicenseProvider defaultProvider] pathForLicenseWithName:[tDictionary objectForKey:@"Template"]
                                                                         language:inLanguage];
                
                break;
        }
        
        if (tPath!=nil)
        {
            [IBtextView_ setString:@""];
            
            tTextStorage=[IBtextView_ textStorage];
        
            [tTextStorage beginEditing];
            success = [tTextStorage readFromURL:[NSURL fileURLWithPath:tPath]
                                        options:[AKPaneController defaultOptionsWithPath:tPath]
                            documentAttributes:NULL];
            
            if (tMode==2)
            {
                // Replace the keywords
                
                NSDictionary * tKeywords;
                
                tKeywords=[tDictionary objectForKey:@"Keywords"];
                
                if (tKeywords!=nil && [tKeywords count]>0)
                {
                    [PBLicenseProvider replaceKeywords:tKeywords
                                    inAttributedString:tTextStorage];
                }
            }
            
            [tTextStorage endEditing];
        }
    }
}

- (IBAction) switchLicenseLanguage:(id) sender
{
    [self setInternalLanguage:[languagesTranslator_ objectForKey:[sender titleOfSelectedItem]]];
}

@end
