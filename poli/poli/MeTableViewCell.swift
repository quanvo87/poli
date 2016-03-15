//
//  MeTableViewCell.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/15/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class MeTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}