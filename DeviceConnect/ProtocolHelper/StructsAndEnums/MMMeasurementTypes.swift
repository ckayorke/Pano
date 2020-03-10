//
//  MMMeasurementTypes.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import UIKit

/// Measurement types available on different devices.
public enum MMMeasurementType : Int {
    case ignore = -1
    
    case distance = 0
    case area
    case volume
    case indirectLength
    case indirectHeight
    case doubleIndirectHeight
    case minMax
    case angle
    case wallArea
    
    case calculatedDistancePlus
    case calculatedDistanceMinus
    case calculatedAreaPlus
    case calculatedAreaMinus
    case calculatedVolumePlus
    case trapezoid
    case calculatedVolumeMinus
    
    case errorResponse
    
    case unknown
    
    // MARK: - Functions
    func description() -> String {
        switch self {
        case .ignore:
            return "ignore"
        case .distance:
            return "distance"
        case .area:
            return "area"
        case .volume:
            return "volume"
        case .indirectLength:
            return "indirectLength"
        case .indirectHeight:
            return "indirectHeight"
        case .doubleIndirectHeight:
            return "doubleIndirectHeight"
        case .minMax:
            return "minMax"
        case .angle:
            return "angle"
        case .wallArea:
            return "wallArea"
        case .calculatedDistancePlus:
            return "calculatedDistancePlus"
        case .calculatedDistanceMinus:
            return "calculatedDistanceMinus"
        case .calculatedAreaPlus:
            return "calculatedAreaPlus"
        case .calculatedAreaMinus:
            return "calculatedAreaMinus"
        case .calculatedVolumePlus:
            return "calculatedVolumePlus"
        case .trapezoid:
            return "trapezoid"
        case .calculatedVolumeMinus:
            return "calculatedVolumeMinus"
        case .errorResponse:
            return "errorResponse"
        case .unknown:
            return "unknown"
        }
    }
    
    /// Grouping measurement types into dimension types, like distances and angles (m, m^2, m^3, degree)
    public func associatedDimensionType() -> MMDimensionType {
        switch (self) {
        case .distance,
             .minMax,
             .indirectHeight,
             .indirectLength,
             .doubleIndirectHeight,
             .trapezoid:
            return .distance;
        case .area,
             .wallArea:
            return .area;
        case .volume:
            return .volume;
        case .angle:
            return .angle;
        default:
            return .unknown;
        }
    }
}

/// Device measurement reference point from which it measures
public enum MMMeasurementBasisType : Int32 {
    case topOfDevice
    case middleOfDevice
    case bottomOfDevice
    case spike
    case unknown
    
    func description() -> String {
        switch self {
        case .topOfDevice:
            return "topOfDevice"
        case .middleOfDevice:
            return "middleOfDevice"
        case .bottomOfDevice:
            return "bottomOfDevice"
        case .spike:
            return "spike"
        case .unknown:
            return "unknown"
        }
    }
}

/// On-device measurement operators
public enum MMMeasurementOperator : UInt {
    case ignore
    case plus
    case minus
    case divide
    case multiply
}

public enum MMDimensionType : UInt {
    case unknown
    case distance
    case area
    case volume
    case angle
}
