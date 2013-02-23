/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationSysctlController.h"

@implementation PBSpecificationSysctlController

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    classKeys_=[[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sysctlKeyClass" ofType:@"plist"]];
    
    [classKeys_ sortUsingSelector:@selector(compare:)];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary tag:(int) inTag
{
    id tObject;
    
    [super initWithDictionary:inDictionary tag:inTag];
    
    if (inDictionary!=nil)
    {
        //NSString * tProperty;
        NSString * tString;
        
        tString=[inDictionary objectForKey:@"SpecArgument"];
        
        if (tString!=nil)
        {
            [IBsysctlKey_ setStringValue:tString];
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
            
            NSLog(@"sysctl IFRequirement: TestOperator is nil");
            
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
        [IBsysctlKey_ setStringValue:@""];
        
        [self setNewKey:[IBsysctlKey_ stringValue]];
    }

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
        tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"sysctl",@"SpecType",
                                                              [NSNumber numberWithInt:[[IBtypePopupButton_ selectedItem] tag]],@"SpecTag",
                                                              [IBsysctlKey_ stringValue],@"SpecArgument",
                                                              [self selectedOperatorItem],@"TestOperator",
                                                              tObject,@"TestObject",
                                                              nil];
    }
    
    return tDictionary;
}

#pragma mark -

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
    [currentKey_ release];
        
    currentKey_=[inKey copy];
    
    // Set the appropriate formater on the Object field
    
    [IBobjectField_ setFormatter:nil];
    
    [IBobjectField_ setStringValue:@""];
}

#pragma mark -

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
    [inView1 setNextKeyView:IBsysctlKey_];
    
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

@end
