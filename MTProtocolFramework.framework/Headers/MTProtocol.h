//
//  MTProtocol.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/23/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDataExchangeService.h"
#import "MTMessage.h"

extern NSString *const MTProtocolErrorDomain;


enum MTProtocolError
{
	MTProtocolError_NoError = 0,                      // Never used
	MTProtocolError_TimeoutError,
    MTProtocolError_BusyError,
    MTProtocolError_InvalidMessageError,
    MTProtocolError_InvalidFrameError
};
typedef enum MTProtocolError MTProtocolError;

@protocol MTProtocolDelegate;


@interface MTProtocol : NSObject <MTDataExchangeServiceDelegate>

+ (id)protocol;

- (void)sendRequest:(MTMessage *)message;

- (void)invalidate;
- (void)resetState;

@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, strong)	MTDataExchangeService *connection;
@property (nonatomic, assign)	id<MTProtocolDelegate> delegate;

@end


@protocol MTProtocolDelegate <NSObject>

- (void)protocol:(MTProtocol *)protocol didReceiveMessage:(MTMessage *)message;
- (void)protocol:(MTProtocol *)protocol didReceiveError:(NSError *)error;

@end
