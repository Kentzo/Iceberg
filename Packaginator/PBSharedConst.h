/*
Copyright (c) 2004-2006, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

enum
{
    kPBBuildingPackage,
    kPBBuildingMetapackage,

    kPBBuildingArchive,
    kPBBuildingSplittingForks,
    kPBBuildingStart,
    kPBBuildingComplete,
    kPBBuildingBom,			/* Creating .bom file */
    kPBBuildingPax,			/* Creating pax archive */
    kPBBuildingCleaning,		/* Cleaning working directory */
    
    kPBDebugInfo,
    
    kPBBuildingComponentSucceeded,
    kPBBuildingPreparingBuildFolder,
    kPBBuildingCreateInfoPlist,
    kPBBuildingCreateDescriptionPlist,
    kPBBuildingCopyBackgroundImage,
    kPBBuildingCopyWelcomeMessage,
    kPBBuildingCopyReadMeMessage,
    kPBBuildingBuildRequirements,
    kPBBuildingCopyScripts,
    kPBBuildingCopyAdditionalResources,
    kPBBuildingCreatePackageVersion,		//
    kPBBuildingCreateTokenDefinitionsPlist,	//
    kPBBuildingCopyingBom,
    kPBBuildingCopyingPax,
	kPBBuildingCopyingPlugins,
    kPBBuildingCopyLicenseDocuments,
	
    kPBErrorUnknown=1024,
    kPBErrorCantCreateFolder,
    kPBErrorCantCreateFile,
    kPBErrorCantCopyFile,
    kPBErrorCantRemoveFile,
    kPBErrorFileDoesNotExist,
    kPBErrorIncorrectFileType,
    kPBErrorInsufficientPrivileges,
    kPBErrorInsufficientPrivilegesSet,
    kPBErrorMissingInformation,
    kPBErrorOutOfMemory,
    kPBErrorPackageSameNames,
    kPBErrorPaxFailed,
    kPBErrorBomFailed,
    kPBErrorCantCleanFolder,
    kPBErrorScratchDoesNotExist,
    kPBErrorMissingLicenseTemplate,
    kPBErrorCantWriteFile,
    kPBErrorFolderDoesNotExist,
	kPBErrorMissingSplitForksMissingTool,
	kPBErrorMissingSplitForksNonHFSVolume,
	kPBErrorMissingSplitForksError,
	
	kPBNotifiicationUnknown=4096,
	
	kPBNotificationBuildCancelledUnsavedFile,
	
	kPBNotificationCleanBuildSuccess
};

enum
{
    kNoNode=-3,
    kRootNode,
    kProjectNode,
    kPBMetaPackageNode,
    kPBPackageNode,
    kSettingsNode,
    kComponentsNode,
    kFilesNode,
    kResourcesNode,
    kScriptsNode,
	kPluginsNode
};

enum
{
    kObjectUnselected=-1,
    kObjectSelected,
    kObjectRequired
};

enum
{
    kName,
    kGlobalPath,
    kRelativeToProjectPath
};

enum
{
	kPluginDefaultStep,
	kPluginCustomizedStep
};

enum
{
    kFileRootNode,
    kBaseNode,
    kNewFolderNode,
    kRealItemNode
};

#define IFPkgDescriptionDeleteWarning		@"IFPkgDescriptionDeleteWarning"
#define IFPkgDescriptionDescription		@"IFPkgDescriptionDescription"
#define IFPkgDescriptionTitle 			@"IFPkgDescriptionTitle"
#define IFPkgDescriptionVersion 		@"IFPkgDescriptionVersion"

#define IFMajorVersion				@"IFMajorVersion"
#define IFMinorVersion				@"IFMinorVersion"
#define IFPkgFlagComponentDirectory		@"IFPkgFlagComponentDirectory"
#define IFPkgFlagPackageList			@"IFPkgFlagPackageList"
#define IFPkgFlagPackageLocation		@"IFPkgFlagPackageLocation"
#define IFPkgFlagPackageSelection		@"IFPkgFlagPackageSelection"

#define IFPkgFormatVersion			@"IFPkgFormatVersion"

#define IFPkgBuildDate				@"IFPkgBuildDate"
#define IFPkgBuildVersion			@"IFPkgBuildVersion"

#define IFPkgCreator				@"IFPkgCreator"

#define IFPkgFlagInstalledSize			@"IFPkgFlagInstalledSize"

#define IFPkgFlagBackgroundScaling		@"IFPkgFlagBackgroundScaling"
#define IFPkgFlagBackgroundAlignment 		@"IFPkgFlagBackgroundAlignment"

#define IFPkgFlagAllowBackRev			@"IFPkgFlagAllowBackRev"
#define IFPkgFlagAuthorizationAction		@"IFPkgFlagAuthorizationAction"
#define IFPkgFlagDefaultLocation		@"IFPkgFlagDefaultLocation"
#define IFPkgFlagFollowLinks			@"IFPkgFlagFollowLinks"
#define IFPkgFlagInstallFat			@"IFPkgFlagInstallFat"
#define IFPkgFlagIsRequired			@"IFPkgFlagIsRequired"
#define IFPkgFlagOverwritePermissions		@"IFPkgFlagOverwritePermissions"
#define IFPkgFlagRelocatable			@"IFPkgFlagRelocatable"
#define IFPkgFlagRestartAction			@"IFPkgFlagRestartAction"
#define IFPkgFlagRootVolumeOnly			@"IFPkgFlagRootVolumeOnly"
#define IFPkgFlagUpdateInstalledLanguages	@"IFPkgFlagUpdateInstalledLanguages"

#define IFRequirementDicts			@"IFRequirementDicts"

#define IFPkgPathMappings			@"IFPkgPathMappings"

#define IFInstallationScriptsPreflight		@"IFInstallationScriptsPreflight"
#define IFInstallationScriptsPreinstall		@"IFInstallationScriptsPreinstall"
#define IFInstallationScriptsPreupgrade		@"IFInstallationScriptsPreupgrade"
#define IFInstallationScriptsPostinstall	@"IFInstallationScriptsPostinstall"
#define IFInstallationScriptsPostupgrade	@"IFInstallationScriptsPostupgrade"
#define IFInstallationScriptsPostflight		@"IFInstallationScriptsPostflight"