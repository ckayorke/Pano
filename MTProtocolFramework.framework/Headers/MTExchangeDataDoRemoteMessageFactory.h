//
//  MMExchangeDataDoRemoteMessageFactory.h
//  MTProtocol
//
//  Created by Raghuraman on 11/11/15.
//  Copyright © 2015 Power Tools . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessageFactory.h"
#import "MTExchangeDataDoRemoteMessage.h"

/**
 Message factory to create message with command ID of 86.
 This wont do any converstion from data and this is reserved for future use.
 */

@interface MTExchangeDataDoRemoteMessageFactory : NSObject <MTMessageFactory>
- (MTExchangeDataDoRemoteMessage *)createExchangeDataContainer:(NSData *)data;

@end
