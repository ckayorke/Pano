//
//  MMMeasurement.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import UIKit

/// Basic measurement object
open class MMMeasurement: NSObject {
    public var identifier: UUID
    
    public var operatorType: MMMeasurementOperator = .ignore
    public var resultType: MMMeasurementType = .unknown
    
    public var resultValue: CGFloat = 0
    public var resultTitle: String = ""
    public var resultTimestamp: Date!
    
    public var value1Type: MMMeasurementType = .unknown
    public var value2Type: MMMeasurementType = .unknown
    public var value3Type: MMMeasurementType = .unknown
    
    
    public var valueTitle1: String = ""
    public var valueTitle2: String = ""
    public var valueTitle3: String = ""
    
    
    public var value1: CGFloat = 0
    public var value2: CGFloat = 0
    public var value3: CGFloat = 0
    
    public var measurementTimestamp: Date!
    public var timestamp1: Date!
    public var timestamp2: Date!
    public var timestamp3: Date!
    
    public var distReference: MMMeasurementBasisType = .unknown
    
    // MARK:  Init
    public override init() {
        self.identifier = UUID()
        super.init()
        // For devices not transmit timestamps, use the current time
        self.setAll(datesWithDate: Date())
    }
    
    public func setAll(datesWithDate date: Date) {
        self.measurementTimestamp = date
        self.resultTimestamp = date
        self.timestamp1 = date
        self.timestamp2 = date
        self.timestamp3 = date
    }
}

