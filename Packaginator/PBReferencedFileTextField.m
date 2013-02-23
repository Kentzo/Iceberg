/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBReferencedFileTextField.h"
#import "PBReferencedFileTextCell.h"
#import "PBFilePathCheckerFormatter.h"

#import "NSString+Iceberg.h"

#import "NSCarbonMenuImp.h"

@implementation PBReferencedFileTextField

+ (Class) cellClass
{
    return [PBReferencedFileTextCell class];
}

+ (void) setCellClass:(Class) inClass
{
}

- (BOOL) isOpaque
{
    return NO;
}

- (void) selectText:(id) inSender
{
    isEditing=YES;

    [super selectText:inSender];
}

- (NSAttributedString *) attributedStringForString:(NSString *) inString
{
    static NSFileManager * sFileManager=nil;
    NSAttributedString * tAttributedString=nil;
    NSString * tAbsolutePath;
    
    if (document_!=nil)
    {
        if (sFileManager==nil)
        {
            sFileManager=[NSFileManager defaultManager];
        }
        
        switch (pathType_)
        {
            case kGlobalPath:
                tAbsolutePath=inString;
                break;
        
            case kRelativeToProjectPath:
                tAbsolutePath=[inString stringByAbsolutingWithPath:[[document_ fileName] stringByDeletingLastPathComponent]];
            
                break;
            default:
                tAbsolutePath=nil;
                break;
        }
        
        if (noCheck_==YES || [sFileManager fileExistsAtPath:tAbsolutePath]==YES)
        {
            tAttributedString=[[NSAttributedString alloc] initWithString:inString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor],NSForegroundColorAttributeName,nil]];
        }
        else
        {
            tAttributedString=[[NSAttributedString alloc] initWithString:inString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSForegroundColorAttributeName,nil]];
        }
    }
    
    return [tAttributedString autorelease];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSAttributedString * tAttributedString;
    NSCell * tCell=[self cell];
        
    isEditing=NO;
    
    [super textDidEndEditing:notification];
    
    tAttributedString=[self attributedStringForString:[tCell stringValue]];
        
    [tCell setAttributedStringValue: tAttributedString];
}

#pragma mark -

- (void) setNoCheck:(BOOL) aBool
{
    noCheck_=aBool;
}

- (void) setDocument:(NSDocument *) inDocument
{
    document_=inDocument;
}

- (void) setStringValue:(NSString *) inString
{
    if (inString!=nil)
    {
        NSAttributedString * tAttributedString;
        
        tAttributedString=[self attributedStringForString:inString];
        
        [[self cell] setAttributedStringValue: tAttributedString];
    }
}

- (void) setAbsolutePath:(NSString *) inAbsolutePath
{
    if (inAbsolutePath!=nil && document_!=nil)
    {
        NSString * tString=nil;
        NSAttributedString * tAttributedString;
        
        switch(pathType_)
        {
            case kGlobalPath:
                tString=inAbsolutePath;
                break;
            case kRelativeToProjectPath:
                tString=[inAbsolutePath stringByRelativizingToPath:[[document_ fileName] stringByDeletingLastPathComponent]];
                
                if (tString==nil)
                {
                    tString=inAbsolutePath;
                }
                break;
        }
        
        tAttributedString=[self attributedStringForString:tString];
        
        [[self cell] setAttributedStringValue: tAttributedString];
    }
}

- (NSString *) absolutePath
{
    NSString * tString;
    
    tString=[self stringValue];

    if (document_!=nil)
    {
        switch(pathType_)
        {
            case kGlobalPath:
                return tString;
            case kRelativeToProjectPath:
                return [tString stringByAbsolutingWithPath:[[document_ fileName] stringByDeletingLastPathComponent]];
        }
    }
    
    return tString;
}

- (int) pathType
{
    return pathType_;
}

- (void) _setPathType:(int) inPathType
{
    pathType_=inPathType;
    
    [self setNeedsDisplay:YES];
}

- (void) setPathType:(int) inPathType
{
    if (pathType_!=inPathType)
    {
    	NSString * tAbsolutePath;
        
        tAbsolutePath=[self absolutePath];
        
        pathType_=inPathType;
        
        if (tAbsolutePath!=nil)
        {
            [self setAbsolutePath:tAbsolutePath];
        }
    }
}

+ (NSImage *) popupImageForReferenceStyle:(int) inStyle
{
    static NSImage * sRelativePopupImage=nil;
    static NSImage * sAbsolutePopupImage=nil;
    
    switch(inStyle)
    {
        case kGlobalPath:
        
            if (sAbsolutePopupImage==nil)
            {
                sAbsolutePopupImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PopAbsolute" ofType:@"tif"]];
            }
            
            return sAbsolutePopupImage;
        
        case kRelativeToProjectPath:
            if (sRelativePopupImage==nil)
            {
                sRelativePopupImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PopRelative" ofType:@"tif"]];
            }
            
            return sRelativePopupImage;
    }
    
    return nil;
}

