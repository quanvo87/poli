//
//  HomeTableViewCell.swift
//  poli
//
//  Created by Vo, Van-Quan N on 2/29/16.
//  Copyright © 2016 TeamTion. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    
    let padding = 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        background.frame = CGRectMake(0, padding, frame.width, frame.height - 2 * padding)
//        typeLabel.frame = CGRectMake(padding, (frame.height - 25)/2, 40, 25)
//        priceLabel.frame = CGRectMake(frame.width - 100, padding, 100, frame.height - 2 * padding)
//        nameLabel.frame = CGRectMake(CGRectGetMaxX(typeLabel.frame) + 10, 0, frame.width - priceLabel.frame.width - (CGRectGetMaxX(typeLabel.frame) + 10), frame.height)
//    }
}