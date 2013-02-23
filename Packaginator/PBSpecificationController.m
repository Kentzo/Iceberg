/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBSpecificationController.h"
#import "PBProjectTree.h"
#import "PBRequirementsController.h"
#import "PBController.h"

NSString * const PBSPECIFICATIONCONTROLLER_EQUAL=@"=";
NSString * const PBSPECIFICATIONCONTROLLER_NOTEQUAL=@"!=";

@implementation NSObject(ComponentName) 

- (void) typeDidChange:(id) sender
{
}

@end

@implementation PBSpecificationController

- (void) awakeFromNib
{
    NSDictionary * tDictionary;
    NSEnumerator * tEnumerator;
    NSString * tLocalizedLabel;
    
    
    tDictionary=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RequirementsType" ofType:@"plist"]];
    
    tEnumerator=[[tDictionary allKeys] objectEnumerator];
    
    while (tLocalizedLabel=[tEnumerator nextObject])
    {
        NSNumber * tNumber;
        int tIndex;
        id tMenuItem;
        NSDictionary * tMenuAttributeDictionary;
        
        tMenuAttributeDictionary=[tDictionary objectForKey:tLocalizedLabel];
        
        tNumber=[tMenuAttributeDictionary objectForKey:@"Tag"];
        
        tIndex=[IBtypePopupButton_ indexOfItemWithTag:[tNumber intValue]];
        
        if (tIndex!=-1)
        {
            tMenuItem=[IBtypePopupButton_ itemAtIndex:tIndex];
        
            if (tMenuItem!=nil)
            {
                NSImage * tImage;
                NSString * tIconName;
                
                tIconName=[tMenuAttributeDictionary objectForKey:@"Icon"];
                
                if (tIconName!=nil)
                {
                    tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:tIconName ofType:@"tiff"]];
            
                    if (tImage!=nil)
                    {
                        [tMenuItem setImage:tImage];
                    
                        [tImage release];
                    }
                }
                
                [tMenuItem setTitle:tLocalizedLabel];
            }
        }
    }
    
    operatorDictionary_=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OperatorDictionary" ofType:@"plist"]];
}

- (void) dealloc
{
    [classDictionary_ release];

    [super dealloc];
}

- (void) setDelegate:(id) inDelegate
{
    delegate_=inDelegate;
}

- (id) delegate
{
    return delegate_;
}

- (id) view
{
    return IBview_;
}

- (void) initWithDictionary:(NSDictionary *) inDictionary tag:(int) inTag
{
    int tMenuIndex;
            
    tMenuIndex=[IBtypePopupButton_ indexOfItemWithTag:inTag];
    
    [IBtypePopupButton_ selectItemAtIndex:tMenuIndex];
}

- (NSDictionary *) dictionary
{
    return nil;
}

- (IBAction) switchType:(id) sender
{
    
    if ([delegate_ respondsToSelector:@selector(typeDidChange:)]==YES)
    {
        [delegate_ performSelector:@selector(typeDidChange:) withObject:sender afterDelay:0.01];
    }
}

- (void) updateNextKeyViewChainBetween:(id) inView1 and:(id) inView2
{
}

- (void) controllerWillChange
{
}

- (void) selectOperatorItem:(NSString *) inOperator
{
    int tTag;
    NSNumber * tNumber;
    
    tNumber=[operatorDictionary_ objectForKey:inOperator];
    
    if (tNumber!=nil)
    {
        tTag=[tNumber intValue];
        
        [IBoperatorPopupButton_ selectItemAtIndex:[IBoperatorPopupButton_ indexOfItemWithTag:tTag]];
    }
    else
    {
        // The operator has not been found
        
        // A COMPLETER
    }
}

- (NSString *) selectedOperatorItem
{
    int tTag;
    int tCount;
    NSArray * tArray;
    
    tTag=[[IBoperatorPopupButton_ selectedItem] tag];

    tArray=[operatorDictionary_ allKeysForObject:[NSNumber numberWithInt:tTag]];
    
    if (tArray!=nil)
    {
        tCount=[tArray count];
        
        if (tCount==1)
        {
            return [tArray objectAtIndex:0];
        }
        else
        {
            // The resources is incorrect
            
            // A COMPLETER
        }
    }
    
    return nil;
}

- (IBAction)switchKey:(id)sender
{
    NSString * tNewKey;
    
    tNewKey=[sender titleOfSelectedItem];
        
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
    
    tClassName=[classDictionary_ objectForKey:inKey];
    
    if ([tClassName isEqualToString:@"NSString"]==YES)
    {
    }
    else if ([tClassName isEqualToString:@"NSNumber"]==YES)
    {
        NSNumberFormatter * tNumberFormatter;
        NSDictionary * tZeroAttributes;
        NSAttributedString * tZeroAttributedString;
        
        tNumberFormatter=[NSNumberFormatter new];
        
        [tNumberFormatter setPositiveFormat:@"0"];
        [tNumberFormatter setNegativeFormat:@"0"];
        
        tZeroAttributes=[tNumberFormatter textAttributesForPositiveValues];
        
        tZeroAttributedString=[[NSAttributedString alloc] initWithString:@"0" attributes:tZeroAttributes];
        
        [tNumberFormatter setAttributedStringForZero:tZeroAttributedString];
        
        [tZeroAttributedString release];
        
        [tNumberFormatter setMinimum:[NSDecimalNumber zero]];
        
        [tNumberFormatter setAllowsFloats:NO];
        [tNumberFormatter setHasThousandSeparators:NO];
        [IBobjectField_ setFormatter:tNumberFormatter];
        
        [tNumberFormatter release];
        
        [IBobjectField_ setObjectValue:[NSNumber numberWithInt:0]];
    }
    else if ([tClassName isEqualToString:@"NSDate"]==YES)
    {
        NSDateFormatter * tDateFormatter;
        NSUserDefaults * tDefaults;
        
        tDefaults=[NSUserDefaults standardUserDefaults];
        
        tDateFormatter=[[NSDateFormatter alloc] initWithDateFormat:[tDefaults objectForKey:NSShortTimeDateFormatString]
                                              allowNaturalLanguage:YES];
        
        [IBobjectField_ setFormatter:tDateFormatter];

        [tDateFormatter release];
                
        [IBobjectField_ setObjectValue:[NSDate date]];
    }
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{    
    if ([aMenuItem action]==@selector(switchType:))
    {
        switch([aMenuItem tag])
        {
            case -2:
                return NO;
            case 4:
                if ([(PBObjectNode *) [[delegate_ parent] objectNode] type]!=kPBMetaPackageNode)
                {
                    return NO;
                }
                
                break;
        }
    }

    return YES;
}

@end
