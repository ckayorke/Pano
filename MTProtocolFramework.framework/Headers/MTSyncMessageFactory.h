//
//  MTSyncMessageFactory.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/26/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessageFactory.h"
#import "MTSyncInputMessage.h"

@interface MTSyncMessageFactory : NSObject <MTMessageFactory>

- (MTSyncInputMessage *)createSyncContainer:(NSData *)data;

@end
