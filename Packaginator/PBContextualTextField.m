/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBContextualTextField.h"

@implementation PBContextualTextField

- (void)drawRect:(NSRect)rect
{
    NSBezierPath * tPath=nil;
    NSRect tRect;
    float tHalfHeight;
        
    tRect=[self bounds];
    
    if (trackingTag_==0)
    {
        trackingTag_=[self addTrackingRect:tRect owner:self userData:NULL assumeInside:NO];
    }
    
    tHalfHeight=NSHeight(tRect)*0.5;
        
    if (pushed_==YES || hovered_==YES)
    {
        tPath=[NSBezierPath bezierPath];
        
        [tPath moveToPoint:NSMakePoint(tHalfHeight*0.6875,tHalfHeight*0.25*0.5)];
        [tPath lineToPoint:NSMakePoint(NSMaxX(tRect),tHalfHeight*0.25*0.5)];
        [tPath lineToPoint:NSMakePoint(NSMaxX(tRect),NSMaxY(tRect)-tHalfHeight*0.5)];
        [tPath lineToPoint:NSMakePoint(tHalfHeight*0.6875,NSMaxY(tRect)-tHalfHeight*0.5)];
        
        [tPath appendBezierPathWithArcWithCenter:NSMakePoint(tHalfHeight*0.6875,tHalfHeight*0.6875+tHalfHeight*0.25*0.5) radius:tHalfHeight*0.6875 startAngle:90 endAngle:270];
    }
    
    
    if (pushed_==YES)
    {
        [[NSColor colorWithDeviceWhite:0.5 alpha:1.0] set];
        
        [tPath fill];
        
        [[self title] drawAtPoint:NSMakePoint(tHalfHeight*0.75,2) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],
                                                                                                        NSForegroundColorAttributeName,
                                                                                                        [self font],
                                                                                                        NSFontAttributeName,
                                                                                                        nil]];
    }
    else
    {
        if (hovered_==YES)
        {
            [[NSColor colorWithDeviceWhite:0.6941 alpha:1.0] set];
            
            [tPath fill];
            
            [[self title] drawAtPoint:NSMakePoint(tHalfHeight*0.75,2) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],
                                                                                                            NSForegroundColorAttributeName,
                                                                                                            [self font],
                                                                                                            NSFontAttributeName,
                                                                                                            nil]];
        }
        else
        {
            [[self title] drawAtPoint:NSMakePoint(tHalfHeight*0.75,2) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor],
                                                                                                            NSForegroundColorAttributeName,
                                                                                                            [self font],
                                                                                                            NSFontAttributeName,
                                                                                                            nil]];
        }
    }
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    hovered_=YES;

    [self display];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    hovered_=NO;
    
    [self display];
}

- (void) mouseDown:(NSEvent *) inEvent
{
    pushed_=YES;
    
    [super mouseDown:inEvent];
    
    pushed_=NO;
    
    [self display];
}

@end
