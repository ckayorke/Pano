//
//  MTThermoConstants.h
//  MTProtocol
//
//  Created by Raghuraman on 15/12/14.
//  Copyright (c) 2014 Power Tools . All rights reserved.
//

#ifndef MTProtocol_MTThermoConstants_h
#define MTProtocol_MTThermoConstants_h


#define MODE_REQUEST_SYNC = 0; // no action -> will not be set by device

// device mode constants in response package (send by device)
typedef NS_ENUM(NSUInteger, MTThermoDevMode) {
    MTThermoDevModeSurfaceTemperature,
    MTThermoDevModeThermalBridge,
    MTThermoDevModeDewPoint,
    MTThermoDevModeUserDefined
};


// all 4 packets will be sent with the same unique ID by GIS device on event (live measurement or send measurement from gallery)
typedef NS_ENUM(NSUInteger, MTThermoPacketNumber) {
    MTThermoPacketNumber1 = 1, // contains temp IR, temp IR min and temp IR max
    MTThermoPacketNumber2, // contains temp IR average, humidity and temp ambient
    MTThermoPacketNumber3, // contains temp dew point, temp K type and emission degree (ED)
    MTThermoPacketNumber4 // contains scale value, thermal leak delta value and empty float
};


// alarms constants
typedef NS_ENUM(NSUInteger, MTThermoAlarm) {
    MTThermoAlarmOff,
    MTThermoAlarmLow,
    MTThermoAlarmHigh
};


// warning constants
#define WARNING_AMB_TEMP_STATUS_OFF = 0;
#define WARNING_AMB_TEMP_STATUS_ON = 1;
#define WARNING_HUMIDITY_STATUS_OFF = 0;
#define WARNING_HUMIDITY_STATUS_ON = 1;
#define WARNING_DEW_POINT_STATUS_OFF = 0;
#define WARNING_DEW_POINT_STATUS_ON = 1;



// error status
#define ERROR_STATUS_OK = 0; // unused: always 0


#endif
