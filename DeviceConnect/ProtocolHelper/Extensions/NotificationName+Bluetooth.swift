//
//  NotificationExtension.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import Foundation

extension Notification {
    struct UserInfoKey {
        static let MTMessage = "MTMessage"
    }
}

extension Notification.Name {
    struct MMBluetoothDevice {
        static let connectivityStatusDidChange  = Notification.Name("MMBluetoothDeviceConnectivityStatusDidChangeNotification")
        static let stateDidChange               = Notification.Name("MMBluetoothDeviceStateDidChangeNotification")
    }
    struct MMBluetoothManager {
        static let didReceiveMessage            = Notification.Name("MMBluetoothManagerDidReceiveMessage")
        static let hardwareStateChange          = Notification.Name("MMBluetoothManagerHardwareStateChangeNotification")
        static let didUpdateAvailableDevices    = Notification.Name("MMBluetoothManagerDidUpdateAvailableDevicesNotification")
        static let didConnect                   = Notification.Name("MMBluetoothManagerDidConnect")
        static let didDisconnect                = Notification.Name("MMBluetoothManagerDidDisconnect")
        static let didReceiveError              = Notification.Name("MMBluetoothManagerDidReceiveError")
        static let didFailedToConnectToDevice   = Notification.Name("MMBluetoothManagerDidFailedToConnectToDevice")
        static let didReceiveDeviceInfoError    = Notification.Name("MMBluetoothManagerDidReceiveDeviceInfoErrorNotification")
    }
}
