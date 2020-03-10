//
//  MTDeviceInfoParser.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import Foundation

/// Retrieving Bosch-device specific data from within bluetooth advertised manufacturing data information.
class MMDeviceInfoParser {
    
    /// Internal stored manufacturing bluetooth data for later inspection
    private var manufacturingData: Data?
    
    /// Advertised manufacturing data data reference locations (serialnumber, baretoolnumber, ...)
    private struct advManData {
        static let length: Int = 19
        static let length_with_sernr: Int = 23
        static let baretn_location: Int = 8
        static let baretn_length: Int = 10
        static let sernr_location: Int = 19
        static let sernr_length: Int = 4
        static let length_with_sernr_version_8: Int = 16
        static let sernr_location_version_8: Int = 12
    }
    
    /// Internally used identifier to detect bluetooth measuring-devices.
    private enum BaretoolNumber: String {
        case GLM_120_C        = "3601K72F00"
        case GLM_120_C_REV    = "00F27K1063"
        
        case GLM_400_C        = "3601K72F10"
        case GLM_400_C_REV    = "01F27K1063"
        case GLM_400_CL       = "3601K72F13"
        case GLM_400_CL_REV   = "31F27K1063"
        
        case GLM_150_C1       = "3601K72FK0"
        case GLM_150_C1_REV   = "0KF27K1063"
        
        case GLM_150_C2       = "3601K72F50"
        case GLM_150_C2_REV   = "05F27K1063"
        
        case GLM_150_C3       = "3601K72FC0"
        case GLM_150_C3_REV   = "0CF27K1063"
        
        case GLM_CAM_CSAM     = "0925219062"
        case GLM_CAM          = "          "
    }
    
    /// Easyly recognizable measuring device naming which will be used, if a device does not broadcast one.
    public struct DisplayName {
        static let GLM_120_C        = "Bosch GLM 120 C"
        static let GLM_400_C        = "Bosch GLM 400 C"
        static let GLM_400_CL       = "Bosch GLM 400 CL"
        static let GLM_150_C        = "Bosch GLM 150 C"
        static let GLM_CAM          = "Bosch GLM CAM"
    }
    
    /// A mapping between baretool numbers and there corresponding device names as a dictionary for easy access.
    private let baretoolNumberWithDeviceName: [BaretoolNumber : String] = [
        // GLM 120
        BaretoolNumber.GLM_120_C : DisplayName.GLM_120_C,
        BaretoolNumber.GLM_120_C_REV : DisplayName.GLM_120_C,
        // GLM 400 ft.
        BaretoolNumber.GLM_400_C : DisplayName.GLM_400_C,
        BaretoolNumber.GLM_400_C_REV : DisplayName.GLM_400_C,
        BaretoolNumber.GLM_400_CL : DisplayName.GLM_400_CL,
        BaretoolNumber.GLM_400_CL_REV : DisplayName.GLM_400_CL,
        // GLM 150
        BaretoolNumber.GLM_150_C1 : DisplayName.GLM_150_C,
        BaretoolNumber.GLM_150_C1_REV : DisplayName.GLM_150_C,
        BaretoolNumber.GLM_150_C2 : DisplayName.GLM_150_C,
        BaretoolNumber.GLM_150_C2_REV : DisplayName.GLM_150_C,
        BaretoolNumber.GLM_150_C3 : DisplayName.GLM_150_C,
        BaretoolNumber.GLM_150_C3_REV : DisplayName.GLM_150_C,
        // GLM CAM
        BaretoolNumber.GLM_CAM : DisplayName.GLM_CAM,
        BaretoolNumber.GLM_CAM_CSAM : DisplayName.GLM_CAM
    ]
    
    // MARK: - Init
    init(withManufacturingData manufacturingData: Data?) {
        self.manufacturingData = manufacturingData
    }
    
    // MARK: -
    public var baretoolNumber: String? {
        guard let manData = self.manufacturingData
            else { return nil }
        return self.getBaretoolNumber(fromManufactureData: manData)
    }
    
    public var serialNumber: String? {
        guard let manData = self.manufacturingData
            else { return nil }
        return self.getSerialNumber(fromManufactureData: manData)
    }
    
    // MARK: - Public functions
    
    /// Checks if a given baretoolnumber is known and therefore the measuring device will be listet for user selection
    public func isKnownBaretoolNumberString(_ baretoolNumberString: String) -> Bool {
        return !(BaretoolNumber(rawValue: baretoolNumberString) == nil)
    }
    
    /// A convinience method for retrieving a device name by it's baretoolnumber.
    /// *Note*: If there is no mapping available between baretoolnumber and a device, a generic 'unknown device' will be returned
    public func getDeviceDiplayName(forBaretoolNumberString baretoolNumberString: String) -> String {
        if let bareToolNumber = BaretoolNumber(rawValue: baretoolNumberString),
            let deviceDisplayName = baretoolNumberWithDeviceName[bareToolNumber] {
            return deviceDisplayName
        }
        else {
            return NSLocalizedString("Unknown device", comment: "Unknown device")
        }
    }
    
    
    // MARK: - Private functions
    /// Retrieving a baretoonumber from a given advertised manufacturing data object.
    private func getBaretoolNumber(fromManufactureData manData: Data) -> String? {
        if (manData.count >= advManData.length) {
            let bareToolNumberDataRange = NSRange(location: advManData.baretn_location, length: advManData.baretn_length)
            let bareToolNumberData = manData.subdata(in: Range(bareToolNumberDataRange)!)
            return String(data: bareToolNumberData, encoding: String.Encoding.utf8)
        }
        else {
            for oneBareToolNumber in Array(baretoolNumberWithDeviceName.keys) {
                guard let manDataString = String(data: manData, encoding: String.Encoding.utf8)
                    else { continue }
                if manDataString.localizedCaseInsensitiveContains(oneBareToolNumber.rawValue) {
                    return oneBareToolNumber.rawValue
                }
            }
        }
        return nil
    }
    
    /// Retrieving a serialnumber from a given advertised manufacturing data object.
    private func getSerialNumber(fromManufactureData manData: Data) -> String? {
        if (manData.count >= advManData.length_with_sernr) {
            let serialNumberDataRange = NSRange(location: advManData.sernr_location, length: advManData.sernr_length)
            let serialNumberData = manData.subdata(in: Range(serialNumberDataRange)!)
            return String(data: serialNumberData, encoding: String.Encoding.utf8)
        }
        else if (manData.count >= advManData.length_with_sernr_version_8) {
            let serialNumberDataRange = NSRange(location: advManData.sernr_location_version_8, length: advManData.sernr_length)
            let serialNumberData = manData.subdata(in: Range(serialNumberDataRange)!)
            return String(data: serialNumberData, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
}
