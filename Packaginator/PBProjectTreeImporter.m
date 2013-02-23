/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBProjectTreeImporter.h"
#import "PBSharedConst.h"
#import <MOKit/MOKit.h>

#include <sys/stat.h>

@implementation PBProjectTreeImporter

+ (NSMutableDictionary *) importInstallationScriptsAtPath:(NSString *) inPath forOldPackage:(NSString *) inPackageName
{
    NSArray * tInstallationScriptsArray;
    NSMutableDictionary * tInstallationDictionary;
    int i,tCount;
    NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    tInstallationScriptsArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"preflight",@"Component path",
                                                                                                    IFInstallationScriptsPreflight,@"Component ID",
                                                                                                       nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.pre_install",inPackageName],@"Component path",
                                                                                                    IFInstallationScriptsPreinstall,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.pre_upgrade",inPackageName],@"Component path",
                                                                                                    IFInstallationScriptsPreupgrade,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.post_install",inPackageName],@"Component path",
                                                                                                    IFInstallationScriptsPostinstall,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@.post_upgrade",inPackageName],@"Component path",
                                                                                                    IFInstallationScriptsPostupgrade,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"postflight",@"Component path",
                                                                                                    IFInstallationScriptsPostflight,@"Component ID",
                                                                                                    nil],
                                                        nil];
        
    tCount=[tInstallationScriptsArray count];
    
    tInstallationDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tPath;
        BOOL isDirectory;
        BOOL tStatus=YES;
        
        tPath=[inPath stringByAppendingPathComponent:[[tInstallationScriptsArray objectAtIndex:i] objectForKey:@"Component path"]];
        
        if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==NO || isDirectory==YES)
        {
            tPath=@"";
            tStatus=NO;
        }
        
        [tInstallationDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:tStatus],@"Status",
                                                                                      tPath,@"Path",
                                                                                      nil]
                                    forKey:[[tInstallationScriptsArray objectAtIndex:i] objectForKey:@"Component ID"]];
    }
    
    return tInstallationDictionary;
}

+ (NSMutableDictionary *) importInstallationScriptsAtPath:(NSString *) inPath
{
    NSArray * tInstallationScriptsArray;
    NSMutableDictionary * tInstallationDictionary;
    int i,tCount;
    NSFileManager * tFileManager;
    
    tFileManager=[NSFileManager defaultManager];
    
    tInstallationScriptsArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"preflight",@"Component path",
                                                                                                    IFInstallationScriptsPreflight,@"Component ID",
                                                                                                       nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"preinstall",@"Component path",
                                                                                                    IFInstallationScriptsPreinstall,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"preupgrade",@"Component path",
                                                                                                    IFInstallationScriptsPreupgrade,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"postinstall",@"Component path",
                                                                                                    IFInstallationScriptsPostinstall,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"postupgrade",@"Component path",
                                                                                                    IFInstallationScriptsPostupgrade,@"Component ID",
                                                                                                    nil],
                                                        [NSDictionary dictionaryWithObjectsAndKeys:@"postflight",@"Component path",
                                                                                                    IFInstallationScriptsPostflight,@"Component ID",
                                                                                                    nil],
                                                        nil];
        
    tCount=[tInstallationScriptsArray count];
    
    tInstallationDictionary=[NSMutableDictionary dictionaryWithCapacity:tCount];
    
    for(i=0;i<tCount;i++)
    {
        NSString * tPath;
        BOOL isDirectory;
        BOOL tStatus=YES;
        
        tPath=[inPath stringByAppendingPathComponent:[[tInstallationScriptsArray objectAtIndex:i] objectForKey:@"Component path"]];
        
        if ([tFileManager fileExistsAtPath:tPath isDirectory:&isDirectory]==NO || isDirectory==YES)
        {
            tPath=@"";
            tStatus=NO;
        }
        
        [tInstallationDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:tStatus],@"Status",
                                                                                      tPath,@"Path",
                                                                                      nil]
                                    forKey:[[tInstallationScriptsArray objectAtIndex:i] objectForKey:@"Component ID"]];
    }
    
    return tInstallationDictionary;
}

