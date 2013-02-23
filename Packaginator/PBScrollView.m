/*
    Portions of this code are from a post on the Cocoa or OmniGroup mailing list
*/

#import "PBScrollView.h"

@interface AJRInstallClipView : NSClipView 
{
}

@end
 
@implementation AJRInstallClipView 

+ (void)load 
 { 
    [[self class] poseAsClass:[NSClipView class]]; 
 } 

 - (BOOL)isOpaque 
 { 
    return NO; 
 } 

 - (void)drawRect:(NSRect)rect 
 {
    if ([[self superview] isMemberOfClass:[PBScrollView class]]==NO)
    {
        [super drawRect:rect];
    }
 } 

 @end 
 
 @implementation PBScrollView

- (void) awakeFromNib 
 { 
    [[self contentView] setCopiesOnScroll:NO]; 

    if ([[self documentView] isKindOfClass:[NSTextView class]])
    { 
        [[self documentView] setDrawsBackground:NO];
    }
}
 
 - (BOOL)isOpaque 
{ 
    return NO; 
}

- (void)drawRect:(NSRect)rect
{
}

@end
