/*
Copyright (c) 2004-2005, Stéphane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import "PBProjectAssistantEngine.h"
#import "PBProjectAssistantPaneController.h"

@interface PBProjectAssistantController : NSObject
{
    NSFileManager * fileManager_;
    NSBundle * pluginBundle_;
    
    PBProjectAssistantEngine * assistantEngine_;
    
    IBOutlet id IBwindow_;
    
    IBOutlet id IBassistantProjectType_;
    
    IBOutlet id IBpreviousButton_;
    IBOutlet id IBnextButton_;
    
    id currentRelativeRootView_;
    int currentPaneIndex_;
    
    IBOutlet id startPaneController_;
    IBOutlet id stopPaneController_;
    
    PBProjectAssistantPaneController * currentPaneController_;
    
    NSMutableArray * projectAssistantInfoArray_;
    NSMutableArray * projectAssistantControllerArray_;
}

+ (id) sharedProjectAssistantController;

- (void) createNewProject;

- (void) processPaneController:(PBProjectAssistantPaneController *) inPaneController withEngine:(id) inEngine;

- (PBProjectAssistantPaneController *) paneControllerAtIndex:(int) inIndex;

-(IBAction) cancel:(id) sender;

-(IBAction) next:(id) sender;

-(IBAction) previous:(id) sender;

-(void) finishSetUp:(id) sender;

- (void) setEnableNextButton:(BOOL) aBool;


@end
