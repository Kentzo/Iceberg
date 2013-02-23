/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBExtensionUtilities.h"

@implementation PBExtensionUtilities

+ (NSString *) extensionForIcnsFileAtPath:(NSString *) inPath
{
    NSString * tExtension;
    
    tExtension=[inPath pathExtension];
    
    if ([tExtension length]==0)
    {
        static NSDictionary * sDictionary=nil;
        
        if (sDictionary==nil)
        {
            sDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:@"icns",@"'ICNS'",
                                                                     nil];
        }
        
        tExtension=NSHFSTypeOfFile(inPath);
        
        if (tExtension!=nil)
        {
            tExtension=[sDictionary objectForKey:tExtension];
        }
    }
    else
    {
        if ([tExtension compare:@"icns" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"icns";
        }
        else
        {
            tExtension=nil;
        }
    }
    
    return tExtension;
}

+ (NSString *) extensionForTextFileAtPath:(NSString *) inPath
{
    NSString * tExtension;
    
    tExtension=[inPath pathExtension];
    
    if ([tExtension length]==0)
    {
        static NSDictionary * sDictionary=nil;
        
        if (sDictionary==nil)
        {
            sDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:@"txt",@"'TEXT'",
                                                                     nil];
        }
        
        NSDictionary * tAttributes;
		
		tAttributes=[[NSFileManager defaultManager] fileAttributesAtPath:inPath traverseLink:NO];
		
		if (tAttributes!=nil)
		{
			NSNumber * tFileType;
				
			tFileType=[tAttributes objectForKey:NSFileHFSTypeCode];
		
			NSLog(@"%@",tFileType);
		}
		
		tExtension=NSHFSTypeOfFile(inPath);
        
        if (tExtension!=nil)
        {
            tExtension=[sDictionary objectForKey:tExtension];
        }
    }
    else
    {
        if ([tExtension compare:@"txt" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"txt";
        }
        else
        if ([tExtension compare:@"rtf" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"rtf";
        }
        else
        if ([tExtension compare:@"rtfd" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"rtfd";
        }
        else
        if ([tExtension compare:@"html" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"html";
        }
        else
        if ([tExtension compare:@"htm" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"html";
        }
        else
        {
            tExtension=nil;
        }
    }
    
    return tExtension;
}

+ (NSString *) extensionForImageFileAtPath:(NSString *) inPath
{
    NSString * tExtension;
    
    tExtension=[inPath pathExtension];
    
    if ([tExtension length]==0)
    {
        static NSDictionary * sDictionary=nil;
        
        if (sDictionary==nil)
        {
			sDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:@"tif",@"'TIFF'",
                                                                     @"jpg",@"'JPEG'",
																	 @"png",@"'PNGf'",
                                                                     @"gif",@"'GIFf'",
                                                                     @"pdf",@"'PDF '",
                                                                     @"eps",@"'EPSF'",
																	 nil];
        }
        
        tExtension=NSHFSTypeOfFile(inPath);
        
        if (tExtension!=nil)
        {
            tExtension=[sDictionary objectForKey:tExtension];
        }
    }
    else
    {
        if ([tExtension compare:@"tiff" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"tif";
        }
        else
        if ([tExtension compare:@"tif" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"tif";
        }
		else
        if ([tExtension compare:@"png" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"png";
        }
        else
        if ([tExtension compare:@"jpg" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"jpg";
        }
        else
        if ([tExtension compare:@"jpeg" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"jpg";
        }
        else
        if ([tExtension compare:@"gif" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"gif";
        }
        else
        if ([tExtension compare:@"pict" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"pict";
        }
        else
        if ([tExtension compare:@"pct" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"pct";
        }
        else
        if ([tExtension compare:@"epsi" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"eps";
        }
        else
        if ([tExtension compare:@"eps" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"eps";
        }
        else
        if ([tExtension compare:@"epi" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"eps";
        }
        else
        if ([tExtension compare:@"pdf" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            tExtension=@"pdf";
        }
        else
        {
            tExtension=nil;
        }
    }
    
    return tExtension;
}

@end
