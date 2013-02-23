/*
Copyright (c) 2004-2007, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSimulatorController.h"
#import "AKListView.h"
#import "PBProjectTree.h"
#import "PBSimulatorLocalizer.h"
#import "PBLanguageConverter.h"
#import "PBSimulatorTigerLocalizer.h"
#import "PBSimulatorImageProvider.h"
#import "PBSystemUtilities.h"

@implementation PBSimulatorController

+ (PBSimulatorController *) defaultController
{
    static PBSimulatorController * sSimulatorController=nil;
    
    if (sSimulatorController==nil)
    {
        sSimulatorController=[PBSimulatorController alloc];
    }
    
    return sSimulatorController;
}

- (BOOL) worksWhenModal
{
    return YES;
}

- (IBAction)switchLanguage:(id)sender
{
    if (selectedLanguage_==nil || [selectedLanguage_ isEqualToString:[sender titleOfSelectedItem]]==NO)
    {
        [selectedLanguage_ release];
    
        selectedLanguage_=[[sender titleOfSelectedItem] copy];
    
        [self setInterfaceForLanguage:selectedLanguage_];
        
        [self setPaneTitleForPaneAtIndex:currentPaneIndex_];
        
        [currentPaneController_ setLanguage:selectedLanguage_];
        
        [IBlist_ setNeedsDisplay:YES];
    }
}

- (void) setLicenseInterfaceForLanguage:(NSString *) inLanguage
{
    PBSimulatorLocalizer * tSimulatorLocalizer=nil;
    PBSimulatorTigerLocalizer * tSimulatorTigerLocalizer=nil;
    NSString * tValue;
    NSRect tFrame;
    NSRect tBoxFrame;
    
    if (isTigrou_==NO)
    {
        tSimulatorLocalizer=[PBSimulatorLocalizer defaultLocalizer];
    }
    else
    {
        tSimulatorTigerLocalizer=[PBSimulatorTigerLocalizer defaultLocalizer];
    }
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"LicensePageTitle" forLanguage:inLanguage];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorLocalizer localizedString:@"LicensePageTitle" forLanguage:selectedLanguage_];
        }
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"PageTitle" forLanguage:inLanguage inBundle:@"License"];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"PageTitle" forLanguage:selectedLanguage_  inBundle:@"License"];
        }
    }
    
    if (tValue==nil)
    {
        tValue=@"Software License Agreement";
    }
    
    [IBpaneTitle_ setStringValue:tValue];
        
    tBoxFrame=[IBbox_ frame];
    
    // localization of the buttons
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"ContinueTitle" forLanguage:inLanguage];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorLocalizer localizedString:@"ContinueTitle" forLanguage:selectedLanguage_];
        }
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Continue" forLanguage:inLanguage inBundle:@"Main"];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Continue" forLanguage:selectedLanguage_ inBundle:@"Main"];
        }
    }
    
    if (tValue==nil)
    {
        tValue=@"Continue";
    }
    
    [IBnextSlide_ setTitle:tValue];
    
    [IBnextSlide_ sizeToFit];
    
    tFrame=[IBnextSlide_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0f;
    }
    
    tFrame.origin.x=NSMaxX(tBoxFrame)-NSWidth(tFrame)+6.0f;
    
    [IBnextSlide_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"GoBackTitle" forLanguage:inLanguage];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorLocalizer localizedString:@"GoBackTitle" forLanguage:selectedLanguage_];
        }
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"GoBack" forLanguage:inLanguage inBundle:@"Main"];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"GoBack" forLanguage:selectedLanguage_ inBundle:@"Main"];
        }
    }
    
    if (tValue==nil)
    {
        tValue=@"Go Back";
    }
    
    [IBpreviousSlide_ setTitle:tValue];
    
    [IBpreviousSlide_ sizeToFit];
    
    tFrame=[IBpreviousSlide_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0f;
    }
    
    tFrame.origin.x=NSMinX([IBnextSlide_ frame])-NSWidth(tFrame);
    
    [IBpreviousSlide_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"PrintTitle" forLanguage:inLanguage];
    
        if (tValue==nil)
        {
            tValue=[tSimulatorLocalizer localizedString:@"PrintTitle" forLanguage:selectedLanguage_];
        }
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Print..." forLanguage:inLanguage inBundle:@"self"];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Print..." forLanguage:selectedLanguage_ inBundle:@"self"];
        }
    }
    
    if (tValue==nil)
    {
        tValue=@"Print...";
    }
    
    [IBprintButton_ setTitle:tValue];
    
    [IBprintButton_ sizeToFit];
    
    tFrame=[IBprintButton_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0f;
    }
    
    tFrame.origin.x=NSMinX(tBoxFrame)-6.0f;
    
    [IBprintButton_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"SaveTitle" forLanguage:inLanguage];
    
        if (tValue==nil)
        {
            tValue=[tSimulatorLocalizer localizedString:@"SaveTitle" forLanguage:selectedLanguage_];
        }
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Save..." forLanguage:inLanguage inBundle:@"self"];
        
        if (tValue==nil)
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Save..." forLanguage:selectedLanguage_ inBundle:@"self"];
        }
    }
    
    if (tValue==nil)
    {
        tValue=@"Save...";
    }
    
    [IBsaveButton_ setTitle:tValue];
    
    [IBsaveButton_ sizeToFit];
    
    tFrame=[IBsaveButton_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0f;
    }
    
    tFrame.origin.x=NSMaxX([IBprintButton_ frame]);
    
    [IBsaveButton_ setFrame:tFrame];
}

- (void) setInterfaceForLanguage:(NSString *) inLanguage
{
    int i,tCount,tIndex=0;
    NSString * tPath;
    NSArray * tArray;
    maxStep_=0;
    NSMutableDictionary * tDictionary;
    PBSimulatorLocalizer * tSimulatorLocalizer=nil;
    PBSimulatorTigerLocalizer * tSimulatorTigerLocalizer=nil;
    NSString * tValue;
    NSString * tLanguage;
    NSRect tFrame;
    NSRect tBoxFrame;
    
    tPath=[[NSBundle mainBundle] pathForResource:@"PaneList" ofType:@"plist"];
    
    tArray=[NSArray arrayWithContentsOfFile:tPath];
    
    tCount=[tArray count];
    
    [infoArray_ release];
    
    infoArray_=[[NSMutableArray alloc] initWithCapacity:tCount];
    
    if (isTigrou_==NO)
    {
        tSimulatorLocalizer=[PBSimulatorLocalizer defaultLocalizer];
    }
    else
    {
        tSimulatorTigerLocalizer=[PBSimulatorTigerLocalizer defaultLocalizer];
    }
    
    tLanguage=inLanguage;
    
    // Localized the Array
    
    for(i=0;i<tCount;i++)
    {
        NSString * tKey;
        NSString * tPluginName=nil;
                
        tDictionary=[[tArray objectAtIndex:i] mutableCopy];
        
        tKey=[tDictionary objectForKey:@"Pane Title"];
        
        if (isTigrou_==YES)
        {
            tPluginName=[tDictionary objectForKey:@"Plugin Name"];
        }
        
        if ([tKey length]>0)
        {
            if (isTigrou_==NO)
            {
                tValue=[tSimulatorLocalizer localizedString:tKey forLanguage:tLanguage];
                
                if (tValue==nil)
                {
                    tLanguage=[[PBLanguageConverter defaultConverter] ISOFromEnglish:inLanguage];
                    
                    tValue=[tSimulatorLocalizer localizedString:tKey forLanguage:tLanguage];
                    
                    if (tValue==nil)
                    {
                        tLanguage=[NSString stringWithString:@"English"];
                        
                        tValue=[tSimulatorLocalizer localizedString:tKey forLanguage:tLanguage];
                    }
                }
            }
            else
            {
                tValue=[tSimulatorTigerLocalizer localizedString:@"PageTitle" forLanguage:tLanguage inBundle:tPluginName];
                
                if (tValue==nil)
                {
                    tLanguage=[[PBLanguageConverter defaultConverter] ISOFromEnglish:inLanguage];
                    
                    tValue=[tSimulatorTigerLocalizer localizedString:@"PageTitle" forLanguage:tLanguage inBundle:tPluginName];
                    
                    if (tValue==nil)
                    {
                        tLanguage=[NSString stringWithString:@"English"];
                        
                        tValue=[tSimulatorTigerLocalizer localizedString:@"PageTitle" forLanguage:tLanguage inBundle:tPluginName];
                    }
                }
            }
            
            [tDictionary setObject:tValue forKey:@"Pane Title"];
        }
        
        tKey=[tDictionary objectForKey:@"List Title"];
        
        if (isTigrou_==NO)
        {
            tValue=[tSimulatorLocalizer localizedString:tKey forLanguage:tLanguage];
        }
        else
        {
             tValue=[tSimulatorTigerLocalizer localizedString:@"InstallerSectionTitle" forLanguage:tLanguage inBundle:tPluginName];
        }
        
        if (tValue==nil)
        {
            tValue=@"";
        }
        
        [tDictionary setObject:tValue forKey:@"List Title"];
        
        [infoArray_ addObject:tDictionary];
        
        [tDictionary release];
    }
    
    if (buttonsShown_==NO)
    {
        [[IBbox_ superview] addSubview:IBprintButton_];
        [[IBbox_ superview] addSubview:IBsaveButton_];
        
        [IBprintButton_ release];
        [IBsaveButton_ release];
        
        buttonsShown_=YES;
    }
        
    tBoxFrame=[IBbox_ frame];
    
    // localization of the buttons
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"ContinueTitle" forLanguage:tLanguage];
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Continue" forLanguage:tLanguage inBundle:@"Main"];
		
		if (tValue==nil)
		{
			tValue=[tSimulatorTigerLocalizer localizedString:@"CONTINUE" forLanguage:tLanguage inBundle:@"Main"];
		}
    }
    
    if (tValue==nil)
    {
        tValue=@"Continue";
    }
    
    [IBnextSlide_ setTitle:tValue];
    
    [IBnextSlide_ sizeToFit];
    
    tFrame=[IBnextSlide_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0;
    }
    
    tFrame.origin.x=NSMaxX(tBoxFrame)-NSWidth(tFrame)+6.0;
    
    [IBnextSlide_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"GoBackTitle" forLanguage:tLanguage];
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"GoBack" forLanguage:tLanguage inBundle:@"Main"];
    
		if (tValue==nil)
		{
			 tValue=[tSimulatorTigerLocalizer localizedString:@"GOBACK" forLanguage:tLanguage inBundle:@"Main"];
		}
	}
    
    if (tValue==nil)
    {
        tValue=@"Go Back";
    }
    
    [IBpreviousSlide_ setTitle:tValue];
    
    [IBpreviousSlide_ sizeToFit];
    
    tFrame=[IBpreviousSlide_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0;
    }
    
    tFrame.origin.x=NSMinX([IBnextSlide_ frame])-NSWidth(tFrame);
    
    [IBpreviousSlide_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"PrintTitle" forLanguage:tLanguage];
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Print..." forLanguage:tLanguage inBundle:@"self"];
    }
    
    if (tValue==nil)
    {
        tValue=@"Print...";
    }
    
    [IBprintButton_ setTitle:tValue];
    
    [IBprintButton_ sizeToFit];
    
    tFrame=[IBprintButton_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0;
    }
    
    tFrame.origin.x=NSMinX(tBoxFrame)-6.0;
    
    [IBprintButton_ setFrame:tFrame];
    
    if (isTigrou_==NO)
    {
        tValue=[tSimulatorLocalizer localizedString:@"SaveTitle" forLanguage:tLanguage];
    }
    else
    {
        tValue=[tSimulatorTigerLocalizer localizedString:@"Save..." forLanguage:tLanguage inBundle:@"self"];
    }
    
    if (tValue==nil)
    {
        tValue=@"Save...";
    }
    
    [IBsaveButton_ setTitle:tValue];
    
    [IBsaveButton_ sizeToFit];
    
    tFrame=[IBsaveButton_ frame];
    
    if (tFrame.size.width<100.0f)
    {
        tFrame.size.width=100.0;
    }
    
    tFrame.origin.x=NSMaxX([IBprintButton_ frame]);
    
    [IBsaveButton_ setFrame:tFrame];
    
    // --------------------------------------------------
    
    [paneControllerArray_ release];
    
    [IBlist_ cleanList];
    
    paneControllerArray_ = [[NSMutableArray arrayWithCapacity:tCount] retain];
    
    for(i=0;i<tCount;i++)
    {
        id tObject;
        id tPaneController;
        NSString * tClassName;
        NSString * tCategoryName;
        
        tObject=[infoArray_ objectAtIndex:i];
        
        tClassName=[tObject objectForKey:@"Class Name"];
        
        if ([tClassName length]>0)
        {
            NSDictionary * tDictionary;
            
            tPaneController=[NSClassFromString(tClassName) alloc];
            [tPaneController loadPaneNib:[tObject objectForKey:@"Nib Name"] withMainController:self];
            
            tCategoryName=[tClassName substringWithRange:NSMakeRange(2,[tClassName length]-16)];
            
            [paneControllerArray_ insertObject:tPaneController atIndex:tIndex];
            
            [tPaneController release];
            
            tDictionary=[infoDictionary_ objectForKey:tCategoryName];
            
            if ([tDictionary count]>0 || [tCategoryName isEqualToString:RESOURCE_WELCOME_KEY]==YES)
            {
                [tPaneController initPaneWithDictionary:tDictionary document:document_];
                
                maxStep_++;
            }
            else
            {
            	[infoArray_ removeObjectAtIndex:i];
                i--;
                tCount--;
                continue;
            }
            
            tIndex++;
        }
        
        [IBlist_ addPaneName:[tObject objectForKey:@"List Title"]];
        
    }
    
    if (currentRelativeRootView_!=nil)
    {
        [currentRelativeRootView_ removeFromSuperview];
    }
    
    currentRelativeRootView_=nil;
    
    currentPaneIndex_=0;
    currentPaneController_=[self paneControllerAtIndex:currentPaneIndex_];
    
    if (buttonsShown_==YES)
    {
        [IBprintButton_ retain];
        [IBsaveButton_ retain];
        
        [IBprintButton_ removeFromSuperview];
        [IBsaveButton_ removeFromSuperview];
        
        buttonsShown_=NO;
    }
        
    if (currentPaneController_!=nil)
    {
        currentRelativeRootView_=[currentPaneController_ relativeRootView];
     
        [IBbox_ addSubview:currentRelativeRootView_];
        [currentRelativeRootView_ setFrameOrigin:NSMakePoint(0,0)];
        
        [IBpreviousSlide_ setEnabled:NO];
        
        
        
        if (currentPaneIndex_<(maxStep_-1))
        {
            [IBnextSlide_ setEnabled:YES];
        }
        else
        {
            [IBnextSlide_ setEnabled:NO];
        }
    }
    else
    {
        NSLog(@"Big Problem !");
    }
}

- (void) showSimulatorWithResourceDictionary:(NSDictionary *) inDictionary fromDocument:(id) inDocument
{
    NSDictionary * tBackgroundDictionary;
    NSMutableArray * tLanguageArray;
    int i,tLanguageCount;
    int j,tCount;
    int k;
    NSArray * tArray,* tLocalizationArray;
    NSArray * tPreferedLocalizations;
    
    showDefaultBackground_=YES;
    
    backgroundSettingsModified_=NO;
    
    document_=inDocument;
    
    currentPaneController_=nil;
    
    if (IBwindow_==nil)
    {
        if ([NSBundle loadNibNamed:@"Simulator" owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"Simulator"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
    }
    
    [infoDictionary_ release];
    
    infoDictionary_=[inDictionary retain];
    
    // Build the Popup Language
    
    [IBpopupLanguage_ removeAllItems];
    
    tLanguageArray=[[[PBSimulatorLocalizer defaultLocalizer] localizations] mutableCopy];
    
    tLanguageCount=[tLanguageArray count];
    
    for(k=0;k<tLanguageCount;k++)
    {
        NSString * tEnglishName;
        
        tEnglishName=[[PBLanguageConverter defaultConverter] englishFromISO:[tLanguageArray objectAtIndex:k]];
        
        if (tEnglishName!=nil)
        {
            [tLanguageArray replaceObjectAtIndex:k withObject:tEnglishName];
        }
    }
    
    tArray=[NSArray arrayWithObjects:RESOURCE_WELCOME_KEY,RESOURCE_README_KEY,RESOURCE_LICENSE_KEY,nil];
    
    for(k=0;k<3;k++)
    {
        tLanguageCount=[tLanguageArray count];
        
        tLocalizationArray=[[infoDictionary_ objectForKey:[tArray objectAtIndex:k]] allKeys];
    
        tCount=[tLocalizationArray count];
        
        for(j=0;j<tCount;j++)
        {
            NSString * tKey;
            
            tKey=[tLocalizationArray objectAtIndex:j];
            
            if ([tKey isEqualToString:@"International"]==NO)
            {
                tLanguageCount=[tLanguageArray count];
                
                for(i=0;i<tLanguageCount;i++)
                {
                    if ([[tLanguageArray objectAtIndex:i] isEqualToString:tKey]==YES)
                    {
                        break;
                    }
                    
                    if ([[tLanguageArray objectAtIndex:i] isEqualToString:[[PBLanguageConverter defaultConverter] englishFromISO:tKey]]==YES)
                    {
                        [tLanguageArray replaceObjectAtIndex:i withObject:tKey];
                        
                        break;
                    }
                }
                
                if (i==tLanguageCount)
                {
                    [tLanguageArray addObject:tKey];
                }
            }
        }
    }
    
    [tLanguageArray sortUsingSelector:@selector(compare:)];
    
    [IBpopupLanguage_ addItemsWithTitles:tLanguageArray];
    
    
    
    // Set Background Picture
    
    tBackgroundDictionary=[infoDictionary_ objectForKey:@"Background Image"];
    
    if (tBackgroundDictionary!=nil)
    {
        if ([[tBackgroundDictionary objectForKey:@"Mode"] intValue]==1)
        {
            NSString * tPath;
            NSImage * tImage;
            NSNumber * tNumber;
            
            tPath=[tBackgroundDictionary objectForKey:@"Path"];
            
            tNumber=[tBackgroundDictionary objectForKey:@"Path Type"];
            
            if (tNumber!=nil)
            {
                if ([tNumber intValue]==kRelativeToProjectPath)
                {
                    tPath=[tPath stringByAbsolutingWithPath:[inDocument folder]];
                }
            }
            
            tImage=[[NSImage alloc] initWithContentsOfFile:tPath];
            
            if (tImage!=nil)
            {
                [IBlogo_ setImageScaling:[[tBackgroundDictionary objectForKey:@"IFPkgFlagBackgroundScaling"] intValue]];
                
                
                
                [IBlogo_ setImageAlignment:[[tBackgroundDictionary objectForKey:@"IFPkgFlagBackgroundAlignment"] intValue]];
        
                [IBlogo_ setImage:tImage];
                
                [tImage release];
            
                showDefaultBackground_=NO;
            }
        }
    }
    
    if (showDefaultBackground_==YES)
    {
        NSImage * tImage;
        
        [IBlogo_ setImageScaling:NSScaleNone];
        [IBlogo_ setImageAlignment:NSImageAlignBottomLeft];
        
        if (isLeopard_==YES)
		{
			NSString * tPath;
			
			tPath=[[NSBundle bundleWithPath:@"/System/Library/CoreServices/Installer.app"] pathForResource:@"defaultBackground" ofType:@"tiff"];
			
			tImage=[[NSImage alloc] initWithContentsOfFile:tPath];
			
			/*tImage=[[NSImage alloc] initWithContentsOfFile:@"/Library/Application Support/Apple/Installer/MacOSXInstallBackground.tiff"];*/
			
			if (tImage!=nil)
			{
				[IBlogo_ setImageScaling:NSScaleProportionally];
				[IBlogo_ setImageAlignment:NSImageAlignLeft];
			
				[tImage autorelease];
			}
		}
		else
		if (isTigrou_==YES)
        {
            tImage=[[PBSimulatorImageProvider defaultProvider] imageNamed:@"defaultBackground"];
        }
        else
        {
            tImage=[[PBSimulatorImageProvider defaultProvider] imageNamed:@"background"];
        }
        
        [IBlogo_ setImage:tImage];
    }
    
    // Set the language for the interface
    
    tPreferedLocalizations=(NSArray *) CFBundleCopyPreferredLocalizationsFromArray((CFArrayRef) tLanguageArray);
    
    selectedLanguage_=[[tPreferedLocalizations objectAtIndex:0] copy];
    
    [IBpopupLanguage_ selectItemWithTitle:selectedLanguage_];
    
    [tLanguageArray release];
    
    [self setInterfaceForLanguage:selectedLanguage_];
    
    [self setPaneTitleForPaneAtIndex:currentPaneIndex_];
    
    [currentPaneController_ setLanguage:selectedLanguage_];
    
    [NSApp runModalForWindow:IBwindow_];
}

