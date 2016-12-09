//
//  AppDelegate.swift
//  Eazespot
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import XMPPFramework
import SWXMLHash

protocol ChatDelegate {
        func buddyWentOnline()
        func buddyWentOffline()
        func didDisconnect()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPRosterDelegate, XMPPStreamDelegate,NSFetchedResultsControllerDelegate {

    var window: UIWindow?
    // for chat
    var delegate:ChatDelegate! = nil
    let xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster
    var xmppUserCoreDataStorageObject = XMPPUserCoreDataStorageObject()
    var xmppRoasterCoreDataStorageObject = XMPPRosterCoreDataStorage()
    var xmppvCardStorage: XMPPvCardCoreDataStorage?
    var xmppvCardTempModule: XMPPvCardTempModule?
    public var xmppvCardAvatarModule: XMPPvCardAvatarModule?
    public var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
   

    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
    }

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        setupStream()
        setupArchiving()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        disconnect()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    
    
    
    
    // MARK: - Chat
    func setupArchiving() {
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
        
        xmppMessageArchiving?.clientSideMessageArchivingOnly = true
        xmppMessageArchiving?.activate(xmppStream)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
    }

    
    func setupStream() {
        //xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.activate(xmppStream)
        xmppRoster.autoFetchRoster = true
        xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
        xmppvCardTempModule!.activate(xmppStream)
        xmppvCardAvatarModule!.activate(xmppStream)
        xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    func goOnline() {
        let presence = XMPPPresence()
        let domain = xmppStream?.myJID.domain
        
        //if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
        let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
        presence?.addChild(priority)
        //}
        xmppStream?.send(presence)
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream?.send(presence)
    }
    
    func connect() -> Bool {
    
        if !(xmppStream?.isConnected())! {
            let jabberID = UserDefaults.standard.string(forKey: "chatUserID")
            let myPassword = UserDefaults.standard.string(forKey: "chatUserPassword")
            
            if !(xmppStream?.isDisconnected())! {
                return true
            }
            if jabberID == nil && myPassword == nil {
                return false
            }
            
            xmppStream?.myJID = XMPPJID(string: jabberID)
            
            print("AA : \(jabberID)")
            print("AAA : \(xmppStream?.myJID)")
            print("AAAA : \(myPassword)")
            
            
            do {
                try xmppStream?.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
        
    }
    
    func disconnect() {
        goOffline()
        xmppStream?.disconnect()
        
        print("CHAT disconnected")
        
    }
    
    
    //MARK: XMPP Delegates
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        do {
            try xmppStream?.authenticate(withPassword: UserDefaults.standard.string(forKey: "chatUserPassword"))
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        goOnline()
    }
    
    

    private func xmppRoster(_ sender: XMPPRoster!, didReceiveRosterPush iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print("Did receive message \(message)")
        
        let user = xmppRosterStorage.user(for: message.from(), xmppStream: xmppStream, managedObjectContext: xmppRosterStorage.mainThreadManagedObjectContext)
 /*
        if !PrivateChatTableViewController.knownUserForJid(jidStr: (user?.jidStr)!) {
            PrivateChatTableViewController.addUserToChatList(jidStr: (user?.jidStr)!)
        }
        */
       /* if message.isChatMessageWithBody() {
           
                //let displayName = user.displayName
//                
//                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
                if let msg: String = message.forName("body")?.stringValue {
                    if let from: String = message.attribute(forName: "from")?.stringValue {
                    
                        let message = JSQMessage(senderId: from, senderDisplayName: from, date: NSDate(), text: msg)
                        messages.addObject(message)
                        
                        self.finishReceivingMessageAnimated(true)
                    }
                }
            

        } else {
            //was composing
            if let _ = message.elementForName("composing") {
                OneMessage.sharedInstance.delegate?.oneStream(sender, userIsComposing: user)
            }
        }
    }
*/
    }
    
    func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        print("Did send message \(message)")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(presenceFromUser)")
            if presenceType == "available" {
//                delegate.buddyWentOnline(name: "\(presenceFromUser)@gmail.com")
            } else if presenceType == "unavailable" {
//                delegate.buddyWentOffline(name: "\(presenceFromUser)@gmail.com")
            }
        }
    }
    
    func xmppRoster(_ sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
            print("Did receive Roster item : \(item)")
            let rosterItem = item!
            let dataString = String(describing: rosterItem)
            
            let xml = SWXMLHash.config { // the xml variable is our XMLIndexer
                config in
                config.shouldProcessLazily = false
                }.parse(dataString)
            
            
            let name = xml["item"].element?.attribute(by: "name")?.text
            let jid = xml["item"].element?.attribute(by: "jid")?.text
            let subscription = xml["item"].element?.attribute(by: "subscription")?.text
       
            if (subscription == "both") {
//                //xmppUserCoreDataStorageObject.update(withItem: rosterItem)
//                
//                
////                XMPPUserCoreDataStorageObject.insert(in: managedObjectContext, with: XMPPJID(string: jid), streamBareJidStr: XMPPJID(string: jid).bare())
//                let context = persistentContainer.viewContext
//                XMPPUserCoreDataStorageObject.insert(in: context, withItem: rosterItem, streamBareJidStr: XMPPJID(string: jid).bare())
//                
//                
//               let user = xmppRoasterCoreDataStorageObject.user(for: XMPPJID(string: jid), xmppStream: xmppStream , managedObjectContext: xmppRosterStorage.mainThreadManagedObjectContext)
//                print("USER DETAILS: \(user?.jidStr)")
        
    }
    
    }
    
//    func xmppRosterDidEndPopulating(sender: XMPPRoster?){
//            var jidList = xmppRosterStorage!.jidsForXMPPStream(xmppStreams)
//            fetchedResultsControllerVar!.fetchedObjects
//    
//            print("List=\(jidList)")
//    
//        }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Eazespot")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
 
    

}


extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}




