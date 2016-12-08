//
//  PrivateChatTableViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework
import SWXMLHash

class PrivateChatTableViewController: UITableViewController, ChatDelegate, XMPPRosterMemoryStorageDelegate,NSFetchedResultsControllerDelegate {
    
    var onlineBuddies = NSMutableArray()
    var xmppUserCoreDataStorageObject = XMPPRosterCoreDataStorage()
    let managedObjectContext = NSManagedObjectContext()
    var chatList = NSArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 65
        let objects = self.fetchedResultsController()!.fetchedObjects
        for object in objects! {
            let object = object as! XMPPUserCoreDataStorageObject
            let name = object.displayName
            let jid = object.jid
            let subscription = object.subscription
            print("NAME:::  \(name) \n JID:: \(jid) \n SUBSCRIPTION: \(subscription)")
            if object.photo != nil {
                print("Photo in Roster found")
            } else {
                
                let data = self.appDelegate.xmppvCardAvatarModule?.photoData(for: jid!)
                print("\(data)")
                let dataString = String(describing: data)
                let xml = SWXMLHash.config { // the xml variable is our XMLIndexer
                    config in
                    config.shouldProcessLazily = false
                    }.parse(dataString)
                
                
                let name1 = xml
                print("yyy : \(name1)")
            }
            
            
            
            
            
            
        }
        
        


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    func getChatsList() -> NSArray {
        if chatList.count == 0  {
            if let chatList: NSMutableArray = getActiveUsersFromCoreDataStorage() as? NSMutableArray {//NSUserDefaults.standardUserDefaults().objectForKey("openChatList")
                chatList.enumerateObjects({ (jidStr, index, finished) -> Void in
                    getUserFromXMPPCoreDataObject(jidStr: jidStr as! String)
                    
                    if let user = userFromRosterForJID(jid: jidStr as! String) {
                       chatList.add(user)
                    }
                })
            }
        }
        return chatList
    }

    // Mark: OneRoster Delegates
    
    func oneRosterContentChanged(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //Will reload the tableView to reflet roster's changes
        tableView.reloadData()
    }
    
    
    // MARK: - ChatDelegate Methods
    
    func buddyWentOnline() {
        //        if !onlineBuddies.contains(name) {
        //            onlineBuddies.add(name)
        //
        //            }
    }
    
    func buddyWentOffline() {
        //            onlineBuddies.remove(name)
        
    }
    
    func didDisconnect() {
        onlineBuddies.removeAllObjects()
        
    }
    
    // MARK: - Core Data Stack
    
    func managedObjectContext_roster() -> NSManagedObjectContext {
        return self.appDelegate.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string: jid)
        
        if let user = self.appDelegate.xmppRosterStorage.user(for: userJID, xmppStream: self.appDelegate.xmppStream, managedObjectContext:managedObjectContext_roster()) {
            return user
        } else {
            return nil
        }
    }
    
    func userFromRosterAtIndexPath(indexPath indexPath:IndexPath) -> XMPPUserCoreDataStorageObject {
        return fetchedResultsController()!.object(at: indexPath) as! XMPPUserCoreDataStorageObject
    }
    
    func removeUserFromRosterAtIndexPath(indexPath indexPath: IndexPath) {
        let user = userFromRosterAtIndexPath(indexPath: indexPath)
        fetchedResultsController()?.managedObjectContext.delete(user)
    }
    


    func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        let moc = managedObjectContext_roster() as NSManagedObjectContext?
        var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
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
        
        return fetchedResultsControllerVar!
        
    }
    func getActiveUsersFromCoreDataStorage() -> NSArray? {
        let moc = managedObjectContext_roster() as NSManagedObjectContext?
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "streamBareJidStr like %@ "
        
        if let predicateString = UserDefaults.standard.string(forKey: "chatUserID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                var _: XMPPMessageArchiving_Message_CoreDataObject
                let archivedMessage = NSMutableArray()
                
                for message in results! {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    } catch _ {
                        element = nil
                    }
                    let sender: String
                    
                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "chatUserID")! && !(element.attributeStringValue(forName: "to") as NSString).contains(UserDefaults.standard.string(forKey: "chatUserID")!) {
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
    

    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    func getUserFromXMPPCoreDataObject(jidStr: String) {
        let moc = managedObjectContext_roster() as NSManagedObjectContext?
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        
        var predicate: NSPredicate
        
        if self.appDelegate.xmppStream == nil {
            predicate = NSPredicate(format: "jidStr == %@", jidStr)
        } else {
            predicate = NSPredicate(format: "jidStr == %@ AND streamBareJidStr == %@", jidStr, UserDefaults.standard.string(forKey: "chatUserID")!)
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            let result =  try moc?.fetch(fetchRequest)
            
            let a = result as! [NSManagedObject]
            
            for aaaa in result! {
                print("\(aaaa)")
            }
            
            var element: DDXMLElement!
            /*do {
             element = //try DDXMLElement(xmlString: String(describing: result))
             } catch _ {
             element = nil
             }*/
            print("HOOO00 \(result)")
            
            
        }
        catch {
            
            
        }
        
    }

    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
