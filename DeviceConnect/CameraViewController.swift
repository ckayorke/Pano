
import UIKit
class CameraViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var roomName:String!
    private var objects: [TableCellObject] = []
    private var storageInfo: HttpStorageInfo?
    private var batteryLevel: NSNumber?
    private var httpConnection: HttpConnection?
    @IBOutlet weak var btnTitle: UIButton!
    private var imageData: Data?
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var motionJpegView: UIImageView!
    @IBOutlet var contentsView: UITableView!
    @IBOutlet var logView: UITextView!
   
    @IBOutlet weak var _done: UIButton!
    @IBAction func done(_ sender: Any) {
        if(SqliteDbStore.shared.fromSelected == 2){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
                   newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
        else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
                   newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
       
    }
    @IBAction func back(_ sender: Any) {
        if(SqliteDbStore.shared.fromSelected == 2){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
                   newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
        else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
                   newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
        
    }
    func appendLog(_ text: String?) {
        logView.text = "\(logView.text ?? "")\(text ?? "")\n"
        logView.scrollRangeToVisible(NSRange(location: logView.text.count, length: 0))
    }
  
    @IBAction func onCaptureClicked(_ sender: Any) {
        
        _done.isEnabled = false
        _done.setTitleColor(UIColor.gray, for: .disabled)
        let senderButton = sender as? UIButton
        senderButton?.isEnabled = false
        setResolution()
        self.appendLog("Picture taken.....")
        self.appendLog("Please wait.....")
        dispatch_async_default({
            // Start shooting process
            let info = self.httpConnection?.takePicture()
            if info != nil {
                dispatch_async_main({
                    self.appendLog("System processing")
                })
                let object = TableCellObject.objectWithInfo(info)
                let thumbData = self.httpConnection?.getThumb(info?.file_id)
                if let thumbData = thumbData {
                   object.thumbnail = UIImage(data: thumbData)
                }
                self.objects.insert(object, at: 0)
                let pos = IndexPath(row: 0, section: 1)
                dispatch_async_main({
                    self.appendLog("Retreving the picture")
                    self.contentsView.insertRows(at: [pos], with: .right)
                    for i in 1..<self.objects.count {
                        let path = IndexPath(row: i, section: 1)
                        self.contentsView.reloadRows(at: [path], with: .none)
                    }
                })
                
                if CODE_JPEG == self.objects[0].objectInfo?.file_format {
                    dispatch_async_default({
                        let request2 = self.httpConnection?.createExecuteRequest()
                        let session2 = HttpSession(request: request2)
                        self.getObject(self.objects[0].objectInfo, with: session2)
                    })
                }
            }
            dispatch_async_main({
                // Enable Capture button and Disconnect button
                //senderButton?.isEnabled = true
                if let info = info {
                    self.appendLog("execShutter[result:\(info)]")
                }
            })
        })
    }
    
    func getObject(_ imageInfo: HttpImageInfo?, with session: HttpSession?) {
        let fileUri = imageInfo?.file_id
        // Semaphore for synchronization (cannot be entered until signal is called)
        let semaphore = DispatchSemaphore(value: 0)
        session?.getResizedImageObject(fileUri, onStart: { totalLength in
            // Callback before object-data reception.
            print(String(format: "getObject(%@) will received %zd bytes.", fileUri ?? "", totalLength))
        }, onWrite: { totalBytesWritten, totalBytesExpectedToWrite in
            // Callback for each chunks.
            DispatchQueue.main.async(execute: {
            // Update progress.
                let j = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                self.appendLog("Processing....\(j)")
              //self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            })
        }, onFinish: { location in
            if let location = location {
                self.imageData = try? Data(contentsOf: location)
                let image2 = UIImage(data: self.imageData!)
                self.processImage(image:image2!)
                self.countNumberOfImages()
                self._done.isEnabled = true
            }
            semaphore.signal()
        })
        // Wait until signal is called
        _ = (semaphore.wait(timeout: DispatchTime.distantFuture) == .success ? 0 : -1)
    }
    
    func processImage(image:UIImage){
        getName()
        let name = roomName
        let file = "DataToZip"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file2 = dir.appendingPathComponent(file)
            let exists = FileManager.default.fileExists(atPath: file2.path)
            if(exists){
                let fileManager = FileManager.default
                do {
                    let filePaths = try fileManager.contentsOfDirectory(atPath: file2.path)
                    for filePath in filePaths {
                        if(filePath == name){
                            try fileManager.removeItem(atPath: file2.path + "/" + filePath)
                        }
                    }
                }
                catch {
                    print("Could not clear DataToZip folder: \(error)")
                }
            }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "DataToZip/" + name!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = UIImageJPEGRepresentation(image, 1),!FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try data.write(to: fileURL)
                    print("file saved")
                    
                    
                    if(SqliteDbStore.shared.fromSelected == 2){
                        let picName = SqliteDbStore.shared._Room!.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if(picName.count == 0){
                            var room3  = SqliteDbStore.shared._Room!
                            room3.PictureName = name!
                            SqliteDbStore.shared._Room! = room3
                            _ =  SqliteDbStore.shared.updateRoom(_Id: room3.RoomId, room: room3)
                        }
                        else{
                            var room3  = SqliteDbStore.shared._Room!
                            room3.PictureName =   room3.PictureName + "," + name!
                            SqliteDbStore.shared._Room! = room3
                            _ = SqliteDbStore.shared.updateRoom(_Id: room3.RoomId, room: room3)
                        }
                    }
                    else{
                        let picName = SqliteDbStore.shared._Project!.Outside3DPictures.trimmingCharacters(in: .whitespacesAndNewlines)
                        if(picName.count == 0){
                            var projec  = SqliteDbStore.shared._Project!
                           projec.Outside3DPictures = name!
                            SqliteDbStore.shared._Project! = projec
                            _ =  SqliteDbStore.shared.updateProject(_Id: projec.Id, project: projec)
                        }
                        else{
                            var projec  = SqliteDbStore.shared._Project!
                            projec.Outside3DPictures =   projec.Outside3DPictures  + "," + name!
                            SqliteDbStore.shared._Project! = projec
                            _ =  SqliteDbStore.shared.updateProject(_Id: projec.Id, project: projec)
                        }
                    }
                    self.captureButton.isEnabled = true
                }
                catch {
                    print("error saving file:", error)
                }
            }
        }
        
    }
    
    func countNumberOfImages(){
        let file = "DataToZip"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file2 = dir.appendingPathComponent(file)
            let fileManager = FileManager.default
            do {
                let filePaths = try fileManager.contentsOfDirectory(atPath: file2.path)
                for filePath in filePaths {
                    print(file2.path + "/" + filePath)
                }
            }
            catch {
                print("Could not clear DataToZip folder: \(error)")
            }
        }
    }
    func enumerateImages() {
        objects.removeAll()
        httpConnection?.getDeviceInfo({ info in
            // "GetDeviceInfo" completion callback.
            dispatch_async_main({
                if let info = info {
                    self.appendLog("DeviceInfo:\(info)")
                }
            })
        })
        
        dispatch_async_default({
            // Create "Waiting" indicator
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            indicator.color = UIColor.gray
            dispatch_async_main({
                // Set indicator to be displayed in the center of the table view
                let w = Float(indicator.frame.size.width)
                let h = Float(indicator.frame.size.height)
                let x = Float(self.contentsView.frame.size.width / 2 - CGFloat(w / 2))
                let y = Float(self.contentsView.frame.size.height / 2 - CGFloat(h / 2))
                indicator.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(w), height: CGFloat(h))
                // Start indicator animation
                self.contentsView.addSubview(indicator)
                indicator.startAnimating()
            })
            
            // Get storage information.
            self.storageInfo = self.httpConnection?.getStorageInfo()
            
            // Get Battery level.
            self.batteryLevel = self.httpConnection?.getBatteryLevel()
            
            // Get object informations for primary images.
            let imageInfoes = self.httpConnection?.getImageInfoes()
            
            dispatch_async_main({
                self.appendLog(String(format: "getImageInfoes() received %zd infoes.", imageInfoes?.count ?? 0))
            })
            
            // Get thumbnail images for each primary images.
            let maxCount = min(imageInfoes?.count ?? 0, 30)
            for i in 0..<maxCount {
                let info = imageInfoes?[i] as? HttpImageInfo
                let object = TableCellObject.objectWithInfo(info)
                let thumbData = self.httpConnection?.getThumb(info?.file_id)
                if let thumbData = thumbData {
                    object.thumbnail = UIImage(data: thumbData)
                }
                self.objects.append(object)
                
                dispatch_async_main({
                    self.appendLog(info?.description)
                    self.appendLog(String(format: "imageInfoes: %ld/%ld", i + 1, maxCount))
                })
            }
            dispatch_async_main({
                // Stop indicator animation
                indicator.stopAnimating()
                
                self.contentsView.reloadData()
                
                // Enable Connect button
                self.captureButton.isEnabled = true
            })
            
            
            // Start live view display
            self.httpConnection?.startLiveView({ frameData in
                dispatch_async_main({
                    var image: UIImage? = nil
                    if let frameData = frameData {
                        image = UIImage(data: frameData)
                    }
                    self.motionJpegView.image = image
                })
            })
            
        })
    }
    
    func connect() {
        appendLog("connecting to 192.168.1.1...")
        // Setup `target IP`(camera IP).
        // Product default is "192.168.1.1".
        httpConnection?.setTargetIp("192.168.1.1")
        // Connect to target.
        httpConnection?.connect({ connected in
            // "Connect" and "OpenSession" completion callback.
            if connected {
                // "Connect" is succeeded.
                //
                dispatch_async_main({
                    self.appendLog("Connected. Getting live view...")
                    self.appendLog("Please wait...")
                })
                // Start enum objects.
                self.enumerateImages()
                //self.setResolution()
            } else {
                // "Connect" is failed.
                dispatch_async_main({
                    self.appendLog("Connection failed.")
                    self.nav()
                })
            }
        })
    }
    
    
    func disconnect() {
        appendLog("disconnecting...")
        httpConnection?.close({
            // "CloseSession" and "Close" completion callback.
            dispatch_async_main({
                self.captureButton.isEnabled = false
                self.motionJpegView.image = nil
                self.appendLog("disconnected.")
                self.objects.removeAll()
                self.contentsView.reloadData()
            })
        })
    }

    func setResolution(){
        let resolutionId = SqliteDbStore.shared._Project!.Resolution
        if(resolutionId == 1){
            self.httpConnection?.setImageFormat(2048, height: 1024)
            self.storageInfo = self.httpConnection?.getStorageInfo()
            if let image_width = self.storageInfo?.image_width, let image_height = self.storageInfo?.image_height {
                self.appendLog(String(format: "image size changed[result:%lux%lu]", image_width, image_height))
            }
        }
        else{
            self.httpConnection?.setImageFormat(5376, height: 2688)
            self.storageInfo = self.httpConnection?.getStorageInfo()
            if let image_width = self.storageInfo?.image_width, let image_height = self.storageInfo?.image_height {
                self.appendLog(String(format: "image size changed[result:%lux%lu]", image_width, image_height))
            }
        }
    }

    // MARK: - UITableViewDataSource delegates.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SqliteDbStore.shared.object = objects[indexPath.row]
        let o = objects[indexPath.row]
        if CODE_JPEG == o.objectInfo?.file_format {
            dispatch_async_default({
                let request2 = self.httpConnection?.createExecuteRequest()
                let session2 = HttpSession(request: request2)
                self.getObject(SqliteDbStore.shared.object?.objectInfo, with: session2)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.httpConnection?.connected() == false {
                return 0
            } else {
                return 1
            }
        }
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TableCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "cameraInfo") as? TableCell
            if let free_space_in_images = storageInfo?.free_space_in_images {
                cell?.textLabel?.text = String(format: "%ld[shots] %ld/%ld[MB] free", free_space_in_images, storageInfo?.free_space_in_bytes ?? 0 / 1024 / 1024, storageInfo?.max_capacity ?? 0 / 1024 / 1024)
            }
            cell?.detailTextLabel?.text = String(format: "BATT %.0f %%", batteryLevel?.doubleValue ?? 0.0 * 100.0)
        } else {
            // NSDateFormatter to display photographing date.
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .medium
            
            let obj = objects[indexPath.row] as TableCellObject
            cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as? TableCell
            if let file_name = obj.objectInfo?.file_name {
                cell?.textLabel?.text = "\(file_name)"
            }
            if let capture_date = obj.objectInfo?.capture_date {
                cell?.detailTextLabel?.text = df.string(from: capture_date)
            }
            cell?.imageView?.image = obj.thumbnail
            cell?.objectIndex = UInt32(indexPath.row)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let path = indexPath
        let pathArray = [path]
        dispatch_async_default({
            let object = self.objects[path.row] as TableCellObject
            if self.httpConnection?.deleteImage(object.objectInfo) != nil {
                dispatch_async_main({
                    // Delete data source
                    self.objects.remove(at: path.row)
                    // Delete row from table
                    self.contentsView.deleteRows(at: pathArray, with: .automatic)
                    for i in path.row..<self.objects.count {
                        let index = IndexPath(row: i, section: path.section)
                        self.contentsView.reloadRows(at: [index], with: .top)
                    }
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        getName()
        objects = []
        httpConnection = HttpConnection()
        contentsView.dataSource = self
        logView.layoutManager.allowsNonContiguousLayout = false
        captureButton.isEnabled = false
        _done.isEnabled = false
        _done.setTitleColor(UIColor.gray, for: .disabled)
        
        if(SqliteDbStore.shared.fromSelected == 2){
           let msg = SqliteDbStore.shared._Room!.LevelName + ": " + SqliteDbStore.shared._Room!.Name
          btnTitle.setTitle(msg, for: .normal)
        }
        else{
            let p = SqliteDbStore.shared._Project
            let msg = p!.Address + "," + p!.City + "," +  p!.State + "," +  p!.ZIPCode
           btnTitle.setTitle(msg, for: .normal)
        }
        connect()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        disconnect()
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        httpConnection?.restartLiveView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func nav(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func getName(){
        let Item  = SqliteDbStore.shared._Project;
        if(SqliteDbStore.shared.fromSelected == 2){
             let r2 = SqliteDbStore.shared._Room
            if(Item!.Status == 0){
                 let picName = r2!.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                 let ms = r2!.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                 let k = picName.lowercased()
                 if(k.count == 0){
                     let name = r2!.Name
                     let name2 = name.replacingOccurrences(of: " ", with: "")
                     let name3 = name2 + "_Pro_\(r2!.ProjectId)_Lev_\(r2!.LevelId)_Pic_11"
                     roomName = name3 + ".jpg"
                 }
                 else{
                     let names = ms.split(separator: ",")
                     let name = r2!.Name
                     let name2 = name.replacingOccurrences(of: " ", with: "")
                     let name3 = name2 + "_Pro_\(r2!.ProjectId)_Lev_\(r2!.LevelId)_Pic_1" + String(names.count + 1)
                     roomName = name3 + ".jpg";
                 }
           }
            else{
                let picName = r2!.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                let ms = r2!.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                let k = picName.lowercased()
                if(k.count == 0){
                    let name = r2!.Name
                    let name2 = name.replacingOccurrences(of: " ", with: "")
                    let name3 = name2 + "_Pro_\(r2!.ProjectId)_Lev_\(r2!.LevelId)_Pic_21"
                    roomName = name3 + ".jpg"
                }
                else{
                    let names = ms.split(separator: ",")
                    let name = r2!.Name
                    let name2 = name.replacingOccurrences(of: " ", with: "")
                    let name3 = name2 + "_Pro_\(r2!.ProjectId)_Lev_\(r2!.LevelId)_Pic_2" + String(names.count + 1)
                    roomName = name3 + ".jpg";
                }
            }
        }
        else{
            if(Item?.Status == 0){
                let k = Item!.Outside3DPictures.trimmingCharacters(in: .whitespacesAndNewlines)
                if (k.count == 0) {
                    let name = "_Pro_\(Item!.ProjectId)_3D_11"
                    roomName = name + ".jpg"
                    return;
                }
                else {
                    let names = Item!.Outside3DPictures.split(separator: ",")
                    let name = "_Pro_\(Item!.ProjectId )_3D_1" + String(names.count + 1);
                    roomName = name + ".jpg";
                    return;
                }
            }
            else{
                let k = Item!.Outside3DPictures.trimmingCharacters(in: .whitespacesAndNewlines)
                if (k.count == 0) {
                    let name = "_Pro_\(Item!.ProjectId)_3D_21"
                    roomName = name + ".jpg"
                    return;
                }
                else {
                    let names = Item!.Outside3DPictures.split(separator: ",")
                    let name = "_Pro_\(Item!.ProjectId )_3D_2" + String(names.count + 1);
                    roomName = name + ".jpg";
                    return;
                }
            }
        }
    }
    
    override open var shouldAutorotate: Bool {
           return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
}

@inline(__always) private func dispatch_async_main(_ block: @escaping () -> ()) {
    DispatchQueue.main.async(execute: block)
}

@inline(__always) private func dispatch_async_default(_ block: @escaping () -> ()) {
    DispatchQueue.global(qos: .default).async(execute: block)
}
