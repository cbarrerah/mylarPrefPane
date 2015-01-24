//
//  PlistHandler.m
//  PlistHandler
//
//  Created by Carlos Barrera on 24/1/15.
//  Copyright (c) 2015 Carlos Barrera. All rights reserved.
//

#import "PlistHandler.h"
#import "PlistHandlerProtocol.h"

@implementation PlistHandler

-(void) writePlist:(NSDictionary*)plistContent
            toPath:(NSString*)destinationPath
         withReply:(void(^)(NSString *))reply
{
    
    //    NSLog(@"executing writeplist from xpc service");
    
    /*
     If we are writing to our user zone
     */
    [self saveAsXML:plistContent atPath:[NSURL URLWithString:destinationPath]];
    
    // and it's done
    //    NSString *result=[NSString stringWithFormat:@"Trying to writeto:%@\n: %@", destinationPath, [plistContent description]];
    //    reply(result);
    
}

-(void) writePlist:(NSDictionary*)plistContent
            toPath:(NSString*)destinationPath
          withAuth:(AuthorizationExternalForm)externalAuth
         withReply:(void(^)(NSString *))reply
{
    
    //NSLog(@"executing writeplist with auth from xpc service");
    
    /*
     We first save it to a tmp file and then move it to its destination
     */
    NSURL * tempURL = [NSURL URLWithString:@"/tmp/edu.barrera.plisthandler.plist"];
    [self saveAsXML:plistContent atPath:tempURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self plistUserURL]path] isDirectory:NO]) {
        //  NSLog(@"already installed as user, let's erase the old plist before creating the new one");
        
        [self runAuthorizedCommand:@"/bin/rm" withArguments:[NSArray arrayWithObjects:@"-f", [[self plistUserURL] path], destinationPath, nil] andAuthorization:externalAuth];
        
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[tempURL path] isDirectory:NO]) {
        //if it saved correctly, move it to it's right place
        [self runAuthorizedCommand:@"/bin/mv" withArguments:[NSArray arrayWithObjects:@"-f", @"/tmp/edu.barrera.plisthandler.plist", destinationPath, nil] andAuthorization:externalAuth];
        //and chown it so the system can use it
        [self runAuthorizedCommand:@"/usr/sbin/chown" withArguments:[NSArray arrayWithObjects:@"root:wheel", destinationPath, nil] andAuthorization:externalAuth];
        
        
    }
    //    NSString *result=[NSString stringWithFormat:@"Trying to writeto:%@\n: %@", destinationPath, [plistContent description]];
    //    reply(result);
    
}

-(void)startServerWithAuth:(AuthorizationExternalForm)externalAuth systemScope:(BOOL)serverScope withReply:(void(^)(NSString *))reply
{
    if (serverScope!=0) {
        NSLog(@"Server Start not functional yet");
//        [self runAuthorizedCommand:@"/bin/launchctl" withArguments:[NSArray arrayWithObjects:@"load", [[self plistSystemURL]path], nil] andAuthorization:externalAuth];
    }else {
        NSLog(@"User Start");
    [self runAuthorizedCommand:@"/bin/launchctl" withArguments:[NSArray arrayWithObjects:@"load", [[self plistUserURL]path], nil] andAuthorization:externalAuth];
        
    }

    // check if we have enough authorization to start the server in the higher scope System>User
    reply(@"started!");
}

-(void)stopServerWithAuth:(AuthorizationExternalForm)externalAuth systemScope:(BOOL)serverScope withReply:(void(^)(NSString *))reply
{
    if (serverScope) {
//        [self runAuthorizedCommand:@"/bin/launchctl" withArguments:[NSArray arrayWithObjects:@"unload", [[self plistSystemURL]path], nil] andAuthorization:externalAuth];
    }else {
        [self runAuthorizedCommand:@"/bin/launchctl" withArguments:[NSArray arrayWithObjects:@"unload", [[self plistUserURL]path], nil] andAuthorization:externalAuth];
        
    }
    
    // check if we have enough authorization to start the server in the higher scope System>User
    reply(@"stoped!");
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(PlistHandlerProtocol)];
    
    newConnection.exportedObject = self;
    
    [newConnection resume];
    
    return YES;
}


- (void) runAuthorizedCommand:(NSString *)command
                withArguments:(NSArray *)args
             andAuthorization:(AuthorizationExternalForm)externalAuth
{
    // Convert command into const char*;
    const char *commandArg = strdup([command UTF8String]);
    
    // Convert args array into void-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [args count] + 1);
    int argvIndex = 0;
    if (args) {
        for (NSString *string in args) {
            // If we just using the returned UTF8String, strange things happen
            argv[argvIndex] = strdup([string UTF8String]);
            argvIndex++;
        }
    }
    argv[argvIndex] = nil;
    
    // Pipe for collecting output
    FILE *processOutput;
    processOutput = NULL;
    
    // Log
    //NSLog(@"Running Authorized: %@", [[[NSArray arrayWithObjects:command, nil] arrayByAddingObjectsFromArray:args] componentsJoinedByString:@" "]);
    
    AuthorizationRef authorizationRef;
    AuthorizationCreateFromExternalForm(&externalAuth, &authorizationRef);
    
    // Run command with authorization
    FILE **processOutputRef = NULL;
    
    // I know it's not the perfect way, but for the moment it's the only one that does not get my head bursting
    // in flames. Maybe one day, i'll have a privileged daemon to do this without the need to hack away like this
    OSStatus processError = AuthorizationExecuteWithPrivileges(authorizationRef, commandArg, kAuthorizationFlagDefaults, (char *const *)argv, processOutputRef);
    // Move along, nothing to see, just a humongous compile warning
    
    //NSLog(@"%d", (int)processError);
    // Release command and args
    free((char*)commandArg);
    if (args) {
        for (int i = 0; i < argvIndex; i++) {
            free((char*)argv[i]);
        }
    }
    free(argv);
    
}

- (void) saveAsXML: (id) thePlist atPath:(NSURL*) thePath{
    
    if (![NSPropertyListSerialization propertyList:thePlist isValidForFormat:NSPropertyListXMLFormat_v1_0]) {
        //NSLog(@"Invalid xml format");
        return;
        //invalid xml format
    }
    NSError * error;
    NSData *data =
    [NSPropertyListSerialization dataWithPropertyList:thePlist format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (data ==nil) {
        //  NSLog(@"error serializing");
        //error serializing
        return;
    }
    
    BOOL writeStatus = [data writeToFile:[thePath path]  options:NSDataWritingAtomic error:&error];
    
    if (!writeStatus){
        //NSLog(@"Unable to write the plist due to error : %@",error);
        return;
        //error writing the file
    }
    //    NSLog(@"plist written ok!");
}

- (NSURL*) plistUserURL
{
    // are we searching for this user or for all?
    NSString * base = @"~";
    NSURL * theURL = [NSURL URLWithString:[[base stringByAppendingString:@"/Library/LaunchAgents/com.mylar.mylar.plist" ] stringByExpandingTildeInPath]];
    //NSLog(@"");
    return theURL;
}

- (NSURL*) plistSystemURL
{
    // are we searching for this user or for all?
    NSString * base = @"";
    NSURL * theURL = [NSURL URLWithString:[[base stringByAppendingString:@"/Library/LaunchDaemons/com.mylar.mylar.plist" ] stringByExpandingTildeInPath]];
    //NSLog(@"");
    return theURL;
}

@end
