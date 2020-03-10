//
//  MTExchangeDataDoRemoteTriggerButtonMessage.h
//  MTProtocol
//
//  Created by Raghuraman on 03/09/15.
//  Copyright (c) 2015 Power Tools . All rights reserved.
//

#import "MTProtocol.h"

#define EN_BUTTON_MEASURE 0

@interface MTExchangeDataDoRemoteTriggerButtonMessage : MTMessage

@property(nonatomic, assign) int buttonNumber;  

@end
