//
//  EazePresence.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol EazePresenceDelegate {
    func EazePresenceDidReceivePresence()
}

public class EazePresence: NSObject {
    var delegate: EazePresenceDelegate?
    
    // MARK: Singleton
    
    class var sharedInstance : EazePresence {
        struct EazePresenceSingleton {
            static let instance = EazePresence()
        }
        return EazePresenceSingleton.instance
    }
    
    // MARK: Functions
    
    class func goOnline() {
            let presence = XMPPPresence()
            let domain = EazeChat.sharedInstance.xmppStream!.myJID.domain
        /*
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
         */
            let priority: DDXMLElement = DDXMLElement(name: "priority", stringValue: "24")
            presence?.addChild(priority)
        
            EazeChat.sharedInstance.xmppStream?.send(presence)
    }
    
    class func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        EazeChat.sharedInstance.xmppStream?.send(presence)
    }
}

extension EazePresence: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        print("Did received presence : \(presence!)")
    }
}
