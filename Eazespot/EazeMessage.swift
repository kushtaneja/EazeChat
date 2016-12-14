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
    var xmppMessageArchivingManagement: XMPPMessageArchiveManagement?
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
        
        xmppMessageArchiving?.clientSideMessageArchivingOnly = true
        xmppMessageArchiving?.activate(EazeChat.sharedInstance.xmppStream)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
        
    }
    
    func doIT(){
        
        
        let field = DDXMLElement(name: "field")
        field.addAttribute(withName: "var", stringValue:"with")
//        field.addAttribute(withName: "type", stringValue:"jid-single")
////         field.addAttribute(withName: "label", stringValue:"kush_1_93@chat.eazespot.com")
        
        let elementValue = DDXMLElement(name: "value")
        elementValue.stringValue = "kush_1_93@chat.eazespot.com"
        field.addChild(elementValue)
        
        let fields = [field]
        
        
        
        XMPPMessageArchivingManagement().retrieveMessageArchive(withFields: fields)
    
    
    
    
    
    }
        /*
        var iq = XMPPIQ.init(type: "set")
        iq?.addAttribute(withName: "id", stringValue: XMPPStream.generateUUID())
       let queryID = XMPPStream.generateUUID()
        var queryElement = DDXMLElement(name: "query", xmlns: "urn:xmpp:mam:1")
        queryElement?.addAttribute(withName: "queryid", stringValue: queryID!)
        iq?.addChild(queryElement!)
        var xElement = DDXMLElement(name: "x", xmlns: "jabber:x:data")
        xElement?.addAttribute(withName: "type", stringValue: "submit")
        xElement?.addChild(XMPPMessageArchiveManagement.field(withVar: "FORM_TYPE", type: "hidden", andValue: "urn:xmpp:mam:1"))
                        xElement?.addChild(field)
        queryElement?.addChild(xElement!)
        debugPrint("**DONE")
        EazeChat.sharedInstance.xmppStream?.send(iq)

    }*/
    
    func setupHistoryfetch() {
    
        let field = XMPPMessageArchiveManagement.field(withVar: "with", type: nil, andValue: "kush_1_93@chat.eazespot.com")
        let fields = [field]
        let set = DDXMLElement(name: "set", xmlns: "http://jabber.org/protocol/rsm")
        let max = DDXMLElement.element(withName: "max") as! DDXMLElement
        max.stringValue = "10"
        set?.addChild(max)
        let resultset = XMPPResultSet(from: set)
        
        xmppMessageArchivingManagement?.retrieveMessageArchive(withFields: fields, with: resultset)
         xmppMessageArchivingManagement?.retrieveFormFields()
          xmppMessageArchiving?.activate(EazeChat.sharedInstance.xmppStream)
        xmppMessageArchivingManagement?.addDelegate(self, delegateQueue: DispatchQueue.main)
        debugPrint("**FUNCTIONCALLLED")
    
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
    
    public func deleteMessagesCoreData(){
        
        let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try moc?.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
        
    }
    
    
    
    
}



extension EazeMessage: XMPPMessageArchiveManagementDelegate{
  
    public func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didFinishReceivingMessagesWith resultSet: XMPPResultSet!) {
        
        debugPrint("FInished Receiving messages with resultset\(resultSet) ")
    
    }
    
    public func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didReceiveMAMMessage message: XMPPMessage!) {
        debugPrint("FInished Receiving messages with message\(message) ")
    
    
    }
    
    public func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didFailToReceiveMessages error: XMPPIQ!) {
    
        debugPrint("Failed Receiving messages with message\(error) ")

    
    }
    
    
    public func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didReceiveFormFields iq: XMPPIQ!) {
    
        debugPrint("FInished Receiving fromFields with result ::: \(iq) ")

    
    }
    
    public func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didFailToReceiveFormFields iq: XMPPIQ!) {
    
        debugPrint("Failed Receiving fromFields with result ::: \(iq) ")
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
        
        var results = message.elements(forXmlns: "urn:xmpp:mam:1")
        
        for result in results! {
            let result = result as! DDXMLElement
            debugPrint("Message Recieved*** \(result)")
            
        var forwarded = result.hasForwardedStanza()
        var queryID = result.attribute(forName: "queryid")?.stringValue
        if forwarded {
         
        }
        }
        
        
        
        
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
    
    
   
}
