
import UIKit
import SystemConfiguration.CaptiveNetwork
//import Reachability
class Authentication: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var reachability:Reachability?
    let users =  SqliteDbStore.shared.queryUsers()
    
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBAction func Submit(_ sender: Any) {
         if(users.count==0){
            let user:IUser = IUser(_Id:-1,_Email:Username.text!,_Pass: Password.text!);
            SqliteDbStore.shared.addUser(_Iuser: user)
            SqliteDbStore.shared._Name = user.Email
            SqliteDbStore.shared._Pass = user.Pass
        }
        else{
           users[0].Email =  Username.text!
           users[0].Pass = Password.text!
           _ = SqliteDbStore.shared.updateUser(_IUser: users[0])
           SqliteDbStore.shared._Name = users[0].Email
           SqliteDbStore.shared._Pass = users[0].Pass
        }
        self.nav();
    }
    
    @IBAction func navBack(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
               newViewController.modalPresentationStyle = .fullScreen
               self.present(newViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(users.count>0){
            Username.text = users[0].Email
            Password.text = users[0].Pass
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        checkReachability()
    }
    func nav(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Database") as! Database
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    func checkReachability(){
        reachability = try! Reachability()
        reachability!.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            }
            else {
                print("Reachable via Cellular")
                self.mobileConnection()
            }
        }
        reachability!.whenUnreachable = { _ in
            print("Not reachable")
            self.noInternetConnection()
        }
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func mobileConnection(){
        let title = "MOBILE CONNECTION"
        let alert = UIAlertController(title: title, message: "Your internet connection is using mobile data. Do you wish to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
            
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true)
    }
    
    func noInternetConnection(){
        let title = "INTERNET CONNECTION"
        let alert = UIAlertController(title: title, message: "No Internet Connection. Go to your settings and connect to WIFI", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProjectViewController") as! ProjectViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true)
    }
    
    func getInterfaces() -> Bool {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            print("this must be a simulator, no interfaces found")
            return false
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            print("System error: did not come back as array of Strings")
            return false
        }
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                print("System error: \(interface) has no information")
                return false
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                print("System error: interface information is not a string-keyed dictionary")
                return false
            }
            for d in SSIDDict.keys {
                print("\(d): \(SSIDDict[d]!)")
            }
        }
        return true
    }
    
    func cleanData(){
        let file = "DataToZip"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let file2 = dir.appendingPathComponent(file)
            let exists = FileManager.default.fileExists(atPath: file2.path)
            if(exists){
                let fileManager = FileManager.default
                do {
                    let filePaths = try fileManager.contentsOfDirectory(atPath: file2.path)
                    for filePath in filePaths {
                        try fileManager.removeItem(atPath: file2.path + "/" + filePath)
                    }
                }
                catch {
                    print("Could not clear DataToZip folder: \(error)")
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
