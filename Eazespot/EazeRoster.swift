//
//  EazeRoster.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol EazeRosterDelegate {
    func EazeRosterContentChanged(controller: NSFetchedResultsController<NSFetchRequestResult>)
}

public class EazeRoster: NSObject, NSFetchedResultsControllerDelegate {
    public var delegate: EazeRosterDelegate?
    public var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: Singleton
    
    public class var sharedInstance : EazeRoster {
        struct EazeRosterSingleton {
            static let instance = EazeRoster()
        }
        return EazeRosterSingleton.instance
    }
    
    public class var buddyList: NSFetchedResultsController<NSFetchRequestResult> {
//        get {
//            if sharedInstance.fetchedResultsControllerVar != nil {
//                return sharedInstance.fetchedResultsControllerVar!
//            }
            return sharedInstance.fetchedResultsController()!
//        }
    }
    
    // MARK: Core Data
    
    func managedObjectContext_roster() -> NSManagedObjectContext {
        return EazeChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    private func managedObjectContext_capabilities() -> NSManagedObjectContext {
        return EazeChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    public func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        let moc = EazeRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
        if fetchedResultsControllerVar == nil {
            
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
            let sortDescriptors = [sd1, sd2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 20
            
            fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
            fetchedResultsControllerVar?.delegate = self
            
            do {
                try fetchedResultsControllerVar!.performFetch()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
        
        return fetchedResultsControllerVar!
        
    }
    public class func userFromRosterAtIndexPath(indexPath: IndexPath) -> XMPPUserCoreDataStorageObject {
        return sharedInstance.fetchedResultsController()!.object(at: indexPath) as! XMPPUserCoreDataStorageObject
    }
    
    public class func removeUserFromRosterAtIndexPath(indexPath: IndexPath) {
       let user = sharedInstance.fetchedResultsController()!.object(at: indexPath) as! XMPPUserCoreDataStorageObject
        sharedInstance.fetchedResultsController()?.managedObjectContext.delete(user)
    }
    
    
    public class func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string: jid)
        
        if let user = EazeChat.sharedInstance.xmppRosterStorage.user(for: userJID, xmppStream: EazeChat.sharedInstance.xmppStream, managedObjectContext:sharedInstance.managedObjectContext_roster()) { debugPrint("user From Roster Added")
            return user
        } else {
            return nil
        }
    }

    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.EazeRosterContentChanged(controller: controller)
    }
}

extension EazeRoster: XMPPRosterDelegate {
    
    public func xmppRoster(_ sender: XMPPRoster!, didReceivePresenceSubscriptionRequest presence: XMPPPresence!) {
        let a = EazeChat.sharedInstance.xmppRosterStorage.user(for: presence.from(), xmppStream: EazeChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
        
        print("**didReceivePresenceSubscriptionRequest of \(a)")
    }
    
    public func xmppRoster(_ sender: XMPPRoster, didReceiveBuddyRequest presence:XMPPPresence!) {
        //was let user
        _ = EazeChat.sharedInstance.xmppRosterStorage.user(for: presence.from(), xmppStream: EazeChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
    }
 
    
    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster!){
        let jidList = EazeChat.sharedInstance.xmppRosterStorage.jids(for: EazeChat.sharedInstance.xmppStream)
        print("xmppRoster  End Populating  with List =\(jidList)")
        
    }
}

extension EazeRoster: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        
        print("Did receive \(iq!) from stream")
     /*
        if (iq.isResultIQ()) {
            
           let iqId = iq.attribute(forName: "id")?.stringValue
            if iqId != nil {
                
                let finElement = iq.elements(forName: "fin")
                            if finElement.count > 0 {
                                        for element in finElement {
                                           let QueryId = element.attribute(forName: "queryid")?.stringValue
                
                                            XMPPMessageArchivingManagement().retrieveMessageArchiveFromQuerryId(QueryId!, iqId: iqId!)
                                            debugPrint("ARCHIVE IQ SENT")
                                } } }
            
//            let iq = XMPPIQ.init(type: "set")
//            iq?.addAttribute(withName: "id", stringValue: iqId!)
//            let queryID = XMPPStream.generateUUID()
//            let queryElement = DDXMLElement(name: "query", xmlns: "urn:xmpp:mam:1")
////            queryElement?.addAttribute(withName: "queryid", stringValue: queryID!)
//            let xElement = DDXMLElement(name: "x", xmlns: "jabber:x:data")
//            xElement?.addAttribute(withName: "type", stringValue: "submit")
//            xElement?.addChild(XMPPMessageArchiveManagement.field(withVar: "FORM_TYPE", type: "hidden", andValue: "urn:xmpp:mam:1"))
//                
//            let first = DDXMLElement(name: "field")
//            let last = DDXMLElement(name: "field")
//                first.addAttribute(withName: "var", stringValue: "start")
//                last.addAttribute(withName: "var", stringValue: "end")
//            let t = "1481323388727237"
//            let firstDate = Date(jsonDate: t)?.iso8601
//            if let dateFromString = firstDate?.dateFromISO8601 {
//                first.stringValue = dateFromString.iso8601
//            }
//            let l = "1481550191617116"
//            let lastDate = Date(jsonDate: l)?.iso8601
//            if let dateFromString = lastDate?.dateFromISO8601 {
//                last.stringValue = dateFromString.iso8601
//            }
//            
//            xElement?.addChild(first)
//            xElement?.addChild(last)
//            queryElement?.addChild(xElement!)
//            //            queryElement?.addChild(set!)
//            
//            iq?.addChild(queryElement!)
//            
//            
//            
//            debugPrint("ARCHIVE IQ SENT")
//            
//            EazeChat.sharedInstance.xmppStream?.send(iq)
//            
//            }
//            
//            
//            
//            
        
            
//
//        
//            
//            }
//        
//        
//        }
//        
        } */
        return false
    }
}
