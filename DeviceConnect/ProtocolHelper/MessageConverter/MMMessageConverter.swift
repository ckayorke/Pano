//
//  MMMessageConverter.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import MTProtocolFramework

/// Converting one or two messages into one MMMeasurement
class MMMessageConverter: NSObject {
    
    // Intermediate messages, used if one message has not enough space for all values associated with a measurment
    var exchangeDataMessageIntermediate1: MTExchangeDataInputMessage?
    var exchangeDataMessageIntermediate2: MTExchangeDataInputMessage?
    
    // MARK: - Command 80
    /// Generate a measurement object from a single 'command 80' response
    public func measurement(fromMessage message: MTSyncInputMessage, withReferenceTimeInterval timeInterval: TimeInterval? = nil) -> MMMeasurement? {
        let measurementType = self.measurementType(fromSyncMessageMode: message.mode)
        guard !(measurementType == .unknown)
            else { return nil }
        
        let measurement = MMMeasurement()
        measurement.resultType = measurementType
        measurement.resultValue = CGFloat(message.result)
        measurement.distReference = MMMeasurementBasisType(rawValue: message.distReference) ?? .unknown
        measurement.operatorType = self.measurementOperator(fromMessageCalcIndicator: message.calcIndicator)
        
        // Set measurement date
        if let tv = timeInterval {
            let measurementDate = Date(timeIntervalSince1970: tv + TimeInterval(message.timestamp))
            measurement.setAll(datesWithDate: measurementDate)
        }
        else {
            measurement.setAll(datesWithDate: Date())
        }
        
        // Set values
        switch measurementType {
        case .area,
             .minMax,
             .indirectHeight,
             .indirectLength:
            measurement.value1 = CGFloat(message.distance1)
            measurement.value2 = CGFloat(message.distance2)
            measurement.value3 = 0
        case .volume,
             .wallArea,
             .doubleIndirectHeight,
             .trapezoid:
            measurement.value1 = CGFloat(message.distance1)
            measurement.value2 = CGFloat(message.distance2)
            measurement.value3 = CGFloat(message.distance3)
        default:
            measurement.value1 = 0
            measurement.value2 = 0
            measurement.value3 = 0
        }
        
        // Set value types
        switch measurementType {
        case .indirectHeight,
             .indirectLength:
            measurement.value1Type = .distance
            measurement.value2Type = .angle
        case .doubleIndirectHeight:
            measurement.value1Type = .distance
            measurement.value2Type = .distance
            measurement.value3Type = .angle
        default:
            measurement.value1Type = .distance
            measurement.value2Type = .distance
            measurement.value3Type = .distance
        }
        
        if (measurement.operatorType == .minus || measurement.operatorType == .plus) {
            measurement.value1Type = measurementType
            measurement.value3Type = measurementType
        }
        
        return measurement
    }
    