- (void) awakeFromNib
{
    PBOSVersion tOSVersion;
    
    buttonsShown_=YES;
    
    _terminateNow_=NO;
    
    tOSVersion=[PBSystemUtilities systemMajorVersion];
    
    isTigrou_=(tOSVersion>=PBTiger);
    
	isLeopard_=(tOSVersion>=PBLeopard);
	
    if (tOSVersion>=PBPanther)
    {
        [IBpaneTitle_ setFont:[NSFont boldSystemFontOfSize:14.0f]];
    }
}


- (AKPaneController *) paneControllerAtIndex:(int) inIndex
{
    int tArrayCount=[paneControllerArray_ count];
    
    if (inIndex>=0 && inIndex<tArrayCount)
    {
        return [paneControllerArray_ objectAtIndex:inIndex];
    }
    
    return nil;
}

- (int) indexOfPaneControllerWithName:(NSString *) inName
{
    int tArrayCount=[paneControllerArray_ count];
    int i;
    
    for(i=0;i<tArrayCount;i++)
    {
        if ([[[infoArray_ objectAtIndex:i] objectForKey:@"List Title"] isEqualToString:inName]==YES)
        {
            return i;
        }
    }
    
    return -1;
}

#pragma mark -

- (void) setPaneTitleForPaneAtIndex:(int) inIndex
{
    if (inIndex>=0 && inIndex<[infoArray_ count])
    {
        NSString * tPaneTitle;
        
        tPaneTitle=[NSString stringWithFormat:[[infoArray_ objectAtIndex:inIndex] objectForKey:@"Pane Title"],NSLocalizedString(@"Simulator",@"No comment")];
        
        [IBpaneTitle_ setStringValue:tPaneTitle];
    }
}

