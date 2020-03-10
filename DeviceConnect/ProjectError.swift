
import Foundation
import UIKit
struct ProjectError: Codable {
    var ProjectId : Int = 0
    var Address : String = ""
    var City : String = ""
    var BK : String = ""
    var EmptyLevels: String = ""
    var MissingPicture : String = ""
    var MissingMeasure : String = ""
    var MissingOutsidePics: String = "No"
    var MissingCheck: String = "No"
}
