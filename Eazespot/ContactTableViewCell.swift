//
//  ContactTableViewCell.swift
//  Eazespot
//
//  Created by Kush Taneja on 11/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var statusView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.layer.cornerRadius = (statusView.frame.width)/2

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
