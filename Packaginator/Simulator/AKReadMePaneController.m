/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AKReadMePaneController.h"

@implementation AKReadMePaneController

- (void) awakeFromNib
{
    [IBtextView_ setDrawsBackground:NO];
    
    [IBtextView_ setTextContainerInset:NSMakeSize(7,7)];
}

- (void) initPaneWithDictionary:(NSDictionary *) inDictionary document:(NSDocument *) inDocument
{
    [super initPaneWithDictionary:inDictionary document:inDocument];
}

- (void) setLanguage:(NSString *) inString
{
    NSDictionary * tDictionary;
    NSTextStorage * tTextStorage;
    NSString * tPath=nil;
    BOOL success;

    
    tDictionary=[dictionary_ objectForKey:inString];
    
    if (tDictionary==nil)
    {
        // Find the best language
        
        if ([dictionary_ count]>0)
        {
            NSArray * tLanguageArray;
            NSArray * tResultArray;
            
            tLanguageArray=[dictionary_ allKeys];
            
            tResultArray=(NSArray *) CFBundleCopyPreferredLocalizationsFromArray((CFArrayRef) tLanguageArray);
            
            if (tResultArray!=nil)
            {
                tDictionary=[dictionary_ objectForKey:[tResultArray objectAtIndex:0]];
            
                [tResultArray release];
            }
            
            if (tDictionary==nil)
            {
                tDictionary=[dictionary_ objectForKey:@"International"];
            }
            
            tPath=[tDictionary objectForKey:@"Path"];
        }
    }
    
    if (tDictionary!=nil)
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
    
    if (tPath!=nil)
    {
        [IBtextView_ setString:@""];
        
        tTextStorage=[IBtextView_ textStorage];
    
        [tTextStorage beginEditing];
        success = [tTextStorage readFromURL:[NSURL fileURLWithPath:tPath]
                                    options:[AKPaneController defaultOptionsWithPath:tPath]
                         documentAttributes:NULL];
        [tTextStorage endEditing];
    }
}


@end
