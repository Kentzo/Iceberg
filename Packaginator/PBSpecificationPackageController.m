/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationPackageController.h"
#import "NSDecimalNumber+FixPList.h"

@implementation PBSpecificationPackageController

- (void) awakeFromNib
{
    // Initialize the Key menu
    
    NSMutableArray * tSortedArray;
    
    [super awakeFromNib];

    classDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PackageKeyClass" ofType:@"plist"]];
    
    if (classDictionary_!=nil)
    {
        tSortedArray=[[classDictionary_ allKeys] mutableCopy];
    
        [tSortedArray sortUsingSelector:@selector(compare:)];
        
        [IBkeyPopupButton_ removeAllItems];
        
        [IBkeyPopupButton_ addItemsWithTitles:tSortedArray];
        
        [tSortedArray release];
    }
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
            [IBbundleIdentifier_ setStringValue:tString];
        }
        else
        {
            // SpecArgument is missing
            
            [IBbundleIdentifier_ setStringValue:@""];
        }
        
        tString=[inDictionary objectForKey:@"TestOperator"];
        
        if (tString!=nil)
        {
            [self selectOperatorItem:tString];
        }
        else
        {
            // TestOperator is missing
            
            NSLog(@"Package IFRequirement: TestOperator is nil");
            
            [self selectOperatorItem:PBSPECIFICATIONCONTROLLER_EQUAL];
        }
        
        tProperty=[inDictionary objectForKey:@"SpecProperty"];
        
        if (tProperty!=nil)
        {
            if (-1!=[IBkeyPopupButton_ indexOfItemWithTitle:tProperty])
            {
                [IBkeyPopupButton_ selectItemWithTitle:tProperty];
                
                [self setNewKey:tProperty];
            }
            else
            {
                // SpecProperty is not in our list (oups!)
                
                // A COMPLETER
            }
        }
        else
        {
            // SpecProperty is missing
            
            // A COMPLETER
        }
        
        tObject=[inDictionary objectForKey:@"TestObject"];
        
        if (tObject!=nil)
        {
            [IBobjectField_ setObjectValue:[inDictionary objectForKey:@"TestObject"]];
        }
        else
        {
            // TestObject is missing
            
            // A COMPLETER
        }
    }
    else
    {
        [IBbundleIdentifier_ setStringValue:@""];
        
        [IBkeyPopupButton_ selectItemAtIndex:0];
        
        [self setNewKey:[IBkeyPopupButton_ titleOfSelectedItem]];
    }
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
        
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"package",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [IBbundleIdentifier_ stringValue],@"SpecArgument",
                                                              [IBkeyPopupButton_ titleOfSelectedItem],@"SpecProperty",
                                                              [self selectedOperatorItem],@"TestOperator",
                                                              tObject,@"TestObject",
                                                              nil];
    }
    
    return tDictionary;
}

#pragma mark -

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
    [inView1 setNextKeyView:IBbundleIdentifier_];
    
    [IBobjectField_ setNextKeyView:inView2];
}

@end