    // MARK: - Command 85
    /// Generate a measurement object from a multiple 'command 85' responses
    /// A measurement is only returend if all messages had been received
    public func measurement(fromMessage message: MTExchangeDataInputMessage) -> MMMeasurement? {
        let measurementType = self.measurementType(fromSyncMessageMode: syncMeasurementMode(fromExchangeDataMeasurementMode: message.mode))
        
        if (measurementType == .unknown) {
            if self.isFirstMessage(ofEdcMessageMode: message.mode) {
                self.exchangeDataMessageIntermediate1 = message
            }
            else if self.isSecondMessage(ofEdcMessageMode: message.mode) {
                self.exchangeDataMessageIntermediate2 = message
            }
            return nil
        }
        
        let measurement = MMMeasurement()
        measurement.resultType = measurementType
        measurement.resultValue = CGFloat(message.result)
        measurement.distReference = MMMeasurementBasisType(rawValue: message.distReference) ?? .unknown
        
        // Measurement values
        switch measurementType {
        case .area,
             .indirectHeight,
             .indirectLength,
             .minMax:
            measurement.value1 = CGFloat(message.component1)
            measurement.value2 = CGFloat(message.component2)
            measurement.value3 = 0
        case .wallArea,
             .doubleIndirectHeight:
            if let intMessage1 = self.exchangeDataMessageIntermediate1 {
                measurement.value1 = CGFloat(intMessage1.component1)
            }
            else {
                measurement.value1 = 0
            }
            measurement.value2 = CGFloat(message.component2)
            measurement.value3 = CGFloat(message.component2)
        case .volume:
            if (message.mode == MODE_CALCULATED_VOLUME_PLUS)
                || (message.mode == MODE_CALCULATED_VOLUME_MINUS) {
                measurement.value1 = CGFloat(message.component1)
                measurement.value2 = CGFloat(message.component2)
                measurement.value3 = 0
            } else {
                if let intMessage1 = self.exchangeDataMessageIntermediate1 {
                    measurement.value1 = CGFloat(intMessage1.component1)
                }
                else {
                    measurement.value1 = 0
                }
                if let intMessage2 = self.exchangeDataMessageIntermediate2 {
                    measurement.value2 = CGFloat(intMessage2.component1)
                }
                else {
                    measurement.value2 = 0
                }
                measurement.value3 = CGFloat(message.component1)
            }
        case .trapezoid:
            if let intMessage1 = self.exchangeDataMessageIntermediate1 {
                measurement.value1 = CGFloat(intMessage1.component1)
            }
            else {
                measurement.value1 = 0
            }
            if let intMessage2 = self.exchangeDataMessageIntermediate2 {
                measurement.value2 = CGFloat(intMessage2.component1)
            }
            else {
                measurement.value2 = 0
            }
            measurement.value3 = CGFloat(message.component1)
        default:
            measurement.value1 = 0
            measurement.value2 = 0
            measurement.value3 = 0
        }
        
        // Result type
        switch measurementType {
        case .indirectHeight,
             .indirectLength:
            measurement.value1Type = .distance
            measurement.value2Type = .angle
            measurement.value3Type = .distance
        case .doubleIndirectHeight:
            measurement.value1Type = .distance
            measurement.value2Type = .distance
            measurement.value3Type = .angle
        case .angle:
            measurement.value1Type = .angle
            measurement.value2Type = .angle
            measurement.value3Type = .angle
        default:
            measurement.value1Type = .distance
            measurement.value2Type = .distance
            measurement.value3Type = .distance
        }
        
        // Operator type and correction of value type
        measurement.operatorType = .ignore
        switch message.mode {
        // Distance
        case MODE_CALCULATED_DISTANCE_PLUS:
            measurement.operatorType = .plus
        case MODE_CALCULATED_DISTANCE_MINUS:
            measurement.operatorType = .minus
        // Area
        case MODE_CALCULATED_AREA_PLUS:
            measurement.operatorType = .plus
            measurement.value1Type = .area
            measurement.value2Type = .area
        case MODE_CALCULATED_AREA_MINUS:
            measurement.operatorType = .minus
            measurement.value1Type = .area
            measurement.value2Type = .area
        // Volume
        case MODE_CALCULATED_VOLUME_PLUS:
            measurement.operatorType = .plus
            measurement.value1Type = .volume
            measurement.value2Type = .volume
        case MODE_CALCULATED_VOLUME_MINUS:
            measurement.operatorType = .minus
            measurement.value1Type = .volume
            measurement.value2Type = .volume
        default:
            break
        }
        
        
        return measurement
    }
    
    // MARK: Detecting multi part messages
    private func isFirstMessage(ofEdcMessageMode mode: Int32) -> Bool {
        // Marked throuhg 'PART_1'
        return mode == MODE_AREA_PART_1
            || mode == MODE_VOLUME_PART_1
            || mode == MODE_DOUBLE_INDIRECT_HEIGHT_PART_1
            || mode == MODE_WALL_AREA_PART_1
            || mode == MODE_TRAPEZOID_PART_1
    }
    
