//
//  MylarPrefPane.m
//  MylarPrefPane
//
//  Created by Carlos Barrera on 27/12/14.
//  Copyright (c) 2014 Carlos Barrera. All rights reserved.
//

#import "MylarPrefPane.h"


@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    
    [attrString endEditing];
    
    return attrString;
}
@end

@implementation MylarPrefPane

- (void)mainViewDidLoad
{
    [self updateGuiFromPrefs:[self recoverStoredPreferences] key:kserverIP gui:self.serverIP];
    [self updateGuiFromPrefs:[self recoverStoredPreferences] key:kserverPort gui:self.serverPort];
    [self updateGuiFromPrefs:[self recoverStoredPreferences] key:kMylarLocation gui:self.mylarLocationTextField];
    [self.startStopSpinner setDisplayedWhenStopped:NO];
    [self.testConnectionSpinner setDisplayedWhenStopped:NO];
    [self setHyperlinkWithTextField:self.gitWebPageField];
    [self setHyperlinkWithTextField:self.forumWebPageField];
    [self testConnectionButtonClicked:nil];
}

-(void)willUnselect
{
    [self saveChangesToDefaults];
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if ( ( self = [super initWithBundle:bundle] ) != nil ) {
        appID = CFSTR("edu.barrera.MylarPrefPane");
    }
    
    return self;
}

- (void) saveChangesToDefaults
{
    [self saveNewPreferencesToDefaults:[self guiPreferences]];
}

- (IBAction)preferencesChanged:(id)sender
{
    [self saveChangesToDefaults];
}

- (NSDictionary *)recoverStoredPreferences
{
/*
    We get the stored preferences from NSUserDefaults and pass them on
 */
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMylarPrefPaneSavedPrefs];
}

- (void)saveNewPreferencesToDefaults:(NSDictionary *) prefs
{
/*
    We store our preferences to the nsuserdefaults for later retrieval
 */
    [[NSUserDefaults standardUserDefaults] setObject:prefs forKey:kMylarPrefPaneSavedPrefs];
}


- (NSDictionary *)guiPreferences
{
    /*
     serverIP
     serverPort
     mylarLocation
     *statusLabel*
     
     We construct a NSDictionary from the values in the gui and return it
     
     whenever we add new ui elements, we'll need to update this method
     
     */
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [[self.serverIP stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], kserverIP,
            [[self.serverPort stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], kserverPort,
            [[self.mylarLocationTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], kMylarLocation,
            nil];
}



- (void)updateGuiFromPrefs:(NSDictionary *)prefs key:(NSString *)key gui:(NSTextField *)cell
{
/*
    We update the gui for the given key in the preferences recovered from the nsuserdefaults
 
 */
    // Clean key
    key = [key stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    // Get value from prefs - may not exist
    id value = [prefs objectForKey:key];
    
    // Value exists
    if (value && value != [NSNull null] && [value isKindOfClass:[NSString class]] && [value length] > 0) {
        
        [cell setStringValue:value];
        
        // No value - set blank
    } else {
        [cell setStringValue:@""];
    }
}


//- (void)setGuiPreferences:(NSDictionary *) prefs defaults:(NSDictionary *) defaults {
//    [self updateGuiFromPrefs:prefs key:kserverIP gui:self.serverIP];
//    [self updateGuiFromPrefs:prefs key:kserverPort gui:self.serverPort];
//    [self updateGuiFromPrefs:prefs key:kMylarLocation gui:self.mylarLocationTextField];
//    
//
//}

- (IBAction)goToConfigButtonClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/config", [self serverURL]]]];
}

- (IBAction)locateMylarButtonClicked:(id)sender
{
    // let's open a file open dialog panel
    NSOpenPanel *openDialog = [NSOpenPanel openPanel];
    // create array of file types allowed (py)
    //NSArray * fileTypesArray = [NSArray arrayWithObjects:@"py", nil];
    // enable options in the dialog
    [openDialog setCanChooseFiles:YES];
    [openDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"py", nil]];
    [openDialog setAllowsMultipleSelection:NO];
    
    // Display dialog and process result if ok pressed
    // runmodal deprecated sinc 10.6
//    if ([openDialog runModal] == NSModalResponseOK) {
//        NSArray *files = [openDialog URLs];
//        
//        //Get the path of the file selected and store it in a string
//        NSString * pathString = [[[files lastObject] path] stringByStandardizingPath];
//        //assign it to the textfield
//        [self.mylarLocationTextField setStringValue:pathString];
//        
//    }
    
    // lets do it the new style
    
    [openDialog beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSString * pathString = [[[[openDialog URLs] lastObject] path] stringByStandardizingPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                
            [self.mylarLocationTextField setStringValue:pathString];
            });
        }
    }];
    
    
}

