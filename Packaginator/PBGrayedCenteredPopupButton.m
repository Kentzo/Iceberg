#import "PBGrayedCenteredPopupButton.h"

@implementation PBGrayedCenteredPopupButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self sizeToFit];
    }
    
    return self;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    id tSuperview;
    
    tSuperview=[self superview];
    
    if (tSuperview!=nil)
    {
        NSRect tSelfBounds;
        NSRect tSuperviewBounds;
        
        [self sizeToFit];
        
        tSuperviewBounds=[tSuperview bounds];
        
        tSelfBounds=[self bounds];
        
        tSelfBounds.origin.x=(NSWidth(tSuperviewBounds)-NSWidth(tSelfBounds))*0.5f+10.0f;
        
        tSelfBounds.origin.y=(NSHeight(tSuperviewBounds)-NSHeight(tSelfBounds))*0.5f-26.0f;
        
        [self setFrame:tSelfBounds];
        
    }
}

- (void) drawRect:(NSRect) aFrame
{
    id tSelectedMenuItem;
    NSString * tMenuItemTitle;
    NSImage * tMenuImage;
    NSRect tBounds;
    NSSize tImageSize;
    NSAttributedString * tAttributedString;
    NSDictionary * tAttributes;
    NSRect tTitleRect;
    NSSize tTitleSize;
    NSBezierPath * tBezierPath;
    
    tBounds=[self bounds];
    
    tSelectedMenuItem=[self selectedItem];
    
    tMenuItemTitle=[tSelectedMenuItem title];
    
    // Image
    
    tMenuImage=[tSelectedMenuItem image];
    
    tImageSize=[tMenuImage size];
    
    [tMenuImage compositeToPoint:NSMakePoint(0,floor((NSHeight(tBounds)+tImageSize.height)*0.5f)-1.0f) operation:NSCompositeSourceOver fraction:0.75f];
    
    // Text
    
    tAttributes=[NSDictionary dictionaryWithObjectsAndKeys:[self font],NSFontAttributeName,
                                                            [NSColor lightGrayColor],NSForegroundColorAttributeName,nil
                                                            ];
    
    tAttributedString=[[NSAttributedString alloc] initWithString:tMenuItemTitle attributes:tAttributes];
    
    tTitleSize=[tAttributedString size];
    
    tTitleRect=tBounds;
    
    tTitleRect.origin.x+=tImageSize.width+4;
    tTitleRect.size.width-=tImageSize.width+4;
    
    [tAttributedString drawInRect:tTitleRect];
    
    [tAttributedString release];
    
    // Draw the Triangle

#define H_OFFSET	5.0f
#define V_OFFSET	1.0f
#define V_CORRECTION	-1.0f
#define TRIANGLE_SIZE	3.0f

    tBezierPath=[NSBezierPath bezierPath];
    
    [tBezierPath moveToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET,NSMidY(tTitleRect)+V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET+TRIANGLE_SIZE,NSMidY(tTitleRect)+TRIANGLE_SIZE+V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET+2*TRIANGLE_SIZE,NSMidY(tTitleRect)+V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET,NSMidY(tTitleRect)+V_OFFSET+V_CORRECTION)];

    [[NSColor lightGrayColor] set];
    
    [tBezierPath fill];
    
    tBezierPath=[NSBezierPath bezierPath];
    
    [tBezierPath moveToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET,NSMidY(tTitleRect)-V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET+TRIANGLE_SIZE,NSMidY(tTitleRect)-TRIANGLE_SIZE-V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET+2*TRIANGLE_SIZE,NSMidY(tTitleRect)-V_OFFSET+V_CORRECTION)];
    
    [tBezierPath lineToPoint:NSMakePoint(NSMinX(tTitleRect)+tTitleSize.width+H_OFFSET,NSMidY(tTitleRect)-V_OFFSET+V_CORRECTION)];

    [[NSColor lightGrayColor] set];
    
    [tBezierPath fill];
}

@end
