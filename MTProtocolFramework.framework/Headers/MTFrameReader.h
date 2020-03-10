//
//  MTFrameReader.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTFrame.h"

@interface MTFrameReader : NSObject

+ (id)frameReader;

- (void)append:(uint8_t)byte;
- (MTFrame *)frame;

@property(nonatomic, assign) uint8_t frameFormat;

@end
