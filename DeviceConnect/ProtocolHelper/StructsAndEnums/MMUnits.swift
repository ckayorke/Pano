//
//  MMUnits.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import UIKit

/// Distance units used for formatting user-facing outputs
public enum MMDistanceUnit {
    case unknown, meter, centimeter
    
    func unitSign() -> String {
        switch self {
        case .unknown:      return ""
        case .meter:        return "m"
        case .centimeter:   return "cm"
        }
    }
    
    static func convert(distInMeter distance: CGFloat, to targetUnit: MMDistanceUnit) -> CGFloat {
        switch targetUnit {
        case .unknown,
             .meter:        return distance
        case .centimeter:   return distance * 100.0
        }
    }
    
    static func convertToArea(inMeter val: CGFloat, to targetUnit: MMDistanceUnit) -> CGFloat {
        switch targetUnit {
        case .unknown,
             .meter:        return val
        case .centimeter:   return val * 100.0 * 100.0
        }
    }
    
    static func convertToVolume(inMeter val: CGFloat, to targetUnit: MMDistanceUnit) -> CGFloat {
        switch targetUnit {
        case .unknown,
             .meter:        return val
        case .centimeter:   return val * 1000.0 * 1000.0
        }
    }
    
    /// Helper method decreasing fraction digits for restults with high values
    func numberOfFractionDigit(forValue val: CGFloat) -> Int {
        switch self {
        case .meter:
            if val >= 100000 {
                return 0
            } else if val >= 10000 {
                return 1
            } else if val >= 1000 {
                return 2
            } else if val >= 10 {
                return 3
            } else {
                return 4
            }
        case .centimeter:
            if val >= 1000 {
                return 1
            } else {
                return 2
            }
        case .unknown:
            return 4
        }
    }
    
}

/// Angle units used for formatting user-facing outputs
public enum MMAngleUnit {
    case unknown, degree
    
    func unitSign() -> String {
        switch self {
        case .unknown:      return ""
        case .degree:       return "\u{00B0}"
        }
    }
    
    static func convert(angleInDegree angle: CGFloat, to targetUnit: MMAngleUnit) -> CGFloat {
        switch targetUnit {
        case .unknown,
             .degree:       return angle
        }
    }
}

/// Temperature units used for formatting user-facing outputs
public enum MMTemperatureUnit {
    case unknown, celcius, fahrenheit
    
    func unitSign() -> String {
        switch self {
        case .unknown:      return ""
        case .celcius:      return "\u{00B0}C"
        case .fahrenheit:   return "\u{00B0}F"
        }
    }
    
    static func convert(tempInCelcius temperature: CGFloat, to targetUnit: MMTemperatureUnit) -> CGFloat {
        switch targetUnit {
        case .unknown,
             .celcius:      return temperature
        case .fahrenheit:   return (temperature * (9.0/5.0)) + 32
        }
    }
}
