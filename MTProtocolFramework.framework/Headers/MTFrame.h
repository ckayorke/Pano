//
//  MTFrame.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/23/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTFrame : NSObject

+ (id)frame;

@property(nonatomic, assign) uint8_t frameFormat;
@property(nonatomic, assign) uint8_t frameType;
@property(nonatomic, assign) uint8_t command;
@property(nonatomic, strong) NSData *data;

@end
