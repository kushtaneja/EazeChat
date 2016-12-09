//
//  PrivateChatTableViewCell.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class PrivateChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatorThumbnail: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var lastMessageTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
