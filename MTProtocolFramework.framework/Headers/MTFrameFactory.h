//
//  MTFrameFactory.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/26/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"
#import "MTRequestFrame.h"

@protocol MTFrameFactory <NSObject>

+ (id)frameFactory;

- (MTRequestFrame *) createRequestFrame:(MTMessage *)message;

@end