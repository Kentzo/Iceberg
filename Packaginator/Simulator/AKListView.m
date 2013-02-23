/*
Copyright (c) 2004-2005, StŽphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AKListView.h"
#import "PBSimulatorImageProvider.h"

@implementation AKListView

- (id) initWithFrame:(NSRect) frame
{
    [super initWithFrame:frame];
    
    currentPaneIndex_=0;
    
    unselectedPaneImage_=[[[PBSimulatorImageProvider defaultProvider] imageNamed:@"DotGray"] retain];
    selectedPaneImage_=[[[PBSimulatorImageProvider defaultProvider] imageNamed:@"DotBlue"] retain];
    unProcessedPaneImage_=[[[PBSimulatorImageProvider defaultProvider] imageNamed:@"DotGrayDisabled"] retain];
    
    array_= [[NSMutableArray alloc] init];
    
    systemVersion_=[PBSystemUtilities systemMajorVersion];
    
    return self;
}

- (void) dealloc
{
    [unselectedPaneImage_ release];
    
    [selectedPaneImage_ release];
    
    [unProcessedPaneImage_ release];
    
    [array_ release];

    [super dealloc];
}

- (void) cleanList
{
    currentPaneIndex_=0;
    
    [array_ release];
    
    array_= [[NSMutableArray alloc] init];
}

- (void) addPaneName:(NSString *) inPaneName
{
    [array_ addObject:inPaneName];
}

- (int) currentPaneIndex
{
    return currentPaneIndex_;
}

- (void) setCurrentPaneIndex:(int) inPaneIndex
{
    currentPaneIndex_=inPaneIndex;
    [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect) frame
{
    int i;
    int tCount=[array_ count];
    NSRect tRect=[self frame];
    NSImage * tImage;
    NSString * tString;
    NSSize tSize;
    NSDictionary * tFontAttributes;
    float tLineHeight;
    float tBulletVerticalOffset;
    float tLeftBorderWidth;
    float tInterspaceWidth;
    
    tRect.origin.x=0;
    
    if (systemVersion_>=PBLeopard)
    {
        tLeftBorderWidth=12.0f;
        
        tLineHeight=24.0f;
        
        tBulletVerticalOffset=0.0f;
        
        tRect.origin.y=NSHeight(tRect)-48.0f;
        
        tInterspaceWidth=3.0f;
    }
	else
	if (systemVersion_>=PBPanther)
    {
        tLeftBorderWidth=12.0f;
        
        tLineHeight=24.0f;
        
        tBulletVerticalOffset=2.0f;
        
        tRect.origin.y=NSHeight(tRect)-48.0f;
        
        tInterspaceWidth=3.0f;
    }
    else
    {
        tLeftBorderWidth=0.0f;
        
        tLineHeight=22.0f;
        
        tBulletVerticalOffset=3.0f;
        
        tRect.origin.y=NSHeight(tRect)-tLineHeight;
        
        tInterspaceWidth=2.0f;
    }
    
    for(i=0;(NSMinY(tRect)>=0 && i<tCount);i++)
    {
        // Draw the Button
        
        NSFont * tFont;
        NSPoint tPoint;
        
        tImage = ((i==currentPaneIndex_) ? selectedPaneImage_ : ((i < currentPaneIndex_) ? unselectedPaneImage_ : unProcessedPaneImage_));
        
        tSize=[tImage size];
        
        [tImage compositeToPoint:NSMakePoint(tLeftBorderWidth,NSMinY(tRect)+(tLineHeight-tSize.height)*0.5f+tBulletVerticalOffset) operation:NSCompositeSourceOver fraction:(unProcessedPaneImage_!=tImage || systemVersion_>=PBPanther) ? 1.0f: 0.5f];
        
        // Draw the PaneTitle
        
        if (systemVersion_>=PBPanther)
        {
            if (unProcessedPaneImage_!=tImage)
            {
                tFont=[NSFont boldSystemFontOfSize:13.0f];
            }
            else
            {
                tFont=[NSFont systemFontOfSize:13.0f];
            }
        }
        else
        {
            tFont=[NSFont systemFontOfSize:13.0f];
        }
        
        tFontAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:tFont,NSFontAttributeName,
                                                                     (i >  currentPaneIndex_) ? [NSColor colorWithDeviceWhite:0.0 alpha: 0.5f] : nil,NSForegroundColorAttributeName,nil];
        
        tString = [array_ objectAtIndex:i];
        
        tPoint.x=tLeftBorderWidth+tSize.width+tInterspaceWidth;
        
	tSize = [tString sizeWithAttributes:tFontAttributes];
        
        tPoint.y=NSMinY(tRect)+(tLineHeight-tSize.height)*0.5f+3.0f;
        
        [tString drawAtPoint:tPoint withAttributes:tFontAttributes];
        
        [tFontAttributes release];
        
        tRect.origin.y-=tLineHeight;
    }
}

@end
