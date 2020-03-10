//
//  OpenProjectCell.swift
//  DeviceConnect
//
//  Created by Charles Yorke on 8/7/19.
//  Copyright © 2019 Tobias Kaulich. All rights reserved.
//

import UIKit

class OpenProjectCell: UITableViewCell {
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var cityZip: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var completed: UISwitch!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var state: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        note.adjustsFontSizeToFitWidth = true
        note.minimumScaleFactor = 0.2
    }
}
