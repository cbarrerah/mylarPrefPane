//
//  PlistHandlerProtocol.h
//  PlistHandler
//
//  Created by Carlos Barrera on 24/1/15.
//  Copyright (c) 2015 Carlos Barrera. All rights reserved.
//

#import <Foundation/Foundation.h>

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol PlistHandlerProtocol

-(void) writePlist:(NSDictionary*)plistContent
            toPath:(NSString*)destinationPath
         withReply:(void(^)(NSString* ))reply;

-(void) writePlist:(NSDictionary*)plistContent
            toPath:(NSString*)destinationPath
          withAuth:(AuthorizationExternalForm)externalAuthorization
         withReply:(void(^)(NSString *))reply;

-(void)startServerWithAuth:(AuthorizationExternalForm)externalAuth systemScope:(BOOL)serverScope withReply:(void(^)(NSString *))reply;

-(void)stopServerWithAuth:(AuthorizationExternalForm)externalAuth systemScope:(BOOL)serverScope withReply:(void(^)(NSString *))reply;
@end

