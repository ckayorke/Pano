//
//  MTRequestFrame.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import "MTFrame.h"

@interface MTRequestFrame : MTFrame

@property(nonatomic, assign) uint8_t responseFrameFormat;

@end
