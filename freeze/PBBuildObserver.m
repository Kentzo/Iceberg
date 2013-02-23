/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBBuildObserver.h"
#import "PBSharedConst.h"

@implementation PBBuildObserver

- (void) setVerbose:(BOOL) inVerbose
{
    verbose_=inVerbose;
}

- (void) processBuildNotification:(NSNotification *) notification
{
    NSDictionary * tUserInfo;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    static int sProcessID=-1;
    
    if (sProcessID==-1)
    {
        sProcessID=[[NSProcessInfo processInfo] processIdentifier];
    }
    
    tUserInfo=[notification userInfo];
    
    if (tUserInfo!=nil)
    {
        NSNumber * tNumber;
        
        tNumber=[tUserInfo objectForKey:@"Process ID"];
        
        if (tNumber!=nil)
        {
            // Check the notification is for us
            
            if ([tNumber intValue]==sProcessID)
            {
                int errorCode;
                id tObject=nil;
                NSArray * tArguments;
                
                tArguments=[tUserInfo objectForKey:@"Arguments"];
                
                if ([tArguments count]>0)
				{
					tObject=[tArguments objectAtIndex:0];
                }
				
                errorCode=[[tUserInfo objectForKey:@"Code"] intValue];
                
                if (errorCode>=kPBErrorUnknown)
                {
                    // An error occured (we always displayed error)
                    
                    (void)fprintf(stderr, "freeze: Build failed / ");
                    
                    switch(errorCode)
                    {
                        case kPBErrorUnknown:
                            (void)fprintf(stderr, "Unknown error\n");
                            break;
                        case kPBErrorCantCreateFolder:
                            (void)fprintf(stderr, "Can't create folder: \"%s\"\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorCantCreateFile:
                            (void)fprintf(stderr, "Can't create file: \"%s\"\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorCantCopyFile:
                            (void)fprintf(stderr, "Can't copy file: \"%s\"\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorCantRemoveFile:
                            (void)fprintf(stderr, "Can't remove file: \"%s\\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorFileDoesNotExist:
                            (void)fprintf(stderr, "File does not exist: \"%s\"\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorIncorrectFileType:
                            (void)fprintf(stderr, "Incorrect file type: \"%s\"\n",[tObject fileSystemRepresentation]);
                            break;
                        case kPBErrorInsufficientPrivileges:
                            (void)fprintf(stderr, "Insufficient privileges\n");
                            break;
                        case kPBErrorInsufficientPrivilegesSet:
                            (void)fprintf(stderr, "Insufficient privileges set\n");
                            break;
                        case kPBErrorMissingInformation:
                            (void)fprintf(stderr, "Missing information (%s)",[tObject UTF8String]);
                            break;
                        case kPBErrorOutOfMemory:
                            (void)fprintf(stderr,"Out of Memory\n");
                            break;
                        case kPBErrorPackageSameNames:
                            (void)fprintf(stderr,"2 components of \"%s\" have the same name: \"%s\"\n",[[tObject stringByDeletingPathExtension] UTF8String],[[[tArguments objectAtIndex:1] stringByDeletingPathExtension] UTF8String]);
                            break;
						case kPBErrorPaxFailed:
							(void)fprintf(stderr,"pax command failed\n");
                            break;
						case kPBErrorBomFailed:
							(void)fprintf(stderr,"mkbom command failed\n");
                            break;
						case kPBErrorCantCleanFolder:
							(void)fprintf(stderr,"Can't clean folder\n");
							break;
						case kPBErrorScratchDoesNotExist:
							(void)fprintf(stderr, "Scratch folder does not exist at  %s",[tObject fileSystemRepresentation]);
							break;
						case kPBErrorMissingLicenseTemplate:
							(void)fprintf(stderr,"Missing license template\n");
							break;
						case kPBErrorMissingSplitForksMissingTool:
							(void)fprintf(stderr,"Missing split forks tool\n");
							break;
						case kPBErrorMissingSplitForksNonHFSVolume:
							(void)fprintf(stderr,"Forks splitting operation tried on a non HFS volume\n");
							break;
						case kPBErrorMissingSplitForksError:
							(void)fprintf(stderr,"Forks splitting operation failed\n");
							break;
					
					}
                    
                    exit(1);
                }
                else
                {
                    if (kPBBuildingComplete==errorCode)
                    {
                        // The build has been successful
                        
                        if (verbose_==YES)
                        {
                            (void)fprintf(stdout, "freeze: Build succeeded\n");
                        }
                    
                        exit(0);
                    }
                    else
                    {
                    	if (verbose_==YES)
                        {
                            NSString * tArgument0;
                            
							tArgument0=tObject;
                            
                            switch(errorCode)
                            {
                                case kPBBuildingPackage:
                                    (void)fprintf(stdout, "freeze: Building package \"%s\"\n",[[tObject lastPathComponent] UTF8String]);
                                    break;
                                case kPBBuildingMetapackage:
                                    (void)fprintf(stdout, "freeze: Building metapackage \"%s\"\n",[[tArgument0 lastPathComponent] UTF8String]);
                                    break;
                                case kPBBuildingArchive:
                                    (void)fprintf(stdout, "freeze: Building files archive hierarchy\n");
                                    break;
                                
                                case kPBBuildingSplittingForks:
                                    (void)fprintf(stdout, "freeze: Splitting forks\n");
                                    break;
                                case kPBBuildingBom:
                                    (void)fprintf(stdout, "freeze: Building .bom bills of material\n");
                                    break;
                                case kPBBuildingPax:
                                    (void)fprintf(stdout, "freeze: Building .pax archive\n");
                                    break;
                                case kPBBuildingCleaning:
                                    (void)fprintf(stdout, "freeze: Cleaning scratch folder\n");
                                    break;
                                case kPBBuildingPreparingBuildFolder:
                                    (void)fprintf(stdout, "freeze: Preparing build folder\n");
                                    break;
                                case kPBBuildingCreateInfoPlist:
                                    (void)fprintf(stdout, "freeze: Creating Info.plist file\n");
                                    break;
                                case kPBBuildingCreateDescriptionPlist:
                                    (void)fprintf(stdout, "freeze: Creating Description.plist files\n");
                                    break;
                                case kPBBuildingCopyBackgroundImage:
                                    (void)fprintf(stdout, "freeze: Copying background image\n");
                                    break;
                                case kPBBuildingCopyWelcomeMessage:
                                    (void)fprintf(stdout, "freeze: Copying welcome message\n");
                                    break;
                                case kPBBuildingBuildRequirements:
                                    (void)fprintf(stdout, "freeze: Building requirements\n");
                                    break;
                                case kPBBuildingCopyScripts:
                                    (void)fprintf(stdout, "freeze: Copying scripts\n");
                                    break;
								case kPBBuildingCopyingPlugins:
									(void)fprintf(stdout, "freeze: Copying plugins\n");
									break;
                                case kPBBuildingCopyAdditionalResources:
                                    (void)fprintf(stdout, "freeze: Copying additional resources\n");
                                    break;
                                case kPBBuildingCreatePackageVersion:
                                    (void)fprintf(stdout, "freeze: Creating package_version file\n");
                                    break;
                                case kPBBuildingCreateTokenDefinitionsPlist:
                                    (void)fprintf(stdout, "freeze: Creating TokensDefinitions.plist file\n");
                                    break;
                                case kPBBuildingCopyingBom:
                                    (void)fprintf(stdout, "freeze: Copying .bom bills of material\n");
                                    break;
                                case kPBBuildingCopyingPax:
                                    (void)fprintf(stdout, "freeze: Copying .pax archive\n");
                                    break;
                            }
                        }
                    }
                }
                
                //NSLog(@"%d %@",[[tUserInfo objectForKey:@"Code"] intValue],[tUserInfo objectForKey:@"Arguments"]);
            }
        }
    }
    
    [pool release];
}

@end
