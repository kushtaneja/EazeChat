//
//  EazeMessage.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import XMPPFramework

public typealias EazeChatMessageCompletionHandler = (_ stream: XMPPStream, _ message: XMPPMessage) -> Void

// MARK: Protocols

public protocol EazeMessageDelegate {
    func EazeStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    func EazeStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

public class EazeMessage: NSObject {
    public var delegate: EazeMessageDelegate?
    
    public var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var didSendMessageCompletionBlock: EazeChatMessageCompletionHandler?
    
    // MARK: Singleton
    
    public class var sharedInstance : EazeMessage {
        struct EazeMessageSingleton {
            static let instance = EazeMessage()
        }
        
        return EazeMessageSingleton.instance
    }
    
    // MARK: private methods
    
    func setupArchiving() {
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
        
        xmppMessageArchiving?.clientSideMessageArchivingOnly = false
        
     
        
        xmppMessageArchiving?.activate(EazeChat.sharedInstance.xmppStream)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    // MARK: public methods
    
    public class func sendMessage(message: String, to receiver: String, completionHandler completion:@escaping EazeChatMessageCompletionHandler) {
        
        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        let messageID = EazeChat.sharedInstance.xmppStream?.generateUUID()
        
//        body.setXmlns(message)
        body.stringValue = message
    
        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement
        
        completeMessage.addAttribute(withName: "id", stringValue: messageID!)
        completeMessage.addAttribute(withName: "type", stringValue: "chat")
        completeMessage.addAttribute(withName: "to", stringValue: receiver)
        
        completeMessage.addChild(body)
        let active = DDXMLElement.element(withName: "active", stringValue:
            "http://jabber.org/protocol/chatstates") as! DDXMLElement
        completeMessage.addChild(active)
        
        sharedInstance.didSendMessageCompletionBlock = completion
        EazeChat.sharedInstance.xmppStream?.send(completeMessage)
    }
    
    public class func sendIsComposingMessage(recipient: String, completionHandler completion:@escaping EazeChatMessageCompletionHandler) {
        if recipient.characters.count > 0 {
            let message = DDXMLElement.element(withName: "message") as! DDXMLElement
            message.addAttribute(withName: "type", stringValue: "chat")
            message.addAttribute(withName: "to", stringValue: recipient)
            
            let composing = DDXMLElement.element(withName: "composing", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            message.addChild(composing)
            
            sharedInstance.didSendMessageCompletionBlock = completion
            EazeChat.sharedInstance.xmppStream?.send(message)
        }
    }
    
    public class func sendIsNotComposingMessage(recipient: String, completionHandler completion:@escaping EazeChatMessageCompletionHandler) {
        if recipient.characters.count > 0 {
            let message = DDXMLElement.element(withName: "message") as! DDXMLElement
            message.addAttribute(withName: "type", stringValue: "chat")
            message.addAttribute(withName: "to", stringValue: recipient)
            
            let active = DDXMLElement.element(withName: "active", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            message.addChild(active)
            
            sharedInstance.didSendMessageCompletionBlock = completion
            EazeChat.sharedInstance.xmppStream?.send(message)
        }
    }
    
    public func loadArchivedMessagesFrom(jid: String) -> NSMutableArray {
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "bareJidStr like %@ "
        let predicate = NSPredicate(format: predicateFormat, jid)
        let retrievedMessages = NSMutableArray()
        
        request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            
            for message in results! {
                let message = message as! XMPPMessageArchiving_Message_CoreDataObject
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: message.messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                let sender: String
                let date: Date
                
                date = message.timestamp
                
                if message.body != nil {
                    body = message.body
                } else {
                    body = ""
                }
                if element.attributeStringValue(forName: "to") == jid {
                    let displayName = EazeChat.sharedInstance.xmppStream?.myJID
                    sender = displayName!.bare()
                } else {
                    sender = jid
                }
                
                let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: body)
                retrievedMessages.add(fullMessage!)
            }
        } catch _ {
            //catch fetch error here
        }
        return retrievedMessages
    }
    
    public func deleteMessagesFrom(jid: String, messages: NSArray) {
        messages.enumerateObjects({ (Message, idx, stop) -> Void in
            let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
            let request = NSFetchRequest<NSFetchRequestResult>()
            let predicateFormat = "messageStr like %@ "
            let predicate = NSPredicate(format: predicateFormat, Message as! String)
            
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                
                for message in results! {
                    let message = message as! XMPPMessageArchiving_Message_CoreDataObject
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: message .messageStr)
                    } catch _ {
                        element = nil
                    }
                    
                    if element.attributeStringValue(forName: "messageStr") == Message as! String {
                        moc?.delete(Message as! NSManagedObject)
                    }
                }
            } catch _ {
                //catch fetch error here
            }
        })
    }
}

extension EazeMessage: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        
        
        if let completion = EazeMessage.sharedInstance.didSendMessageCompletionBlock {
            debugPrint("Message was sent")
            completion(sender, message)
        }
        //EazeMessage.sharedInstance.didSendMessageCompletionBlock!(stream: sender, message: message)
    }
    
    public func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        
        let user = EazeChat.sharedInstance.xmppRosterStorage.user(for: message.from(), xmppStream: EazeChat.sharedInstance.xmppStream, managedObjectContext: EazeRoster.sharedInstance.managedObjectContext_roster())
        
        if let user = user {
        if !EazeChats.knownUserForJid(jidStr: (user.jidStr)!) {
            EazeChats.addUserToChatList(jidStr: (user.jidStr)!)
        }
        
        if message.isChatMessageWithBody() {
            EazeMessage.sharedInstance.delegate?.EazeStream(sender: sender, didReceiveMessage: message, from: user)
        } else {
            //was composing
            if let _ = message.forName("composing") {
                EazeMessage.sharedInstance.delegate?.EazeStream(sender: sender, userIsComposing: user)
            }
        }
    }
}
    
    func getMessagesFromServer() {
        let iQ = DDXMLElement.element(withName: "iq") as! DDXMLElement
        iQ.addAttribute(withName: "type", stringValue: "get")
        iQ.addAttribute(withName: "id", stringValue: "pk1")
        let list = DDXMLElement(name: "query", xmlns: "urn:xmpp:mam:tmp")
        let with = DDXMLElement.element(withName: "with") as! DDXMLElement
        with.stringValue = "ankit@tagbin.in"

        list?.addChild(with)
        iQ.addChild(list!)

        EazeChat.sharedInstance.xmppStream?.send(iQ)
        debugPrint("**IQ \(iQ) SENT")
    }
}