+ (NSMutableArray *) importExceptions
{
    static NSMutableArray * sImportExceptions=nil;
    
    if (sImportExceptions==nil)
    {
        NSArray * tArray;
        
        tArray=[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Import Exceptions" ofType:@"plist"]];
    
        if (tArray!=nil)
        {
            int i,tCount;
            
            tCount=[tArray count];
            
            sImportExceptions=[[NSMutableArray alloc] initWithCapacity:tCount];
            
            for(i=0;i<tCount;i++)
            {
                MORegularExpression * tRegularExpression;
                
                tRegularExpression=[MORegularExpression regularExpressionWithString:[tArray objectAtIndex:i]];
                
                if (tRegularExpression!=nil)
                {
                    [sImportExceptions addObject:tRegularExpression];
                }
            }
        }
    }
    
    return sImportExceptions;
}

+ (BOOL) canImportFileComponent:(NSString *) inComponent
{
    NSMutableArray * tExceptionArray;
    int i,tCount;
    
    tExceptionArray=[PBProjectTreeImporter importExceptions];
    
    tCount=[tExceptionArray count];
    
    for(i=0;i<tCount;i++)
    {
        if ([[tExceptionArray objectAtIndex:i] matchesString:inComponent]==YES)
        {
            return NO;
        }
    }
    
    return YES;
}

+ (NSMutableDictionary *) importAdditionalResourcesAtPath:(NSString *) inPath
{
    NSMutableDictionary * tMutableAdditionalResources;
    NSMutableArray * tMutableInternationalArray;

    tMutableAdditionalResources=[NSMutableDictionary dictionary];
    
    tMutableInternationalArray=[NSMutableArray array];
    
    if ([inPath length]>0)
    {
        NSFileManager * tFileManager;
        NSArray * tResourcesContent;
        int i,tCount;
        NSMutableDictionary * tAdditionalFileObject;
    
        tFileManager=[NSFileManager defaultManager];
        
        tResourcesContent=[tFileManager directoryContentsAtPath:inPath];
        
        tCount=[tResourcesContent count];
        
        for(i=0;i<tCount;i++)
        {
            NSString * tComponent;
            NSString * tPath;
            struct stat tStat;
            
            tComponent=[tResourcesContent objectAtIndex:i];
            
            tPath=[inPath stringByAppendingPathComponent:tComponent];
            
            // Check the kind of file object we're dealing with
                    
            if (lstat([tPath fileSystemRepresentation], &tStat)==0)
            {
                switch((tStat.st_mode & S_IFMT))
                {
                    case S_IFLNK:
                        // Symbolic Link, we don't care
                        break;
                    case S_IFDIR:
                        // Folder, we need to check whether it's a .lproj folder or not
                        
                        if ([tComponent hasSuffix:@".lproj"]==YES)
                        {
                            // Localization folder
                            
                            NSArray * subFolderContent;
                            
                            int j,tSubCount;
                            NSString * tLanguage;
                            
                            tLanguage=[tComponent stringByDeletingPathExtension];
                            
                            subFolderContent=[tFileManager directoryContentsAtPath:tPath];
                            
                            tSubCount=[subFolderContent count];
                            
                            if (tSubCount>0)
                            {
                                NSMutableArray * tLocalizedArray;
                                NSString * tSubComponent;
                                
                                tLocalizedArray=[NSMutableArray arrayWithCapacity:tSubCount];
                                
                                for(j=0;j<tSubCount;j++)
                                {
                                    tSubComponent=[subFolderContent objectAtIndex:j];
                                    
                                    if ([PBProjectTreeImporter canImportFileComponent:tSubComponent]==YES)
                                    {
                                        tAdditionalFileObject=[NSMutableDictionary dictionaryWithObjectsAndKeys:[tPath stringByAppendingPathComponent:tSubComponent],@"Path",
                                                                                                                [NSNumber numberWithBool:YES],@"Status",
                                                                                                                nil];
                            
                                        [tLocalizedArray addObject:tAdditionalFileObject];
                                    }
                                }
                                
                                if ([tLocalizedArray count]>0)
                                {
                                    [tMutableAdditionalResources setObject:tLocalizedArray forKey:tLanguage];
                                }
                            }
                            
                            break;
                        }
                    default:
                        // File, we need to check if it's not an exception
                        
                        if ([PBProjectTreeImporter canImportFileComponent:tComponent]==YES)
                        {
                            tAdditionalFileObject=[NSMutableDictionary dictionaryWithObjectsAndKeys:tPath,@"Path",
                                                                                                    [NSNumber numberWithBool:YES],@"Status",
                                                                                                    nil];
                            
                            [tMutableInternationalArray addObject:tAdditionalFileObject];
                        }
                        break;
                }
            }
        }
    }
    
    [tMutableAdditionalResources setObject:tMutableInternationalArray forKey:@"International"];
    
    return tMutableAdditionalResources;
}

#pragma mark -

+ (NSString *) bagroundImageAtPath:(NSString *) inPath
{
    if ([inPath length]>0)
    {
        // Look for the Background Image
                    
        NSFileManager * tFileManager;
        NSArray * tArray;
        
        tFileManager=[NSFileManager defaultManager];
        
        tArray=[tFileManager directoryContentsAtPath:inPath];
        
        if (tArray!=nil)
        {
            NSEnumerator * tEnumerator;
            NSString * tFileName;
            
            tEnumerator=[tArray objectEnumerator];
            
            while (tFileName=[tEnumerator nextObject])
            {
                if ([tFileName hasPrefix:@"background"]==YES)
                {
                    NSString * tExtension;
                    NSArray * tAllowedExtension=[NSArray arrayWithObjects:@"jpg",
                                                                            @"tif",
                                                                            @"tiff",
                                                                            @"gif",
                                                                            @"pict",
                                                                            @"eps",
                                                                            @"pdf",
                                                                            nil];
                                                                        
                    tExtension=[tFileName pathExtension];
                    
                    if ([tAllowedExtension containsObject:tExtension]==YES)
                    {
                        if ([tFileName isEqualToString:[@"background" stringByAppendingPathExtension:tExtension]]==YES)
                        {
                            return [inPath stringByAppendingPathComponent:tFileName];
                        }
                    }
                }
            }
        }
    }
        
    return nil;
}

+ (NSMutableDictionary *) importPartialDocumentsAtPath:(NSString *) inPath
{
    NSMutableDictionary * tDocumentsDictionary;
    
    tDocumentsDictionary=[NSMutableDictionary dictionary];
    
    if (tDocumentsDictionary!=nil)
    {
        NSMutableDictionary * tWelcomeDictionary;
        NSMutableDictionary * tReadMeDictionary;
        NSMutableDictionary * tLicenseDictionary;
        NSFileManager * tFileManager;
        NSArray * tArray;
		
        tWelcomeDictionary=[NSMutableDictionary dictionary];
        tReadMeDictionary=[NSMutableDictionary dictionary];
        tLicenseDictionary=[NSMutableDictionary dictionary];
    
        if ([inPath length]>0)
        {
            tFileManager=[NSFileManager defaultManager];
        
            tArray=[tFileManager directoryContentsAtPath:inPath];
        
            if (tArray!=nil)
            {
                NSEnumerator * tEnumerator;
                NSString * tFileName;
                NSArray * tAllowedExtensions;
                
                tAllowedExtensions=[NSArray arrayWithObjects:@"rtf",@"txt",@"html",@"rtfd",nil];
                
                tEnumerator=[tArray objectEnumerator];
            
                while (tFileName=[tEnumerator nextObject])
                {
                    NSString * tExtension;
                    NSString * tShortedComponent;
                    NSString * tLocalizedPath;
                        
                    tExtension=[tFileName pathExtension];
                    
                    if ([tAllowedExtensions containsObject:tExtension]==YES)
                    {
                        tShortedComponent=[tFileName stringByDeletingPathExtension];
                
                        if ([tShortedComponent isEqualToString:@"Welcome"]==YES)
                        {
                            tLocalizedPath=[inPath stringByAppendingPathComponent:tFileName];
                            
                            [tWelcomeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                    tLocalizedPath,@"Path",
                                                                                                    nil]
                                                forKey:@"International"];
                        }
                        else
                        if ([tShortedComponent isEqualToString:@"ReadMe"]==YES)
                        {
                            tLocalizedPath=[inPath stringByAppendingPathComponent:tFileName];
                            
                            [tReadMeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                    tLocalizedPath,@"Path",
                                                                                                    nil]
                                                forKey:@"International"];
                        }
                        else
                        if ([tShortedComponent isEqualToString:@"License"]==YES)
                        {
                            tLocalizedPath=[inPath stringByAppendingPathComponent:tFileName];
                            
                            [tLicenseDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                    tLocalizedPath,@"Path",
                                                                                                    nil]
                                                forKey:@"International"];
                        }
                    }
                    else
                    {
                        if ([tExtension isEqualToString:@"lproj"]==YES)
                        {
                            NSArray * tLocalizedArray;
                            NSString * tLocalizedComponent;
                            NSString * tLocalizationFolderPath;
                            NSString * tLanguageName;
                            NSEnumerator * tLocalizedEnumerator;
                            
                            tLocalizationFolderPath=[inPath stringByAppendingPathComponent:tFileName];
                            
                            tLocalizedArray=[tFileManager directoryContentsAtPath:tLocalizationFolderPath];
                    
                            tLocalizedEnumerator=[tLocalizedArray objectEnumerator];
                            
                            tLanguageName=[tFileName stringByDeletingPathExtension];
                            
                            while (tLocalizedComponent=[tLocalizedEnumerator nextObject])
                            {
                                tExtension=[tLocalizedComponent pathExtension];
                                
                                if ([tAllowedExtensions containsObject:tExtension]==YES)
                                {
                                
                                    tShortedComponent=[tLocalizedComponent stringByDeletingPathExtension];
                            
                                    if ([tShortedComponent isEqualToString:@"Welcome"]==YES)
                                    {
                                        tLocalizedPath=[tLocalizationFolderPath stringByAppendingPathComponent:tLocalizedComponent];
                                        
                                        [tWelcomeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                                tLocalizedPath,@"Path",
                                                                                                                nil]
                                                            forKey:tLanguageName];
                                    }
                                    else
                                    if ([tShortedComponent isEqualToString:@"ReadMe"]==YES)
                                    {
                                        tLocalizedPath=[tLocalizationFolderPath stringByAppendingPathComponent:tLocalizedComponent];
                                        
                                        [tReadMeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                                tLocalizedPath,@"Path",
                                                                                                                nil]
                                                            forKey:tLanguageName];
                                    }
                                    else
                                    if ([tShortedComponent isEqualToString:@"License"]==YES)
                                    {
                                        tLocalizedPath=[tLocalizationFolderPath stringByAppendingPathComponent:tLocalizedComponent];
                                        
                                        [tLicenseDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kGlobalPath],@"Mode",
                                                                                                                tLocalizedPath,@"Path",
                                                                                                                nil]
                                                            forKey:tLanguageName];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if ([tWelcomeDictionary objectForKey:@"International"]==nil)
        {
            [tWelcomeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                                                     @"",@"Path",
                                                                                     nil]
                                   forKey:@"International"];
        }
        
        if ([tReadMeDictionary objectForKey:@"International"]==nil)
        {
            [tReadMeDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                                                    @"",@"Path",
                                                                                    nil]
                                  forKey:@"International"];
        }
        
        if ([tLicenseDictionary objectForKey:@"International"]==nil)
        {
            [tLicenseDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"Mode",
                                                                                     @"",@"Path",
                                                                                     nil]
                                   forKey:@"International"];
        }

        [tDocumentsDictionary setObject:tWelcomeDictionary forKey:@"Welcome"];
        
        [tDocumentsDictionary setObject:tReadMeDictionary forKey:@"ReadMe"];
        
        [tDocumentsDictionary setObject:tLicenseDictionary forKey:@"License"];
    
    }

    return tDocumentsDictionary;
}

@end
