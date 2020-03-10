//
//  MMBluetoothService.swift
//  DeviceConnect
//
//  Created by Tobias Kaulich on 21.08.2018.
//  Copyright © 2018 Robert Bosch Power Tools GmbH. All rights reserved.
//

import MTProtocolFramework

public class MMBluetoothService: NSObject, CBCentralManagerDelegate, MTDataExchangeServiceDelegate, MTProtocolDelegate {
    // MARK: - Singleton
    public static let shared = MMBluetoothService()
    
    // MARK: - Structs
    // MARK: Bluetooth service characteristics
    struct UUID_SERVICE {
        // GLM devices
        struct GLM {
            static let DATA_EXCHANGE    = "00005301-0000-0041-5253-534F46540000"
            static let RX               = "00004301-0000-0041-5253-534F46540000"
            static let TX               = "00004302-0000-0041-5253-534F46540000"
        }
        // For now we using the save data exchanges service as GLM, it may change in future, thats why we maintaining a separate varibale
        struct NON_GLM {
            static let DATA_EXCHANGE    = "00005301-0000-0041-5253-534F46540000"
            static let RX               = "00004301-0000-0041-5253-534F46540000"
            static let TX               = "00004302-0000-0041-5253-534F46540000"
        }
        // MirX service UUID
        struct MIRX {
            static let DATA_EXCHANGE    = "02A6C0D0-0451-4000-B000-FB3210111989"
            static let RX_TX            = "02A6C0D1-0451-4000-B000-FB3210111989"
        }
    }
    
    struct BoschDeviceIdentifier {
        struct NameSubstring {
            static let glm = "glm"
            static let glm1 = "glm1"
            static let glm5 = "glm5"
            static let gis = "gis"
            static let plr = "plr"
        }
        struct VersionSubstring {
            static let plr30 = "30"
            static let plr40 = "40"
            static let glm50 = "50"
            static let glm100 = "100"
            static let glm120 = "120"
            static let glm150 = "150"
            static let gis1000c = "1000"
        }
        static let bosch = "bosch"
    }
    
    // MARK: - Private variables
    /// MTProtocol instance for sending and receiving messages from measuring devices
    private var mtProtocol: MTProtocol = MTProtocol()
    private var dataExchangeService: MTDataExchangeService?
    
    private var centralManager: CBCentralManager!
    private var connectionTimeoutTimer: Timer?
    private var isBluetoothInitialized: Bool = false
    
    // MARK: - Public variables
    public var currentDevice: MMBluetoothDevice?
    public var availableDevices: [MMBluetoothDevice] = []
    
    // MARK: Bluetooth and conectivity state
    public var currentBluetoothState: MMBluetoothDeviceState = .unknown {
        didSet {
            if !(oldValue == self.currentBluetoothState) {
                NotificationCenter.default.post(name: Notification.Name.MMBluetoothDevice.stateDidChange , object: self)
            }
        }
    }
    
    public var connectivityStatus: MMBluetoothDeviceConnectivityStatus = .notConnected {
        didSet {
            if !(oldValue == self.connectivityStatus) {
                NotificationCenter.default.post(name: Notification.Name.MMBluetoothDevice.connectivityStatusDidChange , object: self)
            }
        }
    }
    
