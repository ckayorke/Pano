//
//  MTExchangeDataThermalInputMessage.h
//  MTProtocol
//
//  Created by Raghuraman on 15/12/14.
//  Copyright (c) 2014 Power Tools . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"
#import "MTThermoConstants.h"

@interface MTExchangeDataThermoInputMessage : MTMessage


// measurement settings - Device Mode
@property(nonatomic, assign) int mode;
@property(nonatomic, assign) int packetNumber;

// measurement data
@property(nonatomic, assign) float component1;
@property(nonatomic, assign) float component2;
@property(nonatomic, assign) float component3;
@property(nonatomic, assign) int timestamp;

// additional
@property(nonatomic, assign) int laserOn;
@property(nonatomic, assign) int uniqueID;
@property(nonatomic, assign) int measID;
@property(nonatomic, assign) int autoSync;


@property(nonatomic, assign) int temperatureMode;
@property(nonatomic, assign) int alarm;
@property(nonatomic, assign) int warningAmbTemp;
@property(nonatomic, assign) int warningHumidity;
@property(nonatomic, assign) int warningDewPoint;

@end