- (IBAction)setupDaemonButtonClicked:(id)sender
{
    //here we communicate with the helper app to install a launchctl plist according to the selected
    NSLog(@"We want to install the daemon for %@",[[self.daemonInstallType selectedItem] title]);
    
 /*     in the future, we'll install the launchd plist needed for good behaviour, meanwhile, we'll try and
        give the user the needed options to configure the proper daemon
        for starters, the whole text of the launchd plist we have already in the resources of the
        project, with the propper substitutions for the actual location of Mylar.py located with a dialog
  
 */
    // for the moment, let's check if the plist exists, and if not, try to create it
    NSURL * testURL = [self plistURL];

    BOOL test = [[NSFileManager defaultManager] fileExistsAtPath:[testURL path]];
    if (test) {
        NSLog(@"There is a plist at %@", testURL );
        //[self.debugLogOut setString:[NSString stringWithFormat:@"There is a plist at %@",[testURL path]]];
    } else {
        NSLog(@"There is no plist at %@", testURL );
        //[self.debugLogOut setString:[NSString stringWithFormat:@"There is no plist at %@",[testURL path]]];
    }
    
/*
    If we want to install the new plis, we'll need to first create the plist, and then start it up
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 
 <key>Label</key>
 <string>com.mylar.mylar</string>
 
 <key>ProgramArguments</key>
 <array>
 <string>/usr/bin/python2.7</string>
 <string>/Applications/Mylar/Mylar.py</string>
 <string>-q</string>
 </array>
 
 <key>RunAtLoad</key>
 <true/>
 
 <key>KeepAlive</key>
 <false/>
 </dict>
 </plist>

 
 We start by doing the single user step, because the all users step will need privilege escalation and that will lead to the helper app
 */
#pragma mark Let's define the parameters of our plist
    
    NSString *label = @"com.mylar.mylar";
    NSArray *programArguments = [NSArray arrayWithObjects:@"/usr/bin/python2.7", self.mylarLocationTextField.stringValue, @"-q", nil];
    NSNumber * runAtLoad = [NSNumber numberWithBool:YES];
    NSNumber * keepAlive = [NSNumber numberWithBool:NO];
 
    NSArray * objects = [NSArray arrayWithObjects:label, programArguments, runAtLoad, keepAlive, nil];
    //NSLog(objects.description);
    NSArray * keys = [NSArray arrayWithObjects:@"Label", @"ProgramArguments", @"RunAtLoad", @"KeepAlive", nil];
    // NSLog(keys.description);
    NSDictionary *mylarConfig = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    // [self.debugLogOut setString:[mylarConfig description]];
    
    [self saveAsXML:mylarConfig atPath:testURL];
    
}
- (NSURL*) plistURL
    {
        // are we searching for this user or for all?
        NSString * base = @"";
        if ([self.daemonInstallType.selectedItem.title containsString:@"This user only"]) {
            // [self.debugLogOut setString:[NSString stringWithFormat:@"We're trying a install for %@", self.daemonInstallType.selectedItem.title]];
            // if just for this user, we add the ~ to latter expand it and go to the correct domain
            base = @"~";
        } else {
            //  [self.debugLogOut setString:[NSString stringWithFormat:@"We're trying a install for %@", self.daemonInstallType.selectedItem.title]];
            //base = @"";
        }
        
        //base = @"test";
        NSURL * theURL = [NSURL URLWithString:[[base stringByAppendingString:@"/Library/LaunchAgents/com.mylar.mylar.plist" ] stringByExpandingTildeInPath]];
        NSLog(@"");
        return theURL;
        
    }
