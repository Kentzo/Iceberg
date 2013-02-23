/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationPlistController.h"
#import "NSDecimalNumber+FixPList.h"

@implementation PBSpecificationPlistController

- (void) awakeFromNib
{
    // Initialize the Key menu
    
    [super awakeFromNib];

    classDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BundleKeyClass" ofType:@"plist"]];
    
    if (classDictionary_!=nil)
    {
        classKeys_=[[classDictionary_ allKeys] mutableCopy];
    
        [classKeys_ sortUsingSelector:@selector(compare:)];
    }
    
    [IBplistPath_ setFormatter:nil];
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
            [IBplistPath_ setStringValue:tString];
        }
        else
        {
            // SpecArgument is missing
            
            // A COMPLETER
        }
        
        tString=[inDictionary objectForKey:@"TestOperator"];
        
        if (tString!=nil)
        {
            [self selectOperatorItem:tString];
        }
        else
        {
            // TestOperator is missing
            
            NSLog(@"Property List IFRequirement: TestOperator is nil");
            
            [self selectOperatorItem:PBSPECIFICATIONCONTROLLER_EQUAL];
        }
        
        tObject=[inDictionary objectForKey:@"TestObject"];
        
        if (tObject==nil)
        {
            // TestObject is missing
            
            // A COMPLETER
        }
        
        tProperty=[inDictionary objectForKey:@"SpecProperty"];
        
        if (tProperty!=nil)
        {
            [IBplistKey_ setStringValue:tProperty];
            
            [self setNewKeyForClass:NSStringFromClass([tObject class])];
        }
        else
        {
            // SpecProperty is missing
            
            // A COMPLETER
        }
        
        [IBobjectField_ setObjectValue:[inDictionary objectForKey:@"TestObject"]];
    }
    else
    {
        [IBplistPath_ setStringValue:@""];
        
        [IBplistKey_ selectItemAtIndex:0];
        
        [self setNewKey:[IBplistKey_ stringValue]];
    }
}

- (void) dealloc
{
    [classKeys_ release];
    
    [super dealloc];
}

- (NSDictionary *) dictionary
{
    NSDictionary * tDictionary;
    id tObject;
    
    tObject=[IBobjectField_ objectValue];
    
    if (tObject==nil)
    {
        NSBeep();
        
        return nil;
    }
    else
    {
        tObject=[NSDecimalNumber convertObjectToNSNumberIfNeeded:tObject];
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"plist",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [IBplistPath_ stringValue],@"SpecArgument",
                                                              [IBplistKey_ stringValue],@"SpecProperty",
                                                              [self selectedOperatorItem],@"TestOperator",
                                                              tObject,@"TestObject",
                                                              nil];
    }
    
    return tDictionary;
}

#pragma mark -

- (IBAction) switchObjectType:(id) sender
{
    int tTag;
    NSString * tClassName=@"NSString";
    
    tTag=[[sender selectedItem] tag];
    
    // A COMPLETER (optimisation pour ne pas passer par la si non necessaire)
    
    switch(tTag)
    {
        case 0:
            tClassName=@"NSDate";
            break;
        case 1:
            tClassName=@"NSNumber";
            break;
        case 2:
            tClassName=@"NSString";
            break;
    }
    
    [IBobjectField_ setFormatter:nil];
    
    [IBobjectField_ setStringValue:@""];
    
    [self setNewKeyForClass:tClassName];
}

- (IBAction) switchKey:(id) sender
{
    NSString * tNewKey;
    
    tNewKey=[sender stringValue];
    
    if ([tNewKey isEqualToString:currentKey_]==NO)
    {
        [self setNewKey:tNewKey];
    }
}

