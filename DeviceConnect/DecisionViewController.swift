

import UIKit
class DecisionViewController: UIViewController {
    @IBAction func OpenProjectBtn(_ sender: Any) {
       SqliteDbStore.shared.projectStatus = 0;
       nav()
    }
    @IBAction func NeedInfoBtn(_ sender: Any) {
        SqliteDbStore.shared.projectStatus = 2;
        nav()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //testSQLite3()
        //cleanFolder()
       // deleteProjects()
        self.title = NSLocalizedString("Panorama", comment: "Panorama")
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    
    func testSQLite3(){
        SqliteDbStore.shared.addData()
    }
    
    func nav(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
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
    
    func deleteProjects(){
        //DataService.shared.createTables()
        SqliteDbStore.shared.deleteAllRooms()
        SqliteDbStore.shared.deleteAllLevels()
        SqliteDbStore.shared.deleAllProjects()
        //DataService.shared.addData()
    }
    func cleanFolder(){
        let file = "DataToZip"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file2 = dir.appendingPathComponent(file)
            let fileManager = FileManager.default
            do {
                
                let exists = FileManager.default.fileExists(atPath: file2.path)
                if(exists){
                    let filePaths = try fileManager.contentsOfDirectory(atPath: file2.path)
                    for filePath in filePaths {
                        try fileManager.removeItem(atPath: file2.path + "/" + filePath)
                    }
                }
            }
            catch {
                print("Could not clear DataToZip folder: \(error)")
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
