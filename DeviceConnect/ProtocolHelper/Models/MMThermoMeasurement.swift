//
//  MMThermoMeasurement.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import MTProtocolFramework

/// Basic thermo measurement object
class MMThermoMeasurement: NSObject {
    
    public var timeStamp: Date
    public var identifier: UUID
    
    public var tempIR: CGFloat = 0
    public var tempIRMin: CGFloat = 0
    public var tempIRMax: CGFloat = 0
    public var tempIRAvg: CGFloat = 0
    
    public var humidity: CGFloat = 0
    
    public var tempAmbient: CGFloat = 0
    public var tempDewPoint: CGFloat = 0
    public var tempType: CGFloat = 0
    
    public var ed: CGFloat = 0
    public var scaleValue: CGFloat = 0
    public var thermalLeakDeltaValue: CGFloat = 0

    public var temperatureMode: MMThermoTemperatureMode = .surfaceTemperature
    
    public var alarm: MMThermoAlarm = .off
    
    public var warningAmbTemp: Int32 = 0
    public var warningHumidity: Int32 = 0
    public var warningDewPoint: Int32 = 0
    
    
    // MARK: - Init
    override init() {
        self.timeStamp = Date()
        self.identifier = UUID()
        super.init()
    }
}
