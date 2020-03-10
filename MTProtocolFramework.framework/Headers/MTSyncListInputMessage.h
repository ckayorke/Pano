//
//  MTSyncListInputMessage.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/27/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import "MTMessage.h"

@interface MTSyncListInputMessage : MTMessage

@property (nonatomic, assign) int indexFrom;
@property (nonatomic, assign) int indexTo;

@property (nonatomic, strong) NSArray *syncContainers;

@end
