//
//  EazeChats.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

public class EazeChats: NSObject, NSFetchedResultsControllerDelegate {
    
    var chatList = NSMutableArray()
    var list = [XMPPUserCoreDataStorageObject]()
    var chatListBare = NSMutableArray()
    
    // MARK: Class function
    class var sharedInstance : EazeChats {
        struct EazeChatsSingleton {
            static let instance = EazeChats()
        }
        return EazeChatsSingleton.instance
    }
    
    public class func getChatsList() ->[XMPPUserCoreDataStorageObject] {
        /*
        var jid = ""
        let objects = sharedInstance.getChatUsersFromCoreDataStorage()?.fetchedObjects
        for object in objects!{
            let o = object as! XMPPMessageArchiving_Message_CoreDataObject
            jid = o.bareJidStr
        }
       let m = EazeRoster.sharedInstance.fetchedResultsController()?.fetchedObjects
        for n in m! {
            let r  = n as! XMPPUserCoreDataStorageObject
            if (jid == r.jidStr){
                if (!sharedInstance.list.contains(r)){
                sharedInstance.list.append(r)
                }
            }
            
        
        
        }
         */
        return sharedInstance.list
    }
    
    private func getChatUsersFromCoreDataStorage() -> NSFetchedResultsController<NSFetchRequestResult>? {
        let moc = EazeMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext as NSManagedObjectContext?
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
        if fetchedResultsControllerVar == nil {
            
            let entity = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "timestamp", ascending: true)
            let sd2 = NSSortDescriptor(key: "streamBareJidStr", ascending: true)
            let sortDescriptors = [sd1, sd2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 20
            
            fetchedResultsControllerVar =
                NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: nil, cacheName: nil)
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


    private func getActiveUsersFromCoreDataStorage() -> NSArray? {
        let moc = EazeMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext as NSManagedObjectContext?
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "streamBareJidStr like %@ "
        
        if let predicateString = UserDefaults.standard.string(forKey: kXMPP.myJID) {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                
                let archivedMessage = NSMutableArray()
                
                for message in results! {
                    let message = message as! XMPPMessageArchiving_Message_CoreDataObject
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: message.messageStr)
                    } catch _ {
                        element = nil
                    }
                    let sender: String
                    
                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: kXMPP.myJID)! && !(element.attributeStringValue(forName: "to") as NSString).contains(UserDefaults.standard.string(forKey: kXMPP.myJID)!) {
                        sender = element.attributeStringValue(forName: "to")
                        if !archivedMessage.contains(sender) {
                            archivedMessage.add(sender)
                        }
                    }
                }
                return archivedMessage
            } catch _ {
            }
        }
        return nil
    }
    
    
    private func getUserFromXMPPCoreDataObject(jidStr: String)-> XMPPUserCoreDataStorageObject? {
        let moc = EazeRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        
        var predicate: NSPredicate
        if (UserDefaults.standard.string(forKey: kXMPP.myJID) != nil) {
        if EazeChat.sharedInstance.xmppStream == nil {
            predicate = NSPredicate(format: "jidStr == %@", jidStr)
        } else {
            predicate = NSPredicate(format: "jidStr == %@ AND streamBareJidStr == %@", jidStr, UserDefaults.standard.string(forKey: kXMPP.myJID)!)
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            
            let result =  try moc?.fetch(fetchRequest)
            
            for user in result! {
                let user = user as! XMPPUserCoreDataStorageObject
                debugPrint("Got User From XMPPCoreDataObject \(user)")
                return user
            }
        }
        catch {
            debugPrint("Error in getting User From XMPPCoreDataObject")
        }
        }
        return nil
    }
    public class func knownUserForJid(jidStr: String) -> Bool {
        if sharedInstance.chatList.contains(EazeRoster.userFromRosterForJID(jid: jidStr)!) {
            return true
        } else {
            return false
        }
    }
    
    public class func addUserToChatList(jidStr: String) {
        if !knownUserForJid(jidStr: jidStr) {
            
            sharedInstance.chatList.add(EazeRoster.userFromRosterForJID(jid: jidStr)!)
            sharedInstance.chatListBare.add(jidStr)
            debugPrint("user From Roster Added")
        }
    }

    public class func removeUserAtIndexPath(indexPath: NSIndexPath) {
        let user = EazeChats.getChatsList()[indexPath.row]
        
        sharedInstance.removeMyUserActivityFromCoreDataStorageWith(user: user)
        sharedInstance.removeUserActivityFromCoreDataStorage(user: user)
        removeUserFromChatList(user: user)
    }
    
    public class func removeUserFromChatList(user: XMPPUserCoreDataStorageObject) {
        if sharedInstance.chatList.contains(user) {
            sharedInstance.chatList.removeObject(identicalTo: user)
            sharedInstance.chatListBare.removeObject(identicalTo: user.jidStr)
        }
    }
    
    func removeUserActivityFromCoreDataStorage(user: XMPPUserCoreDataStorageObject) {
        let moc = EazeMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "bareJidStr like %@ "
        
        let predicate = NSPredicate(format: predicateFormat, user.jidStr)
        request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            for message in results! {
                moc?.delete(message as! NSManagedObject)
            }
        } catch _ {
        }
    }
    
    func removeMyUserActivityFromCoreDataStorageWith(user: XMPPUserCoreDataStorageObject) {
        let moc = EazeMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "streamBareJidStr like %@ "
        
        if let predicateString = UserDefaults.standard
            .string(forKey: "kXMPPmyJID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                for message in results! {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    } catch _ {
                        element = nil
                    }
                    
                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to") as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                        if element.attributeStringValue(forName: "to") == user.jidStr {
                            moc?.delete(message as! NSManagedObject)
                        }
                    }
                }
            } catch _ {
            }
        }
    }
}
