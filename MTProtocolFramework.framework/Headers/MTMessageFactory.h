//
//  MTMessageFactory.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/26/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"
#import "MTFrame.h"

@protocol MTMessageFactory <NSObject>

+ (id)messageFactory;

- (MTMessage *)createMessage:(MTFrame *)frame;

@end
