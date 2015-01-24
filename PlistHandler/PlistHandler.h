//
//  PlistHandler.h
//  PlistHandler
//
//  Created by Carlos Barrera on 24/1/15.
//  Copyright (c) 2015 Carlos Barrera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlistHandlerProtocol.h"
#import <Security/Security.h>

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface PlistHandler : NSObject <PlistHandlerProtocol>
@end