- (void) setNewKey:(NSString *) inKey
{
    NSString * tClassName;
    
    [currentKey_ release];
        
    currentKey_=[inKey copy];
    
    // Set the appropriate formater on the Object field
    
    [IBobjectField_ setFormatter:nil];
    
    [IBobjectField_ setStringValue:@""];
    
    tClassName=[classDictionary_ objectForKey:currentKey_];
        
    if (tClassName==nil)
    {
        tClassName=@"NSString";
    }
    
    [self setNewKeyForClass:tClassName];
}

- (void) setNewKeyForClass:(NSString *) inClassName
{
    
    if ([inClassName isEqualToString:@"NSString"]==YES)
    {
        [IBplistType_ selectItemAtIndex:[IBplistType_ indexOfItemWithTag:2]];
    }
    else if ([inClassName isEqualToString:@"NSNumber"]==YES)
    {
        NSNumberFormatter * tNumberFormatter;
        NSDictionary * tZeroAttributes;
        NSAttributedString * tZeroAttributedString;
        
        tNumberFormatter=[NSNumberFormatter new];
        
        [tNumberFormatter setPositiveFormat:@"0"];
        [tNumberFormatter setNegativeFormat:@"-0"];
        
        tZeroAttributes=[tNumberFormatter textAttributesForPositiveValues];
        
        tZeroAttributedString=[[NSAttributedString alloc] initWithString:@"0" attributes:tZeroAttributes];
        
        [tNumberFormatter setAttributedStringForZero:tZeroAttributedString];
        
        [tZeroAttributedString release];
        
        [tNumberFormatter setMinimum:[NSDecimalNumber zero]];
        
        [tNumberFormatter setHasThousandSeparators:NO];
        [IBobjectField_ setFormatter:tNumberFormatter];
        
        [tNumberFormatter release];
        
        [IBobjectField_ setObjectValue:[NSNumber numberWithInt:0]];
        
        [IBplistType_ selectItemAtIndex:[IBplistType_ indexOfItemWithTag:1]];
    }
    else if ([inClassName isEqualToString:@"NSDate"]==YES)
    {
        NSDateFormatter * tDateFormatter;
        NSUserDefaults * tDefaults;
        
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        tDateFormatter=[[NSDateFormatter alloc] initWithDateFormat:[tDefaults objectForKey:NSShortTimeDateFormatString]
                                            allowNaturalLanguage:YES];
        
        [IBobjectField_ setFormatter:tDateFormatter];

        [tDateFormatter release];
                
        [IBobjectField_ setObjectValue:[NSDate date]];
        
        [IBplistType_ selectItemAtIndex:[IBplistType_ indexOfItemWithTag:0]];
    }
}

#pragma mark -

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
    [inView1 setNextKeyView:IBplistPath_];
    
    [IBobjectField_ setNextKeyView:inView2];
}

#pragma mark -

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
    return [classKeys_ objectAtIndex:index];
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [classKeys_ count];
}

#pragma mark -

- (IBAction) selectPlistPath:(id) sender
{
    NSOpenPanel * tOpenPanel;
    int tReturnCode;
    
    tOpenPanel=[NSOpenPanel openPanel];
    
    [tOpenPanel setCanChooseFiles:YES];
    [tOpenPanel setCanChooseDirectories:NO];
    
    [tOpenPanel setTitle:NSLocalizedString(@"Choose",@"No comment")];
    [tOpenPanel setPrompt:NSLocalizedString(@"Choose",@"No comment")];
    
    tReturnCode=[tOpenPanel runModalForDirectory:[IBplistPath_ stringValue]
                                            file:nil
                                           types:nil];
    
    if (tReturnCode==NSOKButton)
    {
        [IBplistPath_ setStringValue:[tOpenPanel filename]];
    }
}

- (IBAction) revealPlistPathInFinder:(id) sender
{
    NSString * tPath;
    
    tPath=[IBplistPath_ stringValue];
    
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

    if ([tFileManager fileExistsAtPath:inPath isDirectory:&isDirectory]==YES && isDirectory==NO)
    {
        return YES;
    }
    
    return NO;
}

@end
