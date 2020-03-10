
import Foundation
class RoomName: CustomStringConvertible {
    public var RoomId: Int
    public var LevelId : Int
    public var ProjectId : Int
    public var Name : String
    public var IsCheck: Bool
    init(RoomId: Int, LevelId: Int, ProjectId : Int,Name : String){
        self.RoomId = RoomId
        self.LevelId = LevelId
        self.ProjectId = ProjectId
        self.Name = Name
        self.IsCheck = false
    }
    var description: String{
        return "Id = \(self.RoomId)"
    }
}
