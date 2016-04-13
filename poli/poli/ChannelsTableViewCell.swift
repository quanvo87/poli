//
//  ChannelsTableViewCell.swift
//  poli
//
//  Created by Vo, Van-Quan N on 3/10/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class ChannelsTableViewCell: UITableViewCell {

    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}