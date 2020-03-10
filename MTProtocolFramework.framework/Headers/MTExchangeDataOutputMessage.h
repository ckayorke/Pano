//
//  MTExchangeDataOutputMessage.h
//  MTMeasure&Go
//
//  Created by Rajesh on 18/08/14.
//  Copyright (c) 2014 Robert Bosch - RBEI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTMessage.h"

@interface MTExchangeDataOutputMessage : MTMessage

@property(nonatomic, assign)int mode;
@property(nonatomic, assign)int syncControl;
@property(nonatomic, assign)int keyPadControl;
@property(nonatomic, assign)int remoteControl;

@end
