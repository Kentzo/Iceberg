/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBTableView.h"

static NSColor * _gWhiteColor=nil;
static NSColor * _gGrayColor=nil;

@implementation PBTableView

/*
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
     if (isLocal) return NSDragOperationEvery;
     else return NSDragOperationCopy;
}
*/

- (void) setStripesColor:(NSColor *) inColor
{
    if (inColor!=stripesColor_)
    {
        [stripesColor_ release];
    
        stripesColor_=[inColor copy];
    }
}

- (NSColor *) stripesColor
{
    return [[stripesColor_ retain] autorelease];
}

#pragma mark -

- (NSMenu*) menuForEvent: (NSEvent*)event
{
    NSPoint where;
    int row;

    where = [self convertPoint: [event locationInWindow] fromView: [_window contentView]];
    
    row = [self rowAtPoint: where];
    
    if (row < 0)
    {
        return (showMenuForEmptySelection_==YES) ? [self menu]: nil;
    }
    
    if ([self isRowSelected:row]==NO)
    {
        [self selectRow: row byExtendingSelection: NO];
    }
    
    return [self menu];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
    return acceptFirstClick_;
}

- (void) setAcceptFirstClick:(BOOL) aBool
{
    acceptFirstClick_=aBool;
}

- (void) showMenuForEmptySelection:(BOOL) aBool
{
    showMenuForEmptySelection_=aBool;
}

- (void)textDidEndEditing:(NSNotification *)notification;
{
    if ([[[notification userInfo] valueForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement)
    {
		NSMutableDictionary *newUserInfo;

		newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];

		[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];

		notification = [NSNotification notificationWithName:[notification name]
														 object:[notification object]
													   userInfo:newUserInfo];

		[super textDidEndEditing:notification];

		[newUserInfo release];

		[[self window] makeFirstResponder:self];
    }
    else
    {
		[super textDidEndEditing:notification];
    }
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
    float rowHeight = [self rowHeight] + [self intercellSpacing].height;
    NSRect visibleRect = [self visibleRect];
    NSRect highlightRect;
    NSColor * tRowColor;
    
    if (_gWhiteColor==nil)
    {
        _gWhiteColor=[[NSColor whiteColor] retain];
    }
    
    highlightRect.origin = NSMakePoint(NSMinX(visibleRect), (int)(NSMinY(clipRect)/rowHeight)*rowHeight);
    highlightRect.size = NSMakeSize(NSWidth(visibleRect), rowHeight - [self intercellSpacing].height);
    
    if (stripesColor_==nil)
    {
        if ([[[NSColor colorForControlTint:NSDefaultControlTint] colorNameComponent] isEqualToString:@"graphiteControlTintColor"]==NO)
        {
            tRowColor=[NSColor colorWithCalibratedRed:0.929f
                                                green:0.953f
                                                blue:1.0f
                                                alpha:1.0f];
        }
        else
        {
            if (_gGrayColor==nil)
            {
            	_gGrayColor=[[NSColor colorWithDeviceWhite:0.94f alpha:1.0f] retain];
            }
            
            tRowColor=_gGrayColor;
        }
    }
    else
    {
        tRowColor=stripesColor_;
    }
    
    while (NSMinY(highlightRect) < NSMaxY(clipRect))
    {
        NSRect clippedHighlightRect = NSIntersectionRect(highlightRect, clipRect);
        int row = (int)((NSMinY(highlightRect)+rowHeight*0.5)/rowHeight);
        NSColor * tColor = (0 == (row & 0x1)) ? tRowColor : _gWhiteColor;
        
        [tColor set];
        
        NSRectFill(clippedHighlightRect);
        
        highlightRect.origin.y += rowHeight;
    }
    
    [super highlightSelectionInClipRect: clipRect];	// call superclass's behavior
}

- (void) keyDown:(NSEvent *) theEvent
{
    NSString * tString;
    unsigned int stringLength;
    unsigned int i;
    unichar tChar;
    
    tString= [theEvent characters];
    
    stringLength=[tString length];
    
    for(i=0;i<stringLength;i++)
    {
        tChar=[tString characterAtIndex:i];
        
        if (tChar==0x7F)
        {
            id tMenuItem;
            
            tMenuItem=[[NSMenuItem alloc] initWithTitle:@"" action:@selector(delete:) keyEquivalent:@""];
            
            if ([self validateMenuItem:tMenuItem]==YES)
            {
                [self delete:nil];
            }
            else
            {
                NSBeep();
            }
            
            [tMenuItem release];
            
            return;
        }
    }
    
    [super keyDown:theEvent];
}

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
    if ([aMenuItem action]==@selector(delete:))
    {
        if ([self numberOfSelectedRows]>0)
        {
            return [[self dataSource] validateMenuItem:aMenuItem];
        }
        
        return NO;
    }
    
    return YES;
}

- (IBAction) delete:(id) sender
{
    if ([[self dataSource] respondsToSelector:@selector(deleteSelectedRowsOfTableView:)]==YES)
    {
        [[self dataSource] performSelector:@selector(deleteSelectedRowsOfTableView:)
                                withObject:self];
    }
}

@end
