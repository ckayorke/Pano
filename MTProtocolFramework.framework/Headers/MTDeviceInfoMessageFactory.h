//
//  MTDeviceInfoMessageFactory.h
//  MTProtocol
//
//  Created by Uttam Kumar Sinha on 03/11/15.
//  Copyright © 2015 Power Tools . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessageFactory.h"
#import "MTDeviceInfoMessage.h"

@interface MTDeviceInfoMessageFactory : NSObject<MTMessageFactory>

- (MTDeviceInfoMessage *)createSyncContainer:(NSData *)data;

@end
