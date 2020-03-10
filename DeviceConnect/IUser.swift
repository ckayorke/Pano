
import UIKit
class IUser: CustomStringConvertible {
    public var Id: Int
    public var Email : String
    public var Pass: String
    init(_Id: Int, _Email : String, _Pass : String){
        self.Id = _Id
        self.Email = _Email
        self.Pass = _Pass
    }
    var description: String{
        return "Id = \(self.Id)"
    }
}
