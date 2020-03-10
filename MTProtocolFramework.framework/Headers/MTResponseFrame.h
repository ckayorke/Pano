//
//  MTResponseFrame.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import "MTFrame.h"

@interface MTResponseFrame : MTFrame

@property(nonatomic, assign)uint8_t comStatus;
@property(nonatomic, assign)uint8_t deviceStatus;

@end
