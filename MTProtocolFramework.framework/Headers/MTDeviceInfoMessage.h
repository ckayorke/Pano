//
//  MTDeviceInfoMessage.h
//  MTProtocol
//
//  Created by Uttam Kumar Sinha on 03/11/15.
//  Copyright © 2015 Power Tools . All rights reserved.
//

#import "MTProtocol.h"

@interface MTDeviceInfoMessage : MTMessage

// device info details
@property(nonatomic, assign) NSString *dateCode;
@property(nonatomic, assign) int serialNumber;
@property(nonatomic, assign) int swRevision;
@property(nonatomic, assign) int swVersionMain;
@property(nonatomic, assign) int swVersionSub;
@property(nonatomic, assign) int swVersionBug;
@property(nonatomic, assign) int hwPCBVersion;
@property(nonatomic, assign) int hwPCBVariant;
@property(nonatomic, assign) int hwPCBBug;
@property(nonatomic, assign) NSString *partNumberTTNr;

@end
