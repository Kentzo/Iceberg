/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBCenteredLabelView.h"

@implementation PBCenteredLabelView

- (id) initWithFrame:(NSRect) aFrame
{
    self=[super initWithFrame:aFrame];
    
    if (self!=nil)
    {
        title_=[[NSString alloc] initWithString:@""];
        
        attributes_=[[NSDictionary alloc] initWithObjectsAndKeys:[NSColor lightGrayColor],NSForegroundColorAttributeName,
                                                                 [NSFont systemFontOfSize:18.0],NSFontAttributeName,
                                                                 nil];
    }
    
    return self;
}

- (void) dealloc
{
    [title_ release];
    
    [attributes_ release];

    [super dealloc];
}

- (void) setTitle:(NSString *) inString
{
    if (inString!=title_)
    {
        [title_ release];
        
        title_=[inString copy];
        
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)rect
{
    NSRect tBounds=[self bounds];
    NSPoint tPoint;
    NSSize tSize;
    
    tSize=[title_ sizeWithAttributes:attributes_];
    
    tPoint.x=NSMidX(tBounds)-tSize.width*0.5;
    tPoint.y=NSMidY(tBounds)-tSize.height*0.5;
    
    [title_ drawAtPoint:tPoint withAttributes:attributes_];
}

@end
