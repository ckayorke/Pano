//
//  MTDataExchangeService.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/21/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
//#import "MTBluetoothService.h"
@protocol MTDataExchangeServiceDelegate;


@interface MTDataExchangeService : NSObject

+ (id)dataExchangeServiceWithPeripheral:(CBPeripheral *)peripheral;
- (id)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)send:(NSData *)data;

- (void)clear;
- (void)initialize;
- (void)invalidate;

@property (nonatomic, assign) id<MTDataExchangeServiceDelegate> delegate;
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;
@property (nonatomic, assign) BOOL isConnectedToGLM;
@property (nonatomic, strong) NSString *serviceUUID;
@property (nonatomic, strong) NSString *charectristicsRXUUID;
@property (nonatomic, strong) NSString *charectristicsTXUUID;

@end


@protocol MTDataExchangeServiceDelegate <NSObject>

- (void)dataExchangeService:(MTDataExchangeService *)service didInitilizeWithError:(NSError *)error;
- (void)dataExchangeService:(MTDataExchangeService *)service didReceiveData:(NSData *)data;
- (void)dataExchangeService:(MTDataExchangeService *)service didReceiveError:(NSError *)error;

@end
