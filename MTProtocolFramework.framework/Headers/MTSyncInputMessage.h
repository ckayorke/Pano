//
//  MTSyncInputMessage.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/23/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"

@interface MTSyncInputMessage : MTMessage

// measurement settings
@property(nonatomic, assign) int mode;
@property(nonatomic, assign) int calcIndicator;
@property(nonatomic, assign) int distReference;
@property(nonatomic, assign) int angleReference;
@property(nonatomic, assign) int configUnits;

// measurement data
@property(nonatomic, assign) int soc;
@property(nonatomic, assign) int temperature;
@property(nonatomic, assign) float result;
@property(nonatomic, assign) float distance1;
@property(nonatomic, assign) float distance2;
@property(nonatomic, assign) float distance3;
@property(nonatomic, assign) float angle;
@property(nonatomic, assign) int timestamp;

// additional
@property(nonatomic, assign) int laserOn;
@property(nonatomic, assign) int errors;
@property(nonatomic, assign) int measListIndex;
@property(nonatomic, assign) int compassHeading;
@property(nonatomic, assign) int ndofSensorStatus;

@end
