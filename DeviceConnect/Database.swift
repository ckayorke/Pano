
import UIKit
//import ZIPFoundation
class Database: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate  {
    var outProjects:[Project] = []
    var outLevels:[Level] = []
    var outRooms:[Room] = []
    //=========================================
    var count = 0
    var recount = 0
    var pics:[String] = []
    var picsName:[String] = []
    //=========================================
    var inputFile = "Data"
    let users =  SqliteDbStore.shared.queryUsers()
    var pIds = [Int]()
    //=========================================
    @IBOutlet weak var activityIndi: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndi.transform = CGAffineTransform(scaleX: 3, y: 3)
        houseKeeping()
    }
    
    func houseKeeping(){
        prepareFolder()
        createData()
        initiateLoading()
    }
    func prepareFolder(){
        let name = SqliteDbStore.shared._Name!
        var name2 = name.replacingOccurrences(of: "@", with: "")
        name2 = name2.replacingOccurrences(of: ".", with: "")
        inputFile = "Data_" + name2
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file = dir.appendingPathComponent(inputFile)
            let exists = FileManager.default.fileExists(atPath: file.path)
            if(exists){
                do{
                    let fileManager = FileManager.default
                    do{
                        try fileManager.removeItem(atPath: file.path)
                    }
                    catch {
                        print("Could not delete Data folder: \(error)")
                        self.nav2(msg: "Could not delete Data folder. Report to administrator")
                    }
                }
            }
            
            let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let logsPath = documentsPath1.appendingPathComponent(inputFile)
            do
            {
                try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                print(error)
                self.nav2(msg: "Unable to create directory. Report to administrator")
            }
        }
    }
    
    func createData(){
        let message : String = ""
        let Id: Int = 1
        let name : String = SqliteDbStore.shared._Name!
        let pass : String = SqliteDbStore.shared._Pass!
        getValidProjects()

        let newData2 = Data2(message: message, Id: Id, name: name, pass: pass, projects:outProjects, rooms: outRooms, levels: outLevels)
        let jsonEncoder = JSONEncoder()
        do{
            let jsonData = try jsonEncoder.encode(newData2)
            let json = String(data:jsonData, encoding: .utf8)
            writeTextFile(text: json!)
            
        }
        catch let error as NSError{
            NSLog("Unable to create directory \(error.debugDescription)")
            self.nav2(msg: "Unable to create directory. Report to administrator")
        }
    }
    func writeTextFile(text: String){
        let file = inputFile + "/db.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Unable to write textfile")
                self.nav2(msg: "Unable to write textfile. Report to administrator")
            }
        }
    }
    
    func getValidProjects(){
        outProjects.removeAll()
        outLevels.removeAll()
        outRooms.removeAll()
        let projects =  SqliteDbStore.shared.queryAllProject()
        for p in projects{
           _ = projectCompleteness(p: p)
        }
    }
    func projectCompleteness(p:Project)->Int{
        var pError = ProjectError()
        var req = hasRequired(projectId: p.ProjectId)
        if(p.Status != 0){
            req = ""
        }
        
        
        if (p.Completed == "Yes" && (p.OutsidePictures != "") && (req == "")) {
        }
        else{
            pError.ProjectId = p.ProjectId
            
            if (p.Completed == "Yes") {
                pError.MissingCheck = "No"
            }
            else{
                pError.MissingCheck = "Yes"
            }
            if  (p.OutsidePictures == "") {
                pError.MissingOutsidePics = "Yes"
            }
            if(req.count > 0){
                pError.BK = req
            }
        }
        
        var rooms2:[Room] = []
        let rooms = SqliteDbStore.shared.queryAllRooms()
        for r in rooms {
            if(r.ProjectId == p.ProjectId){
                rooms2.append(r)
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
        
        
        let levels = SqliteDbStore.shared.queryAllLevel(_Id: p.ProjectId)
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
        
        if(rooms2.count == 0 && levels.count == 0){
            let out = p.OutsidePictures.trimmingCharacters(in: .whitespacesAndNewlines)
            if(out.count == 0){
                return 1
            }
        }
        
        
        
        var isGoodProject = false
        for r in rooms{
            if (r.ProjectId == p.ProjectId) {
                isGoodProject = true;
                break;
            }
        }
        
        if(isGoodProject == false) {
            pError.ProjectId = p.ProjectId
            pError.Address = p.Address
        }
        pError.Address = p.Address
        pError.City = p.City  + ", " + p.State + ", " + p.ZIPCode
        
        let bk = pError.BK.trimmingCharacters(in: .whitespacesAndNewlines)
        let eptl = pError.EmptyLevels.trimmingCharacters(in: .whitespacesAndNewlines)
        let mMeasure = pError.MissingMeasure.trimmingCharacters(in: .whitespacesAndNewlines)
        let mPicture = pError.MissingPicture.trimmingCharacters(in: .whitespacesAndNewlines)
        let mOutPicture = pError.MissingOutsidePics.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        if((bk != "") || (eptl != "") ||  (mMeasure != "" ) || (mPicture != "") || (mOutPicture != "No")){
            if(p.Status == 0){
               return 2
            }
            else if(p.Status == 2 && levels.count == 0 && p.OutsidePictures.count == 0 && p.Outside3DPictures.count == 0){
                return 1
             }
            else{
                outProjects.append(p)
                outLevels.append(contentsOf: levels)
                outRooms.append(contentsOf: rooms2)
                selectImages(id: p.ProjectId)
                return 3
            }
        }
        else{
           outProjects.append(p)
           outLevels.append(contentsOf: levels)
           outRooms.append(contentsOf: rooms2)
           selectImages(id: p.ProjectId)
           return 3
        }
    }
    
    func selectImages(id:Int){
        let imagesLoc = "DataToZip"
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let srcFolderURL = dir.appendingPathComponent(imagesLoc)
                let fm = FileManager.default
                do {
                    let items = try fm.contentsOfDirectory(atPath: srcFolderURL.path)
                    for item in items {
                        if(item.contains(".jpg")){
                            if(item.contains("_Pro_" + String(id) + "_")){
                                if let dir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fromUrl = URL(string: srcFolderURL.absoluteString + "/" + item)
                                    let dstFolderURL = URL(string: dir2.absoluteString + "/" + inputFile + "/" + item)
                                    secureCopyItem(at: fromUrl!, to: dstFolderURL!)
                                }
                            }
                            else if(item.contains("Proj_" + String(id) + "_Out")){
                                if let dir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fromUrl = URL(string: srcFolderURL.absoluteString + "/" + item)
                                    let dstFolderURL = URL(string: dir2.absoluteString + "/" + inputFile + "/" + item)
                                    secureCopyItem(at: fromUrl!, to: dstFolderURL!)
                                }
                            }
                            else if(item.contains("Pro_" + String(id) + "_")){
                                if let dir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fromUrl = URL(string: srcFolderURL.absoluteString + "/" + item)
                                    let dstFolderURL = URL(string: dir2.absoluteString + "/" + inputFile + "/" + item)
                                    secureCopyItem(at: fromUrl!, to: dstFolderURL!)
                                }
                            }
                        }
                    }
                }
                catch {
                }
            }
        }
        
    }
    
    func secureCopyItem(at srcURL: URL, to dstURL: URL){
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        }
        catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            self.nav2(msg: "Cannot copy images. Report to administrator")
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
    
    
   //==================================================================
    func initiateLoading(){
        count = 0
        pics.removeAll()
        picsName.removeAll()
        do {
            if let dir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let folderURL = dir2.appendingPathComponent(inputFile)
                let fm = FileManager.default
                do {
                    let items = try fm.contentsOfDirectory(atPath: folderURL.path)
                    for item in items {
                        if(item.contains(".jpg")){
                            count = count + 1
                            pics.append(folderURL.absoluteString + "/" + item)
                            picsName.append(item)
                        }
                    }
                    if(count>0){
                        recount = 0
                        uploadImage(imageUrl:pics[recount], fileName:picsName[recount], start:"1")
                    }
                    else{
                        let file = inputFile + "/db.txt"
                        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let fileURL = dir.appendingPathComponent(file)
                            do {
                                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                                self.uploadText(postString:text2)
                            }
                            catch {
                                print("Unable to upload textfile")
                                self.nav2(msg: "Unable to upload textfile. Report to administrator")
                            }
                        }
                    }
                }
                catch {
                    print("Unable to upload all files")
                    self.nav2(msg: "Unable to upload all files. Report to administrator")
                }
            }
        }
    }
    
    
    func uploadImage(imageUrl:String, fileName:String, start:String){
        let url = NSURL(string: imageUrl)
        let data = try? Data(contentsOf: (url?.absoluteURL!)!)
        let image = UIImage(data: data!)
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        if imageData != nil{
           // var request = URLRequest(url: NSURL(string:"http://192.168.1.15:8085/Home/LoadPictures?file=" + inputFile + "&start=" + start)! as URL)//Send your URL here
            
            var request = URLRequest(url: NSURL(string:"http://360floorplans.nvms.com/Home/LoadPictures?file=" + inputFile + "&start=" + start)! as URL)//Send your URL here
            print(request)
            request.httpMethod = "POST"
            let boundary = NSString(format: "---------------------------14737809831466499882746641449")
            let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            //  println("Content Type \(contentType)")
            request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
            var body = Data()
            body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data;name=\"title\"\r\n\r\n").data(using:String.Encoding.utf8.rawValue)!)
            body.append("Hello".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data;name=\"uploaded_file\";filename=\"" + fileName
                + "\"\\r\n" as NSString).data(using:String.Encoding.utf8.rawValue)!) //Here replace your image name and file name
            body.append(NSString(format: "Content-Type: image/jpeg\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
            body.append(imageData!)
            body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
            request.httpBody = body
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil
                {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async {
                        self.nav2(msg: "Connecting to server for image upload fails. Report to administrator")
                    }
                }
                else{
                    if let httpResponse = response as? HTTPURLResponse {
                        //var u = httpResponse.statusCode
                        switch httpResponse.statusCode {
                        case 200..<300:
                            self.recount = self.recount + 1
                            if(self.recount == self.count){
                                let file = self.inputFile + "/db.txt"
                                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let fileURL = dir.appendingPathComponent(file)
                                    do {
                                        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                                        self.uploadText(postString:text2)
                                    }
                                    catch {
                                        print("Unable to upload textfile")
                                        DispatchQueue.main.async {
                                            self.nav2(msg: "Unable to upload textfile. Report to administrator")
                                        }
                                        
                                    }
                                }
                            }
                            else if(self.recount < self.count){
                                self.uploadImage(imageUrl:self.pics[self.recount], fileName:self.picsName[self.recount], start:"2")
                            }
                        case 400..<500:
                            print("Request error")
                            self.nav2(msg: "Bad request for image upload. Report to administrator")
                        case 500..<600:
                            print("Server error")
                            self.nav2(msg: "Server error for image upload. Report to administrator")
                        case let otherCode:
                            print("Other code: \(otherCode)")
                            self.nav2(msg: "Unknown error for image upload. Report to administrator")
                        }
                    }
               }
                
            }
            task.resume()
        }
    }
    
    func uploadText(postString:String){
        //let myUrl = URL(string: "http://192.168.1.15:8085/Home/LoadDBIOS?file=" + inputFile )
        let myUrl = URL(string: "http://360floorplans.nvms.com/Home/LoadDBIOS?file=" + inputFile )
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                DispatchQueue.main.async {
                    self.nav2(msg: "Connecting to server for textfile upload fails. Report to administrator")
                }
            }
            else{
                    var goodResults = false
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200..<300:
                            goodResults = true
                        case 400..<500:
                            print("Request error")
                            self.nav2(msg: "Bad request for textfile upload. Report to administrator")
                        case 500..<600:
                            print("Server error")
                            self.nav2(msg: "Server error for textfile upload. Report to administrator")
                        case let otherCode:
                            print("Other code: \(otherCode)")
                            self.nav2(msg: "Unknown error for textfile upload. Report to administrator")
                        }
                        
                    }
                    DispatchQueue.main.async {
                        if(goodResults){
                            if let responseData = data,let _ = String(data: responseData, encoding: String.Encoding.utf8) {
                                let report = self.ResetDB(data3: responseData)
                                self.cleanDataToZip()
                                self.prepareFolder()
                                if(report.contains("404")){
                                   self.nav2(msg: "Invalid Login!")
                                }
                                else{
                                    self.nav2(msg: "Database updated!")
                                }
                            }
                            else{
                               self.nav2(msg: "Unknown error for textfile upload. Report to administrator")
                            }
                          
                        }
                        else{
                             self.nav2(msg: "Unknown error for textfile upload. Report to administrator")
                            }
                        
                    }
               }
        }
        task.resume()
    }
    
    func ResetDB(data3: Data) ->String{
        do {
            let jsonDecoder = JSONDecoder()
            let dataOupt = try jsonDecoder.decode(Data2.self, from: data3)
            let projects =  SqliteDbStore.shared.queryAllProject()
            for i in 0..<dataOupt.projects.count{
                var isNewProject = true
                let p = dataOupt.projects[i]
                for j in 0..<projects.count{
                    var old = projects[j]
                    if(p.ProjectId == old.ProjectId){
                        old.Notes = p.Notes
                        old.Resolution = p.Resolution
                        SqliteDbStore.shared.updateProject(_Id: old.ProjectId, project: old)
                        isNewProject = false
                        break
                    }
                }
                if(isNewProject){
                    SqliteDbStore.shared.addProject(project: p)
                }
            }
            
            for i in projects{
                var isOld = true
                for k in dataOupt.projects{
                    if(k.ProjectId == i.ProjectId){
                        isOld = false
                        break
                    }
                }
                if(isOld){
                    SqliteDbStore.shared.deleteProject(_Id: i.ProjectId)
                }
            }
    
            return dataOupt.message.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        catch {
            print("Unable to reset database")
            return "Unable to reset database"
        }
    }
    func cleanDataToZip(){
        let imagesLoc = "DataToZip"
        for p in outProjects{
            let  id = p.ProjectId
            do {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let srcFolderURL = dir.appendingPathComponent(imagesLoc)
                    let fm = FileManager.default
                    do {
                        let items = try fm.contentsOfDirectory(atPath: srcFolderURL.path)
                        for item in items {
                            if(item.contains(".jpg")){
                                if(item.contains("_Pro_" + String(id) + "_")){
                                    let fileManager = FileManager.default
                                    do{
                                        try fileManager.removeItem(atPath: srcFolderURL.path + "/" + item)
                                    }
                                    catch {
                                        print("Could not delete file: \(error)")
                                    }
                                }
                                else if(item.contains("Proj_" + String(id) + "_Out")){
                                    let fileManager = FileManager.default
                                    do{
                                        try fileManager.removeItem(atPath: srcFolderURL.path + "/" + item)
                                    }
                                    catch {
                                        print("Could not delete file: \(error)")
                                    }
                                }
                                else if(item.contains("Pro_" + String(id) + "_")){
                                    let fileManager = FileManager.default
                                    do{
                                        try fileManager.removeItem(atPath: srcFolderURL.path + "/" + item)
                                    }
                                    catch {
                                        print("Could not delete file: \(error)")
                                    }
                                }
                            }
                        }
                    }
                    catch {
                    }
                }
            }
        }
    }
    func nav(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func nav2(msg:String){
        let title = "UPLOAD REPORT"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
    override open var shouldAutorotate: Bool {
           return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
}
