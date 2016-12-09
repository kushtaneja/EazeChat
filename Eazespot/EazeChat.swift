//
//  EazeChat.swift
//  Eazespot
//
//  Created by Kush Taneja on 09/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import XMPPFramework
import CoreData

//public typealias XMPPStreamCompletionHandler = (_ shouldTrustPeer: Bool?) -> Void
//public typealias EazeChatAuthCompletionHandler = (_ stream: XMPPStream, _ error: DDXMLElement?) -> Void
//public typealias EazeChatConnectCompletionHandler = (_ stream: XMPPStream, _ error: DDXMLElement?) -> Void

public protocol EazeChatDelegate {
    func EazeStream(sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?)
    func EazeStreamDidConnect(sender: XMPPStream)
    func EazeStreamDidAuthenticate(sender: XMPPStream)
    func EazeStream(sender: XMPPStream, didNotAuthenticate error: DDXMLElement)
    func EazeStreamDidDisconnect(sender: XMPPStream, withError error: Error)
}

public class EazeChat: NSObject {
    
    var delegate: EazeChatDelegate?
    var window: UIWindow?
    
    public var xmppStream: XMPPStream?
    var xmppReconnect: XMPPReconnect?
    var xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster?
    public var xmppLastActivity: XMPPLastActivity?
    var xmppvCardStorage: XMPPvCardCoreDataStorage?
    var xmppvCardTempModule: XMPPvCardTempModule?
    public var xmppvCardAvatarModule: XMPPvCardAvatarModule?
    var xmppCapabilitiesStorage: XMPPCapabilitiesCoreDataStorage?
    var xmppMessageDeliveryRecipts: XMPPMessageDeliveryReceipts?
    var xmppCapabilities: XMPPCapabilities?
    var user : XMPPUserCoreDataStorageObject?
    var chats: EazeChats?
    let presenceTest = EazePresence()
    let messageTest = EazeMessage()
    let rosterTest = EazeRoster()
    let lastActivityTest = EazeLastActivity()
    
    var customCertEvaluation: Bool?
    var isXmppConnected: Bool?
    var password: String?
    
//    var streamDidAuthenticateCompletionBlock: EazeChatAuthCompletionHandler?
//    var streamDidConnectCompletionBlock: EazeChatConnectCompletionHandler?
    
    // MARK: Singleton
    
    public class var sharedInstance : EazeChat {
        struct EazeChatSingleton {
            static let instance = EazeChat()
        }
        return EazeChatSingleton.instance
    }
    
    // MARK: Functions
    
    public class func stop() {
        sharedInstance.teardownStream()
    }
    
    public class func start(archiving: Bool? = false, delegate: EazeChatDelegate? = nil) {
        
        sharedInstance.setupStream()
        
        if archiving! {
            EazeMessage.sharedInstance.setupArchiving()
        }
        if let delegate: EazeChatDelegate = delegate {
            sharedInstance.delegate = delegate
        }
        EazeRoster.sharedInstance.fetchedResultsController()?.delegate = EazeRoster.sharedInstance
    }
    