- (void) saveAsXML: (id) thePlist atPath:(NSURL*) thePath{

    if (![NSPropertyListSerialization propertyList:thePlist isValidForFormat:NSPropertyListXMLFormat_v1_0]) {
        NSLog(@"Invalid xml format");
        return;
        //invalid xml format
    }
    NSError * error;
    NSData *data =
    [NSPropertyListSerialization dataWithPropertyList:thePlist format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (data ==nil) {
        NSLog(@"error serializing");
        //error serializing
        return;
    }
    
    BOOL writeStatus = [data writeToFile:[thePath path]  options:NSDataWritingAtomic error:&error];
    
    if (!writeStatus){
        NSLog(@"Unable to write the plist due to error : %@",error);
        return;
        //error writing the file
    }
    NSLog(@"plist written ok!");
}

- (NSString*) serverURL
{
    return     [NSString stringWithFormat:@"http://%@:%@/", [self.serverIP stringValue],[self.serverPort stringValue]];

}

- (IBAction)testConnectionButtonClicked:(id)sender
{
    [self.testConnectionSpinner startAnimation:self];
    self.statusLabel.stringValue = @"";
    NSString *theAddress = [self serverURL];

    //[self.debugLogOut isRichText];
    
    //[self.debugLogOut setString:theAddress];

    NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@home",theAddress ]];
    NSLog(@"we create the url: %@", theURL);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:theURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSLog(@"We send the async request");
        NSString *theResponseAsync =        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSUInteger identifierLocation = [theResponseAsync rangeOfString:@"<title>Mylar - Home</title>"].location;

        // we are working in a block so when we manipulate UI, we go back to main queue
        if (identifierLocation != NSNotFound){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Did contain the Mylar header");
                // [self.debugLogOut setString:theResponseAsync];
                self.statusLabel.stringValue = @"Online";
                [self.startStopButton setTitle:@"Stop"];
                [self.testConnectionSpinner stopAnimation:self];
            }
                           );
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Didn't contain the Mylar header");
                    // [self.debugLogOut setString:@"La cagamos"];
                    self.statusLabel.stringValue = @"Offline";
                    [self.startStopButton setTitle:@"Start"];
                    [self.testConnectionSpinner stopAnimation:self];
                }
                    );
            }
    }];
    // Task created, let's start it up
    [task resume];
    
}

- (IBAction)startStopServer:(id)sender
{
    // first let's see if we have already a plist installed
    
    BOOL plistInstalled = [[NSFileManager defaultManager] fileExistsAtPath:[[self plistURL] path]];
    NSLog(@"Is there a plist at? :%@", [self plistURL]);
    
    if (!plistInstalled) {
        NSLog(@"couldn't find the plist");
    }
    NSLog(@"Yes there is, let's use it for our server");
    [self.testConnectionSpinner startAnimation:self];
    NSString * previousStatus = self.statusLabel.stringValue;
    self.statusLabel.stringValue=@"";
    // update status of the server
    //[self testConnectionButtonClicked:self];
    
    //Once we have created the required plist in the required library, we try to load it unto launchd
    
    // launchctl unload "pathToPlist"
    // launchctl load "pathToPlist"
    
    // and voila, the service is ready to go
    NSString * launchCTTL = @"/bin/launchctl";
    NSString * command = @"unload";
    NSString * pathToPlist = [[self plistURL]path];
    
    NSTask * unloadTask = [[NSTask alloc] init];
    
    unloadTask.launchPath = launchCTTL;
    unloadTask.arguments = [NSArray arrayWithObjects:command, pathToPlist, nil];
    [unloadTask launch];
    
    [unloadTask waitUntilExit];
    NSLog(@"finished unloading daemon");
    
    // if we came from an offline mode, we start up the server
    if ([previousStatus containsString:@"Off"]) {
        
        NSTask * loadTask = [[NSTask alloc] init];
        command = @"load";
        
        loadTask.launchPath = launchCTTL;
        loadTask.arguments = [NSArray arrayWithObjects:command, pathToPlist, nil];
        [loadTask launch];
        
        [loadTask waitUntilExit];
        
        NSLog(@"finished loading daemon");
    }
    
    // clumsy, but to be improved
    sleep(2);
    //wait for the server to initialize and update status signals in ui
    [self.startStopSpinner stopAnimation:self];
    [self testConnectionButtonClicked:self];
    
    
    // in case we are installing it as a /Library service, the plot thickens...
    // to be continued

}

- (IBAction)goToWebPage:(NSTextField *)sender {
    NSURL * theURL = [NSURL URLWithString:sender.stringValue];
    
    [[NSWorkspace sharedWorkspace] openURL:theURL];
    
}

-(void)setHyperlinkWithTextField:(NSTextField*)inTextField
{
    // both are needed, otherwise hyperlink won't accept mousedown
    [inTextField setAllowsEditingTextAttributes: YES];
    [inTextField setSelectable: YES];
    
    NSURL* url = [NSURL URLWithString:inTextField.stringValue];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:inTextField.stringValue withURL:url]];
    
    // set the attributed string to the NSTextField
    [inTextField setAttributedStringValue: string];
    
}

@end
