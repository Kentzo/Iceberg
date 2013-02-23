/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationGestaltController.h"
#import "PBOSTypeFormatter.h"
#import "PBPositiveIntegerFormatter.h"

@implementation PBSpecificationGestaltController

- (void) awakeFromNib
{
    PBOSTypeFormatter * tOSTypeFormatter;
    PBPositiveIntegerFormatter * tPositiveIntegerFormatter;
    NSMenu * tMenu;
    
    tOSTypeFormatter=[PBOSTypeFormatter new];
    
    tPositiveIntegerFormatter=[PBPositiveIntegerFormatter new];
    
    [super awakeFromNib];
    
    [IBgestaltSelectorField_ setFormatter:tOSTypeFormatter];
    
    [tOSTypeFormatter release];
    
    [IBobjectField_ setFormatter:tPositiveIntegerFormatter];
    
    [tPositiveIntegerFormatter release];
    
    // Set the PopupButton items
    
    gestaltSelectorDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GestaltList" ofType:@"plist"]];
    
    gestaltSelectorArray_=[[gestaltSelectorDictionary_ allKeys] mutableCopy];
    
    [gestaltSelectorArray_ sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [IBgestaltTypePopupButton_ addItemsWithTitles:gestaltSelectorArray_];
    
    // Disable the Unknown item
    
    tMenu=[IBgestaltTypePopupButton_ menu];
    
    [tMenu setAutoenablesItems:NO];
    
    [[IBgestaltTypePopupButton_ itemAtIndex:0] setEnabled:NO];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary tag:(int) inTag
{
    id tObject;
    
    [super initWithDictionary:inDictionary tag:inTag];
    
    if (inDictionary!=nil)
    {
        NSString * tString;
        
        tString=[inDictionary objectForKey:@"SpecArgument"];
        
        if (tString!=nil)
        {
            [IBgestaltSelectorField_ setStringValue:tString];
        }
        else
        {
            // SpecArgument is missing
            
            NSLog(@"Gestalt IFRequirement: SpecArgument is nil");
            
            [IBgestaltSelectorField_ setStringValue:@""];
        }
        
        [self selectGestaltSelectorWithOSType:[PBOSTypeFormatter fixOSTypeString:tString]];
        
        tString=[inDictionary objectForKey:@"TestOperator"];
        
        if (tString!=nil)
        {
            [self selectOperatorItem:tString];
        }
        else
        {
            // TestOperator is missing
            
            NSLog(@"Gestalt IFRequirement: TestOperator is nil");
            
            [self selectOperatorItem:PBSPECIFICATIONCONTROLLER_EQUAL];
        }
        
        tObject=[inDictionary objectForKey:@"TestObject"];
        
        if (tObject==nil)
        {
            // TestObject is missing
            
            // A COMPLETER
        }
        
        [IBobjectField_ setObjectValue:tObject];
    }
    else
    {
        [IBgestaltSelectorField_ setStringValue:@""];
        
        [self selectGestaltSelectorWithOSType:nil];
        
        [self setNewKey:[IBgestaltSelectorField_ stringValue]];
    }
}

- (void) dealloc
{
    [gestaltSelectorDictionary_ release];
    [gestaltSelectorArray_ release];
    
    [super dealloc];
}

#pragma mark -

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
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"gestalt",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [PBOSTypeFormatter fixOSTypeString:[IBgestaltSelectorField_ stringValue]],@"SpecArgument",
                                                              [self selectedOperatorItem],@"TestOperator",
                                                              tObject,@"TestObject",
                                                              nil];
    }
    
    return tDictionary;
}

#pragma mark -

- (void) setNewKey:(NSString *) inKey
{
    PBPositiveIntegerFormatter * tPositiveIntegerFormatter;
    
    [super setNewKey:inKey];
    
    tPositiveIntegerFormatter=[PBPositiveIntegerFormatter new];
    
    [IBobjectField_ setFormatter:tPositiveIntegerFormatter];
    
    [tPositiveIntegerFormatter release];
}

- (void) selectGestaltSelectorWithOSType:(NSString *) inOSType
{
    NSString * tKey=nil;
    
    if (inOSType!=nil)
    {
        NSArray * tArray;
        NSString * tOSType;
        
        tOSType=[PBOSTypeFormatter fixOSTypeString:inOSType];
        
        tArray=[gestaltSelectorDictionary_ allKeysForObject:tOSType];
            
        if ([tArray count]>0)
        {
            tKey=[tArray objectAtIndex:0];
        }
    }
    
    if (tKey==nil)
    {
        [IBgestaltTypePopupButton_ selectItemAtIndex:[IBgestaltTypePopupButton_ indexOfItemWithTag:-1]];
    }
    else
    {
        [IBgestaltTypePopupButton_ selectItemWithTitle:tKey];
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([aNotification object]==IBgestaltSelectorField_)
    {
        NSString * tObject;
        
        tObject=[[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string];
        
        [self selectGestaltSelectorWithOSType:tObject];
    }
}

- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error
{
    if (control==IBgestaltSelectorField_ || control==IBobjectField_)
    {
        NSBeep();
    }
}

- (IBAction) switchGestatltType:(id) sender
{
    int tTag;
    id tSelectedItem;
    
    tSelectedItem=[sender selectedItem];
    
    if (tSelectedItem!=nil)
    {
        tTag=[tSelectedItem tag];
        
        if (tTag>=0)
        {
            NSString * tSelectedKey;
            NSString * tGestaltSelector;
            
            tSelectedKey=[tSelectedItem title];
            
            if (tSelectedKey!=nil)
            {
                tGestaltSelector=[gestaltSelectorDictionary_ objectForKey:tSelectedKey];
                
                if (tGestaltSelector!=nil)
                {
                    [IBgestaltSelectorField_ setStringValue:tGestaltSelector];
                }
            }
        }
    }
}

#pragma mark -

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
    [inView1 setNextKeyView:IBgestaltSelectorField_];
    
    [IBobjectField_ setNextKeyView:inView2];
}

@end
