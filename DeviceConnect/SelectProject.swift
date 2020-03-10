
import UIKit
import Photos
import SystemConfiguration.CaptiveNetwork
import CoreLocation
class SelectProject: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate  {
    
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    var ssid: String = "notconnected"
    var  pictureNames = [String]()
    var levels = [Level]()
    var tabView:UITableView?
    var has3DPicture:Bool = true;

    @IBOutlet weak var base: UIButton!
    @IBOutlet weak var firstfloor: UIButton!
    @IBOutlet weak var secondfloor: UIButton!
    @IBOutlet weak var thirdfloor: UIButton!
    @IBOutlet weak var fourthfloor: UIButton!
    @IBOutlet weak var bar: UIButton!
    @IBOutlet weak var btnCompleted: UIButton!
    @IBOutlet weak var btnSurrounding: UIButton!
    @IBAction func AddBasement(_ sender: Any) {
        CreateLevel(name: "BASEMENT", levId: 1)
    }
    @IBAction func AddFirstFloor(_ sender: Any) {
         CreateLevel(name: "FIRST FLOOR", levId: 2)
    }
    @IBAction func AddSecondFloor(_ sender: Any) {
         CreateLevel(name: "SECOND FLOOR", levId: 3)
    }
    @IBAction func AddThirdFloor(_ sender: Any) {
        CreateLevel(name: "THIRD FLOOR", levId: 4)
    }
    @IBAction func AddFourthFloor(_ sender: Any) {
        CreateLevel(name: "FOURTH FLOOR", levId: 5)
    }
    @IBAction func TakeSurroundPic(_ sender: Any) {
        picLoader()
    }
    @IBAction func CheckForCompleteness(_ sender: Any) {
        checkProjectComplete()
    }
    
