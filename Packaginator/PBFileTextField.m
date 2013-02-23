/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBFileTextField.h"
#import "PBFilePathCheckerFormatter.h"

@implementation PBFileTextField

- (NSString *) hintString
{
    return [hintCell_ stringValue];
}
- (void) setHintString:(NSString *) inHintString
{
    [hintCell_ setObjectValue:inHintString];
}

- (void) setStringValue:(NSString *) inString
{
    if (inString!=nil)
    {
        if (helpValue!=inString)
        {
            [helpValue release];
            helpValue=[inString copy];
        }
    }
    
    [super setStringValue:inString];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    [helpValue release];
    helpValue = [[[_window fieldEditor: YES forObject: self] string] copy];
    
    [super textDidEndEditing:notification];
    
}

- (void) drawRect:(NSRect) aRect
{
    [super drawRect:aRect];
        
    if ([helpValue length]==0)
    {
        [hintCell_ drawWithFrame:[self bounds] inView:self];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    PBFilePathCheckerFormatter * tFormatter;
    
    self=[super initWithCoder:aDecoder];
    
    if (self!=nil)
    {
        tFormatter=[PBFilePathCheckerFormatter new];
    
        if (tFormatter!=nil)
        {
            [self setFormatter:tFormatter];
        
            [tFormatter release];
        }
        
        helpValue=[[self stringValue] copy];
        
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
        
        hintCell_=[[self cell] copy];
        [hintCell_ setFormatter:nil];
        [hintCell_ setTextColor:[NSColor lightGrayColor]];
        [hintCell_ setObjectValue:@""];
    }
    
    return self;
}

- (void) dealloc
{
    [helpValue release];

    [hintCell_ release];
    
    [super dealloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([self delegate]!=nil)
    {
        NSPasteboard *pboard;
        NSDragOperation sourceDragMask;
    
        sourceDragMask = [sender draggingSourceOperationMask];
        pboard = [sender draggingPasteboard];
    
        if ( [[pboard types] containsObject:NSFilenamesPboardType] )
        {
            if (sourceDragMask & NSDragOperationCopy)
            {
                NSArray * files = [pboard propertyListForType:NSFilenamesPboardType];
                
                if ([files count]==1)
                {
                    if ([[self delegate] textField:self shouldAcceptFileAtPath:[files objectAtIndex:0]]==YES)
                    {
                        return NSDragOperationCopy;
                    }
                }
            }
        }
    }
    
    return [super draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;

    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType] )
    {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        if ([files count]==1)
        {
            return [[self delegate] textField:self didAcceptFileAtPath:[files objectAtIndex:0]];
        }
    }
    
    return [super performDragOperation:sender];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{

    [super prepareForDragOperation:sender];
    
    return YES;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [super draggingExited:sender];
}

@end


@implementation NSObject(PBFileTextFieldNotifications)

- (BOOL) textField:(PBFileTextField *) inTextField shouldAcceptFileAtPath:(NSString *) inPath
{
    return NO;
}

- (BOOL) textField:(PBFileTextField *) inTextField didAcceptFileAtPath:(NSString *) inPath
{
    [inTextField setStringValue:inPath];
    
    return YES;
}

@end