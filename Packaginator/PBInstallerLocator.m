#import "PBInstallerLocator.h"

@implementation PBInstallerLocator

+ (NSString *) pathForInstaller
{
	NSWorkspace * tWorkspace;
	NSString * tPath;
	
	tWorkspace=[NSWorkspace sharedWorkspace];
	
	tPath=[tWorkspace fullPathForApplication:@"Installer.app"];
	
	if (tPath==nil)
	{
		NSFileManager * tFileManager;
		
		tFileManager=[NSFileManager defaultManager];
		
		tPath=@"/Applications/Utilities/Installer.app";
		
		if ([tFileManager fileExistsAtPath:tPath]==NO)
		{
			tPath=@"/System/Library/CoreServices/Installer.app";
		
			if ([tFileManager fileExistsAtPath:tPath]==NO)
			{
				tPath=nil;
			}
		}
	}
	
	return tPath;
}

@end
