#import "PBDocument+BuildingNotification.h"
#import "NSString+Iceberg.h"
#import "BuildingNotification+Constants.h"

#import "PBPreferencePaneFilesController+Constants.h"

@implementation PBDocument (BuildingNotification)

- (void) builderNotification:(NSNotification *)notification
{
    NSDictionary * tUserInfo;
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
            if ([tNumber intValue]==sProcessID)
            {
                NSString * tPath;
                
                tPath=[tUserInfo objectForKey:@"Project Path"];
                
                if (tPath!=nil)
                {
                    if ([tPath isEqualToString:[self fileName]]==YES)
                    {
                        NSDictionary * tDictionary;
                        NSString * tTitle;
                        int tStatusCode;
                        NSString * tExplanation=@"";
                        NSArray * tArguments;
                        id tFirstArgument=nil;
                        
                        tStatusCode=[[tUserInfo objectForKey:@"Code"] intValue];
                        
                        // This is the document concerned by the Notification
                        
                        tArguments=[tUserInfo objectForKey:@"Arguments"];
                        
                        if (tArguments!=nil &&[tArguments count]>0)
                        {
                            tFirstArgument=[tArguments objectAtIndex:0];
                        }
                        
                        switch(tStatusCode)
                        {
                            case kPBBuildingStart:
                                buildingState_=kPBBuildingStarted;
                                break;
                            
                            case kPBBuildingPackage:
                                tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_PACKAGE,@"No comment"),[tFirstArgument lastPathComponent]];
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                break;
                            case kPBBuildingMetapackage:
                                tTitle=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_METAPACKAGE,@"No comment"),[tFirstArgument lastPathComponent]];
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                
                                break;
                            case kPBBuildingArchive:
                                tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_ARCHIVE,@"No comment");
                                break;
                            case kPBBuildingSplittingForks:
                                tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_SPLITTING_FORKS,@"No comment");
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                break;
                            case kPBBuildingBom:
                                tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_BOM,@"No comment");
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                break;
                            case kPBBuildingPax:
                                tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDING_PAX,@"No comment");
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                                                                  break;
                                
                            case kPBBuildingCopyScripts:
								 tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_SCRIPTS,@"No comment");
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                                                                  break;
							
							case kPBBuildingCopyingPlugins:
								 tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_COPYING_PLUGINS,@"No comment");
                                
                                tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:1],@"Status ID",
                                                                                       nil];
                                                                                       
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:tDictionary];
                                                                                  break;
							
							case kPBBuildingComplete:
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:[NSDictionary dictionary]];
                                buildingState_=kPBBuildingNone;
                                
                                if (launchAfterBuild_==YES)
                                {
                                    // Get the Build location
                                    
                                    NSString * tPath;
                                    
                                    tPath=[[[self projectNode] settings] objectForKey:@"Build Path"];
                                    
                                    if (tPath!=nil)
                                    {
                                        NSWorkspace * tWorkSpace;
                                        PBObjectNode * tObjectNode;
                                        NSString * tName, * tSuffix;
                                        int tType;
                                        NSNumber * tNumber;
                                        
                                        tNumber=[[[self projectNode] settings] objectForKey:@"Build Path Type"];
                                        
                                        if (tNumber!=nil)
                                        {
                                            if ([tNumber intValue]==kRelativeToProjectPath)
                                            {
                                                tPath=[tPath stringByAbsolutingWithPath:[self folder]];
                                            }
                                        }
                                        
                                        // Get the file name
                                        
                                        tWorkSpace=[NSWorkspace sharedWorkspace];
                                        
                                        tObjectNode=[self mainPackageNode];
                                        
                                        tName=[tObjectNode name];
                                        
                                        tType=[tObjectNode type];
                                        
                                        if (tType==0)
                                        {
                                            // Meta
                                            
                                            tSuffix=@".mpkg";
                                        }
                                        else
                                        {
                                            // Package
                                            
                                            tSuffix=@".pkg";
                                        }
                                        
                                        if ([tName hasSuffix:tSuffix]==NO)
                                        {
                                            tName=[tName stringByAppendingString:tSuffix];
                                        }
                                        
                                        [tWorkSpace openFile:[tPath stringByAppendingPathComponent:tName]];
                                    }
                                }
                                
                                break;
                            
                            case kPBErrorUnknown:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_UNKNOWNERROR,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorCantCreateFolder:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_CREATEFOLDER,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorCantCreateFile:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_CREATEFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorCantCopyFile:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_COPYFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent],[[tArguments objectAtIndex:1] lastPathComponent],[[tArguments objectAtIndex:1] stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorCantRemoveFile:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_CANT_REMOVEFILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorFileDoesNotExist:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_FILE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorIncorrectFileType:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_INCORRECT_FILE_TYPE,@"No comment"),[tFirstArgument lastPathComponent],[tFirstArgument stringByDeletingLastPathComponent]];
                                break;
                            case kPBErrorInsufficientPrivileges:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_INSUFFICIENT_PRIVILEGES,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorInsufficientPrivilegesSet:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SET_INSUFFICIENT_PRIVILEGES,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorMissingInformation:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_INFORMATION,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorOutOfMemory:
                                tExplanation=NSLocalizedString(PB_BUILDNOTIFICATION_OUT_OF_MEMORY,@"No comment");
                                break;
                            case kPBErrorPackageSameNames:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_TWIN_COMPONENTS,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorMissingLicenseTemplate:
                                
								if ([tArguments count]>1)
								{
									tExplanation=[NSString stringWithFormat:NSLocalizedString(@"License template (%@): %@ localization is missing.",@"No comment"),tFirstArgument,[tArguments objectAtIndex:1]];
                                }
								else
								{
									if (tFirstArgument==nil)
									{
										tFirstArgument=@"";
									}
									
									tExplanation=[NSString stringWithFormat:NSLocalizedString(@"License template (%@): Missing Template",@"No comment"),tFirstArgument];
								}
								break;
                            case kPBErrorScratchDoesNotExist:
                                tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_MISSING_SCRATCH_FOLDER,@"No comment"),tFirstArgument];
                                break;
                            case kPBErrorMissingSplitForksMissingTool:
								{
									NSString * tToolPath=nil;
									
									if ([tFirstArgument isEqualToString:SPLITFORKSTOOL_GOLDIN]==YES)
									{
										tToolPath=@"/usr/local/bin/goldin";
									}
									else if ([tFirstArgument isEqualToString:SPLITFORKSTOOL_SPLITFORKS]==YES)
									{
										tToolPath=@"/Developer/Tools/SplitForks";
									}
									
									tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_MISSINGTOOL,@"No comment"),tFirstArgument,tToolPath];
								}
								break;
							case kPBErrorMissingSplitForksNonHFSVolume:
								tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_NONHFSVOLUME,@"No comment"),tFirstArgument];
								break;
							case kPBErrorMissingSplitForksError:
								tExplanation=[NSString stringWithFormat:NSLocalizedString(PB_BUILDNOTIFICATION_SPLITFORKS_ERROR,@"No comment"),tFirstArgument];
								break;
								
							case kPBNotificationBuildCancelledUnsavedFile:
								tTitle=NSLocalizedString(PB_BUILDNOTIFICATION_BUILDCANCELLED_UNSAVEDFILE,@"No comment");
								
								tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:4],@"Status ID",
                                                                                       nil];
                                                                                       
								[[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
																					object:self
																				  userInfo:tDictionary];
																					  
								buildingState_=kPBBuildingNone;
								return;
							
							case kPBNotificationCleanBuildSuccess:
								tTitle=NSLocalizedString(@"Clean succeeded",@"No comment");
								
								tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:4],@"Status ID",
                                                                                       nil];
                                                                                       
								[[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
																					object:self
																				  userInfo:tDictionary];
																					  
								buildingState_=kPBBuildingNone;
								return;
							
							case kPBDebugInfo:
                                break;
                            default:
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                    object:self
                                                                                  userInfo:[NSDictionary dictionary]];
                                
                                buildingState_=kPBBuildingNone;
                                break;
                        }
                        
                        if (tStatusCode>=kPBErrorUnknown)
                        {
                            tTitle=[NSString stringWithFormat:NSLocalizedString(@"Build failed / %@",@"No comment"),tExplanation];
                            
                            tDictionary=[NSDictionary dictionaryWithObjectsAndKeys:tTitle,@"Status String",
                                                                                       [NSNumber numberWithInt:4],@"Status ID",
                                                                                       nil];
                                                                                       
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PBDocumentStatusChanged"
                                                                                object:self
                                                                              userInfo:tDictionary];
                                                                                  
                            buildingState_=kPBBuildingNone;
                        }
                    }
                }
            }
        }
    }
}

@end
