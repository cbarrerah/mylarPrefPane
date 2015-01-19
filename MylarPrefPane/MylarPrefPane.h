//
//  MylarPrefPane.h
//  MylarPrefPane
//
//  Created by Carlos Barrera on 27/12/14.
//  Copyright (c) 2014 Carlos Barrera. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <Foundation/Foundation.h>

//#import <ServiceManagement/ServiceManagement.h>

//#import "PGPrefsUtilities.h"


#define kMinServerResponseLength 300
#define kMylarPrefPaneSavedPrefs @"MylarPrefPaneTestMessage"

#define kserverIP @"serverIP"
#define kserverPort @"serverPort"
#define kMylarLocation @"MylarPyLocation"

// Minimum length of a correct response from our server (length of an empty fresh install)
// used to diferentiate between an offline or online server status.


@interface MylarPrefPane : NSPreferencePane
{
    CFStringRef appID;
    BOOL    *serverState;
}

@property (weak) IBOutlet NSTextField *serverIP;
@property (weak) IBOutlet NSTextField *serverPort;
@property (weak) IBOutlet NSTextField *statusLabel;
//@property (weak) IBOutlet NSPopUpButton *daemonInstallType;
@property (weak) IBOutlet NSTextField *mylarLocationTextField;

@property (unsafe_unretained) IBOutlet NSPopUpButton *daemonInstallType;

@property (unsafe_unretained) IBOutlet NSButtonCell *startStopButton;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *startStopSpinner;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *testConnectionSpinner;
@property (unsafe_unretained) IBOutlet NSTextField *gitWebPageField;
@property (unsafe_unretained) IBOutlet NSTextField *forumWebPageField;

//@property (unsafe_unretained) IBOutlet NSTextView *debugLogOut;

- (NSDictionary *)recoverStoredPreferences;

- (void)saveNewPreferencesToDefaults:(NSDictionary *) prefs;

- (IBAction)goToConfigButtonClicked:(id)sender;
- (IBAction)locateMylarButtonClicked:(id)sender;

- (IBAction)setupDaemonButtonClicked:(id)sender;
- (IBAction)testConnectionButtonClicked:(id)sender;

- (id)initWithBundle:(NSBundle *)bundle;

- (void)preferencesChanged:(id)sender;

- (IBAction)startStopServer:(id)sender;

- (IBAction)goToWebPage:(NSTextField *)sender;

@end
