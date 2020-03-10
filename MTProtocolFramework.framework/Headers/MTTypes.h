//
//  MTTypes.h
//  MTMeasure&Go
//
//  Created by Andrejs Cernikovs on 5/24/13.
//  Copyright (c) 2013 grandcentrix GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

// General types
union unionNibble
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui8Low          : 4;
        uint8_t ui8High         : 4;
    }fields;
};

union unionUint16
{
    uint16_t ui16Value;
    struct
    {
        uint8_t ui8LSB          : 8;
        uint8_t ui8MSB          : 8;
    }fields;
};

union unionUint24
{
    uint16_t ui24Value;
    struct
    {
        uint8_t ui8Byte1          : 8;
        uint8_t ui8Byte2          : 8;
        uint8_t ui8Byte3          : 8;
        
    }fields;
};

union unionUint8
{
    uint16_t ui8Value;
    struct
    {
        uint8_t ui1Bit1            : 1;
        uint8_t ui1Bit2            : 1;
        uint8_t ui1Bit3            : 1;
        uint8_t ui1Bit4            : 1;
        uint8_t ui4MSB             : 4;
    }fields;
};

union unionUintByte
{
    uint16_t ui8Value;
    struct
    {
        uint8_t ui8ByteData             : 8;
    }fields;
};

union unionUint32
{
    uint32_t ui32Value;
    struct
    {
        uint8_t ui8Byte1          : 8;
        uint8_t ui8Byte2          : 8;
        uint8_t ui8Byte3          : 8;
        uint8_t ui8Byte4          : 8;
    }fields;
};


//UInt32 single byte
union unionVersion8
{
    uint32_t ui8Value;
    struct
    {
        uint8_t ui8Byte1          : 8;
        
    }fields;
};


union unionFloat
{
    float floatValue;
    struct
    {
        uint8_t ui8Byte1          : 8;
        uint8_t ui8Byte2          : 8;
        uint8_t ui8Byte3          : 8;
        uint8_t ui8Byte4          : 8;
    }fields;
};

// Frame types
union unionFrameMode
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui2ResponseFrameFormat  : 2;
        uint8_t ui2RequestFrameFormat   : 2;
        uint8_t ui2Reserved             : 2;
        uint8_t ui2FrameType            : 2;
    }fields;
};

union unionFrameStatus
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui3ComStatus            : 3;
        uint8_t ui3DeviceStatus         : 3;
        uint8_t ui2FrameType            : 2;
    }fields;
};

// Sync Container types
union unionRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui5ModeHeader           : 5;
        uint8_t ui1SignalOperation      : 1;
        uint8_t ui1SyncControl          : 1;
        uint8_t ui1SwitchMode           : 1;
    }fields;
};

union unionRequestReferences
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui3DistReference        : 3;
        uint8_t ui3AngleReference       : 3;
    }fields;
};


union unionResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui5ModeHeader           : 5;
        uint8_t ui3CalcIndicator        : 3;
    }fields;
};

union unionResponseReferences
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui3DistReference        : 3;
        uint8_t ui3AngleReference       : 3;
        uint8_t ui1DeviceConfig         : 1;
    }fields;
};

union unionErrorsAndLaser
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1LaserOnOff           : 1;
        uint8_t ui7Error                : 7;
    }fields;
};
//Exchange Data Container Types
union unionExchangeDataRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1SyncControl          : 1;
        uint8_t ui1keypadBypass         : 1;
        uint8_t ui6DevModeHeader        : 6;
    }fields;
};

union unionExchangeDataRequestReferences
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui3DistReference        : 3;
        uint8_t ui3AngleReference       : 3;
    }fields;
};

union unionExchangeDataResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1DistReference        : 1;
        uint8_t ui1AngleReference       : 1;
        uint8_t ui6DevModeHeader        : 6;
        
    }fields;
};

union unionExchangeDataDevStatusResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        
        uint8_t ui1LaserStatus          : 1;
        uint8_t ui1temperatureWarning   : 1;
        uint8_t ui1Batterywarning       : 1;
        uint8_t ui5Status               : 5;
        
    }fields;
};


//Thermo related
union unionExchangeDataThermoRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1SyncControl          : 1;  //0 to stop sync, 1 to start sync
        uint8_t ui1Unused               : 1;  //Reserved for future use
        uint8_t ui6RemoteMode           : 6;  //Used to start pinging between the device and app. Currently iOS not needed pinging, so always set it to 0
    }fields;
};


union unionExchangeDataThermoResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui3PacketNumber         : 3; //bit 1, 2 and 3
        uint8_t ui2DevModeHeader        : 2; //bit 4 and 5
        uint8_t ui3Unused               : 3; //bit 6 and 7
        
        
    }fields;
};

union unionExchangeDataThermoDevStatusResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui2Alarm                : 2; // 0,1
        uint8_t ui1WarningAmbTemp       : 1; // 2
        uint8_t ui1WarningHumidity      : 1; // 3
        uint8_t ui1WarningDewPoint      : 1; // 4
        uint8_t ui3Unused               : 3;  //bit 5, 6 and 7
        
    }fields;
};

union remoteControlByte
{
    uint8_t ui8Value;
    struct
    {
        uint8_t listIndex               : 6;  //6 bits ListIndex - GLM 50c
        uint8_t indicator               : 2;  //2 bits indicator - GLM 50c
    }fields;
    
};

// GRL Log size in packets
union unionLogSizeRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1DataType             : 1;
        uint8_t ui4LastSyncTime         : 4;
    }fields;
};

union unionLogSizeResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui2CalibStroredSize     : 2;
    }fields;
};

union unionLogPacketRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1DataType               : 1;
        uint8_t ui2PacketNumRequired      : 2;
    }fields;
};

union unionLogPacketResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui2CalibStroredSize      : 2;
    }fields;
};

union unionSyncStatusRequestHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1SyncStatus            : 1;
        uint8_t ui7Reserved              : 7;
    }fields;
};

union unionSyncStatusResponseHeaders
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1DevConStatus         : 1;
        uint8_t ui1BatteryStatus        : 1;
        uint8_t ui1SysMode              : 1;
        uint8_t ui1Orientation          : 1;
        uint8_t ui1SlopeStatus          : 1;
        uint8_t ui1ADSStatus            : 1;
        uint8_t ui1AccessLock           : 1;
    }fields;
};


union unionDevConnectionStatus
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1SyncStatus      : 1;
        uint8_t ui7Reserved        : 7;
    }fields;
};


union unionSyncCalStatusResponseHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1CalTimeActive       : 1;
        uint8_t ui1CalShockActive      : 1;
        uint8_t ui1CalTempActive       : 1;
        uint8_t ui5Reserved            : 5;
        
    }fields;
};


union unionSyncSpindleStatusResponseHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1SpindleStatusMode      : 2;
        uint8_t ui1SpindleStatusRPM       : 2;
        uint8_t ui4Reserved               : 4;
        
    }fields;
};


union unionSyncErrorDataResponseHeader{
    uint16_t ui16Value;
    struct
    {
        uint8_t ui1xAxisOutSideLevelRange      : 1;
        uint8_t ui1yAxisOutSideLevelRange      : 1;
        uint8_t ui1zAxisOutSideLevelRange      : 1;
        uint8_t ui1xSlopeOutsideRange          : 1;
        uint8_t ui1ySlopeOutsideRange          : 1;
        uint8_t ui1levelTimeOut                : 1;
        uint8_t ui1systemError                 : 1;
        uint8_t ui2error                       : 2;
        uint8_t ui8Reserved                    : 8;
    }fields;
};


union unionSyncSystemErrorResponseHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1VialBroken          : 1;
        uint8_t ui1SpindleError        : 1;
        uint8_t ui1BluetoothError      : 1;
        uint8_t ui5Reserved            : 5;
        
    }fields;
};

union unionSyncLEDStatus{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1LedBatteryCritical      : 1;
        uint8_t ui1LedPowerGreen           : 1;
        uint8_t ui1LedPowerRed             : 1;
        uint8_t ui1LedADSRed               : 1;
        uint8_t ui1LedADSGreen             : 1;
        uint8_t ui1LedCalGuard             : 1;
        uint8_t ui1LedCalibration          : 1;
        uint8_t ui1LedBlueTooth            : 1;
    }fields;
};


union unionLaserSlopeModeHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1XValidity          : 1;
        uint8_t ui1YValidity          : 1;
        uint8_t ui1LevelMode          : 1;
        uint8_t ui5Reserved           : 5;
        
    }fields;
};

union unionLaserSlopeDataHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui8Data          : 8;
        
    }fields;
};


union unionCalGuardResponseHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1TemperatureFailure          : 1;
        uint8_t ui1ShockFailure                : 1;
        uint8_t ui1TimeFailure                 : 1;
        
    }fields;
};


union unionSyncCalibrationHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui2XCalibration                     : 2;
        uint8_t ui2YCalibration                     : 2;
        uint8_t ui2ZCalibration                     : 2;
        uint8_t ui2DeviceCalibration                : 2;
        
    }fields;
};

union unionGCLSystemStatusHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1isOutOfLevel          : 1;
        uint8_t ui1isPulseMode           : 1;
        uint8_t ui1isPendulumLocked      : 1;
        uint8_t ui1isRotaryBasePlugged   : 1;
        uint8_t ui1ShockEventTriggered   : 1;
        uint8_t ui1tLowEventTriggered    : 1;
        uint8_t ui1tHighEventTriggered   : 1;
        uint8_t ui1TimeEventTriggered    : 1;
        
    }fields;
};

union unionLasersStatusHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1HorizontalLaser       : 1;
        uint8_t ui1VerticalLaser         : 1;
        uint8_t ui1DotUpDowLaser         : 1;
        uint8_t ui1Reserved              : 5;
        
    }fields;
};

union unionSetLasersAndBuzzerHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1HorizontalLaser       : 1;
        uint8_t ui1VerticalLaser         : 1;
        uint8_t ui1DotUpDowLaser         : 1;
        uint8_t ui4Reserved              : 4;
        uint8_t ui1Buzzer                : 1;
        
    }fields;
};


union unionMotorOperationRequestHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1MotorSpeed   : 1;
        uint8_t ui1SingleStep   : 1;
        uint8_t ui1Direction    : 1;
        uint8_t ui4Reserved     : 4;
        uint8_t ui1TurnMotor    : 1;
    }fields;
};


union unionSimulateControlKeyRequestHeader{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1FastClockwiseButton              : 1;
        uint8_t ui1FastCounterClockwiseButton       : 1;
        uint8_t ui1SlowClockwiseButton              : 1;
        uint8_t ui1SlowCounterClockwiseButton       : 1;
        uint8_t ui1StepClockwiseButton              : 1;
        uint8_t ui1StepCounterClockwiseButton       : 1;
        uint8_t ui1ModeSelectionButton              : 1;
        uint8_t ui1PulseModeButton                  : 1;
    }fields;
};

union unionClearCalibrationRequestHeader
{
    uint8_t ui8Value;
    struct
    {
        uint8_t ui1clearCalibration     : 1;
        uint8_t ui7Reserved             : 7;
    }fields;
};


