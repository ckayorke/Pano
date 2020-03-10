//
//  MTSyncOutputMessage.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/23/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"

@interface MTSyncOutputMessage : MTMessage

@property(nonatomic, assign)int mode;
@property(nonatomic, assign)int signalOperation;
@property(nonatomic, assign)int syncControl;
@property(nonatomic, assign)int distReference;
@property(nonatomic, assign)int angleReference;
@property(nonatomic, assign)int switchMode;

@end


