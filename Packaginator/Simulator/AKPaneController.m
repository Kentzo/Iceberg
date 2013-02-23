/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AKPaneController.h"

@implementation AKPaneController

- (id) relativeRootView
{
    return relativeRootView_;
}

- (void) loadPaneNib:(NSString *) inNibName withMainController: (id) inMainController
{
    if (!relativeRootView_)
    {
        mainController_ = inMainController;
        
        previousPaneIndex_= -1;
        
        if ([NSBundle loadNibNamed:inNibName owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),inNibName],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
        
        [self awakeFromNib];
    }
}

- (void) awakeFromNib
{
    /* This iss called by the loadPaneNib:withMainController method */
    /* If you need to do some stuff at nib initialization, overload this method */
}

- (NSString *) nextPaneName
{
    return nil;
}

- (void) setPreviousPaneIndex:(int) inPreviousPaneIndex
{
    previousPaneIndex_=inPreviousPaneIndex;
}

- (int) previousPaneIndex
{
    return previousPaneIndex_;
}

#pragma mark -

- (void) initPaneWithDictionary:(NSDictionary *) inDictionary document:(NSDocument *) inDocument
{
    [dictionary_ release];
    
    dictionary_=[inDictionary retain];
    
    document_=inDocument;
}

- (void) setLanguage:(NSString *) tString
{
}

+ (NSDictionary *) defaultOptionsWithPath:(NSString *) inPath
{
    NSDictionary * tOptionsDictionary;
    NSDictionary * tFontDictionary;
    
    tFontDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName,nil];
    
    tOptionsDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[inPath stringByDeletingLastPathComponent],@"BaseURL",
                                                                  tFontDictionary,@"DefaultAttributes",
                                                                  nil];
    
    return tOptionsDictionary;
}

@end
