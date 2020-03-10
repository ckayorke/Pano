//
//  MMMeasurementFormatter.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import UIKit

/// Formatting basic measurement results from laser-range finder devices.
/// It is used for user-facing output with optional unit casting.
class MMMeasurementFormatter: NSObject {
    
    func stringRepresentation(forAngle angle: CGFloat, in unit: MMAngleUnit = .degree) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        nf.usesGroupingSeparator = false
        nf.minimumIntegerDigits = 1
        nf.maximumFractionDigits = 4
        nf.minimumFractionDigits = 0
        
        let angleInUnit = MMAngleUnit.convert(angleInDegree: angle, to: unit)
        let formattedNumber = nf.string(from: NSNumber(value: Double(angleInUnit))) ?? "-"
        return String(format: "%@ %@", arguments: [formattedNumber, unit.unitSign()])
    }
    
    func stringRepresentation(forDistance distance: CGFloat, in unit: MMDistanceUnit = .meter) -> String {
        let fractionDigits = unit.numberOfFractionDigit(forValue: distance)
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        nf.usesGroupingSeparator = false
        nf.minimumIntegerDigits = 1
        nf.maximumFractionDigits = fractionDigits
        nf.minimumFractionDigits = fractionDigits
        
        let distanceInUnit = MMDistanceUnit.convert(distInMeter: distance, to: unit)
        let formattedNumber = nf.string(from: NSNumber(value: Double(distanceInUnit))) ?? "-"
        return String(format: "%@ %@", arguments: [formattedNumber, unit.unitSign()])
    }
    
    func stringRepresentation(forArea area: CGFloat, in unit: MMDistanceUnit = .meter) -> String {
        var fractionDigits = 3
        if area >= 100000 {
            fractionDigits = 0
        } else if area >= 10000 {
            fractionDigits = 1
        } else if area >= 1000 {
            fractionDigits = 2
        }
        
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        nf.usesGroupingSeparator = false
        nf.minimumIntegerDigits = 1
        nf.maximumFractionDigits = fractionDigits
        nf.minimumFractionDigits = fractionDigits
        
        let areaInUnit = MMDistanceUnit.convertToArea(inMeter: area, to: unit)
        let formattedNumber = nf.string(from: NSNumber(value: Double(areaInUnit))) ?? "-"
        return String(format: "%@ %@%@", arguments: [formattedNumber, unit.unitSign(), "\u{00B2}"])
    }
    
    func stringRepresentation(forVolumen area: CGFloat, in unit: MMDistanceUnit = .meter) -> String {
        var fractionDigits = 3
        if area >= 100000 {
            fractionDigits = 0
        } else if area >= 10000 {
            fractionDigits = 1
        } else if area >= 1000 {
            fractionDigits = 2
        }
        
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        nf.usesGroupingSeparator = false
        nf.minimumIntegerDigits = 1
        nf.maximumFractionDigits = fractionDigits
        nf.minimumFractionDigits = fractionDigits
        
        let areaInUnit = MMDistanceUnit.convertToVolume(inMeter: area, to: unit)
        let formattedNumber = nf.string(from: NSNumber(value: Double(areaInUnit))) ?? "-"
        return String(format: "%@ %@%@", arguments: [formattedNumber, unit.unitSign(), "\u{00B3}"])
    }
    
}
