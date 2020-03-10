
import UIKit

class TreeSingleViewController: UIViewController {

    @IBOutlet weak var viewArea2: UIView!
    @IBOutlet weak var _titleBtn: UIButton!
    @IBAction func back(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
        self.present(newViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let data:[DataNode] = getDataNodes1()
        let nodes = TreeNodeHelper.sharedInstance.getSortedNodes(data, defaultExpandLevel: 0)
        
        //var cGRect = viewArea2.bounds
        
        let tableview: TreeTableView = TreeTableView(frame: CGRect(x: 0, y: 70, width: self.view.frame.width, height: self.view.frame.height-110), withData: nodes)
        //let tableview: TreeTableView = TreeTableView(frame: cGRect, withData: nodes)
        self.view.addSubview(tableview)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getDataNodes()-> [DataNode]{
        var data:[DataNode] = []
        let dataNode = DataNode(id:"1", pid:"0", name:"45321 Blue Spruce Ct", description:"", mainNode: true)
        data.append(dataNode)
        let dataNode2 = DataNode(id:"2", pid:"1", name:"Required Room Missing", description:"", mainNode: false)
        data.append(dataNode2)
        
        let dataNode3 = DataNode(id:"3", pid:"2", name:"Kitchen", description:"",  mainNode: false)
        data.append(dataNode3)
        
        let dataNode4 = DataNode(id:"4", pid:"2", name:"Bathroom", description:"", mainNode: false)
        data.append(dataNode4)
        
        let dataNode5 = DataNode(id:"5", pid:"2", name:"Bedroom", description:"", mainNode: false)
        data.append(dataNode5)
        
        
        let dataNode6 = DataNode(id:"6", pid:"1", name:"Empty Levels", description:"", mainNode: false)
        data.append(dataNode6)
        
        let dataNode7 = DataNode(id:"7", pid:"6", name:"First Floor", description:"", mainNode: false)
        data.append(dataNode7)
        
        let dataNode8 = DataNode(id:"8", pid:"6", name:"Second Floor", description:"", mainNode: false)
        data.append(dataNode8)
        
        let dataNode9 = DataNode(id:"9", pid:"6", name:"Third Floor", description:"", mainNode: false)
        data.append(dataNode9)
        
        
        let dataNode10 = DataNode(id:"10", pid:"1", name:"Rooms Missing Pictures", description:"", mainNode: false)
        data.append(dataNode10)
        
        let dataNode11 = DataNode(id:"11", pid:"10", name:"Bedroom 1", description:"", mainNode: false)
        data.append(dataNode11)
        
        let dataNode12 = DataNode(id:"12", pid:"10", name:"Bathroom 1", description:"",  mainNode: false)
        data.append(dataNode12)
        
        let dataNode13 = DataNode(id:"13", pid:"10", name:"Kitchen 1", description:"", mainNode: false)
        data.append(dataNode13)
        
        
        let dataNode14 = DataNode(id:"14", pid:"1", name:"Rooms Missing Measurements", description:"", mainNode: false)
        data.append(dataNode14)
        
        let dataNode15 = DataNode(id:"15", pid:"14", name:"Bedroom 1", description:"",  mainNode: false)
        data.append(dataNode15)
        
        let dataNode16 = DataNode(id:"16", pid:"14", name:"Bathroom 1", description:"", mainNode: false)
        data.append(dataNode16)
        
        let dataNode17 = DataNode(id:"17", pid:"14", name:"Kitchen 1", description:"",  mainNode: false)
        data.append(dataNode17)
        
        let dataNode18 = DataNode(id:"18", pid:"1", name:"Missing Outside Pictures", description:"", mainNode: false)
        data.append(dataNode18)
        
        let dataNode19 = DataNode(id:"19", pid:"18", name:"Yes", description:"",  mainNode: false)
        data.append(dataNode19)
        
        let dataNode20 = DataNode(id:"20", pid:"1", name:"Upload Check", description:"", mainNode: false)
        data.append(dataNode20)
        
        let dataNode21 = DataNode(id:"21", pid:"20", name:"Yes", description:"",  mainNode: false)
        data.append(dataNode21)
    
        return data
    }
    
    
    func getDataNodes1()-> [DataNode]{
        let pErrorData = SqliteDbStore.shared.projectErrors
        var data:[DataNode] = []
        if(pErrorData.count<1){
            return data
        }
        var count = 1
        for pError in pErrorData{
            let pjId = "\(count)"
            let dataNode = DataNode(id:pjId, pid:"0", name:pError.Address, description:"", mainNode: true)
            data.append(dataNode)
            count = count + 1
            
            let req =  pError.BK.trimmingCharacters(in: .whitespacesAndNewlines)
            if(req.count > 0 ){
                let pjId2 = "\(count)"
                let dataNode2 = DataNode(id:pjId2, pid:pjId, name:"Required Room Missing", description:"", mainNode: false)
                data.append(dataNode2)
                count = count + 1
                let arr = req.components(separatedBy: ",")
                for room in arr {
                    let pjId3 = "\(count)"
                    let dataNode3 = DataNode(id:pjId3, pid:pjId2, name:room, description:"",  mainNode: false)
                    data.append(dataNode3)
                    count = count + 1
                }
            }
            
            let emptyLevels =  pError.EmptyLevels.trimmingCharacters(in: .whitespacesAndNewlines)
            if(emptyLevels.count > 0 ){
                let pjId4 = "\(count)"
                let dataNode6 = DataNode(id:pjId4, pid:pjId, name:"Empty Levels", description:"", mainNode: false)
                data.append(dataNode6)
                count = count + 1
                let arr = emptyLevels.components(separatedBy: ",")
                for level in arr {
                    let pjId5 = "\(count)"
                    let dataNode7 = DataNode(id:pjId5, pid:pjId4, name:level, description:"",  mainNode: false)
                    data.append(dataNode7)
                    count = count + 1
                }
            }
            
            let roomPics =  pError.MissingPicture.trimmingCharacters(in: .whitespacesAndNewlines)
            if(roomPics.count > 0 ){
                let pjId6 = "\(count)"
                let dataNode10 = DataNode(id:pjId6, pid:pjId, name:"Rooms Missing Pictures", description:"", mainNode: false)
                data.append(dataNode10)
                count = count + 1
                let arr = roomPics.components(separatedBy: ",")
                for room in arr {
                    let pjId7 = "\(count)"
                    let dataNode11 = DataNode(id:pjId7, pid:pjId6, name:room, description:"",  mainNode: false)
                    data.append(dataNode11)
                    count = count + 1
                }
            }
            
            let roomMeasure =  pError.MissingMeasure.trimmingCharacters(in: .whitespacesAndNewlines)
            if(roomMeasure.count > 0 ){
                let pjId8 = "\(count)"
                let dataNode14 = DataNode(id:pjId8, pid:pjId, name:"Rooms Missing Measurements", description:"", mainNode: false)
                data.append(dataNode14)
                count = count + 1
                let arr = roomMeasure.components(separatedBy: ",")
                for room in arr {
                    let pjId9 = "\(count)"
                    let dataNode15 = DataNode(id:pjId9, pid:pjId8, name:room, description:"",  mainNode: false)
                    data.append(dataNode15)
                    count = count + 1
                }
            }
            let outPic =  pError.MissingOutsidePics.trimmingCharacters(in: .whitespacesAndNewlines)
            if(outPic.contains("Yes")){
                let pjId10 = "\(count)"
                let dataNode18 = DataNode(id:pjId10, pid:pjId, name:"Missing Outside Pictures", description:"", mainNode: false)
                data.append(dataNode18)
                count = count + 1
                let pjId11 = "\(count)"
                let dataNode19 = DataNode(id:pjId11, pid:pjId10, name:"Yes", description:"",  mainNode: false)
                data.append(dataNode19)
                count = count + 1
            }
            
            let upload =  pError.MissingCheck.trimmingCharacters(in: .whitespacesAndNewlines)
            if(upload.contains("Yes")){
                let pjId12 = "\(count)"
                let dataNode20 = DataNode(id:pjId12, pid:pjId, name:"Upload Check", description:"", mainNode: false)
                data.append(dataNode20)
                count = count + 1
                let pjId13 = "\(count)"
                let dataNode19 = DataNode(id:pjId13, pid:pjId12, name:"Yes", description:"",  mainNode: false)
                data.append(dataNode19)
                count = count + 1
            }
        }
        return data
    }
    
    override open var shouldAutorotate: Bool {
           return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
}