#pragma mark -

- (IBAction)nextSlide:(id)sender
{
    AKPaneController * tPaneController;
    int tIndex;
    NSString * tNextPaneName;
    
    tNextPaneName=[currentPaneController_ nextPaneName];
    
    if (tNextPaneName!=nil)
    {
        tIndex=[self indexOfPaneControllerWithName:tNextPaneName];
    }
    else
    {
        tIndex=currentPaneIndex_+1;
    }
    
    tPaneController = [self paneControllerAtIndex:tIndex];
    
    if (tPaneController!=nil)
    {
        // Set up the new content of the box
        
        [currentRelativeRootView_ removeFromSuperview];
        
        [IBbox_  addSubview:[tPaneController relativeRootView]];
        
        currentRelativeRootView_=[tPaneController relativeRootView];
        [currentRelativeRootView_ setFrameOrigin:NSZeroPoint];
    }
    else
    {
        NSLog(@"The next pane was not found");
        return;
    }
    
    if (currentPaneIndex_==0)
    {
        [IBpreviousSlide_ setEnabled:YES];
        
        if (buttonsShown_==NO)
        {
            [[IBbox_ superview] addSubview:IBprintButton_];
            [[IBbox_ superview] addSubview:IBsaveButton_];
            
            [IBprintButton_ release];
            [IBsaveButton_ release];
            
            buttonsShown_=YES;
        }
    }
    
    [tPaneController setPreviousPaneIndex:currentPaneIndex_];
    
    currentPaneIndex_=tIndex;
    currentPaneController_=tPaneController;
    
    [self setPaneTitleForPaneAtIndex:tIndex];
    
    if (currentPaneIndex_==(maxStep_-1))
    {
        [IBnextSlide_ setEnabled:NO];
    }
    
    // Update the list View

    [IBlist_ setCurrentPaneIndex:currentPaneIndex_];
    
    [currentPaneController_ setLanguage:[IBpopupLanguage_ titleOfSelectedItem]];
}

