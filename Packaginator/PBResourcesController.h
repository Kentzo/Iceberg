/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PBController.h"
#import "PBLicenseProvider.h"

enum
{
    kPBResourcesWelcome,
    kPBResourcesReadMe,
    kPBResourcesLicense
};

@interface PBResourcesController : PBController
{
    int partID_;
    
    IBOutlet id IBimageMode_;
    IBOutlet id IBimagePath_;
    IBOutlet id IBimageAlignment_;
    IBOutlet id IBimageScaling_;
    
    IBOutlet id IBwelcomeLanguage_;
    IBOutlet id IBwelcomeMode_;
    IBOutlet id IBwelcomePath_;
    
    IBOutlet id IBreadMeLanguage_;
    IBOutlet id IBreadMeMode_;
    IBOutlet id IBreadMePath_;
    
    IBOutlet id IBlicenseLanguage_;
    IBOutlet id IBlicenseMode_;
    IBOutlet id IBlicensePopup_;
    IBOutlet id IBlicensePath_;
    IBOutlet id IBlicenseArray_;

    NSString * currentWelcomeLanguage_;
    NSString * currentReadMeLanguage_;
    NSString * currentLicenseLanguage_;
    
    PBLicenseProvider * licensesProvider_;
    
    NSArray * keywords_;
    NSMutableDictionary * values_;
}

+ (PBResourcesController *) resourcesController;


- (IBAction) selectImagePath:(id) sender;
- (void) imageOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (IBAction) revealImageInFinder:(id) sender;
- (IBAction) openImage:(id) sender;

- (IBAction) updateImage:(id) sender;

- (IBAction) selectWelcomePath:(id) sender;
- (void) welcomeOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (IBAction) revealWelcomeInFinder:(id) sender;
- (IBAction) openWelcome:(id) sender;

- (IBAction) switchWelcomeLanguage:(id) sender;
- (IBAction) updateWelcome:(id) sender;
- (void) updateWelcomeLanguage;
- (void) removeWelcomeLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;


- (IBAction) selectReadMePath:(id) sender;
- (void) readMeOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (IBAction) revealReadMeInFinder:(id) sender;
- (IBAction) openReadMe:(id) sender;

- (IBAction) switchReadMeLanguage:(id) sender;
- (IBAction) updateReadMe:(id) sender;
- (void) updateReadMeLanguage;
- (void) removeReadMeLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction) selectLicensePath:(id) sender;
- (void) licenseOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (IBAction) revealLicenseInFinder:(id) sender;
- (IBAction) openLicense:(id) sender;

- (IBAction) switchLicenseTemplate:(id) sender;
- (IBAction) switchLicenseLanguage:(id) sender;
- (IBAction) updateLicense:(id) sender;
- (void) updateLicenseLanguage;
- (void) removeLicenseLocalizationSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

+ (NSDictionary *) cleanDictionary:(NSDictionary *) inDictionary forDocument:(NSDocument *) inDocument
;

- (void) backgroundImageSettingsDidChange:(NSNotification *)notification;

@end
