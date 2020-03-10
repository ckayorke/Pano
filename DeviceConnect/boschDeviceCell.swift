

import UIKit

class boschDeviceCell: UITableViewCell {
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var connect: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        note.adjustsFontSizeToFitWidth = true
        note.minimumScaleFactor = 0.2
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
