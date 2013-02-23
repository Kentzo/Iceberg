#import "PBPreferencesController+AppleScript.h"

static unsigned long sReferenceStyleAppleCode[2]={
                                                    'RAbs',
                                                    'RPRe'
                                                };
                                                
@implementation PBPreferencesController  (AppleScript)

- (NSNumber *) defaultReferenceStyle
{
    int tSelectedTag=0;
    NSNumber * tNumber=nil;
    
    if (IBwindow_!=nil)
    {
        tSelectedTag=[[IBdefaultReferenceStyle_ selectedItem] tag];
    }
    else
    {
        NSUserDefaults * tDefaults;
    
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        tSelectedTag=[tDefaults integerForKey:@"Default Reference Style"];
    }
    
    tSelectedTag--;
        
    if (tSelectedTag>=0 && tSelectedTag<=1)
    {
        tNumber=[NSNumber numberWithUnsignedLong:sReferenceStyleAppleCode[tSelectedTag]];
    }
    
    return tNumber;
}

- (void) setDefaultReferenceStyle:(NSNumber *) inNumber
{
    if ([inNumber isKindOfClass:[NSNumber class]])
    {
        unsigned long tValue;
        int i;
        
        tValue=[inNumber unsignedLongValue];
        
        for(i=0;i<2;i++)
        {
            if (tValue==sReferenceStyleAppleCode[i])
            {
                int tSelectedTag;
                NSUserDefaults * tDefaults;
                 
                tSelectedTag=i+1;
                
                if (IBwindow_!=nil)
                {
                    [IBdefaultReferenceStyle_ selectItemAtIndex:[IBdefaultReferenceStyle_ indexOfItemWithTag:tSelectedTag]];
                }
                
                tDefaults=[NSUserDefaults standardUserDefaults];
                
                [tDefaults setInteger:tSelectedTag forKey:@"Default Reference Style"];
                    
                [tDefaults synchronize];
                
                break;
            }
        }
    }
}

- (BOOL) copyPackageWhenImporting
{
    if (IBwindow_!=nil)
    {
        return ([IBcopyPackage_ state]==NSOnState);
    }
    else
    {
        NSUserDefaults * tDefaults;
    
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        return [tDefaults boolForKey:@"CopyPackageOnImport"];
    }
}

- (void) setCopyPackageWhenImporting:(BOOL) aBool
{
    NSUserDefaults * tDefaults;
    
    if (IBwindow_!=nil)
    {
        [IBcopyPackage_ setState:aBool ? NSOnState : NSOffState];
    }
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    [tDefaults setBool:aBool forKey:@"CopyPackageOnImport"];
        
    [tDefaults synchronize];
}

- (BOOL) importMetapackageComponents
{
    if (IBwindow_!=nil)
    {
        return ([IBimportMetapackageComponents_ state]==NSOnState);
    }
    else
    {
        NSUserDefaults * tDefaults;
    
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        return [tDefaults boolForKey:@"ImportMetapackageComponents"];
    }
}

- (void) setImportMetapackageComponents:(BOOL) aBool
{
    NSUserDefaults * tDefaults;
    
    if (IBwindow_!=nil)
    {
        [IBimportMetapackageComponents_ setState:aBool ? NSOnState : NSOffState];
    }
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    [tDefaults setBool:aBool forKey:@"ImportMetapackageComponents"];
        
    [tDefaults synchronize];
}

- (BOOL) saveProjectBeforeBuilding
{
    if (IBwindow_!=nil)
    {
        return ([IBsaveBuild_ state]==NSOnState);
    }
    else
    {
        NSUserDefaults * tDefaults;
    
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        return [tDefaults boolForKey:@"SaveBeforeBuild"];
    }
}

- (void) setSaveProjectBeforeBuilding:(BOOL) aBool
{
    NSUserDefaults * tDefaults;
    
    if (IBwindow_!=nil)
    {
        [IBsaveBuild_ setState:aBool ? NSOnState : NSOffState];
    }
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    [tDefaults setBool:aBool forKey:@"SaveBeforeBuild"];
        
    [tDefaults synchronize];
}

- (NSString *) scratchFolderLocation
{
    if (IBwindow_!=nil)
    {
        return [IBscratchPath_ stringValue];
    }
    else
    {
        NSUserDefaults * tDefaults;
    
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        return [tDefaults objectForKey:@"Scratch Path"];
    }
}

- (void) setScratchFolderLocation:(NSString *) aString
{
    NSUserDefaults * tDefaults;
    
    if (IBwindow_!=nil)
    {
        [IBscratchPath_ setStringValue:aString];
    }
    
    tDefaults=[NSUserDefaults standardUserDefaults];
    
    [tDefaults setObject:aString forKey:@"Scratch Path"];
        
    [tDefaults synchronize];
}

@end
