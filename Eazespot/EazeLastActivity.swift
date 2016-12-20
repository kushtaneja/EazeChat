//
//  EazeLastActivity.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

public typealias EazeMakeLastCallCompletionHandler = (_ response: XMPPIQ?, _ forJID:XMPPJID?, _ error: DDXMLElement?) -> Void

public class EazeLastActivity: NSObject {
    
    var didMakeLastCallCompletionBlock: EazeMakeLastCallCompletionHandler?
    
    // MARK: Singleton
    
    public class var sharedInstance : EazeLastActivity {
        struct EazeLastActivitySingleton {
            static let instance = EazeLastActivity()
        }
        return EazeLastActivitySingleton.instance
    }
    
    // MARK: Public Functions
    
    public func getStringFormattedDateFrom(second: UInt) -> String{
        if second > 0 {
            let time = NSNumber(integerLiteral: Int(second))
            let interval = time.doubleValue
            let elapsedTime = Date(timeIntervalSince1970: interval)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let string = dateFormatter.string(from: elapsedTime)
            return string
        } else {
            return ""
        }
    }
    
    public func getStringForNavigationBarFrom(seconds: UInt) -> String {
        let time = NSNumber(integerLiteral: Int(seconds))
        let interval = time.intValue
        var lastSeen: String = ""
        
        switch interval {
        case 0:
            lastSeen = "now"
        case 1..<60:
            lastSeen = "\(interval) seconds ago"
        case 60..<3600:
            lastSeen = "\(Int(interval/60)) minutes ago"
        case 3600..<86400:
            lastSeen = "\(Int(interval/3600)) hours ago"
            
        default:
            if (interval >= 86400) {
                lastSeen = "\(Int(interval/86400)) days ago"
            }
        }
        return "Active" + " " + lastSeen
    
    }
    
    
    
    
    
    public func getStringFormattedElapsedTimeFrom(date: Date!) -> String {
        
        var elapsedTime = "nc"
        let compEazents = date!.daysFrom(Date())
        
    
        
        if nil == date {
            return elapsedTime
        }
        
        if 52 < compEazents.weekOfYear! {
            elapsedTime = "more than a year"
        } else if 1 <= compEazents.weekOfYear! {
            if 1 < compEazents.weekOfYear! {
                elapsedTime = "\((compEazents.weekOfYear)!) weeks"
            } else {
                elapsedTime = "\((compEazents.weekOfYear)!) week"
            }
        } else if 1 <= compEazents.day! {
            if 1 < compEazents.day!{
                elapsedTime = "\((compEazents.day)!) days"
            } else {
                elapsedTime = "\((compEazents.day)!) day"
            }
        } else if 1 <= compEazents.hour! {
            if 1 < compEazents.hour! {
                elapsedTime = "\((compEazents.hour)!) hours"
            } else {
                elapsedTime = "\((compEazents.hour)!) hour"
            }
        } else if 1 <= compEazents.minute! {
            if 1 < compEazents.minute! {
                elapsedTime = "\((compEazents.minute)!) minutes"
            } else {
                elapsedTime = "\((compEazents.minute)!) minute"
            }
        } else if 1 <= compEazents.second!{
            if 1 < compEazents.second! {
                elapsedTime = "\((compEazents.second)!) seconds"
            } else {
                elapsedTime = "\((compEazents.second)!) second"
            }
        } else {
            elapsedTime = "now"
        }
        
        return elapsedTime
    }

    public class func sendLastActivityQueryToJID(userName: String, sender: XMPPLastActivity? = nil, completionHandler completion:@escaping EazeMakeLastCallCompletionHandler) {
        sharedInstance.didMakeLastCallCompletionBlock = completion
        let userJID = XMPPJID(string: userName)
        _ = sender?.sendQuery(to: userJID)
    }
}

extension EazeLastActivity: XMPPLastActivityDelegate {
    
    public func xmppLastActivity(_ sender: XMPPLastActivity!, didNotReceiveResponse queryID: String!, dueToTimeout timeout: TimeInterval) {
        if let callback = EazeLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
            callback(nil, nil ,DDXMLElement(name: "TimeOut"))
        }
    }
    
    public func xmppLastActivity(_ sender: XMPPLastActivity!, didReceiveResponse response: XMPPIQ!) {
        if let callback = EazeLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
            if let resp = response {
                if resp.forName("error") != nil {
                    if let from = resp.value(forKey: "from") {
                        callback(resp, XMPPJID(string:"\(from)"), resp.forName("error"))
                    } else {
                        callback(resp, nil, resp.forName("error"))
                    }
                } else {
                    if let from = resp.attribute(forName: "from") {
                        callback(resp, XMPPJID(string:"\(from)"), nil)
                    } else {
                        callback(resp, nil, nil)
                    }
                }
            }
        }
    }
    
    public func numberOfIdleTimeSeconds(for sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
        return 30
    }
}
