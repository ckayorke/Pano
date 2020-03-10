
import UIKit

class TreeNodeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var nodeName: UILabel!
    @IBOutlet weak var nodeIMG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