- (IBAction)previousSlide:(id)sender
{
    AKPaneController * tPaneController;
    int tIndex;
    
    tIndex=[currentPaneController_ previousPaneIndex];
    
    if (tIndex==-1)
    {
        NSLog(@"No previous pane is defined for this pane");
        return;
    }
        
    tPaneController = [self paneControllerAtIndex:tIndex];
    
    if (tPaneController!=nil)
    {
        // Set up the new content of the box
        
        [currentRelativeRootView_ removeFromSuperview];
        
        [IBbox_  addSubview:[tPaneController relativeRootView]];
        
        currentRelativeRootView_=[tPaneController relativeRootView];
        [currentRelativeRootView_ setFrameOrigin:NSZeroPoint];
    }
    else
    {
        NSLog(@"The previous pane was not found");
        return;
    }
    
    currentPaneIndex_=tIndex;
    currentPaneController_=tPaneController;
    [self setPaneTitleForPaneAtIndex:tIndex];
    
    
    if (currentPaneIndex_<(maxStep_-1))
    {
        [IBnextSlide_ setEnabled:YES];
    }

    if (currentPaneIndex_==0)
    {
        [IBpreviousSlide_ setEnabled:NO];
        
        if (buttonsShown_==YES)
        {
            [IBprintButton_ retain];
            [IBsaveButton_ retain];
        
            [IBprintButton_ removeFromSuperview];
            [IBsaveButton_ removeFromSuperview];
            
            buttonsShown_=NO;
        }
    }
    
    {
        NSString * tValue;
        NSRect tFrame;
        NSRect tBoxFrame;
        PBSimulatorLocalizer * tSimulatorLocalizer=nil;
        PBSimulatorTigerLocalizer * tSimulatorTigerLocalizer=nil;
        
        if (isTigrou_==NO)
        {
            tSimulatorLocalizer=[PBSimulatorLocalizer defaultLocalizer];
        }
        else
        {
            tSimulatorTigerLocalizer=[PBSimulatorTigerLocalizer defaultLocalizer];
        }
        
        tBoxFrame=[IBbox_ frame];
        
        // localization of the buttons
        
        if (isTigrou_==NO)
        {
            tValue=[tSimulatorLocalizer localizedString:@"ContinueTitle" forLanguage:selectedLanguage_];
        }
        else
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Continue" forLanguage:selectedLanguage_ inBundle:@"Main"];
        }
        
        if (tValue==nil)
        {
            tValue=@"Continue";
        }
        
        [IBnextSlide_ setTitle:tValue];
        
        [IBnextSlide_ sizeToFit];
        
        tFrame=[IBnextSlide_ frame];
        
        if (tFrame.size.width<100.0f)
        {
            tFrame.size.width=100.0f;
        }
        
        tFrame.origin.x=NSMaxX(tBoxFrame)-NSWidth(tFrame)+6.0f;
        
        [IBnextSlide_ setFrame:tFrame];
        
        if (isTigrou_==NO)
        {
            tValue=[tSimulatorLocalizer localizedString:@"GoBackTitle" forLanguage:selectedLanguage_];
        }
        else
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"GoBack" forLanguage:selectedLanguage_ inBundle:@"Main"];
        }
        
        if (tValue==nil)
        {
            tValue=@"Go Back";
        }
        
        [IBpreviousSlide_ setTitle:tValue];
        
        [IBpreviousSlide_ sizeToFit];
        
        tFrame=[IBpreviousSlide_ frame];
        
        if (tFrame.size.width<100.0f)
        {
            tFrame.size.width=100.0f;
        }
        
        tFrame.origin.x=NSMinX([IBnextSlide_ frame])-NSWidth(tFrame);
        
        [IBpreviousSlide_ setFrame:tFrame];
        
        if (isTigrou_==NO)
        {
            tValue=[tSimulatorLocalizer localizedString:@"PrintTitle" forLanguage:selectedLanguage_];
        }
        else
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Print..." forLanguage:selectedLanguage_ inBundle:@"self"];
        }
        
        if (tValue==nil)
        {
            tValue=@"Print...";
        }
        
        [IBprintButton_ setTitle:tValue];
        
        [IBprintButton_ sizeToFit];
        
        tFrame=[IBprintButton_ frame];
        
        if (tFrame.size.width<100.0f)
        {
            tFrame.size.width=100.0f;
        }
        
        tFrame.origin.x=NSMinX(tBoxFrame)-6.0f;
        
        [IBprintButton_ setFrame:tFrame];
        
        if (isTigrou_==NO)
        {
            tValue=[tSimulatorLocalizer localizedString:@"SaveTitle" forLanguage:selectedLanguage_];
        }
        else
        {
            tValue=[tSimulatorTigerLocalizer localizedString:@"Save..." forLanguage:selectedLanguage_ inBundle:@"self"];
        }
        
        if (tValue==nil)
        {
            tValue=@"Save...";
        }
        
        [IBsaveButton_ setTitle:tValue];
        
        [IBsaveButton_ sizeToFit];
        
        tFrame=[IBsaveButton_ frame];
        
        if (tFrame.size.width<100.0f)
        {
            tFrame.size.width=100.0f;
        }
        
        tFrame.origin.x=NSMaxX([IBprintButton_ frame]);
        
        [IBsaveButton_ setFrame:tFrame];
    }
    
    // Update the list View
    
    [IBlist_ setCurrentPaneIndex:currentPaneIndex_];
    
    [tPaneController setLanguage:[IBpopupLanguage_ titleOfSelectedItem]];
}

