/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBFileNameFormatter.h"

@implementation PBFileNameFormatter

- (id) init
{
    self=[super init];
    
    cantStartWithADot_=YES;
    
    return self;
}

- (BOOL) cantStartWithADot
{
    return cantStartWithADot_;
}

- (void) setCantStartWithADot:(BOOL) aBool
{
    cantStartWithADot_=aBool;
}

#pragma mark -

- (NSString *)stringForObjectValue:(id)obj
{
    return ((obj && [obj isKindOfClass:[NSString class]]) ? obj : @"");
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error
{
    *obj=[[string copy] autorelease];
     
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
    int i,tLength;
    unichar tUniChar;
    
    tLength=[partialString length];
    
    if (tLength>256)
    {
        *newString=nil;
            
        *error=@"Error";
            
        return NO;
    }
    
    if (tLength>0)
    {
        if (cantStartWithADot_==NO)
        {
            tUniChar=[partialString characterAtIndex:0];
            
            if (tUniChar=='.')
            {
                *newString=nil;
                
                *error=@"Error";
                
                return NO;
            }
        }
        
        for(i=0;i<tLength;i++)
        {
            tUniChar=[partialString characterAtIndex:i];
            
            if (tUniChar=='/')
            {
                *newString=nil;
                
                *error=@"Error";
                
                return NO;
            }
        }
    }
    
    return YES;
}

@end
