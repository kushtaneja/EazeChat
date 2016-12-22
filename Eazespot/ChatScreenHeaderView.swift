//
//  ChatScreenHeaderView.swift
//  Eazespot
//
//  Created by Kush Taneja on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ChatScreenHeaderView: UIView {
    
    @IBOutlet weak var nameTextLabel: UILabel!

    @IBOutlet weak var statusTextLabel: UILabel!
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = UIColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.backgroundColor = UIColor.clear.cgColor
        frame = bounds
        translatesAutoresizingMaskIntoConstraints = true
    
    }
    
    
    
    
    
      /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
