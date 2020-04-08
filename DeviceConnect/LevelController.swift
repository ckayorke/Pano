
import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation
class LevelController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    @IBOutlet weak var bar: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UIButton!
    @IBOutlet weak var levelLabel: UIButton!
     var ssid: String = "notconnected"
    var moveWidth =  0
    let cellSize = 9
    var grid = [[Tile]]()
    var startGrid = [Tile]()
    var existedGrid = [Tile]()
    var levelName:String = ""
    var p = SqliteDbStore.shared._Project
    var level =   SqliteDbStore.shared._Level
    var startRoomTilesCollection = false
    var numbOfSelection:Int = 0
    var emptyTiles = [[Int]]()
    var currentRoom:Int = -20
    var textLayers:[CATextLayer] = []
    
    @IBAction func doneWithLevel(_ sender: Any) {
        saveScreen()
        houseKeeping()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func backToSelectedProject(_ sender: Any) {
        saveScreen()
        houseKeeping()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func houseKeeping(){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
        for r in allRooms{
            if(r.Connectors == ""){
                _ = SqliteDbStore.shared.deleteRoom(_Id: r.Id)
            }
        }
    }
    
    @IBAction func saveRoom(_ sender: Any) {
        if(startGrid.count > 0 && currentRoom > -1) {
            var ids = [String]()
            for i in startGrid{
                ids.append(String(i.mRectSquare.tag))
            }
            
            let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
            for var r in allRooms{
                if(currentRoom == r.Id){
                    r.Connectors = ids.joined(separator:",")
                    _ = SqliteDbStore.shared.updateRoom(_Id: r.Id, room: r)
                    break;
                }
            }
        }
        getEmptyBoard()
        startRoomTilesCollection = false
        numbOfSelection = 0
        SqliteDbStore.shared.StartNewRoom = false
        startGrid.removeAll()
        
        houseKeeping()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
        saveScreen()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
        createColors()
        createGrid()
        startRoomTilesCollection = SqliteDbStore.shared.StartNewRoom
        let address = p!.Address + "," + p!.City + "," +  p!.State + "," +  p!.ZIPCode
        bar.setTitle(address,for: .normal)
        levelLabel.setTitle("Floor: " + level!.Name,for: .normal)
        if(SqliteDbStore.shared.StartNewRoom){
            let r = DoSelectItem(name: SqliteDbStore.shared.StartNewRoomName)
            startRoomTiles(room: r)
            SqliteDbStore.shared.StartNewRoom = false
        }
        loadExistingRooms()
        
        
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
    
    func createGrid(){
        let frameTop:CGPoint = topLabel.frame.origin
        let topY = Int(frameTop.y) + 70
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let xPos = 0
        let yPos = topY
        let rectWidth = (Int(screenWidth))/cellSize
        moveWidth = rectWidth
        let rectHeight = rectWidth
        var startLeft = xPos
        var startTop = yPos
        var count = 1
        for _ in 0 ..< cellSize
        {
            var row = [Tile]()
            for _ in 0 ..< cellSize
            {
                let rectFrame: CGRect = CGRect(x:CGFloat(startLeft), y:CGFloat(startTop), width:CGFloat(rectWidth), height:CGFloat(rectHeight))
                // Create a UIView object which use above CGRect object.
                let greenView = UIView(frame: rectFrame)
                greenView.backgroundColor = UIColor.gray
                greenView.layer.borderColor = UIColor.black.cgColor
                greenView.layer.borderWidth = 0.3
                
                let touchGesture = UITapGestureRecognizer(target: self, action: #selector(hangleTap(gestureRecognizer:)))
                touchGesture.numberOfTapsRequired = 1
                greenView.addGestureRecognizer(touchGesture)
                
                let doubleTouchGesture = UITapGestureRecognizer(target: self, action: #selector(hangleDoubleTap(gestureRecognizer:)))
                doubleTouchGesture.numberOfTapsRequired = 2
                greenView.addGestureRecognizer(doubleTouchGesture)
                
                let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapHangle(gestureRecognizer:)))
                greenView.addGestureRecognizer(longTap)
                greenView.tag = count
                
                self.view.addSubview(greenView)
                row.append(Tile(X: startLeft,Y: startTop, Id:count, RoomRoom:"", mRectSquare: greenView, mSquareColor:UIColor.gray.cgColor))
                startLeft = startLeft + rectWidth
                count = count + 1
            }
            grid.append(row)
            startLeft = 0
            startTop = startTop + rectWidth
        }
    }
    @objc func hangleTap(gestureRecognizer: UITapGestureRecognizer)
    {
        let viewId = gestureRecognizer.view?.tag
        for i in 0 ..< existedGrid.count
        {
            let tile = existedGrid[i]
            if(tile.Id == viewId){
               print("This part belongs to another room so handle double tap!")
               return
            }
        }
        
        let defaultColor = UIColor.gray
        if(startRoomTilesCollection) {
            var name = ""
            let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
            for r in allRooms{
                if(r.RoomId == currentRoom){
                    name = r.Name
                }
            }
            
            for i in 0 ..< cellSize
            {
                let row = grid[i]
                for j in 0 ..< cellSize
                {
                    let tile = row[j]
                    if(tile.Id == viewId){
                        if (tile.mRectSquare.backgroundColor == defaultColor) {
                            emptyTiles[i][j] = 1
                             //startGrid.append(tile)
                            if(checkConnectedCell(id: viewId!)){
                                tile.mRectSquare.backgroundColor = UIColor.magenta
                                tile.RoomRoom = name
                                startGrid.append(tile)
                                numbOfSelection = numbOfSelection + 1;
                            }
                            else{
                                tile.mRectSquare.backgroundColor = defaultColor
                                tile.RoomRoom = ""
                                //startGrid.remove(at: startGrid.count - 1)
                                 emptyTiles[i][j] = 0
                                print("Please select neighbor cells only!")
                            }
                        }
                       else {
                            if(numbOfSelection == 1){
                                emptyTiles[i][j] = 0
                                numbOfSelection = 0
                                tile.RoomRoom = ""
                                startGrid.removeAll()
                                    //  self.deleteRoom(t.X, t.Y);
                            }
                            else{
                                tile.mRectSquare.backgroundColor = defaultColor
                                numbOfSelection = numbOfSelection - 1;
                                emptyTiles[i][j] = 0
                                tile.RoomRoom = ""
                                for k in 0 ..< startGrid.count
                                {
                                    if(startGrid[k].mRectSquare.tag == viewId){
                                         startGrid.remove(at: k)
                                        break
                                        
                                    }
                                }
                            }
                        }
                    
                    }
                }
            }
            if(UIColor.gray == gestureRecognizer.view?.backgroundColor){
            }
        }
        else{
            print("Long Tap to start a new room!")
            let title2 = "CREATE ROOM"
            let msg = "Long Tap to start a new room!"
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert2, animated: true)
            
        }
    }
    @objc func hangleDoubleTap(gestureRecognizer: UITapGestureRecognizer)
    {
        var found = false
        let viewId = gestureRecognizer.view?.tag
        for i in 0 ..< existedGrid.count
        {
            let tile = existedGrid[i]
            if(tile.Id == viewId){
                found = true
                break
            }
        }
        
        if(found){
            let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
            for r in allRooms{
                if(r.Connectors.count>0){
                    let list = r.Connectors.components(separatedBy: ",");
                    var ids = [Int]()
                    for k in list{
                        let a:Int? = Int(k)
                        ids.append(a!)
                    }
                    if(ids.contains(viewId!)){
                        SqliteDbStore.shared._Room = r
                        showEventDialog()
                        break;
                    }
                }
            }
        }
    
    }
    @objc func longTapHangle(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if(startRoomTilesCollection){
            print("Save the existing layout before starting a new room")
            let title2 = "DATA VALIDATION"
            let msg = "Save the existing layout before starting a new room"
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert2, animated: true)
            return
        }
        
        
        let viewId = gestureRecognizer.view?.tag
        for i in 0 ..< existedGrid.count
        {
            let tile = existedGrid[i]
            if(tile.Id == viewId){
                print("This part belongs to another room!")
                let title2 = "FLOOR VALIDATION"
                let msg = "This part belongs to another room!"
                let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert2, animated: true)
                return
            }
        }
        if(checkConnectedCell(id: viewId!)){
            SqliteDbStore.shared.StartNewRoomId = gestureRecognizer.view!.tag
            handlePop()
        }
        else{
            let title2 = "FLOOR VALIDATION"
            let msg = "Rooms must be connected"
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert2, animated: true)
            return
        }
    }
    
    func checkConnectedCell(id: Int)->Bool{
        var searchGrid = [Tile]()
        searchGrid.append(contentsOf: startGrid)
        searchGrid.append(contentsOf: existedGrid)
        
        if(searchGrid.count==0){
            return true
        }
        
        for i in 0 ..< searchGrid.count
        {
            let tileId = searchGrid[i].Id
            if(  ((tileId + 1) == id) || ((tileId - 1) == id)  || ((tileId + 9) == id) || ((tileId - 9) == id)){
                return true
            }
        }
        return false
    }
    

    func handlePop(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let newViewController = storyBoard.instantiateViewController(withIdentifier: "RoomNamesViewController") as! RoomNamesViewController
               newViewController.modalPresentationStyle = .fullScreen
               self.present(newViewController, animated: true, completion: nil)
    }
    
    func getEmptyBoard() {
            emptyTiles = Array(repeating: Array(repeating: 0, count: cellSize), count: cellSize)
    }
    func startRoomTiles(room:Room){
       startRoomTilesCollection = true;
        getEmptyBoard()
        startGrid.removeAll()
        for i in 0 ..< cellSize
        {
            let row = grid[i]
            for j in 0 ..< cellSize
            {
                let tile = row[j]
                if(tile.Id == SqliteDbStore.shared.StartNewRoomId){
                    tile.mRectSquare.backgroundColor = UIColor.magenta
                    tile.RoomRoom = room.Name
                    startGrid.append(tile)
                    emptyTiles[i][j] = 1
                }
            }
        }
    }

    func DoSelectItem(name: String) ->Room{
        let newRoom = Room(
            Id: -20,
            RoomId: SqliteDbStore.shared.queryAllRooms().count + 1,
            ProjectId: p!.ProjectId,
            LevelId: level!.LevelId,
            Name: name,
            LevelName: level!.Name,
            Address: p!.Address,
            State : p!.State,
            City: p!.City,
            ZIP: p!.ZIPCode,
            
            PictureName: "",
            RoomLength: "",
            RoomWidth: "",
            Connectors: "",
            
            CenterX: "0",
            CenterY: "0",
            ScaleX:  "0",
            ScaleY: "0",
            Rotation: "0",
            Shape: "0",
            Fliped: "0"
        )
        SqliteDbStore.shared.addRoom(room: newRoom)
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
        for r in allRooms{
            if(r.Name.contains(name)){
                currentRoom = r.Id
                return r
            }
        }
        return newRoom
    }
    func loadExistingRooms(){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
        var rx = 1
        for var r in allRooms{
            if(r.Connectors.count>0){
                let list = r.Connectors.components(separatedBy: ",");
                var ids = [Int]()
                
                for k in list{
                    let a:Int? = Int(k)
                    ids.append(a!)
                }
                
                var toLine = Array2D(columns: cellSize, rows: cellSize, initialValue: 0)
                for i in 0 ..< cellSize
                {
                    let row = grid[i]
                    for j in 0 ..< cellSize
                    {
                        let tile = row[j]
                          if(ids.contains(tile.Id)){
                            tile.mRectSquare.backgroundColor = gridColors[rx % 3]
                            existedGrid.append(tile)
                            toLine[j, i] = 1
                         }
                          else{
                            toLine[j, i] = 0
                        }
                    }
                }
                
                
                var topData = [CGPoint]()
                var bottomData = [CGPoint]()
                for col in 0 ..< cellSize
                {
                    var co = [Tile]()
                    for row in 0 ..< cellSize
                    {
                        if(toLine[col, row] == 1){
                            co.append(grid[row][col]);
                        }
                    }
                    
                    if(co.count > 0) {
                        let top = co[0]
                        let k = top.mRectSquare.frame.origin
                        topData.append(k)
                        var kWidth = top.mRectSquare.frame.width
                        topData.append(CGPoint(x: k.x + kWidth, y: k.y))
                        let bottom = co[co.count - 1]
                        let k2 = bottom.mRectSquare.frame.origin
                        let kHeight = bottom.mRectSquare.frame.height
                        kWidth = bottom.mRectSquare.frame.width
                        bottomData.append( CGPoint(x: k2.x, y: k2.y + kHeight));
                        bottomData.append( CGPoint(x: k2.x + kWidth, y: k2.y + kHeight))
                    }
                    
                }
                bottomData.reverse()
                for i in 0 ..< bottomData.count{
                    topData.append(bottomData[i])
                }
                
               
                let c = getStateColor(r2: r)
                drawLine(topData: topData, color:c)
                let loc = topData[0]
                
                
                
                var label = UILabel(frame: CGRect(x: loc.x, y: loc.y, width: 90, height: 18))
                let oldX = Int(Double(r.CenterX)!)
                let oldY = Int(Double(r.CenterY)!)
                
                if((oldX == 0) || oldY == 0){
                    r.CenterX = "\(Int(loc.x))"
                    r.CenterY = "\(Int(loc.y))"
                    // r.CenterX = "\(Int(loc.x) + Int(moveWidth))"
                    // r.CenterY = "\(Int(loc.y) - Int(moveWidth/2))"
                    _ = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
                }
                else{
                    //label.center = CGPoint(x: oldX, y: oldY)
                    label = UILabel(frame: CGRect(x: oldX, y: oldY, width: 90, height: 18))
                }
                
                label.textAlignment = .center
                label.text = r.Name
                label.tag = r.Id
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(LevelController.draggedView(_:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(panGesture)
                self.view.addSubview(label)
                
                rx = rx + 1
            }
            
        }
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: sender.self.view!)
        let translation = sender.translation(in: self.view)
        sender.self.view!.center = CGPoint(x: sender.self.view!.center.x + translation.x, y: sender.self.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        let newCenter = sender.self.view!.center
        let id = sender.self.view!.tag
        
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: level!.LevelId);
        for var r in allRooms{
            if(r.Id == id){
                r.CenterX = "\(newCenter.x)"
                r.CenterY = "\(newCenter.y)"
                _  = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
                break;
            }
        }
    }

    func getStateColor(r2:Room)-> UIColor{
        var k:UIColor?
        let name = r2.Name.trimmingCharacters(in: .whitespacesAndNewlines)
        let name2 = name.lowercased()
        
        let picName = r2.PictureName.trimmingCharacters(in: .whitespacesAndNewlines)
        let picName2 = picName.lowercased()
        
        let roomLength = r2.RoomLength.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if (name.contains("crawl space") || name.contains("attic") ||
              name2.contains("staircase")) {
               k = UIColor.black
        }
        else if ((picName2.count > 0) && (roomLength.count > 0)) {
              k = UIColor.black
        }
        else if ((picName2.count == 0) && (roomLength.count == 0)) {
             k = UIColor.white
        }
        else if (picName2.count == 0) {
              k = UIColor.red
        }
        else if (roomLength.count == 0) {
             k = UIColor.magenta
        }
        return k!
    }
    
    func drawLine(topData:[CGPoint], color:UIColor) {
        
        //var loc = topData[0]
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: topData[0].x, y: topData[0].y))
        for i in 1 ..<  topData.count{
             starPath.addLine(to: CGPoint(x: topData[i].x, y: topData[i].y))
        }
        starPath.close()
        let layer = CAShapeLayer()
        layer.path = starPath.cgPath
        layer.fillColor = nil
        //layer.strokeColor = UIColor.red.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = 3
        view.layer.addSublayer(layer)
    }
    

    func showEventDialog(){
        let r = SqliteDbStore.shared._Room
        let title = SqliteDbStore.shared._Room!.LevelName + ": " + SqliteDbStore.shared._Room!.Name
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete Room", style: .default, handler: { action in
            _ =  SqliteDbStore.shared.deleteRoom(_Id: r!.Id)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Take Room Picture", style: .default, handler: { action in
            if (r!.PictureName.count == 0) {
                self.checkCamConnection()
            }
            else{
                let title2 = "ROOM PICTURES"
                let msg = "Taking Additional Room Picture. Are you sure?"
                let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                    self.checkCamConnection()
                }))
                alert2.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
                    
                }))
                self.present(alert2, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Take Room Measurement", style: .default, handler: { action in
            if (r!.RoomLength.count == 0) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "DeviceViewController") as! DeviceViewController
                 newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
            }
            else{
                let title2 = "ROOM MEASUREMENTS"
                let msg = "Retaking Room Measurements. Are you sure?"
                let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "DeviceViewController") as! DeviceViewController
                     newViewController.modalPresentationStyle = .fullScreen
                    self.present(newViewController, animated: true, completion: nil)
                }))
                alert2.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
                }))
                self.present(alert2, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete All Rooms", style: .default, handler: { action in
            let title2 = "DELETE CONFIRMATION"
            let msg = "Are you sure you want to delete all rooms, their photos and measurements for this level?"
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
                for r2 in allRooms{
                    _ = SqliteDbStore.shared.deleteRoom(_Id: r2.Id)
                }
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
                 newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
            }))
            alert2.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
            }))
            self.present(alert2, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Shift Layout Left", style: .default, handler: { action in
            self.shiftSideToSide(dir: 1)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Shift Layoout Right", style: .default, handler: { action in
            self.shiftSideToSide(dir: 2)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Shift Layout Up", style: .default, handler: { action in
            self.shiftTopToDown(dir: 1)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Shift Layoout Down", style: .default, handler: { action in
            self.shiftTopToDown(dir: 2)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
        }))
        self.present(alert, animated: true)
    }
    
    
    func shiftSideToSide(dir: Int){
        var colTotalArray = [[Int]]()
        for i in 0 ..< 9
        {
             var colArray = [Int]()
             var value = 1
            for _ in 0 ..< 9 {
                colArray.append(i + value);
               value = value + 9;
            }
            colTotalArray.append(colArray );
        }
        
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        var all = [Int]()
        for n in allRooms{
            if(n.Connectors.count>0){
                let list = n.Connectors.components(separatedBy: ",");
                for k in list{
                    let a:Int? = Int(k)
                    all.append(a!)
                }
            }
        }
                
        if(dir == 1) {
            for i in 0 ..< 9 {
                let set1 = colTotalArray[i]
               let set2 = set1.filter(all.contains)
               if (set2.count > 0) {
                    if (i > 0) {
                        shiftLeft(col: 1);
                    }
                    break;
               }
           }
        }
        else if(dir == 2) {
            let colTotalArrayReversed = colTotalArray.reversed()
            var i = 0
            for  set1 in  colTotalArrayReversed{
                let set2 = set1.filter(all.contains)
               if (set2.count > 0) {
                    if (i > 0) {
                        shiftRight(col: 1);
                    }
                   break;
               }
                i = i + 1
           }
        }
    }
    
    func shiftTopToDown(dir: Int){
        var rowTotalArray = [[Int]]()
        var value = 1
        for _ in 0 ..< 9
        {
            var rowArray = [Int]()
            for _ in 0 ..< 9 {
                rowArray.append(value);
                value = value + 1;
            }
            rowTotalArray.append(rowArray );
        }
        
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        var all = [Int]()
        for n in allRooms{
            if(n.Connectors.count>0){
                let list = n.Connectors.components(separatedBy: ",");
                for k in list{
                    let a:Int? = Int(k)
                    all.append(a!)
                }
            }
        }
                
        if(dir == 1) {
            for i in 0 ..< 9 {
                let set1 = rowTotalArray[i]
                let set2 = set1.filter(all.contains)
                if (set2.count > 0) {
                    if (i > 0) {
                        shiftUp(row: 9)
                    }
                    break;
                }
            }
        }
        else if(dir == 2) {
            let rowTotalArrayReversed = rowTotalArray.reversed();
            var i = 0
            for  set1 in  rowTotalArrayReversed{
                let set2 = set1.filter(all.contains)
                if (set2.count > 0) {
                    if (i > 0) {
                        shiftDown(row: 9);
                    }
                    break;
                }
                i = i + 1
            }
        }
    }

    func shiftLeft(col: Int){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        for var r in allRooms{
            if(r.Connectors.count>0){
                let list = r.Connectors.components(separatedBy: ",");
                var ids1 = [String]()
                
                for k in list{
                    let a:Int? = Int(k)
                    ids1.append(String(a! - col))
                }
                r.Connectors = ids1.joined(separator:",")
                
                let t1 = r.CenterX
                let t2 = Int(Double(t1)!)
                let t = t2 - moveWidth
                r.CenterX = String(t)
                
               _ = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
            }
        }
    }
    
    func shiftRight(col: Int){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        for var r in allRooms{
            if(r.Connectors.count>0){
                let list = r.Connectors.components(separatedBy: ",");
                var ids1 = [String]()
                
                for k in list{
                    let a:Int? = Int(k)
                    ids1.append(String(a! + col))
                }
                
                r.Connectors = ids1.joined(separator:",")
                let t1 = r.CenterX
                let t2 = Int(Double(t1)!)
                let t = t2 + moveWidth
                r.CenterX = String(t)
                //n.CenterX = "" + (Integer.parseInt(n.CenterX) +  mCustomView.snappSize);
                _ = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
            }
        }
    }
    
    func shiftUp(row:Int){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        for var r in allRooms{
            if(r.Connectors.count>0){
                let list = r.Connectors.components(separatedBy: ",");
                var ids1 = [String]()
                
                for k in list{
                    let a:Int? = Int(k)
                    ids1.append(String(a! - row))
                }
                
                r.Connectors = ids1.joined(separator:",")
                
                let t1 = r.CenterY
                let t2 = Int(Double(t1)!)
                let t = t2 - moveWidth
                r.CenterY = String(t)
                
               _ = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
            }
        }
    }
    
    func shiftDown(row:Int){
        let allRooms = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: self.p!.ProjectId, _lId: self.level!.LevelId);
        for var r in allRooms{
            if(r.Connectors.count>0){
                let list = r.Connectors.components(separatedBy: ",");
                var ids1 = [String]()
                
                for k in list{
                    let a:Int? = Int(k)
                    ids1.append(String(a! + row))
                }
                
                r.Connectors = ids1.joined(separator:",")
                let t1 = r.CenterY
                let t2 = Int(Double(t1)!)
                let t = t2 + moveWidth
                r.CenterY = String(t)
                _ = SqliteDbStore.shared.updateRoom(_Id: r.RoomId, room: r)
            }
        }
    }
    
    var gridColors:[UIColor] = []
    func createColors(){
        let color1 = hexStringToUIColor(hex: "#FDCC0D")
        let color2 = hexStringToUIColor(hex: "#dab600")
        let color3 = hexStringToUIColor(hex: "#a98600")
        gridColors.append(color1)
        gridColors.append(color2)
        gridColors.append(color3)
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func getWiFiSsid() -> String? {
        return ssid
    }
    
    func checkCamConnection(){
        let p = getWiFiSsid()
        if (p!.contains("THETAYJ")   &&  p!.contains(".OSC")) {
            SqliteDbStore.shared.fromSelected = 2
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
             newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
            
        }
        else{
            let title2 = "CAMERA WIFI CONNECTION"
            let msg = "Please connect your phone to the camera WIFI before continue."
            let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.saveScreen()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
                
            }))
            self.present(alert2, animated: true)
        }
    }
    
    func getLevelName(){
        let P = SqliteDbStore.shared._Project
        if(P?.Status == 0){
            let item  = SqliteDbStore.shared._Level
            let levName = item?.Name
            let levName2 = levName!.replacingOccurrences(of: " ", with: "")
            if let pID1 = item?.ProjectId {
                let pID = String(pID1)
                levelName = "Pro_\(pID)_" + levName2 + "1.jpg"
            }
        }
        else{
            let item  = SqliteDbStore.shared._Level
            let levName = item?.Name
            let levName2 = levName!.replacingOccurrences(of: " ", with: "")
            
            if let pID1 = item?.ProjectId {
                let pID = String(pID1)
                levelName = "Pro_\(pID)_" + levName2 + "2.jpg"
            }
        }
    }
    func saveScreen(){
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext()
        else {
            return
        }
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        getLevelName()
        processImage(image:screenshotImage!)
    }
    
    func processImage(image:UIImage){
        let file = "DataToZip"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file2 = dir.appendingPathComponent(file)
            let exists = FileManager.default.fileExists(atPath: file2.path)
            if(exists){
                let fileManager = FileManager.default
                do {
                    let filePaths = try fileManager.contentsOfDirectory(atPath: file2.path)
                    for filePath in filePaths {
                        if(filePath == levelName){
                            try fileManager.removeItem(atPath: file2.path + "/" + filePath)
                        }
                    }
                }
                catch {
                    print("Could not clear DataToZip folder: \(error)")
                }
            }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "DataToZip/" + levelName
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = UIImageJPEGRepresentation(image, 1),!FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try data.write(to: fileURL)
                    print("file saved")
                    SqliteDbStore.shared._Level?.PicName = levelName
                    _ = SqliteDbStore.shared.updateLevel(_Id: SqliteDbStore.shared._Level!.LevelId, level: SqliteDbStore.shared._Level!)
                }
                catch {
                    print("error saving file:", error)
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


public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}

