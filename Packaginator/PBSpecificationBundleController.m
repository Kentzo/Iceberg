/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationBundleController.h"
#import "NSDecimalNumber+FixPList.h"

@implementation PBSpecificationBundleController

- (void) awakeFromNib
{
    // Initialize the Key menu
    
    NSMutableArray * tSortedArray;
    
    [super awakeFromNib];

    classDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BundleKeyClass" ofType:@"plist"]];
    
    if (classDictionary_!=nil)
    {
        tSortedArray=[[classDictionary_ allKeys] mutableCopy];
    
        [tSortedArray sortUsingSelector:@selector(compare:)];
        
        [IBbundleKey_ removeAllItems];
        
        [IBbundleKey_ addItemsWithTitles:tSortedArray];
        
        [tSortedArray release];
    }
    
    [IBbundlePath_ setFormatter:nil];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary tag:(int) inTag
{
    id tObject;
    
    [super initWithDictionary:inDictionary tag:inTag];
    
    if (inDictionary!=nil)
    {
        NSString * tProperty;
        NSString * tString;
        
        tString=[inDictionary objectForKey:@"SpecArgument"];
        
        if (tString!=nil)
        {
            [IBbundlePath_ setStringValue:tString];
        }
        else
        {
            // SpecArgument is missing
            
            [IBbundlePath_ setStringValue:@""];
        }
        
        tProperty=[inDictionary objectForKey:@"SpecProperty"];
        
        if (tProperty==nil)
        {
            // Tests whether a bundle exists or not
            
            tString=[inDictionary objectForKey:@"TestOperator"];
        
            if ([tString isEqualTo:@"=="]==YES ||
                [tString isEqualTo:PBSPECIFICATIONCONTROLLER_EQUAL]==YES ||
                [tString isEqualTo:@"eq"]==YES)
            {
                // Bundle does not exists
                
                currentMode_=2;
            }
            else if ([tString isEqualTo:PBSPECIFICATIONCONTROLLER_NOTEQUAL]==YES || [tString isEqualTo:@"ne"]==YES)
            {
                // Bundle does exists
            
                currentMode_=1;
            }
            else
            {
                // Problem
                
                // A COMPLETER
            }
            
            
        }
        else
        {
            // Add the Subview
            
            currentMode_=0;
            
            [IBview_ addSubview:IBsubview_];
            
            [IBsubview_ setFrameOrigin:NSZeroPoint];
            
            if (-1!=[IBbundleKey_ indexOfItemWithTitle:tProperty])
            {
                [IBbundleKey_ selectItemWithTitle:tProperty];
                
                [self setNewKey:tProperty];
                
                tString=[inDictionary objectForKey:@"TestOperator"];
            }
            else
            {
                // SpecProperty is not in our list (oups!)
                
                // A COMPLETER
            }
            
            if (tString!=nil)
            {
                [self selectOperatorItem:tString];
            }
            else
            {
                // TestOperator is missing
                
                NSLog(@"Bundle IFRequirement: TestOperator is nil");
            
                [self selectOperatorItem:PBSPECIFICATIONCONTROLLER_EQUAL];
            }
            
            tObject=[inDictionary objectForKey:@"TestObject"];
        
            if (tObject!=nil)
            {
                [IBobjectField_ setObjectValue:[inDictionary objectForKey:@"TestObject"]];
            }
            else
            {
                // TestObject is missing
                
                NSLog(@"oh oh bundle");
                
                // A COMPLETER
            }
        }
    }
    else
    {
        // Add the subview
        
        currentMode_=0;
        
        [IBview_ addSubview:IBsubview_];
            
        [IBsubview_ setFrameOrigin:NSZeroPoint];
        
        [IBbundlePath_ setStringValue:@""];
        
        [IBbundleKey_ selectItemAtIndex:0];
        
        [self setNewKey:[IBbundleKey_ titleOfSelectedItem]];
    }
    
    [IBbundleMode_ selectItemAtIndex:[IBbundleMode_ indexOfItemWithTag:currentMode_]];

}

- (NSDictionary *) dictionary
{
    NSDictionary * tDictionary=nil;
    id tObject;
    
    switch(currentMode_)
    {
        case 0:
            tObject=[IBobjectField_ objectValue];
    
            if (tObject==nil)
            {
                NSBeep();
                
                return nil;
            }
            else
            {
                tObject=[NSDecimalNumber convertObjectToNSNumberIfNeeded:tObject];
                
                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"bundle",@"SpecType",
                                                                    [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                                    [IBbundlePath_ stringValue],@"SpecArgument",
                                                                    [IBbundleKey_ titleOfSelectedItem],@"SpecProperty",
                                                                    [self selectedOperatorItem],@"TestOperator",
                                                                    tObject,@"TestObject",
                                                                    nil];
            }
            break;
        case 1:
            tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"bundle",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [IBbundlePath_ stringValue],@"SpecArgument",
                                                              PBSPECIFICATIONCONTROLLER_NOTEQUAL,@"TestOperator",
                                                              @"",@"TestObject",
                                                              nil];
            break;
        case 2:
            tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"bundle",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [IBbundlePath_ stringValue],@"SpecArgument",
                                                              PBSPECIFICATIONCONTROLLER_EQUAL,@"TestOperator",
                                                              @"",@"TestObject",
                                                              nil];
            break;
    }
    
    return tDictionary;
}

