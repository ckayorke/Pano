
import UIKit
class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet var myTitle: UIButton!
    
    @IBAction func back(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DecisionViewController") as! DecisionViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    @IBAction func download(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Authentication") as! Authentication
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    var projects:[Project] =  []
    override func viewDidLoad() {
        super.viewDidLoad()
        if(SqliteDbStore.shared.projectStatus == 0){
            myTitle.setTitle("Assigned Projects",for: .normal)
            projects =  SqliteDbStore.shared.queryAllProject2()
        }
        else if(SqliteDbStore.shared.projectStatus == 2){
            //self.title = NSLocalizedString("Need Info. Projects", comment: "Need Info. Projects")
            projects =  SqliteDbStore.shared.queryAllProject2()
            myTitle.setTitle("Need Info. Projects",for: .normal)
        }
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier:"OpenProjectCell", for: indexPath) as! OpenProject
        let project = projects[indexPath.row];
        myCell.address?.text = "Address: " + project.Address
        myCell.city?.text = "City: "  + project.City
        myCell.stateZip?.text = "State: "  + project.State  +  " " + project.ZIPCode
        myCell.status?.text = "Status: " + project.Status2
        myCell.upload?.text = "UPLOAD"
        myCell.note.text = "Note: " + "No Comments"
        if(project.Completed=="Yes"){
            myCell.completed.setOn(true, animated: false)
        }
        else{
            myCell.completed.setOn(false, animated: false)
        }
        
        myCell.completed.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        myCell.completed.tag = project.Id
        
        let layer = myCell.contentView.layer
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0;
        
        if(projectCompleteness(p:project) == 1){
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 0;
        }
        else if(projectCompleteness(p:project) == 2){
            //---------------------------------------/
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 3;
            //---------------------------------------/
        }
        else if(projectCompleteness(p:project) == 3){
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.green.cgColor
            layer.borderWidth = 3;
        }
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SqliteDbStore.shared._Project = projects[indexPath.row]

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SelectProject") as! SelectProject
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        let id = mySwitch.tag
        for var p in projects{
            if(p.Id == id){
                if(value && projectCompleteness(p:p) == 3){
                    p.Completed = "Yes"
                    SqliteDbStore.shared.updateProject(_Id: p.ProjectId, project:p)
                }
                else{
                      mySwitch.isOn = false
                      p.Completed = "No"
                      SqliteDbStore.shared.updateProject(_Id: p.ProjectId, project:p)
                      let title2 = "PROJECT COMPLETION CHECK"
                      let msg = "Project is not complete."
                      let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
                      alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      }))
                      self.present(alert2, animated: true)
                    }
                break
            }
        }
    }
    
    func projectCompleteness(p:Project)->Int{
        var pError = ProjectError()
        let req = hasRequired(projectId: p.ProjectId)
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
                return 3
            }
        }
        else{
           return 3
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
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
}
