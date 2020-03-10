
import UIKit

class OpenProject: UITableViewCell {
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var stateZip: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var upload: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var completed: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        note.adjustsFontSizeToFitWidth = true
        note.minimumScaleFactor = 0.2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
