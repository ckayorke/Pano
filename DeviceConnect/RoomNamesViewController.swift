
import UIKit
class RoomNamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
var names: [RoomName] = []
@IBAction func naviback(_ sender: Any) {
    SqliteDbStore.shared.StartNewRoom = false
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
    newViewController.modalPresentationStyle = .fullScreen
    self.present(newViewController, animated: true, completion: nil)
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.names.count;
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text  = names[indexPath.row].Name
    return cell;
}
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    SqliteDbStore.shared.StartNewRoomName =  names[indexPath.row].Name
    SqliteDbStore.shared.StartNewRoom = true
    
    //add a room to database here
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let newViewController = storyBoard.instantiateViewController(withIdentifier: "LevelController") as! LevelController
    newViewController.modalPresentationStyle = .fullScreen
    self.present(newViewController, animated: true, completion: nil)
}
override func viewDidLoad() {
    super.viewDidLoad()
    names = SqliteDbStore.shared.getRoomNames()
    let p = SqliteDbStore.shared._Project
    let l = SqliteDbStore.shared._Level
    let existedNames = SqliteDbStore.shared.queryAllRoomsByProjectIdAndLevelId(_pId: p!.ProjectId, _lId: l!.LevelId)
    
    var existedIDs = [String]()
    for r in existedNames{
        existedIDs.append(r.Name)
    }
    
    var names2 = [RoomName]()
    for r in names{
        if(existedIDs.contains(r.Name)){
           continue
        }
        names2.append(r)
    }
    names = names2
}

override open var shouldAutorotate: Bool {
       return false
}

override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
    return UIInterfaceOrientationMask.portrait
}
}
