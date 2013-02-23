#import "PBMagicCheckButtonCell.h"
#import "PBSimulatorImageProvider.h"

@implementation PBMagicCheckButtonCell

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	if ([self tag]!=0)
	{
		return NO;
	}
	
	return [super startTrackingAt:startPoint inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if ([self tag]!=0)
	{
		static NSImage * sImage=nil;
		static NSRect sImageRect;
		
		if (sImage==nil)
		{
			sImage=[[[PBSimulatorImageProvider defaultProvider] imageNamed:@"DotGray"] retain];
			
			sImageRect.origin=NSZeroPoint;
			sImageRect.size=[sImage size];
		}
		
		if (sImage!=nil)
		{
			cellFrame.origin.x=floor(NSMidX(cellFrame)-NSWidth(sImageRect)*0.5f);
			cellFrame.origin.y=floor(NSMidY(cellFrame)-NSHeight(sImageRect)*0.5f);
			
			cellFrame.size=sImageRect.size;
			
			[sImage drawInRect:cellFrame fromRect:sImageRect operation:NSCompositeSourceOver fraction:1.0f];
		}
	}
	else
	{
		[super drawInteriorWithFrame:cellFrame inView:controlView];
	}
}

@end
