//
//  CustomCells.swift
//  Eazespot
//
//  Created by Kush Taneja on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class MessageViewIncoming: JSQMessagesCollectionViewCellIncoming {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
    }
    override class func nib() -> UINib {
        return UINib (nibName: "MessageViewIncoming", bundle: Bundle.main)
        
    }
    
    override class func cellReuseIdentifier() -> String {
        return "MessageViewIncoming"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return "MessageViewIncoming_JSQMedia"
    }
    
}

class MessageViewOutgoing: JSQMessagesCollectionViewCellOutgoing {
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      
    }
    
    override class func nib() -> UINib {
        return UINib (nibName: "MessageViewOutgoing", bundle: Bundle.main)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "MessageViewOutgoing"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return "MessageViewOutgoing_JSQMedia"
    }
    
}
