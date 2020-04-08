
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
        
        
        let complete = SqliteDbStore.shared.projectCompleted(p:project)
        if(complete.ReturnType == 1){
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 0;
        }
        else if(complete.ReturnType == 2){
            //---------------------------------------/
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 3;
            //---------------------------------------/
        }
        else if(complete.ReturnType == 3 && project.Completed != "Yes"){
            //---------------------------------------/
            let layer = myCell.contentView.layer
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 3;
            //---------------------------------------/
        }
        else if(complete.ReturnType == 3){
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
                let complete = SqliteDbStore.shared.projectCompleted(p:p)
                if(value &&  (complete.ReturnType == 3)){
                    p.Completed = "Yes"
                    SqliteDbStore.shared.updateProject(_Id: p.ProjectId, project:p)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
                    newViewController.modalPresentationStyle = .fullScreen
                    self.present(newViewController, animated: true, completion: nil)
                }
                else{
                      mySwitch.isOn = false
                      p.Completed = "No"
                      SqliteDbStore.shared.updateProject(_Id: p.ProjectId, project:p)
                      let title2 = "PROJECT COMPLETION CHECK"
                      let msg = "Project is not complete."
                      let alert2 = UIAlertController(title: title2, message: msg, preferredStyle: .alert)
                      alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
                        newViewController.modalPresentationStyle = .fullScreen
                        self.present(newViewController, animated: true, completion: nil)
                      }))
                      self.present(alert2, animated: true)
                    }
                break
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
