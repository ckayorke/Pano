//  Converted to Swift 5.1 by Swiftify v5.1.26565 - https://objectivec2swift.com/
/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

import Foundation
import UIKit

@objcMembers
class TableCellObject: NSObject {
    var thumbnail: UIImage?
    var objectInfo: HttpImageInfo?

    /**
     * Function for object creation
     * @param info
     */
    class func objectWithInfo(_ info: HttpImageInfo?) -> TableCellObject {
        let object = TableCellObject()
        object.objectInfo = info
        return object
    }
}
