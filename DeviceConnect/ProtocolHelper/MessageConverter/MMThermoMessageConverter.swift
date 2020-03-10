//
//  MMThermoMessageConverter.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import MTProtocolFramework

/// Converting multiple messages into one MMThermoMeasurement
class MMThermoMessageConverter: NSObject {
    
    private var currentMeasurement: MMThermoMeasurement?
    /// A unique identifier which will be the same for all successiv messages send for one measurement
    private var currentMeasurementUniqueId: Int32!
    /// This counter makes sure only packages in the right order will be used to form the current measurement object
    private var countOfReceivedMessages: Int32!
    
    // MARK: - Init
    override init() {
        super.init()
        self.resetReceivedMessages()
    }
    
    /// Resetting received message cound and previously stored measurement results
    public func resetReceivedMessages() {
        self.countOfReceivedMessages = 0
        self.currentMeasurementUniqueId = 0
        self.currentMeasurement = nil
    }
    
    /// Generate a new measurement from received messages.
    /// A measurement (MMThermoMeasurement) is only returned after the last packages was received an all packages are processed in the right order.
    public func measurement(fromMessage message: MTExchangeDataThermoInputMessage) -> MMThermoMeasurement? {
        let packetNumber = message.packetNumber
        switch MTThermoPacketNumber(rawValue: UInt(packetNumber)) {
        case MTThermoPacketNumber.number1?:
            // Reset and recreat fresh measurement
            self.resetReceivedMessages()
            self.currentMeasurement = MMThermoMeasurement()
            // Set uniqueID once to check messages with the same id
            self.currentMeasurementUniqueId = message.uniqueID
            // The initial packetNumber is an indicator on how many packages will be send
            self.countOfReceivedMessages = packetNumber
            
            self.currentMeasurement?.tempIR = CGFloat(message.component1)
            self.currentMeasurement?.tempIRMin = CGFloat(message.component2)
            self.currentMeasurement?.tempIRMax = CGFloat(message.component3)
            
        case MTThermoPacketNumber.number2?:
            guard (self.currentMeasurementUniqueId == message.uniqueID)
                && (self.countOfReceivedMessages == (packetNumber - 1))
                else {
                    NSLog("Error: MMThermoMessageConverter P2, wrong uniqueId or packageNumber")
                    break
            }
            self.countOfReceivedMessages = packetNumber
            
            self.currentMeasurement?.tempIRAvg = CGFloat(message.component1)
            self.currentMeasurement?.humidity = CGFloat(message.component2)
            self.currentMeasurement?.tempAmbient = CGFloat(message.component3)
            
        case MTThermoPacketNumber.number3?:
            guard (self.currentMeasurementUniqueId == message.uniqueID)
                && (self.countOfReceivedMessages == (packetNumber - 1))
                else {
                    NSLog("Error: MMThermoMessageConverter P3, wrong uniqueId or packageNumber")
                    break
            }
            self.countOfReceivedMessages = packetNumber
            
            self.currentMeasurement?.tempDewPoint = CGFloat(message.component1)
            self.currentMeasurement?.tempType = (message.component2.isNaN) ? 0 : CGFloat(message.component2)
            self.currentMeasurement?.ed = CGFloat(message.component3)
            
        case MTThermoPacketNumber.number4?:
            guard (self.currentMeasurementUniqueId == message.uniqueID)
                && (self.countOfReceivedMessages == (packetNumber - 1))
                else {
                    NSLog("Error: MMThermoMessageConverter P4, wrong uniqueId or packageNumber")
                    break
            }
            self.countOfReceivedMessages = packetNumber
            
            self.currentMeasurement?.scaleValue = CGFloat(message.component1)
            self.currentMeasurement?.thermalLeakDeltaValue = CGFloat(message.component2)
            self.currentMeasurement?.temperatureMode = MMThermoTemperatureMode(rawValue: message.mode) ?? .surfaceTemperature
            self.currentMeasurement?.alarm = MMThermoAlarm(rawValue: message.alarm) ?? .off
            self.currentMeasurement?.warningAmbTemp = message.warningAmbTemp
            self.currentMeasurement?.warningHumidity = message.warningHumidity
            self.currentMeasurement?.warningDewPoint = message.warningDewPoint
            
            return self.currentMeasurement
            
        case nil:
            NSLog("MMThermoMessageConverter unrecognized packetNumber received")
            break
        }
        
        // Return `nil` if there are more packaes to come or and error occured
        return nil
    }
}
