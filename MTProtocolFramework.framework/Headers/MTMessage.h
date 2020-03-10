//
//  MTMessage.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/26/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTMessage : NSObject

+ (id)message;

@property (nonatomic, assign)int commandId;

@end
