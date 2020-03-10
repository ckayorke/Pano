
import Foundation
import UIKit
struct Data2: Codable {
    var message : String
    var Id: Int
    var name : String
    var pass : String
    var projects: [Project]
    var rooms: [Room]
    var levels: [Level]
}
