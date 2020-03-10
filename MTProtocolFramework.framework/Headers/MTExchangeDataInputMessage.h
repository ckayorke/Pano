//
//  MTExchangeDataInputMessage.h
//  MTMeasure&Go
//
//  Created by Rajesh on 18/08/14.
//  Copyright (c) 2014 Robert Bosch - RBEI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"

@interface MTExchangeDataInputMessage : MTMessage

// measurement settings - Device Mode
@property(nonatomic, assign) int mode;  // 2-7 bits
@property(nonatomic, assign) int calcIndicator; // Dev-Mode - 16/17

// Remote Ctrl Data
@property(nonatomic, assign) int distReference;
@property(nonatomic, assign) int angleReference;
@property(nonatomic, assign) int configUnits;

// measurement data
@property(nonatomic, assign) int soc; //Dev mode -18
@property(nonatomic, assign) int temperatureStatus; //Dev mode -18
@property(nonatomic, assign) int batteryStatus;

@property(nonatomic, assign) float result;
@property(nonatomic, assign) float component1;
@property(nonatomic, assign) float component2;
@property(nonatomic, assign) int timestamp;

// additional
@property(nonatomic, assign) int laserOn;
//@property(nonatomic, assign) int errors;
@property(nonatomic, assign) int errorStatus;
@property(nonatomic, assign) int uniqueID;
//@property(nonatomic, assign) int measListIndex;
@property(nonatomic, assign) int autoSync;
@property(nonatomic, assign) int keypadBypass;

-(int)turnSyncModeToEDCMode:(int)mode;
// added trapezoid
-(int)turnEDCModeToSyncMode:(int)edcMode;
@end
