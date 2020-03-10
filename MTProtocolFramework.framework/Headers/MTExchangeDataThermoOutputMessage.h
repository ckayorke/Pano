//
//  MTExchangeDataThermoOutputMessage.h
//  MTProtocol
//
//  Created by Raghuraman on 15/12/14.
//  Copyright (c) 2014 Power Tools . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"

@interface MTExchangeDataThermoOutputMessage : MTMessage

@property(nonatomic, assign)int syncControl;
@property(nonatomic, assign)int packetNumber;
@property(nonatomic, assign)int mode;

@end