    public func setupStream() {
        // Setup xmpp stream
        //
        // The XMPPStream is the base class for all activity.
        // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
        
        xmppStream = XMPPStream()
        
        #if !TARGET_IPHEaze_SIMULATOR
            // Want xmpp to run in the background?
            //
            // P.S. - The simulator doesn't support backgrounding yet.
            //        When you try to set the associated property on the simulator, it simply fails.
            //        And when you background an app on the simulator,
            //        it just queues network traffic til the app is foregrounded again.
            //        We are patiently waiting for a fix from Apple.
            //        If you do enableBackgroundingOnSocket on the simulator,
            //        you will simply see an error message from the xmpp stack when it fails to set the property.
            xmppStream!.enableBackgroundingOnSocket = true
        #endif
        
        // Setup reconnect
        //
        // The XMPPReconnect module monitors for "accidental disconnections" and
        // automatically reconnects the stream for you.
        // There's a bunch more information in the XMPPReconnect header file.
        
        xmppReconnect = XMPPReconnect()
        
        // Setup roster
        //
        // The XMPPRoster handles the xmpp protocol stuff related to the roster.
        // The storage for the roster is abstracted.
        // So you can use any storage mechanism you want.
        // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
        // or setup your own using raw SQLite, or create your own storage mechanism.
        // You can do it however you like! It's your application.
        // But you do need to provide the roster with some storage facility.
        
        //xmppRosterStorage = XMPPRosterCoreDataStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        
        xmppRoster!.autoFetchRoster = true;
        xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
        
        // Setup vCard support
        //
        // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
        // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
        
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
        
        // Setup capabilities
        //
        // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
        // Basically, when other clients broadcast their presence on the network
        // they include information about what capabilities their client supports (audio, video, file transfer, etc).
        // But as you can imagine, this list starts to get pretty big.
        // This is where the hashing stuff comes into play.
        // Most people running the same version of the same client are going to have the same list of capabilities.
        // So the protocol defines a standardized way to hash the list of capabilities.
        // Clients then broadcast the tiny hash instead of the big list.
        // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
        // and also persistently storing the hashes so lookups aren't needed in the future.
        //
        // Similarly to the roster, the storage of the module is abstracted.
        // You are strongly encouraged to persist caps information across sessions.
        //
        // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
        // It can also be shared amongst multiple streams to further reduce hash lookups.
        
        xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage)
        
        xmppCapabilities!.autoFetchHashedCapabilities = true;
        xmppCapabilities!.autoFetchNonHashedCapabilities = false;
        
        xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts(dispatchQueue: DispatchQueue.main)
        
        
        xmppMessageDeliveryRecipts!.autoSendMessageDeliveryReceipts = true
        xmppMessageDeliveryRecipts!.autoSendMessageDeliveryRequests = true
        
        xmppLastActivity = XMPPLastActivity()
        
        // Activate xmpp modules
        xmppReconnect!.activate(xmppStream)
        xmppRoster!.activate(xmppStream)
        xmppvCardTempModule!.activate(xmppStream)
        xmppvCardAvatarModule!.activate(xmppStream)
        xmppCapabilities!.activate(xmppStream)
        xmppMessageDeliveryRecipts!.activate(xmppStream)
        xmppLastActivity!.activate(xmppStream)
        
        // Add ourself as a delegate to anything we may be interested in
        xmppStream!.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(messageTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(messageTest, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(rosterTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(rosterTest, delegateQueue: DispatchQueue.main)
        
        xmppStream!.addDelegate(presenceTest, delegateQueue: DispatchQueue.main)
        xmppRoster!.addDelegate(presenceTest, delegateQueue: DispatchQueue.main)
        
        xmppLastActivity!.addDelegate(lastActivityTest, delegateQueue: DispatchQueue.main)
        
        // Optional:
        //
        // Replace me with the proper domain and port.
        // The example below is setup for a typical google talk account.
        //
        // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
        // For example, if you supply a JID like 'user@quack.com/rsrc'
        // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
        //
        // If you don't specify a hostPort, then the default (5222) will be used.
        
        //	[xmppStream setHostName:@"talk.google.com"];
        //	[xmppStream setHostPort:5222];
        
        
        // You may need to alter these settings depending on the server you're connecting to
        customCertEvaluation = true;
    }
    
    private func teardownStream() {
        xmppStream!.removeDelegate(self)
        xmppRoster!.removeDelegate(self)
        xmppLastActivity!.removeDelegate(lastActivityTest)
        
        xmppLastActivity!.deactivate()
        xmppReconnect!.deactivate()
        xmppRoster!.deactivate()
        xmppvCardTempModule!.deactivate()
        xmppvCardAvatarModule!.deactivate()
        xmppCapabilities!.deactivate()
        EazeMessage.sharedInstance.xmppMessageArchiving!.deactivate()
        xmppStream!.disconnect()
        
        EazeMessage.sharedInstance.xmppMessageStorage = nil;
        xmppStream = nil;
        xmppReconnect = nil;
        xmppRoster = nil;
        //xmppRosterStorage = nil;
        xmppvCardStorage = nil;
        xmppvCardTempModule = nil;
        xmppvCardAvatarModule = nil;
        xmppCapabilities = nil;
        xmppCapabilitiesStorage = nil;
        xmppLastActivity = nil;
    }
    
    // MARK: Connect / Disconnect
    
    public func connect(){
        
        if !isConnected() {
            if (Reachability.isConnectedToNetwork()) {
            
         if let jid = UserDefaults.standard.string(forKey: kXMPP.myJID) {
            xmppStream?.myJID = XMPPJID(string: jid)
         } else {
            debugPrint("Empy Jabber ID")
            }
        
         if let password = UserDefaults.standard.string(forKey: kXMPP.myPassword) {
            self.password = password
         } else {
            debugPrint("Empty Jabber Password")
            }
         do {
            try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
            debugPrint("Connection success")
         } catch {
            debugPrint("Something went wrong!")
            }
            }
        }
        else {
            debugPrint("Stream is already connected")
        }
    }
    
    public func isConnected() -> Bool {
        return xmppStream!.isConnected()
    }
    
    public func disconnect() {
        EazePresence.goOffline()
        xmppStream?.disconnect()
    }
    
    // Mark: Private function
    
    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // Mark: UITableViewCell helpers
    
    public func configurePhotoForCell(imageViewInCell: UIImageView, user: XMPPUserCoreDataStorageObject) {
        // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
        // We only need to ask the avatar module for a photo, if the roster doesn't have it.
        if user.photo != nil {
            imageViewInCell.image = user.photo!;
        } else {
            let photoData = xmppvCardAvatarModule?.photoData(for: user.jid)
            
            if let photoData = photoData {
                imageViewInCell.image = UIImage(data: photoData)
            } else {
                imageViewInCell.image = UIImage(named: "person")
            }
        }
    }
}

// MARK: XMPPStream Delegate

extension EazeChat: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?) {
        delegate?.EazeStream(sender: sender, socketDidConnect: socket)
    }
    
