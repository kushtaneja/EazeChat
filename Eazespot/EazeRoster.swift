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
    func EazeRosterContentChanged()
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
        get {
            if sharedInstance.fetchedResultsControllerVar != nil {
                return sharedInstance.fetchedResultsControllerVar!
            }
            return sharedInstance.fetchedResultsController()!
       }
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
      //  var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
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
    
//        delegate?.EazeRosterContentChanged()

        return fetchedResultsControllerVar!
        
    }
    public func filteredUsersFetchedResultsController(frorName name: String?) -> NSFetchedResultsController<NSFetchRequestResult>? {
        let moc = EazeRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
        if fetchedResultsControllerVar == nil {
            
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
            let sortDescriptors = [sd1, sd2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "displayName CONTAINS[cd] %@", name!)
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
        
        //        delegate?.EazeRosterContentChanged()
        
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
        
        if let user = EazeChat.sharedInstance.xmppRosterStorage.user(for: userJID, xmppStream: EazeChat.sharedInstance.xmppStream, managedObjectContext:sharedInstance.managedObjectContext_roster()) { 
            return user
        } else {
            return nil
        }
    }
    public class func removeUsers() {
        let users = sharedInstance.fetchedResultsController()!.fetchedObjects
        for user in users! {
            let user = user as! XMPPUserCoreDataStorageObject
            sharedInstance.fetchedResultsController()?.managedObjectContext.delete(user)
           
        }
        
        do {
            try sharedInstance.fetchedResultsController()?.managedObjectContext.save()
        }
            
        catch _ {
            
        }
    

        /*
        let moc = EazeRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try moc?.execute(deleteRequest)
            
        } catch _ {
            //catch fetch error here
        }
        
        */
          }
    

    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.EazeRosterContentChanged()
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
        if iq.isResultIQ() {
        let finElements = iq.elements(forXmlns: "urn:xmpp:mam:1")
            for finElement in finElements! {
                let finElement = finElement as! DDXMLElement
                let sets = finElement.elements(forXmlns: "http://jabber.org/protocol/rsm")
                for set in sets! {
                    let set = set as! DDXMLElement
                    let last = set.elements(forName: "last")
                    debugPrint("Lasttt *** -- \(last)")
                    for lastUID in last {
                        let lastUID = lastUID as! DDXMLElement
                        let uid = lastUID.stringValue
                       debugPrint("Lasttt StringValue*** -- \(uid)")
                        UserDefaults.standard.set(uid!, forKey: "lastUID")
                    
                    }
                }
            
            }
         
        }
        
        return false
    }
}
