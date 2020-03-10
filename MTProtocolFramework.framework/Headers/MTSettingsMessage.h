//
//  MTSettingsMessage.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/27/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import "MTMessage.h"

@interface MTSettingsMessage : MTMessage

@property (nonatomic, assign) int spiritLevelEnabled;
@property (nonatomic, assign) int dispRotationEnabled;
@property (nonatomic, assign) int speakerEnabled;
@property (nonatomic, assign) int laserPointerEnabled;
@property (nonatomic, assign) int backlightMode;
@property (nonatomic, assign) int angleUnit;
@property (nonatomic, assign) int measurementUnit;
@property (nonatomic, assign) int devConfiguration;
@property (nonatomic, assign) int lastUsedListIndex;
@property (nonatomic, assign) int unitOption;

@end
