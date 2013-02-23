/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBImageView.h"

#define PBIMAGEVIEW_HOVERRECT_WIDE_WIDTH	96.0f

#define PBIMAGEVIEW_HOVERRECT_WIDTH		32.0f

#define PBIMAGEVIEW_TRIANGLE_CONST		5.0f

#import "NSCarbonMenuImp.h"

@implementation PBImageView

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (NSBezierPath *) hoverPath
{
    static NSBezierPath * tBezierPath=nil;
        
    if (tBezierPath==nil)
    {
        NSRect tRect;
        
        tRect=[self bounds];
        
        tBezierPath=[NSBezierPath new];
        
        [tBezierPath moveToPoint:NSMakePoint(PBIMAGEVIEW_TRIANGLE_CONST,2.0f*PBIMAGEVIEW_TRIANGLE_CONST)];
        
        [tBezierPath lineToPoint:NSMakePoint(PBIMAGEVIEW_TRIANGLE_CONST*2.0f,PBIMAGEVIEW_TRIANGLE_CONST)];
        [tBezierPath lineToPoint:NSMakePoint(PBIMAGEVIEW_TRIANGLE_CONST*3.0f,2.0f*PBIMAGEVIEW_TRIANGLE_CONST)];
        [tBezierPath closePath];
    }
    
    return tBezierPath;
}


- (void)drawRect:(NSRect)rect
{
    NSRect tRect;
        
    tRect=[self bounds];
    
    if (trackingTag_==0)
    {
        NSRect tHoverRect;
        
        tHoverRect=NSMakeRect(0,
                              0,
                              PBIMAGEVIEW_HOVERRECT_WIDE_WIDTH,
                              PBIMAGEVIEW_HOVERRECT_WIDE_WIDTH);
        
        trackingTag_=[self addTrackingRect:tHoverRect owner:self userData:NULL assumeInside:NO];
    }
    
    [super drawRect:rect];
    
    if (hovered_==YES)
    {
        // Draw the contextual triangle
        
        NSBezierPath * tBezierPath;
        
        tBezierPath=[self hoverPath];
        
        [[NSColor blackColor] set];
        
        [tBezierPath fill];
    }
}

- (void) mouseDown:(NSEvent *) inEvent
{
    NSPoint tMouseLoc=[self convertPoint:[inEvent locationInWindow] fromView:nil];
    NSRect tClickRect;
    
    tClickRect=NSMakeRect(0,0,4.0f*PBIMAGEVIEW_TRIANGLE_CONST,4.0f*PBIMAGEVIEW_TRIANGLE_CONST);
    
    if (NSPointInRect(tMouseLoc,tClickRect)==YES)
    {
        NSPoint tPoint;
        NSMenu * tMenu;
        NSMenu * tScalingMenu;
        NSMenu * tAlignmentMenu;
        NSImageAlignment tAlignment;
        NSImageScaling tScaling; 
        NSCarbonMenuImpl * tCarbonMenuImplementation;
            
        tCarbonMenuImplementation=[NSCarbonMenuImpl new];
            
        tPoint=NSMakePoint(0.0f,-4.0f);
    
        tMenu=[self menu];
        
        tAlignment=[self imageAlignment];
        tScaling=[self imageScaling];
        
        tScalingMenu=[[tMenu itemAtIndex:0] submenu];
        tAlignmentMenu=[[tMenu itemAtIndex:1] submenu];
        
        [[tScalingMenu itemWithTag:tScaling] setState:NSOnState];
        [[tAlignmentMenu itemWithTag:tAlignment] setState:NSOnState];
    
        [tCarbonMenuImplementation popUpMenu:[self menu] atLocation:tPoint width:10 forView:self withSelectedItem:0 withFont:[self font]];
        
        [[tScalingMenu itemWithTag:tScaling] setState:NSOffState];
        [[tAlignmentMenu itemWithTag:tAlignment] setState:NSOffState];
        
        [tCarbonMenuImplementation release];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSRect tRect;
    
    tRect=[self bounds];
    
    hovered_=YES;
    
    [self displayRect:NSMakeRect(0,0,PBIMAGEVIEW_HOVERRECT_WIDTH,PBIMAGEVIEW_HOVERRECT_WIDTH)];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSRect tRect;
    
    tRect=[self bounds];
    
    hovered_=NO;

    [self displayRect:NSMakeRect(0,0,PBIMAGEVIEW_HOVERRECT_WIDTH,PBIMAGEVIEW_HOVERRECT_WIDTH)];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    // No contextual menu, niark!
}

@end
