//
//  MTExchangeDataThermoMessageFactory.h
//  MTProtocol
//
//  Created by Raghuraman on 15/12/14.
//  Copyright (c) 2014 Power Tools . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessageFactory.h"
#import "MTExchangeDataThermoInputMessage.h"

@interface MTExchangeDataThermoMessageFactory : NSObject <MTMessageFactory>

- (MTExchangeDataThermoInputMessage *)createExchangeDataThermoContainer:(NSData *)data;

@end