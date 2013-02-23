/*
 *  NDResourceFork.m
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 *
 *	Currently ResourceFork will not add resource forks to files
 *	or create new files with resource forks
 *
 */

#import "NDResourceFork.h"
#import "NSString+CarbonUtilities.h"
//#import "NSURL+NDCarbonUtilities.h"

OSErr createResourceFork( NSURL * aURL );

@implementation NDResourceFork

/*
 * resourceForkForReadingAtURL:
 */
+ (id)resourceForkForReadingAtURL:(NSURL *)aURL
{
	return [[[self alloc] initForReadingAtURL:aURL] autorelease];
}

/*
 * resourceForkForWritingAtURL:
 */
+ (id)resourceForkForWritingAtURL:(NSURL *)aURL
{
	return [[[self alloc] initForWritingAtURL:aURL] autorelease];
}

/*
 * resourceForkForReadingAtPath:
 */
+ (id)resourceForkForReadingAtPath:(NSString *)aPath
{
	return [[[self alloc] initForReadingAtPath:aPath] autorelease];
}

/*
 * resourceForkForWritingAtPath:
 */
+ (id)resourceForkForWritingAtPath:(NSString *)aPath
{
	return [[[self alloc] initForWritingAtPath:aPath] autorelease];
}

/*
 * initForReadingAtURL:
 */
- (id)initForReadingAtURL:(NSURL *)aURL
{
	return [self initForPermission:fsRdPerm AtURL:aURL];
}

/*
 * initForWritingAtURL:
 */
- (id)initForWritingAtURL:(NSURL *)aURL
{
	return [self initForPermission:fsWrPerm AtURL:aURL];
}

/*
 * initForPermission:AtURL:
 */
- (id)initForPermission:(char)aPermission AtURL:(NSURL *)aURL
{
	return [self initForPermission:aPermission AtPath:[aURL path]];
}

- (id)initForPermission:(char)aPermission AtPath:(NSString *)aPath
{
	OSErr			theError = !noErr;
	FSRef			theFsRef,
					theParentFsRef;

	if( self = [self init] )
	{
		/*
		 * if write permission then create resource fork
		 */
		if( (aPermission & 0x06) != 0 )		// if write permission
		{
			if ( [[aPath stringByDeletingLastPathComponent] getFSRef:&theParentFsRef] )
			{
				unsigned int	theNameLength;
				unichar 			theUnicodeName[ PATH_MAX ];
				NSString			* theName;

				theName = [aPath lastPathComponent];
				theNameLength = [theName length];

				if( theNameLength <= PATH_MAX )
				{
					[theName getCharacters:theUnicodeName range:NSMakeRange(0,theNameLength)];

					FSCreateResFile( &theParentFsRef, theNameLength, theUnicodeName, 0, NULL, NULL, NULL );		// doesn't replace if already exists

					theError =  ResError( );

					if( theError == noErr || theError == dupFNErr )
					{
						[aPath getFSRef:&theFsRef];
						fileReference = FSOpenResFile ( &theFsRef, aPermission );
						theError = fileReference > 0 ? ResError( ) : !noErr;
					}
				}
				else
					theError = !noErr;
			}
		}
		else		// dont have write permission
		{
			[aPath getFSRef:&theFsRef];
			fileReference = FSOpenResFile ( &theFsRef, aPermission );
			theError = fileReference > 0 ? ResError( ) : !noErr;
		}

	}

	if( noErr != theError && theError != dupFNErr )
	{
		[self release];
		self = nil;
	}

	return self;
}

/*
 * initForReadingAtPath:
 */
- (id)initForReadingAtPath:(NSString *)aPath
{
	if( [[NSFileManager defaultManager] fileExistsAtPath:aPath] )
		return [self initForPermission:fsRdPerm AtURL:[NSURL fileURLWithPath:aPath]];
	else
		return nil;
}

/*
 * initForWritingAtPath:
 */
- (id)initForWritingAtPath:(NSString *)aPath
{
	return [self initForPermission:fsWrPerm AtURL:[NSURL fileURLWithPath:aPath]];
}

/*
 * dealloc
 */
- (void)dealloc
{
	CloseResFile( fileReference );
	
	[super dealloc];
}

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(short)anID name:(NSString *)aName
{
	Handle		theResHandle;
	
	if( [self removeType:aType Id:anID] )
	{
		short			thePreviousRefNum;

		thePreviousRefNum = CurResFile();	// save current resource
		UseResFile( fileReference );    			// set this resource to be current
	
		// copy NSData's bytes to a handle
		if ( noErr == PtrToHand ( [aData bytes], &theResHandle, [aData length] ) )
		{
			Str255			thePName;
			
			CopyCStringToPascal ( [aName lossyCString], thePName );
			
			HLock( theResHandle );
			AddResource( theResHandle, aType, anID, thePName );
			HUnlock( theResHandle );
			
			UseResFile( thePreviousRefNum );     		// reset back to resource previously set
	
//			DisposeHandle( theResHandle );
			return ( ResError( ) == noErr );
		}
	}
	
	return NO;
}

/*
 * dataForType:Id:
 */
- (NSData *)dataForType:(ResType)aType Id:(short)anID
{
	NSData		* theData = nil;
	Handle		theResHandle;
	short			thePreviousRefNum;

	thePreviousRefNum = CurResFile();	// save current resource
	
	UseResFile( fileReference );    		// set this resource to be current

	if( noErr ==  ResError( ) )
	{
		theResHandle = Get1Resource( aType, anID );

		if( theResHandle && noErr ==  ResError( ) )
		{
			HLock(theResHandle);
			theData = [NSData dataWithBytes:*theResHandle length:GetHandleSize( theResHandle )];
			HUnlock(theResHandle);
		}
		
		if ( theResHandle )
			ReleaseResource( theResHandle );
	}
	
	UseResFile( thePreviousRefNum );     		// reset back to resource previously set
	
	return theData;
}

/*
 * -addString:type:Id:name:
 *		adds a string to the resource fork as a pascal string
 */
- (BOOL)addString:(NSString *)aString type:(ResType)aType Id:(short)anID name:(NSString *)aName
{
	unsigned int		theLength;

	theLength = [aString length];

	if( theLength < 256 )
	{
		NSMutableData		* theData;

		theData = [NSMutableData dataWithLength:1];
		*((char*)[theData mutableBytes]) = (char)theLength;
		[theData appendData:[aString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
		return [self addData:theData type:aType Id:anID name:aName];
	}
	else
		return NO;
}

/*
 * -stringForType:Id:
 */
- (NSString *)stringForType:(ResType)aType Id:(short)anID
{
	NSData			* theData;

	theData = [self dataForType:aType Id:anID];

	return theData ? [NSString stringWithCString:([theData bytes] + 1) length:[theData length] - 1] : nil;
}

/*
 * removeType: Id:
 */
- (BOOL)removeType:(ResType)aType Id:(short)anID
{
	Handle		theResHandle;
	OSErr			theErr;
	
	UseResFile( fileReference );    			// set this resource to be current

	theResHandle = Get1Resource( aType, anID );
	theErr = ResError( );
	if( theResHandle && theErr == noErr )
	{
		RemoveResource( theResHandle );		// Disposed of in current resource file
		theErr = ResError( );
	}
	return theErr == noErr;
}

@end