    public func xmppStream(_ sender: XMPPStream?, willSecureWithSettings settings: NSMutableDictionary?) {
        let expectedCertName: String? = xmppStream?.myJID.domain
        
        if expectedCertName != nil {
            settings![kCFStreamSSLPeerName as String] = expectedCertName
        }
        if customCertEvaluation! {
            settings![GCDAsyncSocketManuallyEvaluateTrust] = true
        }
    }
    
    /**
     * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
     *
     * This is only called if the stream is secured with settings that include:
     * - GCDAsyncSocketManuallyEvaluateTrust == YES
     * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
     *
     * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
     *
     * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
     *
     * Note from Apple's documentation:
     *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
     *   [it] might block while attempting network access. You should never call it from your main thread;
     *   call it only from within a function running on a dispatch queue or on a separate thread.
     *
     * This is why this method uses a completionHandler block rather than a normal return value.
     * The idea is that you should be performing SecTrustEvaluate on a background thread.
     * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
     * It is safe to invoke the completionHandler block even if the socket has been closed.
     *
     * Keep in mind that you can do all kinds of cool stuff here.
     * For example:
     *
     * If your development server is using a self-signed certificate,
     * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
     * you're actually connecting to the expected dev server.
     *
     * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
     * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
     * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
     *
     * Generally, only Eaze delegate should implement this method.
     * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
     * And subsequent invocations of the completionHandler are ignored.
     **/
//
    public func xmppStream(_ sender: XMPPStream!, didReceive trust: SecTrust!, completionHandler: ((Bool) -> Swift.Void)!) {
        _ = DispatchQueue.global(qos: .userInitiated).async {
            var result: SecTrustResultType = SecTrustResultType.deny
            
            let status = SecTrustEvaluate(trust, &result)
            
            if status == noErr {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }

        }
    
        public func xmppStreamDidSecure(_ sender: XMPPStream!) {
        //did secure
    }
    
    public func xmppStreamDidConnect(_ sender: XMPPStream!) {
        do {
            try xmppStream?.authenticate(withPassword: password)
        } catch {
            print("Could not Authenticate")
        }
    }
    
    
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream!)
    {
        debugPrint("Stream Authenticated With Presence as online")
        EazePresence.goOnline()
    }
    
    public func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        debugPrint("Error in Stream Authentication")
    }
    
    public func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!) {
        delegate?.EazeStreamDidDisconnect(sender: sender, withError: error)
    }
}
