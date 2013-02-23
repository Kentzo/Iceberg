/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBAboutBoxController.h"
#import "PBVersionSwitchView.h"

#define	SCROLL_DELAY_SECONDS	0.03	// time between animation frames
#define SCROLL_AMOUNT_PIXELS	1.00	// amount to scroll in each animation frame
#define	BLANK_LINE_COUNT	16

@implementation PBAboutBoxController

- (void) awakeFromNib
{
    NSMutableAttributedString	* textToScroll;
    NSAttributedString * newline;
    int	i;
    
    textToScroll=[[[NSMutableAttributedString alloc] initWithPath: [[NSBundle mainBundle] pathForResource:@"About" ofType:@"rtf"]
                                               documentAttributes: nil] autorelease];

    newline = [[[NSAttributedString alloc] initWithString: @"\n"] autorelease];

    //	Append that one newline to the real text a bunch of times
    
    for (i = 0; i < BLANK_LINE_COUNT; i++)
        [textToScroll appendAttributedString: newline];

    [[IBtextView_ textStorage] setAttributedString: textToScroll];
    
    [IBwindow_ setBackgroundColor:[NSColor whiteColor]];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    if ([aNotification object]==IBwindow_)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedAnimationStart:) object:nil];
    
        [timer_ invalidate];

        [timer_ release];
        timer_ = nil;
    }
}

- (void) setScrollAmount: (float) newAmount
{
    //	Scroll so that (0, amount) is at the upper left corner of the scroll view
    //	(in other words, so that the top 'newAmount' scan lines of the text
    //	 is hidden).
    [[IBscrollView_ documentView] scrollPoint: NSMakePoint (0.0, newAmount)];

    //	If anything overlaps the text we just scrolled, it won’t get redraw by the
    //	scrolling, so force everything in that part of the panel to redraw.
    {
        NSRect scrollViewFrame;

        //	Find where the scrollview’s bounds are, then convert to panel’s coordinates
        scrollViewFrame = [IBscrollView_ bounds];
        scrollViewFrame = [[IBwindow_ contentView] convertRect: scrollViewFrame  fromView: IBscrollView_];

        //	Redraw everything which overlaps it.
        [[IBwindow_ contentView] setNeedsDisplay:YES/*InRect: scrollViewFrame*/];
    }
}

- (void) scrollOneUnit
{
    float	currentScrollAmount;

    currentScrollAmount = [IBscrollView_ documentVisibleRect].origin.y;
    
    [self setScrollAmount: (currentScrollAmount + SCROLL_AMOUNT_PIXELS)];
    
    if ([IBscrollView_ documentVisibleRect].origin.y==currentScrollAmount)
    {
        [timer_ invalidate];

        [timer_ release];
        timer_ = nil;
        
        [self setScrollAmount: 0.0];
        
        [self performSelector:@selector(delayedAnimationStart:) withObject:nil afterDelay:8];
    }
}

- (void) showAboutBoxWindow
{
    if (IBwindow_==nil)
    {
        NSDictionary * tDictionary;
        
        if ([NSBundle loadNibNamed:@"PBAboutBox" owner:self]==NO)
        {
            NSBeep();
            
            NSRunCriticalAlertPanel([NSString stringWithFormat:NSLocalizedString(@"Iceberg can't find the \"%@\".nib resource file.",@"No comment"),@"PBAboutBox"],NSLocalizedString(@"Iceberg will stop running to avoid improper behavior.\nYou should check that the application has not been corrupted.",@"No comment"), nil,nil,nil);
            
            [NSApp terminate:nil];
        }
        
        tDictionary=[[NSBundle mainBundle] infoDictionary];
        
        [IBversion_ setTitle:[tDictionary objectForKey:@"CFBundleShortVersionString"]];
        
        [IBversion_ setAlternateTitle:[NSString stringWithFormat:@"Build %@",[tDictionary objectForKey:@"CFBuildNumber"]]];
    }
    
    if ([IBwindow_ isVisible]==NO)
    {
        [self setScrollAmount: 0.0];
        
        [IBwindow_ center];
        
        [IBwindow_ makeKeyAndOrderFront:self];
        
        [self performSelector:@selector(delayedAnimationStart:) withObject:nil afterDelay:8];
    }
}

- (void) delayedAnimationStart:(id) object
{
    if (timer_ != nil)
        return;
    
    //	Start a timer which will send us a 'scrollOneUnit' message regularly
    timer_ = [[NSTimer scheduledTimerWithTimeInterval: SCROLL_DELAY_SECONDS
                        target: self
                        selector: @selector(scrollOneUnit)
                        userInfo: nil
                        repeats: YES] retain];
}

@end
