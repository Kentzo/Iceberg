#import "PBHalfToneButton.h"
#include <Carbon/Carbon.h>

BOOL _PBHalfToneButton_Needs_AdditionalCode=YES;

@implementation PBHalfToneButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (_PBHalfToneButton_Needs_AdditionalCode==YES)
	{
		NSColor * sBottomFrameColor=nil;
		NSColor * sTopFrameColor=nil;
		NSColor * tUpperHalfBackgroundColor=nil;
		NSColor * tLowerHalfBackgroundColor=nil;
		NSColor * tTopLineColor=nil;
		NSColor * tBottomLineColor=nil;
		
		NSRect tRect;
		NSRect tHalfRect;
		
		tRect=NSInsetRect(cellFrame,0,1);
		
		// Choose the colors
		
		tTopLineColor=[NSColor colorWithDeviceWhite:0.0f alpha:0.12f];
		
		tBottomLineColor=[NSColor colorWithDeviceWhite:0.0f alpha:0.02f];
		
		if ([self isEnabled]==NO || [self isHighlighted]==NO)
		{
			sBottomFrameColor=[NSColor colorWithDeviceWhite:0.5922f alpha:1.0f];
				
			sTopFrameColor=[NSColor colorWithDeviceWhite:0.4902f alpha:1.0f];
				
			tUpperHalfBackgroundColor=[NSColor colorWithDeviceWhite:0.9843f alpha:1.0f];
				
			tLowerHalfBackgroundColor=[NSColor colorWithDeviceWhite:0.9294f alpha:1.0f];
		}
		else
		{
			// Standard
				
			sBottomFrameColor=[NSColor colorWithDeviceWhite:0.3176f alpha:1.0f];
				
			sTopFrameColor=[NSColor colorWithDeviceWhite:0.2588f alpha:1.0f];
				
			tUpperHalfBackgroundColor=[NSColor colorWithDeviceWhite:0.5216f alpha:1.0f];
				
			tLowerHalfBackgroundColor=[NSColor colorWithDeviceWhite:0.4902f alpha:1.0f];
		}
		
		// Draw the Frame
		
		[sTopFrameColor set];
		
		// Top Frame
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(tRect),NSMinY(tRect)+0.5f) toPoint:NSMakePoint(NSMaxX(tRect),NSMinY(tRect)+0.5f)];
		
		[sBottomFrameColor set];
		
		// Bottom Frame
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(tRect)+0.5f,NSMinY(tRect)+1.0f) toPoint:NSMakePoint(NSMinX(tRect)+0.5f,NSMaxY(tRect))];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(tRect)+1.0f,NSMaxY(tRect)-0.5f) toPoint:NSMakePoint(NSMaxX(tRect)-1.0f,NSMaxY(tRect)-0.5f)];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(tRect)-0.5f,NSMaxY(tRect)) toPoint:NSMakePoint(NSMaxX(tRect)-0.5f,NSMinY(tRect)+1.0f)];
		
		// Draw the background
		
		// Upper Half
		
		[tUpperHalfBackgroundColor set];
		
		tHalfRect=NSInsetRect(tRect,1,1);
		
		tHalfRect.size.height=floor(NSHeight(tHalfRect)*0.5f);
		
		NSRectFill(tHalfRect);
		
		// LowerHalf
		
		[tLowerHalfBackgroundColor set];
		
		tHalfRect.origin.y+=NSHeight(tHalfRect);
		
		tHalfRect.size.height=NSHeight(tRect)-NSHeight(tHalfRect)-2.0f;
		
		NSRectFill(tHalfRect);
		
		// Draw the horizontal border lines
		
		// Top
		
		[tTopLineColor set];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(tRect),NSMinY(tRect)-0.5f) toPoint:NSMakePoint(NSMaxX(tRect),NSMinY(tRect)-0.5f)];
		
		// Top
		
		[tBottomLineColor set];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(tRect),NSMaxY(tRect)+0.5f) toPoint:NSMakePoint(NSMaxX(tRect),NSMaxY(tRect)+0.5f)];
		
		// Offset for 10.2 and 10.4
		
		cellFrame=NSInsetRect(cellFrame,-4,0);
		
		cellFrame=NSOffsetRect(cellFrame,0,2);
		
		[self drawInteriorWithFrame:cellFrame inView:controlView];
	}
	else
	{
		[super drawWithFrame:cellFrame inView:controlView];
	}
}

@end

@implementation PBHalfToneButton

+ (void) initialize
{
	// Get the OS Version
	
	OSErr tError;
    SInt32 tSystemVersion;
    
    tError=Gestalt(gestaltSystemVersion,&tSystemVersion);
    
    if (tError==noErr)
    {
        if ((tSystemVersion & 0x0000FFF0)>=0x1040)
		{
			_PBHalfToneButton_Needs_AdditionalCode=NO;
		}
    }
}

- (id) initWithCoder:(NSCoder *) inCoder
{
	self=[super initWithCoder:inCoder];
	
	if (self!=nil)
	{
		if (_PBHalfToneButton_Needs_AdditionalCode==YES)
		{
			PBHalfToneButtonCell * tHalfToneButtonCell;
			
			tHalfToneButtonCell=[[PBHalfToneButtonCell alloc] initTextCell:@""];
			
			if (tHalfToneButtonCell!=nil)
			{
				NSButtonCell * tCurrentCell;
				
				tCurrentCell=[self cell];
				
				if (tCurrentCell!=nil)
				{
					// General Appearance
					
					[tHalfToneButtonCell setTransparent:[tCurrentCell isTransparent]];
					
					[tHalfToneButtonCell setEnabled:[tCurrentCell isEnabled]];
					
					[tHalfToneButtonCell setBordered:[tCurrentCell isBordered]];
					
					[tHalfToneButtonCell setTag:[tCurrentCell tag]];
					
					[tHalfToneButtonCell setState:[tCurrentCell state]];
					
					[self setAllowsMixedState:NO];
					
					[tHalfToneButtonCell setType:[tCurrentCell type]];
					
					[tHalfToneButtonCell setButtonType:NSMomentaryLightButton];
					
					[tHalfToneButtonCell setBezelStyle:NSRegularSquareBezelStyle];
					
					[tHalfToneButtonCell setShowsStateBy:[tCurrentCell showsStateBy]];
					
					[tHalfToneButtonCell setHighlightsBy:[tCurrentCell highlightsBy]];
					
					// Action
					
					[tHalfToneButtonCell setAction:[tCurrentCell action]];
					
					[tHalfToneButtonCell setTarget:[tCurrentCell target]];
					
					// Text
					
					[tHalfToneButtonCell setTitle:[tCurrentCell title]];
					
					[tHalfToneButtonCell setAlternateTitle:[tCurrentCell alternateTitle]];
					
					[tHalfToneButtonCell setFont:[tCurrentCell font]];
					
					// Image
					
					[tHalfToneButtonCell setImagePosition:[tCurrentCell imagePosition]];
					
					[tHalfToneButtonCell setImage:[tCurrentCell image]];
					
					[tHalfToneButtonCell setAlternateImage:[tCurrentCell alternateImage]];
				}
			
				[self setCell:tHalfToneButtonCell];
				
				[tHalfToneButtonCell release];
			}
		}
		else
		{
			// We just need to set the appropriate Bezel Style
			
			[self setBezelStyle:10];
		}
	}
	
	return self;
}

@end
