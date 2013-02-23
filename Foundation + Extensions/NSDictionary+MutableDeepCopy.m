#import "NSDictionary+MutableDeepCopy.h"

@implementation NSDictionary (WBMutableDeepCopy)

- (id) mutableDeepCopy
{
	NSData * tData;
	NSString * tErrorString;
	
	tData=[NSPropertyListSerialization dataFromPropertyList:self
													 format:NSPropertyListXMLFormat_v1_0
										   errorDescription:&tErrorString];
	
	if (tData!=nil)
	{
		NSMutableDictionary * tMutableDictionary;
		NSPropertyListFormat tFormat;
		
		tMutableDictionary=(NSMutableDictionary *) [NSPropertyListSerialization propertyListFromData:tData
															mutabilityOption:NSPropertyListMutableContainersAndLeaves
																	  format:&tFormat
															errorDescription:&tErrorString];
	
		if (tMutableDictionary==nil)
		{
			NSLog(@"[NSDictionary mutableDeepCopy] : %@",tErrorString);
		
			[tErrorString release];
		}
		
		return [tMutableDictionary retain];
	}
	else
	{
		NSLog(@"[NSDictionary mutableDeepCopy] : %@",tErrorString);
		
		[tErrorString release];
	}
	
	return nil;
}

@end
