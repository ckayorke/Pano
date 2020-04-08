
import UIKit
import MTProtocolFramework
class DeviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var manipulate: UIButton!
    var pics:[String] = []
    var measures: [CGFloat] = []
    var measureLabels: [UILabel] = []
    
    @IBOutlet weak var lmeasure1: UILabel!
    @IBOutlet weak var lmeasure2: UILabel!
    @IBOutlet weak var lmeasure3: UILabel!
    @IBOutlet weak var lmeasure4: UILabel!
    
    @IBOutlet weak var lmeasure5: UILabel!
    @IBOutlet weak var lmeasure6: UILabel!
    @IBOutlet weak var lmeasure7: UILabel!
    @IBOutlet weak var lmeasure8: UILabel!
    @IBOutlet weak var lmeasure9: UILabel!
    @IBOutlet weak var lmeasure10: UILabel!
    
    
    @IBOutlet weak var editText: UILabel!
    @IBOutlet weak var connectedInfo: UIButton!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBAction func done(_ sender: Any) {
        backTo()
    }
    
    
    @IBAction func backNav(_ sender: Any) {
        backTo()
    }
    
    func backTo(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    /// Contains the current list of reachable devices.
    var devicesList: [MMBluetoothDevice] = []
    
    //var myConnectedDevice:MMBluetoothDevice!
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    // MARK: Message converted
    var thermoMessageConverter = MMThermoMessageConverter()
    var messageConverter = MMMessageConverter()
    
    var mainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        manipulate.isEnabled = false
        manipulate.setTitleColor(UIColor.gray, for: .disabled)
        loadLabels()
        setupNavigationBarItem()
        // Activate Bluetooth scanning
        if(SqliteDbStore.shared.myConnectedDevice == nil  || SqliteDbStore.shared.myConnectedDevice.isConnected == false){
            self.scanForBluetoothDevices()
            editText.isHidden = true
        }
        else{
            editText.isHidden = false
            tabView.isHidden = true
            connectedInfo.setTitle("Connected To: " + SqliteDbStore.shared.dName,for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.teardownObserver()
    }
    

    /*
    // MARK: - Navigation
    */
    func setupNavigationBarItem() {
        let navigationItem = UINavigationItem(title: "Navigation bar")
        //let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(DeviceViewController.scanForBluetoothDevices))
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(DeviceViewController.scanForBluetoothDevices))
        refreshBtn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationItem.rightBarButtonItem = refreshBtn
        
        let p = SqliteDbStore.shared._Project
        navigationItem.title =  p!.Address + "," + p!.City + "," +  p!.State + "," +  p!.ZIPCode
        navBar.setItems([navigationItem], animated: false)
        
        //self.navigationItem.rightBarButtonItems = [
         //   UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(DeviceViewController.scanForBluetoothDevices))
        //]
    }
    
    // MARK: - Bluetooth
    /// Initiates the bluetooth scanning process or shows an error message if bluetooth isn't supported.
    @objc func scanForBluetoothDevices() {
        if(SqliteDbStore.shared.myConnectedDevice != nil  && SqliteDbStore.shared.myConnectedDevice.isConnected){
            let alertController = UIAlertController()
            alertController.title = NSLocalizedString("Device Is Connected", comment: "Device Is Connected")
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if(mainTableView != nil){
            mainTableView.isUserInteractionEnabled = true
            mainTableView.isHidden = false
        }
        
        let btService = MMBluetoothService.shared
        if btService.isSupported() {
            // Try to reconnect to last used device, otherwise collect all devices found
            btService.startDiscovery()
        }
        else {
            // If bluetooth is not supported display warning accordingly
            let alertController = UIAlertController()
            alertController.title = NSLocalizedString("No Bluetooth", comment: "No Bluetooth")
            alertController.message = NSLocalizedString("Bluetooth is not supported on your device.", comment: "Bluetooth is not supported on your device.")
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Observer
    /// Register observer for all changes within the MTBluetoothService, which handles the communication between measuring tool and iOS device.
    func setupObserver() {
        // BL-Device
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.bluetoothManagerDidUpdateDeviceList(notification:)),
                                               name: NSNotification.Name.MMBluetoothDevice.connectivityStatusDidChange,
                                               object: MMBluetoothService.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.bluetoothManagerDidUpdateDeviceList(notification:)),
                                               name: NSNotification.Name.MMBluetoothDevice.stateDidChange,
                                               object: MMBluetoothService.shared)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.didConnectedToDevice(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didConnect,
                                               object: MMBluetoothService.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.didDisconnectedFromDevice(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didDisconnect,
                                               object: MMBluetoothService.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.bluetoothManagerDidUpdateDeviceList(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didFailedToConnectToDevice,
                                               object: MMBluetoothService.shared)
        
        // BL-Manager
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.bluetoothManagerDidUpdateDeviceList(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didUpdateAvailableDevices,
                                               object: MMBluetoothService.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.bluetoothManagerDidUpdateDeviceList(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.hardwareStateChange,
                                               object: MMBluetoothService.shared)
        
        // Messages - Receive all messages send form a measuring device
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.didReceiveMessage(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didReceiveMessage,
                                               object: MMBluetoothService.shared)
        
        // Error
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceViewController.didReceiveError(notification:)),
                                               name: NSNotification.Name.MMBluetoothManager.didReceiveError,
                                               object: MMBluetoothService.shared)
    }
    
    /// Removes all observers associated with this class
    func teardownObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Functsion used by observer
    /// Update internally used list of devices and reloads the tableView
    @objc func bluetoothManagerDidUpdateDeviceList(notification: Notification) {
        self.devicesList.removeAll()
        
        for device in MMBluetoothService.shared.availableDevices {
            self.devicesList.append(device)
        }
        
        //DispatchQueue.main.async {
           // if self.devicesList.count == 0 {
            //    self.title = NSLocalizedString("Searching...", comment: "Searching...")
           // }
            //else if self.devicesList.count == 1 {
            //    self.title = NSLocalizedString("Found one device", comment: "One device")
           // }
            //else {
            //    self.title = String(format: "Found %d", arguments: [self.devicesList.count]) + " " + NSLocalizedString("devices", comment: "devices")
           // }
        //}
        
        self.tabView.reloadData()
    }
    
    /// A measurement-device had been successfully connected
    @objc func didConnectedToDevice(notification: Notification) {
        connectedInfo.setTitle("Connected To: " + SqliteDbStore.shared.dName,for: .normal)//self.displaySingleInfoLabel(text: NSLocalizedString("Connected", comment: "Connected"))
        self.hidePopup()
    }
    
    /// The connected measurement-device were disconnected
    @objc func didDisconnectedFromDevice(notification: Notification) {
        //self.displaySingleInfoLabel(text: NSLocalizedString("Disconnected", comment: "Disconnected"))
       // self.tableView.reloadData()
    }
    
    @objc func didReceiveError(notification: Notification) {
        print("An error occured.", notification.userInfo ?? "-Unknown-")
    }
    
    /// All messages received from the connected device will be processed here
    /// One might use this method for filtering messages, like mode and reference changes against actual measurements.
    
    
    // MARK: - Display measurement results on screen
    func display(distanceMeasurment measurement: MMMeasurement) {
        let distanceMeasurementFormatter = MMMeasurementFormatter()
        var formattedMeasurementString: String = ""
        switch measurement.resultType.associatedDimensionType() {
        case .angle:
            formattedMeasurementString = distanceMeasurementFormatter.stringRepresentation(forAngle: measurement.resultValue, in: .degree)
        case .distance:
            formattedMeasurementString = distanceMeasurementFormatter.stringRepresentation(forDistance: measurement.resultValue, in: .meter)
            
            //editText.text = formattedMeasurementString
            updateView(measure:measurement.resultValue)
            
        
        case .area:
            formattedMeasurementString = distanceMeasurementFormatter.stringRepresentation(forArea: measurement.resultValue, in: .meter)
        case .volume:
            formattedMeasurementString = distanceMeasurementFormatter.stringRepresentation(forVolumen: measurement.resultValue, in: .meter)
        default:
            formattedMeasurementString = String(format: "%.2f", arguments: [measurement.resultValue])
        }
        
        print(formattedMeasurementString)

    }
    
    @objc func didReceiveMessage(notification: Notification) {
        guard let userInfo = notification.userInfo
            else { return }
        
        if let message = userInfo[Notification.UserInfoKey.MTMessage] as? MTSyncInputMessage {
            if message.laserOn > 0 {
               // self.displaySingleInfoLabel(text: NSLocalizedString("Measuring...", comment: "Measuring..."))
            }
            else if let measurement = messageConverter.measurement(fromMessage: message, withReferenceTimeInterval: MMBluetoothService.shared.currentDevice?.birthDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970) {
                if !(measurement.resultValue == 0) {
                   self.display(distanceMeasurment: measurement)
                }
            }
            else {
                // Measurement with unknown type had been made
            }
        }
        else if let message = userInfo[Notification.UserInfoKey.MTMessage] as? MTExchangeDataInputMessage {
            if message.laserOn > 0 {
                //self.displaySingleInfoLabel(text: NSLocalizedString("Measuring...", comment: "Measuring..."))
            }
            else if let measurement = messageConverter.measurement(fromMessage: message) {
                if !(measurement.resultValue == 0) {
                    self.display(distanceMeasurment: measurement)
                }
            }
        }
        else if let message = userInfo[Notification.UserInfoKey.MTMessage] as? MTExchangeDataThermoInputMessage {
            if thermoMessageConverter.measurement(fromMessage: message) != nil {
                //self.display(thermalMeasurement: measurement)
            }
            else {
                // Transmitting data in 4 packages will be done right now
               // self.displaySingleInfoLabel(text: NSLocalizedString("Finishing processing...", comment: "Finishing processing..."))
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         mainTableView = tableView
        let cell = tableView.dequeueReusableCell(withIdentifier:"boschDeviceCell", for: indexPath) as! boschDeviceCell
        cell.note.text  = devicesList[indexPath.row].name
        cell.connect.setOn(false, animated: false)
        cell.connect.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        cell.connect.tag = indexPath.row
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainTableView = tableView
        handleConnect(row:indexPath.row)
        //tableView.isUserInteractionEnabled = false
    }
    
    // MARK: Waiting - popup
    fileprivate var isPopupPresented: Bool = false
    
    func showPopup(withTitle title: String) {
        let alert = UIAlertController(title: nil, message: title, preferredStyle: .alert)
        // Add an activity indicator to the alert controller and start animating it
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating();
        alert.view.addSubview(activityIndicator)
        self.isPopupPresented = true
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Hides the last presented popup.
    func hidePopup() {
        if self.isPopupPresented {
            self.dismiss(animated: true, completion: nil)
            self.isPopupPresented = false
        }
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        if(value){
            let id = mySwitch.tag
            handleConnect(row:id)
        }
    }
    
    func handleConnect(row:Int){
        let bluetoothService = MMBluetoothService.shared
        // One might check if bluetooth services are enabled
        if bluetoothService.isEnabled() {
            // One might get the reference within MTBluetoothService.bluetoothDevices array
            let device = self.devicesList[row]
            SqliteDbStore.shared.dName = device.name
            if let btDevice = bluetoothService.getDevice(forUUID: device.uuid) {
                SqliteDbStore.shared.myConnectedDevice = btDevice
                if btDevice.isConnected {
                    // Disconnect device if it was already connected
                    //                    bluetoothService.disconnect(btDevice)
                    bluetoothService.disconnect(fromDevice: btDevice)
                }
                else {
                    // Try to connect with device and show waiting indicator
                    
                    bluetoothService.connect(toDevice: btDevice)
                    self.showPopup(withTitle: NSLocalizedString("Connecting...", comment: "Connecting..."))
                    mainTableView.isUserInteractionEnabled = false
                    mainTableView.isHidden = true
                    editText.isHidden = false
                }
            }
        }
    }
    
    func updateView(measure:CGFloat){
        var m = measure
        m = m * 3.28084
        let feet = Int(m)
        let inch = m - CGFloat(feet)
        
        let inche =  NSString(format:"%.2f", inch * 12)
        measures.append(measure)
        if(measures.count < 4) {
            if(measures.count == 1){
                measureLabels[measures.count - 1].text = "Length: \(feet)'\( inche)\'\'"
                editText.text = "Confirm Length Measurement"
            }
            else if(measures.count == 2){
                measureLabels[measures.count - 1].text = "Confirmed Length: \(feet)'\( inche)\'\'"
                editText.text = "Measure Width Of Room"
            }
            else if(measures.count == 3){
               measureLabels[measures.count - 1].text = "Width: \(feet)'\( inche)\'\'"
                editText.text = "Confirm Width Measurement"
            }
            SqliteDbStore.shared._Room!.RoomLength = SqliteDbStore.shared._Room!.RoomLength + ", " + "\(measure)"
            _ = SqliteDbStore.shared.updateRoom(_Id: SqliteDbStore.shared._Room!.RoomId, room: SqliteDbStore.shared._Room!)
            manipulate.isEnabled = false
            manipulate.setTitleColor(UIColor.gray, for: .disabled)
            
        }
        else if (measures.count < 11){
            if(measures.count == 4){
                 measureLabels[measures.count - 1].text = "Confirmed Width: \(feet)'\( inche)\'\'"
            }
            else {
                measureLabels[measures.count - 1].text = "Extra Wall\(measures.count - 3):  \(feet)'\( inche)\'\'"
            }
            SqliteDbStore.shared._Room!.RoomLength = SqliteDbStore.shared._Room!.RoomLength + ", " + "\(measure)"
            _ = SqliteDbStore.shared.updateRoom(_Id: SqliteDbStore.shared._Room!.RoomId, room: SqliteDbStore.shared._Room!);
            
            if(measures.count > 3) {
              manipulate.isEnabled = true
              
            }
            if(measures.count > 9){
                loopMeasureEnd()
            }
            else {
               loopMeasure()
            }
        }
    }
    
    func loopMeasureEnd(){
        let title = "COMPLEX ROOM"
        let msg = "The Room Is Too Complex. If There Are Additional Walls, Try To Make 2 Rooms."
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
    
        }))
        self.present(alert, animated: true)
    }
   func loopMeasure(){
    let title = "MEASUREMENT"
    let msg = "Are there any more wall to measure?"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
            self.editText.text =  "Optional: Additional Measurement " + String(self.measures.count - 3)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
             self.editText.text =  ""
             self.backTo()
        }))
        self.present(alert, animated: true)
    }
    
    func loadLabels(){
        measureLabels.append(lmeasure1)
        measureLabels.append(lmeasure2)
        measureLabels.append(lmeasure4)
        measureLabels.append(lmeasure3)
        measureLabels.append(lmeasure5)
        measureLabels.append(lmeasure6)
        measureLabels.append(lmeasure7)
        measureLabels.append(lmeasure8)
        measureLabels.append(lmeasure9)
        measureLabels.append(lmeasure10)
    }
    override open var shouldAutorotate: Bool {
           return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
}