    @IBAction func navBack(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func takeEntrancePic(_ sender: Any) {
        checkCamConnection()
    }
    

    func picLoader(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.processImage(image:pickedImage)
                self.countNumberOfImages()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
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
    
    func processImage(image:UIImage){
        let name = getOutsideImageNumber()
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
            let fileName = "DataToZip/" + name
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = UIImageJPEGRepresentation(image, 1),!FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try data.write(to: fileURL)
                    print("file saved")
                    self.pictureNames.append(name);
                    var project = SqliteDbStore.shared._Project
                    if(self.pictureNames.count<2){
                        project!.OutsidePictures = name
                        SqliteDbStore.shared.updateProject(_Id: project!.ProjectId, project: project!);
                        SqliteDbStore.shared._Project = project
                        return
                    }
                    
                    project!.OutsidePictures = self.pictureNames.joined(separator:",")
                    project!.OutsidePictures  = project!.OutsidePictures.trimmingCharacters(in: .whitespacesAndNewlines)
                    SqliteDbStore.shared.updateProject(_Id: project!.ProjectId, project: project!);
                    SqliteDbStore.shared._Project = project
                }
                catch {
                    print("error saving file:", error)
                }
            }
        }
        
    }
    
    func getOutsideImageNumber() -> String{
        let project = SqliteDbStore.shared._Project
        var ms = project!.OutsidePictures;
        ms = ms.trimmingCharacters(in: .whitespacesAndNewlines)
        if(project!.Status == 0) {
            if (ms.count == 0) {
                return "Proj_" + String(project!.ProjectId) + "_Out_11.jpg"
            }
            let msArray = ms.split(separator: ",")
            pictureNames.removeAll()
            for n in msArray {
                pictureNames.append(n.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let name = "Proj_" + String(project!.ProjectId) + "_Out_1" + String(msArray.count + 1) + ".jpg"
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else{
            if (ms.count == 0) {
                return "Proj_" + String(project!.ProjectId) + "_Out_21.jpg";
            }
            let msArray = ms.split(separator: ",")
            pictureNames.removeAll()
            for n in  msArray {
                pictureNames.append(n.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let name = "Proj_" + String(project!.ProjectId) + "_Out_2" + String(msArray.count + 1) + ".jpg";
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func createFolder(){
        let fileManager = FileManager.default
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesPath = documentsURL.appendingPathComponent("DataToZip")
        
        if(directoryExistsAtPath(imagesPath.absoluteString) == false){
            do
            {
                try FileManager.default.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tabView = tableView
        return levels.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let level = levels[indexPath.row];
        let cell = UITableViewCell()
        cell.textLabel?.text = level.Name
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(has3DPicture == false){
            has3DPictureAlert();
            return;
        }
        
        let level = levels[indexPath.row];
        SqliteDbStore.shared._Level = level
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createFolder();
        let p = SqliteDbStore.shared._Project
        let address = p!.Address + "," + p!.City + "," +  p!.State + "," +  p!.ZIPCode
        bar.setTitle(address,for: .normal)
        levels =  SqliteDbStore.shared.queryAllLevel(_Id: SqliteDbStore.shared._Project!.ProjectId)
        for l in levels {
            if(l.Name.contains("BASEMENT")){
                base.isEnabled = false
                base.setTitleColor(UIColor.gray, for: .disabled)
            }
            else if(l.Name.contains("FIRST FLOOR")){
                firstfloor.isEnabled = false
                firstfloor.setTitleColor(UIColor.gray, for: .disabled)
            }
            else if(l.Name.contains("SECOND FLOOR")){
                secondfloor.isEnabled = false
                secondfloor.setTitleColor(UIColor.gray, for: .disabled)
            }
            else if(l.Name.contains("THIRD FLOOR")){
                thirdfloor.isEnabled = false
                thirdfloor.setTitleColor(UIColor.gray, for: .disabled)
            }
            else if(l.Name.contains("FOURTH FLOOR")){
                fourthfloor.isEnabled = false
                fourthfloor.setTitleColor(UIColor.gray, for: .disabled)
            }
        }
        
        if(p?.Outside3DPictures.count == 0  && SqliteDbStore.shared._Project?.Status == 0){
                has3DPicture = false;
                base.isEnabled = false
                base.setTitleColor(UIColor.gray, for: .disabled)
            
                firstfloor.isEnabled = false
                firstfloor.setTitleColor(UIColor.gray, for: .disabled)
            
                secondfloor.isEnabled = false
                secondfloor.setTitleColor(UIColor.gray, for: .disabled)
            
                thirdfloor.isEnabled = false
                thirdfloor.setTitleColor(UIColor.gray, for: .disabled)
            
                fourthfloor.isEnabled = false
                fourthfloor.setTitleColor(UIColor.gray, for: .disabled)
            
                btnCompleted.isEnabled = false
                btnCompleted.setTitleColor(UIColor.gray, for: .disabled)
            
                btnSurrounding.isEnabled = false
                btnSurrounding.setTitleColor(UIColor.gray, for: .disabled)
            
        }
        
        //=====================================================================
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedWhenInUse {
                updateWiFi()
            }
            else {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }
        }
        else {
            updateWiFi()
        }
        //=====================================================================
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    func updateWiFi(){
           print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
           ssid =  (currentNetworkInfos?.first?.ssid)!
           //bssidLabel.text = currentNetworkInfos?.first?.bssid
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if status == .authorizedWhenInUse {
               updateWiFi()
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPermission()
    }

    func CreateLevel(name: String, levId:Int){
        let levls = SqliteDbStore.shared.queryAllLevel(_Id:SqliteDbStore.shared._Project!.ProjectId)
        for l in  levls {
            if(l.LevelId == levId){
                return
            }
        }
        let pId = SqliteDbStore.shared._Project!.ProjectId
        let newLevel = Level(Id: -1,LevelId: levId,ProjectId: pId,Name:name,Status: 0,Status2: "Created",PicName: "")
        SqliteDbStore.shared.addlevel(level: newLevel)
        levels =  SqliteDbStore.shared.queryAllLevel(_Id: SqliteDbStore.shared._Project!.ProjectId)
        nav()
    }
    
    func nav(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Good")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
            (newStatus) in print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                  print("Good")
                }
            })
            case .restricted:
                print("User do not have access to photo album.")
            case .denied:
                print("User has denied the permission.")
            }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: self.tabView)
            if let indexPath = self.tabView!.indexPathForRow(at: touchPoint) {
                print("Long pressed row: \(indexPath.row)")
                let level = levels[indexPath.row];
                let title = "DELETE CONFIRMATION"
                let alert = UIAlertController(title: title, message: "Are you sure you want to delete \(level.Name)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: level.ProjectId, _lId: level.LevelId);
                    for r2 in allRooms{
                        _ = SqliteDbStore.shared.deleteRoom(_Id: r2.Id)
                    }
                    _ = SqliteDbStore.shared.deleteLevel(_Id: level.Id)
                    self.nav()
                    
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                    
                }))
                 self.present(alert, animated: true)
            }
        }
    }
    
    
    func checkProjectComplete(){
        var pError = ProjectError()
        let p = SqliteDbStore.shared._Project
        var req = hasRequired(projectId: p!.ProjectId)
        if(p?.Status != 0){
            req = ""
        }
        if (p!.Completed == "Yes" && (p!.OutsidePictures != "") && (req == "")) {
        }
        else{
            pError.ProjectId = p!.ProjectId
            if (p!.Completed == "Yes") {
                pError.MissingCheck = "No"
            }
            else{
                pError.MissingCheck = "Yes"
            }
            if  (p!.OutsidePictures=="") {
                pError.MissingOutsidePics = "Yes"
            }
            if(req.count > 0){
                pError.BK = req
            }
        }
        
        //var needsCheck:[Int] = []
        let rooms = SqliteDbStore.shared.queryAllRooms()
        
        for r in rooms {
            if(r.ProjectId == SqliteDbStore.shared._Project?.ProjectId){
                
                let name = r.Name.trimmingCharacters(in: .whitespacesAndNewlines)
                let name2 = name.lowercased()
                
                let PictureName = r.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                let PictureName2 = PictureName.lowercased()
                
                let RoomLength = r.RoomLength.trimmingCharacters(in: .whitespacesAndNewlines)
                let RoomLength2 = RoomLength.lowercased()
                
                if(name2.contains("crawl space") || name2.contains("attic") || name2.contains("staircase")){
                    continue
                }
                else if((PictureName2 != "") && (RoomLength2 != "")){
                }
                else{
                    pError.Address = r.Address
                    if(PictureName2 == "" ){
                        if(pError.MissingPicture == ""){
                            pError.MissingPicture = r.Name
                        }
                        else{
                            pError.MissingPicture = pError.MissingPicture + ", " + r.Name
                        }
                    }
                    if(RoomLength2 == ""){
                        if(pError.MissingMeasure == ""){
                            pError.MissingMeasure =  r.Name
                        }
                        else{
                            pError.MissingMeasure = pError.MissingMeasure + ", " + r.Name
                        }
                    }
                }
            }
        }
        
        
        let levels = SqliteDbStore.shared.queryAllLevel(_Id: SqliteDbStore.shared._Project!.ProjectId)
        for l in levels {
            var isGoodLevel = false
            for r in rooms {
                if (r.ProjectId == l.ProjectId && r.LevelId == l.LevelId) {
                    isGoodLevel = true
                    break
                }
            }
            if(isGoodLevel==false) {
                if(pError.EmptyLevels == ""){
                    pError.EmptyLevels = l.Name
                }
                else{
                   pError.EmptyLevels = pError.EmptyLevels + ", " + l.Name
                }
            }
        }
        
        

        var isGoodProject = false
        for r in rooms{
            if (r.ProjectId == p!.ProjectId) {
                isGoodProject = true;
                break;
            }
        }
        
        
        if(isGoodProject == false) {
            pError.ProjectId = p!.ProjectId
            pError.Address = p!.Address
        }
        pError.Address = p!.Address
        pError.City = p!.City  + ", " + p!.State + ", " + p!.ZIPCode
        
        
        let bk = pError.BK.trimmingCharacters(in: .whitespacesAndNewlines)
        let eptl = pError.EmptyLevels.trimmingCharacters(in: .whitespacesAndNewlines)
        let mMeasure = pError.MissingMeasure.trimmingCharacters(in: .whitespacesAndNewlines)
        let mPicture = pError.MissingPicture.trimmingCharacters(in: .whitespacesAndNewlines)
        let mOutPicture = pError.MissingOutsidePics.trimmingCharacters(in: .whitespacesAndNewlines)
        if((bk != "") || (eptl != "") ||  (mMeasure != "" ) || (mPicture != "") || (mOutPicture != "No")){
            showDialog(pError: pError)
        }
        else{
            let title2 = "PROJECT COMPLETION CHECK"
            let msg = "Project is complete."
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert2, animated: true)
        }
    }
    
    func hasRequired(projectId:Int)-> String{
        let rooms = SqliteDbStore.shared.queryAllRooms()
        var bath = 0
        var kitchen = 0
        var bed = 0
    
        for r in rooms {
             if(r.ProjectId == projectId){
                let name = r.Name.trimmingCharacters(in: .whitespacesAndNewlines)
                let name2 = name.lowercased()
                 if(name2.contains("bathroom")){
                     bath = 1
                 }
                 else if(name2.contains("kitchen")){
                    kitchen = 1
                 }
                 else if(name2.contains("bedroom")){
                    bed = 1
                 }
             }
        }
        var req = ""
        if(bed == 0){
           req = "Bedroom"
        }
        if(bath == 0){
           req = req + ", Bathroom"
        }
        if(kitchen == 0){
           req = req + ", Kitchen"
        }
        return req
    }
    
    func showDialog(pError: ProjectError){
        SqliteDbStore.shared.projectErrors.removeAll()
        SqliteDbStore.shared.projectErrors.append(pError)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "TreeSingleViewController") as! TreeSingleViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    override open var shouldAutorotate: Bool {
           return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    
    func has3DPictureAlert(){
        let title2 = "ENTRANCE PHOTO VALIDATION"
        let msg = "You must take entrance picture before continue."
        let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert2, animated: true)
    }
    
    func checkCamConnection(){
        let p = getWiFiSsid()
        if (p!.contains("THETAYJ")   &&  p!.contains(".OSC")) {
            SqliteDbStore.shared.fromSelected = 1
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
       }
       else{
            let title9 = "CAMERA WIFI CONNECTION"
            let msg9 = "Please connect your phone to the camera WIFI before continue."
            let alert9 = UIAlertController(title: title9, message: msg9, preferredStyle: .alert)
            alert9.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
                
            }))
            self.present(alert9, animated: true)
        }
    }
    func getWiFiSsid() -> String? {
        return ssid
    }
}