- (IBAction) endSimulator:(id) sender
{
    if (backgroundSettingsModified_==YES) 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Do you want to apply the modifications made on the Background Image settings?",@"No comment"),
                          NSLocalizedString(@"Apply",@"No comment"),
                          NSLocalizedString(@"Don't Apply",@"No comment"),
                          nil,
                          IBwindow_,
                          self,
                          @selector(applyBackgroundModificationsSheetDidEnd:returnCode:contextInfo:),
                          nil,
                          NULL,
                          NSLocalizedString(@"The Background Image alignment or/and scaling settings have been modified via the contextual menu.",@"No comment"));
    }
    else
    {
        [NSApp stopModal];
    
        [IBwindow_ orderOut:self];
    }
}

- (void) applyBackgroundModificationsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode==NSAlertDefaultReturn)
    {
        NSDictionary * tUserInfo;
        
        tUserInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[IBlogo_ imageAlignment]],@"Alignment",
                                                             [NSNumber numberWithInt:[IBlogo_ imageScaling]],@"Scaling",
                                                             nil];
        
        // Send the notitication
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PBBackgroundImageSettingsDidChange"
                                                            object:document_
                                                          userInfo:tUserInfo];
    }
    
    [NSApp stopModal];
    
    [IBwindow_ orderOut:self];
}

#pragma mark -

- (IBAction) setImageScaling:(id) sender
{
    int tTag;
    
    tTag=[sender tag];
    
    if (tTag!=[IBlogo_ imageScaling])
    {
        [IBlogo_ setImageScaling:tTag];
        
        backgroundSettingsModified_=YES;
    }
}

- (IBAction) setImageAlignment:(id) sender 
{
    int tTag;
    
    tTag=[sender tag];

    if (tTag!=[IBlogo_ imageAlignment])
    {
        [IBlogo_ setImageAlignment:tTag];
        
        backgroundSettingsModified_=YES;
    }
}

- (BOOL) validateMenuItem:(NSMenuItem *) anItem
{
    SEL tAction=[anItem action];
    
    if (tAction==@selector(switchLanguage:))
    {
        return YES;
    }
    else if (tAction==@selector(setImageScaling:) ||
             tAction==@selector(setImageAlignment:))
    {
        return (showDefaultBackground_==NO);
    }
    
    return NO;
}

@end
