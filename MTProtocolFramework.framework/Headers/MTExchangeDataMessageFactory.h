//
//  MTExchangeDataMessageFactory.h
//  MTMeasure&Go
//
//  Created by Rajesh on 18/08/14.
//  Copyright (c) 2014 Robert Bosch - RBEI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessageFactory.h"
#import "MTExchangeDataInputMessage.h"

@interface MTExchangeDataMessageFactory : NSObject<MTMessageFactory>

- (MTExchangeDataInputMessage *)createExchangeDataContainer:(NSData *)data;

@end
