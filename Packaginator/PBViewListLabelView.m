/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */

#import "PBViewListLabelView.h"

static const float _DisclosureTrianglePad = 4.0;
static const float _RegularDisclosureTriangleDimension = 10.0;
static const float _SmallDisclosureTriangleDimension = 8.0;
static const float _LabelBarTextHeightPad = 2.0;

typedef struct _MO__TriangleImages
{
    NSImage *collapsedTriangle;
    NSImage *expandedTriangle;
    NSImage *highlightedCollapsedTriangle;
    NSImage *highlightedExpandedTriangle;
} _MO_TriangleImages;

#define NUM_APPEARANCES 5

// Cache for images for each appearance, and for each control size

static _MO_TriangleImages _imageCache[NUM_APPEARANCES*2] = {
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil},
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}, 
    {nil, nil, nil, nil}
};

static unsigned _imageCacheIndexForAppearanceAndSize(MOViewListViewLabelBarAppearance appearance, NSControlSize controlSize) {
    if (controlSize == NSRegularControlSize) {
        return appearance;
    } else {
        return appearance + NUM_APPEARANCES;
    }
}

static void _drawLowerRightTrianglePath(float dimension, BOOL right)
{
    NSBezierPath *path = [[NSBezierPath allocWithZone:NULL] init];
    
    [path setLineJoinStyle:NSMiterLineJoinStyle];
    
    if (right)
    {
        [path moveToPoint:NSMakePoint(1.0, 0.0)];
        [path lineToPoint:NSMakePoint(1.0, dimension-1.0)];
        [path lineToPoint:NSMakePoint(dimension, (dimension-1.0) / 2.0)];
    }
    else
    {
        [path moveToPoint:NSMakePoint(1.0, dimension-1.0)];
        [path lineToPoint:NSMakePoint(dimension, dimension-1.0)];
        [path lineToPoint:NSMakePoint(((dimension-1.0) / 2.0) + 1.0, 0.0)];
    }
    
    [path closePath];
    [path fill];
    [path release];
}

static NSImage *_makeRetainedTriangleImage(float dimension, BOOL right, BOOL shadow)
{
    NSImage *image = [[NSImage allocWithZone:NULL] initWithSize:NSMakeSize(dimension, dimension)];
    
    if (![image isValid])
    {
        NSLog(@"Failed to lock focus on new image to draw!");
    }
    else
    {
        [image lockFocus];
        
        [[NSColor clearColor] set];
        
        NSRectFill(NSMakeRect(0.0, 0.0, dimension, dimension));

        if (shadow)
        {
            [[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] set];
            
            _drawLowerRightTrianglePath(dimension, right);
        }
        else
        {
            [[NSColor colorWithCalibratedWhite:0.25 alpha:1.0] set];
            
            _drawLowerRightTrianglePath(dimension, right);
        }
        
        [image unlockFocus];
    }
    
    return image;
}

@implementation PBViewListLabelView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (NSRect)frameForLabelText
{
    NSRect rect = [self bounds];
    
    float dim = _RegularDisclosureTriangleDimension;
    float extraSpace = _DisclosureTrianglePad + dim + _DisclosureTrianglePad;
    
    float lineHeight = [[[self _MO_labelTextFieldCell] font] defaultLineHeightForFont];
    
    rect = NSMakeRect(NSMinX(rect) + extraSpace, NSMinY(rect) + ((NSHeight(rect) - lineHeight) *0.5f) + 1.0f, NSWidth(rect) - extraSpace, lineHeight);
    
    return rect;
}

- (NSTextFieldCell *)_MO_labelTextFieldCell
{
    static NSTextFieldCell *_cell = nil;
    
    if (!_cell)
    {
        _cell = [[NSTextFieldCell allocWithZone:[self zone]] initTextCell:@""];
        [_cell setBordered:NO];
        [_cell setBezeled:NO];
        
        [_cell setTextColor:[NSColor blackColor]];
        [_cell setFont:[NSFont boldSystemFontOfSize:11.0f]];
    }
    
    return _cell;
}

- (NSImage *)_MO_collapsedDisclosureTriangle:(BOOL)highlighted
{
    unsigned cacheIndex = _imageCacheIndexForAppearanceAndSize(MOViewListViewFinderLabelBars, NSRegularControlSize);
    
    if (highlighted)
    {
        if (!_imageCache[cacheIndex].highlightedCollapsedTriangle)
        {
            _imageCache[cacheIndex].highlightedCollapsedTriangle = _makeRetainedTriangleImage(_RegularDisclosureTriangleDimension, YES, NO);
        }
        
        return _imageCache[cacheIndex].highlightedCollapsedTriangle;
        
    }
    else
    {
        if (!_imageCache[cacheIndex].collapsedTriangle)
        {
            _imageCache[cacheIndex].collapsedTriangle = _makeRetainedTriangleImage(_RegularDisclosureTriangleDimension, YES, YES);
        }
        
        return _imageCache[cacheIndex].collapsedTriangle;
    }
}

- (NSImage *)_MO_expandedDisclosureTriangle:(BOOL)highlighted
{
    unsigned cacheIndex = _imageCacheIndexForAppearanceAndSize(MOViewListViewFinderLabelBars, NSRegularControlSize);

    if (highlighted)
    {
        if (!_imageCache[cacheIndex].highlightedExpandedTriangle)
        {
            _imageCache[cacheIndex].highlightedExpandedTriangle = _makeRetainedTriangleImage(_RegularDisclosureTriangleDimension, NO, NO);
        }
        
        return _imageCache[cacheIndex].highlightedExpandedTriangle;
    }
    else
    {
        if (!_imageCache[cacheIndex].expandedTriangle)
        {
            _imageCache[cacheIndex].expandedTriangle = _makeRetainedTriangleImage(_RegularDisclosureTriangleDimension, NO, YES);
        }
        
        return _imageCache[cacheIndex].expandedTriangle;
    }
}

@end
