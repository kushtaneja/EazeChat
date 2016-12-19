//
//  XMPPMessageArchivingManagement.swift
//  Eazespot
//
//  Created by Kush Taneja on 13/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

fileprivate var messagesPerView: Int = 20

class XMPPMessageArchivingManagement {
    
    func retrieveMessageArchive(withFields fields: [Any]) {
    
        let iq = XMPPIQ.init(type: "set")
        iq?.addAttribute(withName: "id", stringValue: XMPPStream.generateUUID())
            let queryID = XMPPStream.generateUUID()
            let queryElement = DDXMLElement(name: "query", xmlns: "urn:xmpp:mam:1")
            queryElement?.addAttribute(withName: "queryid", stringValue: queryID!)
      
                let xElement = DDXMLElement(name: "x", xmlns: "jabber:x:data")
                xElement?.addAttribute(withName: "type", stringValue: "submit")
            xElement?.addChild(XMPPMessageArchiveManagement.field(withVar: "FORM_TYPE", type: "hidden", andValue: "urn:xmpp:mam:1"))
            for field in fields {
            xElement?.addChild(field as! DDXMLElement)
            }
        
        
            let set = DDXMLElement(name: "set", xmlns: "http://jabber.org/protocol/rsm")
            let max = DDXMLElement(name: "max")
            max.stringValue = "20"
           set?.addChild(max)
            queryElement?.addChild(xElement!)
           queryElement?.addChild(set!)
            iq?.addChild(queryElement!)
        
       // XMPPIDTracker().add(iq, target: self, selector:Selector("handleMessageArchiveIQ"), timeout: 60)
        debugPrint("ARCHIVE \(iq!) SENT")
        
        EazeChat.sharedInstance.xmppStream?.send(iq)
    
    }
    
    
    
    public func field(withVar Var:String, andValue value: String) -> DDXMLElement
    {
        
        let field = DDXMLElement(name: "field")
        field.addAttribute(withName: "var", stringValue:Var)
        let elementValue = DDXMLElement(name: "value")
        elementValue.stringValue = value
        field.addChild(elementValue)
        return field
    }
    
    
    public func retriveChatHistoryFrom(fromBareJid jid:String){
        
        let field1 = field(withVar: "with", andValue: String(jid))
        
        
        var value: String?
        let date = Date().iso8601
        if let dateFromString = date.dateFromISO8601 {
            value = dateFromString.iso8601
        }
        let field2 = field(withVar: "end", andValue: value!)
        
        let fields = [field1,field2]
    
        retrieveMessageArchive(withFields: fields)
    }
            
    }
    extension XMPPMessageArchivingManagement: XMPPStreamDelegate {
        /*
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
            
            
            
*/










        }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    func retrieveMessageArchiveFromQuerryId(_ queeryId:String, iqId: String){
     
        let iq = XMPPIQ.init(type: "get")
        iq?.addAttribute(withName: "id", stringValue: iqId)
        let queryElement = DDXMLElement(name: "query", xmlns: "urn:xmpp:mam:1")
//        queryElement?.addAttribute(withName: "with", stringValue: "kush_1_93@chat.eazespot.com")
//       queryElement?.addAttribute(withName: "start", stringValue: "2016-12-03T00:00:00Z")
        let set = DDXMLElement(name: "set", xmlns: "http://jabber.org/protocol/rsm")
        let max = DDXMLElement(name: "max")
        max.stringValue = "100"
        set?.addChild(max)
        queryElement?.addChild(set!)
       
        iq?.addChild(queryElement!)
        EazeChat.sharedInstance.xmppStream?.send(iq)
        debugPrint("Message IQ SENT")
    
    
    }

*/


