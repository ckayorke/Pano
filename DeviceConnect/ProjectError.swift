
import Foundation
import UIKit
struct ProjectError: Codable {
    var ProjectId : Int = 0
    var ReturnType : Int = 1
    var Address : String = ""
    var City : String = ""
    var BK : String = ""
    var EmptyLevels: String = ""
    var MissingPicture : String = ""
    var MissingMeasure : String = ""
    var MissingOutsidePics: String = "No"
    var MissingOutside3DPics: String = "No"
    var MissingCheck: String = "No"
}
