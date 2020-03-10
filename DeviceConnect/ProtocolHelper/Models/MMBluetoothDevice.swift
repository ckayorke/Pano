//
//  MMBluetoothDevice.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import CoreBluetooth

/// Wrapper class for holding a strong reference to connected bluetooth peripherals.
public class MMBluetoothDevice: NSObject {
    
    // MARK: - Private variables
    private var advDataLocalName: String!
    
    // MARK: - Public variables
    public var uuid: UUID!
    /// A reference to the represented bluetooth device.
    public var peripheral: CBPeripheral!
    /// A timestamp representing the first time the peripheral had been communicated with the device.
    /// It is used for calculating measurement timestamps.
    public var birthDate: Date!
    
    // MARK: - Read-only variabels
    public var name: String {
        get {
            return self.advDataLocalName
        }
    }
    
    public var isConnected: Bool {
        get {
            return self.peripheral.state == .connected
        }
    }
    
    public var icConnecting: Bool {
        get {
            return self.peripheral.state == .connecting
        }
    }
    
    // MARK: - Init
    public init(withPeripheral peripheral: CBPeripheral, advDataLocalName: String) {
        self.peripheral = peripheral
        self.uuid = self.peripheral.identifier
        self.advDataLocalName = advDataLocalName
    }
    
    // MARK: - Functions
    /// Updating a device birthdate.
    /// *NOTE:* The birthdate should be set after the first message had been received from a measuring device.
    public func setBirthdate(fromTimeStamp timestamp: TimeInterval) {
        let timeInterval = Date().timeIntervalSince1970 - timestamp
        self.birthDate = Date(timeIntervalSince1970: timeInterval)
    }

}