    // MARK: - Initializer
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Connection Timeout
    @objc func handleTimeoutForConnection(timer: Timer) {
        self.connectivityStatus = .notConnected
        if let cDevice = self.currentDevice {
            self.centralManager.cancelPeripheralConnection(cDevice.peripheral)
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didFailedToConnectToDevice , object: cDevice)
        }
    }
    
    func configureConnectionTimeoutTimer() {
        if let timer = self.connectionTimeoutTimer {
            timer.invalidate()
            self.connectionTimeoutTimer = nil
        }
        
        self.connectionTimeoutTimer = Timer.scheduledTimer(timeInterval: 1000000,
                                                           target: self,
                                                           selector: #selector(MMBluetoothService.handleTimeoutForConnection(timer:)),
                                                           userInfo: nil,
                                                           repeats: false)
    }
    
    
    // MARK: - CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let manData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        var nameAdvertised = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        
        let deviceInfoParser = MMDeviceInfoParser(withManufacturingData: manData)
        if let bareToolNumber = deviceInfoParser.baretoolNumber {
            let displayName = deviceInfoParser.getDeviceDiplayName(forBaretoolNumberString: bareToolNumber)
            
            if (displayName.contains(MMDeviceInfoParser.DisplayName.GLM_120_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_150_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_400_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_400_CL)) {
                nameAdvertised = deviceInfoParser.getDeviceDiplayName(forBaretoolNumberString: bareToolNumber)
            }
            
        }
        
        if let displayName = nameAdvertised,
            self.isCommonMeasuringDevice(deviceName: displayName) {
            let device = MMBluetoothDevice(withPeripheral: peripheral, advDataLocalName: displayName)
            self.addDevice(device)
        }
        else if let bareToolNumber = deviceInfoParser.baretoolNumber ,
            let displayName = nameAdvertised,
            (displayName.contains(MMDeviceInfoParser.DisplayName.GLM_120_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_150_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_400_C)
            || displayName.contains(MMDeviceInfoParser.DisplayName.GLM_400_CL)) {
            
            var displayName = deviceInfoParser.getDeviceDiplayName(forBaretoolNumberString: bareToolNumber)
            if let serialNumber = deviceInfoParser.serialNumber {
                displayName = String(format: "%@ %@", arguments: [displayName, serialNumber])
            }
            
            let device = MMBluetoothDevice(withPeripheral: peripheral, advDataLocalName: displayName)
            self.addDevice(device)
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("Did fail to connecting device")
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("Did connect to: %@ ", peripheral)
        
        self.connectionTimeoutTimer?.invalidate()
        self.connectionTimeoutTimer = nil
        
        if let cDevice = self.currentDevice {
            cDevice.uuid = peripheral.identifier
        }
        self.dataExchangeService = MTDataExchangeService.dataExchangeService(with: peripheral) as? MTDataExchangeService
        guard let dataExchangeService = self.dataExchangeService
            else { return }
        self.dataExchangeService!.delegate = self
        
        if self.isGlm100Device(deviceName: peripheral.name ?? "") {
            dataExchangeService.isConnectedToGLM = true
            
            dataExchangeService.serviceUUID = UUID_SERVICE.GLM.DATA_EXCHANGE
            dataExchangeService.charectristicsRXUUID = UUID_SERVICE.GLM.RX
            dataExchangeService.charectristicsTXUUID = UUID_SERVICE.GLM.TX
        }
        else if (self.isGlm50Device(deviceName: peripheral.name ?? "") || self.isPlrDevice(deviceName: peripheral.name ?? "") || self.isGis1000Device(deviceName: peripheral.name ?? "")) {
            dataExchangeService.isConnectedToGLM = false
            
            dataExchangeService.serviceUUID = UUID_SERVICE.NON_GLM.DATA_EXCHANGE
            dataExchangeService.charectristicsRXUUID = UUID_SERVICE.NON_GLM.RX
            dataExchangeService.charectristicsTXUUID = UUID_SERVICE.NON_GLM.TX
        }
        else {
            dataExchangeService.isConnectedToGLM = false
            
            dataExchangeService.serviceUUID = UUID_SERVICE.MIRX.DATA_EXCHANGE
            dataExchangeService.charectristicsRXUUID = UUID_SERVICE.MIRX.RX_TX
            dataExchangeService.charectristicsTXUUID = UUID_SERVICE.MIRX.RX_TX
        }
        self.dataExchangeService!.initialize()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("Did disconnect device %@", peripheral)
        
        if let _ = error {
            if let foundDevice = self.availableDevices.first(where: { (btDevice: MMBluetoothDevice) -> Bool in
                return btDevice.peripheral.isEqual(peripheral)
            }) {
                removeDevice(foundDevice)
            }
        }
        
        if let cDevice = self.currentDevice,
            cDevice.uuid == peripheral.identifier {
            self.currentDevice = nil
            self.dataExchangeService?.invalidate()
            self.dataExchangeService = nil
            
            if !(self.connectivityStatus == MMBluetoothDeviceConnectivityStatus.notConnected) {
                self.connectivityStatus = .notConnected
                
                NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didDisconnect , object: self)
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveDeviceInfoError , object: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            NSLog("CoreBluetooth BLE hardware is powered OFF")
            self.currentBluetoothState = .poweredOff
            self.connectivityStatus = .notConnected
            
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveDeviceInfoError , object: nil)
        case .poweredOn:
            NSLog("CoreBluetooth BLE hardware is powered on and ready")
            self.currentBluetoothState = .poweredOn
            self.isBluetoothInitialized = true
            self.startDiscovery()
        case .resetting:
            NSLog("bluetooth_hardware_is_resetting")
        case .unauthorized:
            NSLog("CoreBluetooth BLE state is unauthorized")
        case .unknown:
            NSLog("bluetooth_state_is_unknown")
            self.currentBluetoothState = .unknown
        case .unsupported:
            NSLog("no_bluetooth_support_for_this_platform")
        }
        
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.hardwareStateChange , object: self)
    }
    
    // MARK: Bluetooth Helper
    func startDiscovery() {
        if self.isBluetoothInitialized {
            self.stopDiscovery()
            self.clearDevices()
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func stopDiscovery() {
        if self.isBluetoothInitialized {
            self.centralManager.stopScan()
        }
    }
    
    /// Check if bluetooth is avaialbe and authorized to be used
    public func isSupported() -> Bool {
        if #available(iOS 10.0, *) {
            return !(self.centralManager.state == CBManagerState.unsupported)
                && !(self.centralManager.state == CBManagerState.unauthorized)
        } else {
            // Fallback on earlier versions < 10.0
            return !(self.centralManager.state.rawValue == CBCentralManagerState.unsupported.rawValue)
                && !(self.centralManager.state.rawValue == CBCentralManagerState.unauthorized.rawValue)
        }
    }
    
    /// Checks if bluetooth is powered on
    public func isEnabled() -> Bool {
        if #available(iOS 10.0, *) {
            return self.centralManager.state == CBManagerState.poweredOn
        } else {
            // Fallback on earlier versions < 10.0
            return self.centralManager.state.rawValue == CBCentralManagerState.poweredOn.rawValue
        }
    }
    
    /// Adding a new device to the list of devices and posting a notification
    func addDevice(_ newDevice: MMBluetoothDevice) {
        self.removeDevice(newDevice)
        self.availableDevices.append(newDevice)
        
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didUpdateAvailableDevices , object: self)
    }
    
    // Removing a given device from the list of devices without posting a notification
    func removeDevice(_ device: MMBluetoothDevice) {
        if let deviceIndex = self.availableDevices.index(where: { (knownDevice: MMBluetoothDevice) -> Bool in
            return knownDevice.peripheral.isEqual(device.peripheral)
        }) {
            self.availableDevices.remove(at: deviceIndex)
        }
    }
    
    // MARK: - Device Detection Helper
    /// Decides if a given device name can be associated with a Bosch device
    /// Checking for: Bosch && ((GLM && (100 || 50)) || (GIS && (1000)))`
    func isCommonMeasuringDevice(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        let isBoschDevice = lcDeviceName.contains(BoschDeviceIdentifier.bosch)
        let isGlmDevice = (lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.glm1) || lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.glm5)) && (lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm100) || lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm50))
        let isGisDevice = (lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.gis)) && (lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.gis1000c))
        let isPlrDevice = lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.plr)
        
        // Bosch && ((GLM && (100 || 50)) || (GIS && (1000)))
        return isBoschDevice && (isGlmDevice || isGisDevice || isPlrDevice)
    }
    
    public func isGlm50Device(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        return lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.glm5)
                && lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm50)
    }
    
    public func isPlrDevice(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        return lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.plr)
    }
    
    public func isGlm100Device(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        return lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.glm1)
            && lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm100)
    }
    
    public func isGlm120Device(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        return lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.glm)
            && (lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm120) || lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.glm150))
    }
    
    public func isGis1000Device(deviceName: String) -> Bool {
        guard !deviceName.isEmpty
            else { return false }
        let lcDeviceName = deviceName.lowercased()
        
        return lcDeviceName.contains(BoschDeviceIdentifier.NameSubstring.gis)
            && lcDeviceName.contains(BoschDeviceIdentifier.VersionSubstring.gis1000c)
    }
    
    // MARK: - MTProtocol Delegate
    /// Receiving messages from mtprotocol and posting messages accodringly for in-app usage
    public func `protocol`(_ protocol: MTProtocol!, didReceive message: MTMessage!) {
        NSLog("MMProtocol didReceiveMessage: %@", message)
        
        if let cMessage = message as? MTSyncInputMessage {
            // ### 80 Response
            if let cDevice = self.currentDevice, (cDevice.birthDate == nil) {
                self.currentDevice?.setBirthdate(fromTimeStamp: TimeInterval(cMessage.timestamp))
            }
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveMessage, 
                                            object: self,
                                            userInfo: [Notification.UserInfoKey.MTMessage : cMessage])
        }
        else if let cMessage = message as? MTExchangeDataInputMessage {
            // ### 85 Response
            if let cDevice = self.currentDevice, (cDevice.birthDate == nil) {
                self.currentDevice?.setBirthdate(fromTimeStamp: TimeInterval(cMessage.timestamp))
            }
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveMessage,
                                            object: self,
                                            userInfo: [Notification.UserInfoKey.MTMessage : cMessage])
        }
        else if let cMessage = message as? MTExchangeDataThermoInputMessage {
            // ### 94 Response
            if let cDevice = self.currentDevice, (cDevice.birthDate == nil) {
                self.currentDevice?.setBirthdate(fromTimeStamp: TimeInterval(cMessage.timestamp))
            }
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveMessage,
                                            object: self,
                                            userInfo: [Notification.UserInfoKey.MTMessage : cMessage])
        }
    }
    
    public func `protocol`(_ protocol: MTProtocol!, didReceiveError error: Error!) {
        NSLog("MMProtocol didReceiveError: %@", error.localizedDescription)
        `protocol`.resetState()
        
        if ((error as NSError).code == Int(MTProtocolError_TimeoutError.rawValue)) {
            NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didReceiveError,
                                            object: self,
                                            userInfo: ["Error" : error])
        }
    }
    
    // MARK: - MMDataExchangeService Delegate
    public func dataExchangeService(_ service: MTDataExchangeService!, didInitilizeWithError error: Error!) {
        if let _ = error,
            let cDevice = self.currentDevice {
            self.disconnect(fromDevice: cDevice)
        }
        else {
            NSLog("Initializitaion callback: init completed, no error.")
            self.mtProtocol = MTProtocol.`protocol`() as! MTProtocol
            self.mtProtocol.connection = service
            self.mtProtocol.delegate = self
            service.delegate = self.mtProtocol
            
            NSLog("MTProtocol ready ...")
            self.turnOnAutoSync()
        }
    }
    
    public func dataExchangeService(_ service: MTDataExchangeService!, didReceive data: Data!) { }
    public func dataExchangeService(_ service: MTDataExchangeService!, didReceiveError error: Error!) { }
    
    // MARK: Device handshake
    func turnOnAutoSync() {
        guard self.mtProtocol.isReady,
            let currentDeviceAdvertisedName = self.currentDevice?.name
            else { return }
        
        if self.isGlm100Device(deviceName: currentDeviceAdvertisedName) {
            let message = MTSyncOutputMessage.message() as! MTSyncOutputMessage
            message.syncControl = MODE_AUTOSYNC_CONTROL_ON
            self.mtProtocol.sendRequest(message)
        }
        else if self.isGlm50Device(deviceName: currentDeviceAdvertisedName) || self.isGlm120Device(deviceName: currentDeviceAdvertisedName) || self.isPlrDevice(deviceName: currentDeviceAdvertisedName) {
            let message = MTExchangeDataOutputMessage.message() as! MTExchangeDataOutputMessage
            message.syncControl = MODE_AUTOSYNC_CONTROL_ON
            self.mtProtocol.sendRequest(message)
        }
        else if self.isGis1000Device(deviceName: currentDeviceAdvertisedName) {
            let message = MTExchangeDataThermoOutputMessage.message() as! MTExchangeDataThermoOutputMessage
            message.syncControl = MODE_AUTOSYNC_CONTROL_ON
            self.mtProtocol.sendRequest(message)
        }
        
        self.connectivityStatus = .connected
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didConnect , object: self)
    }
    
    // MARK: - Bluetooth connect / disconnect devices
    var cDevice: MMBluetoothDevice!
    func connect(toDevice device: MMBluetoothDevice) {
        guard self.isBluetoothInitialized,
            !(device.peripheral == nil),
            !(device.name.isEmpty)
            else { return }
        NSLog("Connecting device: %@", device.peripheral);
        
        if let oldConnectedDevice = self.currentDevice,
            (oldConnectedDevice.isConnected || oldConnectedDevice.icConnecting) {
            self.disconnect(fromDevice: oldConnectedDevice)
        }
        
        self.connectivityStatus = .connecting
        self.currentDevice = self.getDevice(forUUID: device.uuid)
        self.centralManager.connect(self.currentDevice!.peripheral, options: nil)
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothDevice.connectivityStatusDidChange, object: nil, userInfo: ["deviceName" : device.name])
        
        self.configureConnectionTimeoutTimer()
    }
    
    func disconnect(fromDevice device: MMBluetoothDevice) {
        guard self.isBluetoothInitialized, !(device.peripheral == nil)
            else { return }
        self.centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    
    // MARK: - Helper Methods
    func clearDevices() {
        self.currentDevice = nil
        self.availableDevices.removeAll()
        NotificationCenter.default.post(name: Notification.Name.MMBluetoothManager.didUpdateAvailableDevices , object: self)
    }
    
    public func getDevice(forUUID uuid: UUID) -> MMBluetoothDevice? {
        for device in self.availableDevices {
            if device.uuid == uuid {
                return device
            }
        }
        return nil
    }
}