- (void) controllerWillChange
{
    if (currentMode_==0)
    {
        [IBsubview_ removeFromSuperview];
    }
}

- (IBAction) switchMode:(id) sender
{
    int tTag;
    
    tTag=[[sender selectedItem] tag];
    
    if (tTag!=currentMode_)
    {
        if (tTag==0)
        {
            [IBview_ addSubview:IBsubview_];
            
            [IBobjectField_ setNextKeyView:[IBbundlePath_ nextKeyView]];
            
            [IBbundlePath_ setNextKeyView:IBobjectField_];
            
            [IBsubview_ setFrameOrigin:NSZeroPoint];
        }
        else
        {
            if (currentMode_==0)
            {
                [IBbundlePath_ setNextKeyView:[IBobjectField_ nextKeyView]];
            
                [IBsubview_ removeFromSuperview];
            }
        }
        
        currentMode_=tTag;
    }
}

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
    [inView1 setNextKeyView:IBbundlePath_];
    
    if (currentMode_==1 || currentMode_==2)
    {
        [IBbundlePath_ setNextKeyView:inView2];
    }
    else
    {
        [IBbundlePath_ setNextKeyView:IBobjectField_];
        
        [IBobjectField_ setNextKeyView:inView2];
    }
}

#pragma mark -

- (IBAction) selectBundlePath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    int tReturnCode;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:NO];
    [tOpenPanel setTreatsFilePackagesAsDirectories:YES];
    [tOpenPanel setCanChooseDirectories:YES];
    
    [tOpenPanel setTitle:NSLocalizedString(@"Choose",@"No comment")];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    tReturnCode=[tOpenPanel runModalForDirectory:[IBbundlePath_ stringValue]
                                            file:nil
                                           types:nil];
    
    if (tReturnCode==NSOKButton)
    {
        [IBbundlePath_ setStringValue:[tOpenPanel filename]];
    }
}

- (IBAction) revealBundlePathInFinder:(id) sender
{
    NSString * tPath;
    
    tPath=[IBbundlePath_ stringValue];
    
    if (tPath!=nil && [tPath length]>0)
    {
        NSWorkspace * tWorkSpace;
    
        tWorkSpace=[NSWorkspace sharedWorkspace];
    
        [tWorkSpace selectFile:tPath inFileViewerRootedAtPath:@""];
    }
}

#pragma mark -

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    NSFileManager * tFileManager=[NSFileManager defaultManager];
    BOOL isDirectory;

    if ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==YES)
    {
        return YES;
    }
    
    return NO;
}

@end
