//
//  MTFrameWriter.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTRequestFrame.h"
#import "MTResponseFrame.h"

@interface MTFrameWriter : NSObject

+ (id)frameWriter;

- (NSData *)writeRequest:(MTRequestFrame *)frame;
- (NSData *)writeResponse:(MTResponseFrame *)frame;

@end
