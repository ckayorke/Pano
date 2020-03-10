//
//  MTCrc.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EN_CRC8_INITIAL_VALUE 0xAA
#define EN_CRC16_INITIAL_VALUE (EN_CRC8_INITIAL_VALUE | (EN_CRC8_INITIAL_VALUE << 8))
#define EN_CRC32_INITIAL_VALUE (EN_CRC8_INITIAL_VALUE | (EN_CRC8_INITIAL_VALUE << 8) | (EN_CRC8_INITIAL_VALUE << 16) | (EN_CRC8_INITIAL_VALUE << 24))

@interface MTCrc : NSObject

+ (uint8_t)calcCrc8ForData:(uint8_t)f_ui8Data initialValue:(uint8_t)f_ui8InitialValue;
+ (uint8_t)calcCrc8ForData:(uint8_t)f_ui8Data;

+ (uint8_t)calcCrc8ForData:(const uint8_t *) data withNumElements:(uint16_t)f_ui16NumElements initialValue:(uint8_t) f_ui8InitialValue;
+ (uint8_t)calcCrc8ForData:(const uint8_t *) data withNumElements:(uint16_t)f_ui16NumElements;

+ (uint8_t)calcCrc8ForData:(const uint8_t *) data withNumElements:(uint16_t)f_ui16NumElements initialValue:(uint8_t) f_ui8InitialValue polynomial:(uint8_t) f_ui8Polynomial;
+ (uint8_t)calcCrc8ForData:(uint8_t) f_ui8Data initialValue:(uint8_t) f_ui8InitialValue polynomial:(uint8_t) f_ui8Polynomial;

+ (uint16_t)calcCrc16ForData:(uint8_t)f_ui8Data initialValue:(uint16_t)f_ui16InitialValue;
+ (uint16_t)calcCrc16ForData:(uint8_t)f_ui8Data;

+ (uint16_t)calcCrc16ForData:(const uint8_t *) data withNumElements:(uint16_t)f_ui16NumElements initialValue:(uint16_t) f_ui16InitialValue;
+ (uint16_t)calcCrc16ForData:(const uint8_t *) data withNumElements:(uint16_t)f_ui16NumElements;

@end
