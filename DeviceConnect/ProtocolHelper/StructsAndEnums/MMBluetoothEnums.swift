//
//  MMBluetoothEnums.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import Foundation

public enum MMBluetoothDeviceState: Int {
    case unknown = -1
    case poweredOff = 0
    case poweredOn = 1
}

public enum MMBluetoothDeviceConnectivityStatus: Int {
    case notConnected
    case connecting
    case connected
}
