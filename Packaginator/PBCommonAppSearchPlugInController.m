/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBCommonAppSearchPlugInController.h"

@implementation PBCommonAppSearchPlugInController

- (NSView *) previousKeyView
{
    return IBidentifier_;
}

- (void) setNextKeyView:(NSView *) inView
{
    [IBpath_ setNextKeyView:inView];
}

- (void) initWithDictionary:(NSDictionary *) inDictionary
{
    NSString * tPath;
    NSString * tIdentifier;
    
    tIdentifier=[inDictionary objectForKey:@"identifier"];
    
    if (tIdentifier==nil)
    {
        tIdentifier=@"";
    }
    
    [IBidentifier_ setStringValue:tIdentifier];
    
    tPath=[inDictionary objectForKey:@"path"];
    
    if (tPath==nil)
    {
        tPath=@"";
    }
    
    [IBpath_ setStringValue:tPath];
}

- (NSDictionary *) dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"CommonAppSearch",@"searchPlugin",
                                                      [IBpath_ stringValue],@"path",
                                                      [IBidentifier_ stringValue],@"identifier",
                                                      nil];
}

- (BOOL) hasIncorrectValues
{
    NSString * tPath;
    NSString * tIdentifier;
    
    tPath=[IBpath_ stringValue];
    
    if ([PBSearchPlugInController checkAbsolutePath:tPath]==NO)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The path value is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the path you entered and fix it.",@"No comment")];
    
        return YES;
    } 
    
    tIdentifier=[IBidentifier_ stringValue];
    
    if ([tIdentifier length]==0)
    {
        [self showAlertWithTitle:NSLocalizedString(@"The identifier value is incorrect",@"No comment")
                         message:NSLocalizedString(@"Please check the identifier you entered and fix it.",@"No comment")];
    
        return YES;
    }
    
    return NO;
}

@end
