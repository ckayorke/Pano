//
//  MMThermoMeasurementFormatter.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import UIKit

/// Formatting basic thermal measurement results for user-facing output with optional unit casting.
class MMThermoMeasurementFormatter: NSObject {
    
    func stringRepresentation(forTemperature tempValue: CGFloat, in unit: MMTemperatureUnit = .celcius) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        nf.maximumIntegerDigits = 3
        nf.minimumIntegerDigits = 1
        
        let temperature = MMTemperatureUnit.convert(tempInCelcius: tempValue, to: unit)
        let formattedNumber = nf.string(from: NSNumber(value: Double(temperature))) ?? "-"
        return String(format: "%@ %@", arguments: [formattedNumber, unit.unitSign()])
    }
    
    func stringRepresentation(forHumidity humidityValue: CGFloat) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        nf.minimumFractionDigits = 1
        nf.maximumIntegerDigits = 3
        nf.minimumIntegerDigits = 1
        
        let formattedNumber = nf.string(from: NSNumber(value: Double(humidityValue))) ?? "-"
        return String(format: "%@%%", arguments: [formattedNumber])
    }
    
    func stringRepresentation(forEmissiveDensity emissiveDensityValue: CGFloat) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 1
        nf.maximumIntegerDigits = 3
        nf.minimumIntegerDigits = 1
        
        let formattedNumber = nf.string(from: NSNumber(value: Double(emissiveDensityValue))) ?? "-"
        return String(format: "%@", arguments: [formattedNumber])
    }
    
}
