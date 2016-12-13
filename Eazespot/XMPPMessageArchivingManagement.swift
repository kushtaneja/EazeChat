//
//  XMPPMessageArchivingManagement.swift
//  Eazespot
//
//  Created by Kush Taneja on 13/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

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
//        let set = DDXMLElement(name: "set", xmlns: "http://jabber.org/protocol/rsm")
        for field in fields {
            xElement?.addChild(field as! DDXMLElement)
        }

        
       
        let first = DDXMLElement(name: "field")
        let last = DDXMLElement(name: "field")
        first.addAttribute(withName: "var", stringValue: "start")
//        first.addAttribute(withName: "type", stringValue:"text-single")
//        last.addAttribute(withName: "type", stringValue:"text-single")
        last.addAttribute(withName: "var", stringValue: "end")
        let firstValue = DDXMLElement(name: "value")
        let secondValue = DDXMLElement(name: "value")
        let t = "1481323388727237"
        let firstDate = Date(jsonDate: t)?.iso8601
        if let dateFromString = firstDate?.dateFromISO8601 {
//            firstValue.stringValue = dateFromString.iso8601
            firstValue.stringValue = "2016-12-03T00:00:00Z"
        }
        let l = "1481550191617116"
        let lastDate = Date(jsonDate: l)?.iso8601
        if let dateFromString = lastDate?.dateFromISO8601 {
//            secondValue.stringValue = dateFromString.iso8601
            secondValue.stringValue = "2016-12-13T00:00:00Z"
        }
             first.addChild(firstValue)
             last.addChild(secondValue)
            xElement?.addChild(first)
            xElement?.addChild(last)
        
            queryElement?.addChild(xElement!)
//            queryElement?.addChild(set!)

            iq?.addChild(queryElement!)
        
        
        
        debugPrint("ARCHIVE \(iq!) SENT")
        
        EazeChat.sharedInstance.xmppStream?.send(iq)
    
    }
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


















}