+ (NSMenu *) referenceStyleMenuForTarget:(id) inTarget
{
    NSMenu * nReferenceStyleMenu=nil;
    
    nReferenceStyleMenu=[[NSMenu alloc] initWithTitle:@""];
    
    if (nReferenceStyleMenu!=nil)
    {
        id tMenuItem;
        NSImage * tImage;
        
        tMenuItem=[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Project Relative",@"No comment")
                                             action:@selector(takeReferenceStyle:)
                                      keyEquivalent:@""];
    
        [tMenuItem setTarget:inTarget];
        
        [tMenuItem setTag:kRelativeToProjectPath];
        
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Relative" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
        
        [nReferenceStyleMenu addItem:tMenuItem];
        
        [tMenuItem release];
        
	tMenuItem=[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Absolute Path",@"No comment")
                                             action:@selector(takeReferenceStyle:)
                                      keyEquivalent:@""];
    
        [tMenuItem setTarget:inTarget];
        
        [tMenuItem setTag:kGlobalPath];
        
        tImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Absolute" ofType:@"tif"]];
        
        if (tImage!=nil)
        {
            [tMenuItem setImage:tImage];
        
            [tImage release];
        }
        
        [nReferenceStyleMenu addItem:tMenuItem];
        
        [tMenuItem release];
    }
    
    return [nReferenceStyleMenu autorelease];
}

- (IBAction) takeReferenceStyle:(id) sender
{
    if (pathType_!=[sender tag])
    {
    	NSString * tAbsolutePath;
        
        tAbsolutePath=[self absolutePath];
        
        pathType_=[sender tag];
        
        [self setAbsolutePath:tAbsolutePath];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: NSControlTextDidChangeNotification
                                                            object: self
                                                        userInfo: nil];
        
        if ([self target]!=nil)
        {
            [[self target] performSelector:[self action] withObject:self];
        }
    }
}

#pragma mark -

- (void) drawRect:(NSRect) inFrame
{
    NSRect tBounds;
    
    tBounds=[self bounds];
    
    // Draw the background
    
    [[NSColor whiteColor] set];
    
    NSRectFill(tBounds);
    
    // Draw Frame
    
    [[self cell] _drawThemeBezelWithFrame:tBounds inView:self];
    
    // Draw the appropriate icon
    
    [[PBReferencedFileTextField popupImageForReferenceStyle:pathType_] compositeToPoint:NSMakePoint(2,19) operation:NSCompositeSourceOver];
    
    // Draw the Focus ring
    
    if (isEditing==YES)
    {
        if ([_window isKeyWindow])
        {
            NSBezierPath * tBezierPath;
        
            tBezierPath=[NSBezierPath bezierPathWithRect:tBounds];
                    
            [NSGraphicsContext saveGraphicsState]; 
                    
            NSSetFocusRingStyle(NSFocusRingOnly); 
                    
            [tBezierPath fill];
                    
            [tBezierPath removeAllPoints];
                    
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    else
    {
        [[self cell] drawWithFrame:tBounds inView:self];
    }
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    PBReferencedFileTextCell * tCell;
    NSControlSize tControlSize;
    
    [super initWithCoder:aDecoder];
    
    pathType_=kGlobalPath;
    
    tCell=[[PBReferencedFileTextCell alloc] initTextCell:@""];
    
    tControlSize=[[self cell] controlSize];
    
    [tCell setDrawsBackground:YES];
    [tCell setEditable:[self isEditable]];
    [tCell setWraps:NO];
    [tCell setScrollable:YES];
    [tCell setSelectable:YES];
    [tCell setEnabled:YES];
    
    [tCell setFont:[[self cell] font]];
    
    [tCell setSendsActionOnEndEditing:[[self cell] sendsActionOnEndEditing]];
    
    [self setCell:tCell];
    
    [self setMenu:[PBReferencedFileTextField referenceStyleMenuForTarget:self]];
    
    [tCell release];
    
    return self;
}

- (void)setKeyboardFocusRingNeedsDisplayInRect:(NSRect) aFrame
{
    [super setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
}

- (void) mouseDown:(NSEvent *) theEvent
{
    NSPoint tMouseLoc=[self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect tRect;
    NSRect tBounds=[self bounds];
    
    // Check if the click is on the PopUp
    
    tRect=NSMakeRect(2,0,27,NSHeight(tBounds));
    
    if (NSMouseInRect(tMouseLoc,tRect,[self isFlipped])==YES)
    {
        int oldTag;
        NSCarbonMenuImpl * tCarbonMenuImplementation;
        
        [self selectText:self];
        
        tRect=[self bounds];
        
        tMouseLoc=NSMakePoint(NSMinX(tRect)-19.0f,NSHeight(tRect)+4);
        
        tCarbonMenuImplementation=[NSCarbonMenuImpl new];
            
        // Add the Check mark
        
        oldTag=pathType_;
        
        [[[self menu] itemWithTag:pathType_] setState:NSOnState];
        
        [tCarbonMenuImplementation popUpMenu:[self menu] atLocation:tMouseLoc width:10 forView:self withSelectedItem:0 withFont:[self font]];
        
        // Remove the Check mark
        
        [[[self menu] itemWithTag:oldTag] setState:NSOffState];
        
        [tCarbonMenuImplementation release];
    
        [[self window] makeFirstResponder:self];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

- (void)resetCursorRects
{
    NSRect tBounds=[self bounds];
    
    [self addCursorRect:NSMakeRect(0,0,29,NSHeight(tBounds))
                 cursor:[NSCursor arrowCursor]];
    
    [self addCursorRect:NSMakeRect(29,0,NSWidth(tBounds)-29,NSHeight(tBounds))
                     cursor:[NSCursor IBeamCursor]];
}

@end
