//
//  EazeRoom.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework

typealias EazeRoomCreationCompletionHandler = (_ sender: XMPPRoom) -> Void

protocol EazeRoomDelegate {
    //func EazePresenceDidReceivePresence()
}

class EazeRoom: NSObject {
    var delegate: EazeRoomDelegate?
    
    var didCreateRoomCompletionBlock: EazeRoomCreationCompletionHandler?
    
    // MARK: Singleton
    class var sharedInstance : EazeRoom {
        struct EazeRoomSingleton {
            static let instance = EazeRoom()
        }
        return EazeRoomSingleton.instance
    }
    
    //Handle nickname changes
    class func createRoom(roomName: String, delegate: AnyObject? = nil, completionHandler completion:@escaping EazeRoomCreationCompletionHandler) {
        sharedInstance.didCreateRoomCompletionBlock = completion
        
        let roomMemoryStorage = XMPPRoomMemoryStorage()
        let domain = EazeChat.sharedInstance.xmppStream!.myJID.domain
        let roomJID = XMPPJID(string:"\(roomName)@conference.\(domain)")
        let xmppRoom = XMPPRoom(roomStorage: roomMemoryStorage, jid: roomJID, dispatchQueue: DispatchQueue.main)
        
        xmppRoom?.activate(EazeChat.sharedInstance.xmppStream)
        xmppRoom?.addDelegate(delegate, delegateQueue: DispatchQueue.main)
    /*
    print(EazeChat.sharedInstance.xmppStream?.myJID.bare())
        */
        xmppRoom!.join(usingNickname: EazeChat.sharedInstance.xmppStream!.myJID.bare() as String, history: nil, password: nil)
        xmppRoom!.fetchConfigurationForm()
        
    }
}

extension EazeRoom: XMPPRoomDelegate {
    /**
     * Invoked with the results of a request to fetch the configuration form.
     * The give
     n config form will look something like:
     *
     * <x xmlns='jabber:x:data' type='form'>
     *   <title>Configuration for MUC Room</title>
     *   <field type='hidden'
     *           var='FORM_TYPE'>
     *     <value>http://jabber.org/protocol/muc#roomconfig</value>
     *   </field>
     *   <field label='Natural-Language Room Name'
     *           type='text-single'
     *            var='muc#roomconfig_roomname'/>
     *   <field label='Enable Public Logging?'
     *           type='boolean'
     *            var='muc#roomconfig_enablelogging'>
     *     <value>0</value>
     *   </field>
     *   ...
     * </x>
     *
     * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
     *
     * @see fetchConfigurationForm:
     * @see configureRoomUsingOptions:
     **/
    
    func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        //[xmppRoom fetchConfigurationForm];
        print("room did create")
        didCreateRoomCompletionBlock!(sender)
    }
    
    func xmppRoomDidDestroy(_ sender: XMPPRoom!) {
        //
    }
    
    private func xmppRoomDidJoin(sender: XMPPRoom!) {
        print("room did join")
    }
    
    func xmppRoomDidDestroy(sender: XMPPRoom!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        print("did fetch config \(configForm)")
    }
    
    func xmppRoom(_ sender: XMPPRoom!, willSendConfiguration roomConfigForm: XMPPIQ!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didConfigure iqResult: XMPPIQ!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didNotConfigure iqResult: XMPPIQ!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, with presence: XMPPPresence!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, with presence: XMPPPresence!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, with presence: XMPPPresence!) {
        //
    }
    
    /**
     * Invoked when a message is received.
     * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
     **/
    
    func xmppRoom(_ sender: XMPPRoom!, didReceive message: XMPPMessage!, from occupantJID: XMPPJID!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchBanList items: [Any]!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didNotFetchBanList iqError: XMPPIQ!) {
        //
    }

    func xmppRoom(_ sender: XMPPRoom!, didFetchMembersList items: [Any]!) {
        //
    }
    
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchModeratorsList items: [AnyObject]!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didNotFetchModeratorsList iqError: XMPPIQ!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didEditPrivileges iqResult: XMPPIQ!) {
        //
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didNotEditPrivileges iqError: XMPPIQ!) {
        //
    }
}
