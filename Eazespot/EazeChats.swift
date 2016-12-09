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
    var chatListBare = NSMutableArray()
    
    // MARK: Class function
    class var sharedInstance : EazeChats {
        struct EazeChatsSingleton {
            static let instance = EazeChats()
        }
        return EazeChatsSingleton.instance
    }
    
    public class func getChatsList() -> NSArray {
        if sharedInstance.chatList.count == 0  {
            if let chatList: NSMutableArray = sharedInstance.getActiveUsersFromCoreDataStorage() as? NSMutableArray
            
            {   sharedInstance.chatList = chatList
                sharedInstance.chatList.enumerateObjects({ (jidStr, index, finished) -> Void in
                    
                    
                  //  if let user = EazeRoster.userFromRosterForJID(jid: jidStr as! String) 
                   if let user = sharedInstance.getUserFromXMPPCoreDataObject(jidStr: jidStr as! String) {
                        sharedInstance.chatList.add(user)
                    }
                })
            }
        }
        return sharedInstance.chatList
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
        }
    }

    public class func removeUserAtIndexPath(indexPath: NSIndexPath) {
        let user = EazeChats.getChatsList().object(at: indexPath.row) as! XMPPUserCoreDataStorageObject
        
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
