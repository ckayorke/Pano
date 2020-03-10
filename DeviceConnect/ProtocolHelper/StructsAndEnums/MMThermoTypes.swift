//
//  MMThermoTypes.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import Foundation

enum MMThermoTemperatureMode: Int32 {
    case surfaceTemperature
    case thermalBridge
    case dewPoint
    case userDefined
}

// All 4 packets will be sent with the same unique ID by GIS device on event (live measurement or send measurement from gallery)
enum MMThermoPacket: Int32 {
    /// contains temp IR, temp IR min and temp IR max
    case number1 = 1
    /// contains temp IR average, humidity and temp ambient
    case number2
    /// contains temp dew point, temp K type and emission degree (ED)
    case number3
    /// contains scale value, thermal leak delta value and empty float
    case number4
}

enum MMThermoAlarm: Int32 {
    case off
    case low
    case high
}