    private func isSecondMessage(ofEdcMessageMode mode: Int32) -> Bool {
        // Marked throuhg 'PART_2'
        return mode == MODE_VOLUME_PART_2
            || mode == MODE_TRAPEZOID_PART_2
    }
    
    // MARK: - Private functions converting modes and types
    private func syncMeasurementMode(fromExchangeDataMeasurementMode mode: Int32) -> Int32 {
        switch (mode) {
        case MODE_SINGLE_DISTANCE,
             MODE_CALCULATED_DISTANCE_PLUS,
             MODE_CALCULATED_DISTANCE_MINUS:
            return MEAS_MODE_SINGLE
        case MODE_CONTINUOUS_DISTANCE:
            return MEAS_MODE_MIN_MAX
        case MODE_AREA_PART_1,
             MODE_AREA_FINAL,
             MODE_CALCULATED_AREA_PLUS,
             MODE_CALCULATED_AREA_MINUS:
            return MEAS_MODE_AREA
        case MODE_VOLUME_PART_1,
             MODE_VOLUME_PART_2,
             MODE_VOLUME_FINAL,
             MODE_CALCULATED_VOLUME_PLUS,
             MODE_CALCULATED_VOLUME_MINUS:
            return MEAS_MODE_VOLUME
        case MODE_SINGLE_ANGLE,
             MODE_CONTINUOUS_ANGLE:
            return MEAS_MODE_ANGLE
        case MODE_INDIRECT_HEIGHT:
            return MEAS_MODE_INDIRECT_HEIGHT
        case MODE_INDIRECT_LENGTH:
            return MEAS_MODE_INDIRECT_LENGTH
        case MODE_DOUBLE_INDIRECT_HEIGHT_PART_1,
             MODE_DOUBLE_INDIRECT_HEIGHT_FINAL:
            return MEAS_MODE_DOUBLE_INDIRECT_HEIGHT
        case MODE_WALL_AREA_PART_1,
             MODE_WALL_AREA_FINAL:
            return MEAS_MODE_WALL_AREA
        case MODE_TRAPEZOID_PART_1,
             MODE_TRAPEZOID_PART_2,
             MODE_TRAPEZOID_PART_FINAL:
            return MEAS_MODE_TRAPEZOID
        default:
            return 0
        }
    }
    
    private func measurementOperator(fromMessageCalcIndicator indicator: Int32) -> MMMeasurementOperator {
        switch indicator {
        case CALCIND_MINUS_EQUAL:
            return .minus
        case CALCIND_PLUS_EQUAL:
            return .plus
        default:
            return .ignore
        }
    }
    
    private func measurementType(fromSyncMessageMode mode: Int32) -> MMMeasurementType {
        switch (mode) {
        case MEAS_MODE_SINGLE:
            return MMMeasurementType.distance
        case MEAS_MODE_AREA:
            return MMMeasurementType.area
        case MEAS_MODE_VOLUME:
            return MMMeasurementType.volume
        case MEAS_MODE_ANGLE:
            return MMMeasurementType.angle
        case MEAS_MODE_MIN_MAX:
            return MMMeasurementType.minMax
        case MEAS_MODE_INDIRECT_HEIGHT:
            return MMMeasurementType.indirectHeight
        case MEAS_MODE_INDIRECT_LENGTH:
            return MMMeasurementType.indirectLength
        case MEAS_MODE_DOUBLE_INDIRECT_HEIGHT:
            return MMMeasurementType.doubleIndirectHeight
        case MEAS_MODE_WALL_AREA:
            return MMMeasurementType.wallArea
        case MEAS_MODE_TRAPEZOID:
            return MMMeasurementType.trapezoid
        default:
            return MMMeasurementType.unknown
        }
    }
}
