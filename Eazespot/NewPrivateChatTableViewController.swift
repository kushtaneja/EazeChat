//
//  NewPrivateChatTableViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework
import SWXMLHash

class NewPrivateChatTableViewController: UITableViewController,EazeRosterDelegate {
    
    var onlineBuddies = NSMutableArray()
    var xmppUserCoreDataStorageObject = XMPPRosterCoreDataStorage()
    var chatList = [NSFetchRequestResult]()
    
    class var sharedInstance : NewPrivateChatTableViewController {
        struct OneChatsSingleton {
            static let instance = NewPrivateChatTableViewController()
        }
        return OneChatsSingleton.instance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EazeRoster.sharedInstance.delegate = self
        let objects = EazeRoster.sharedInstance.fetchedResultsController()?.fetchedObjects
        chatList = objects!
        debugPrint("**CHATLIst :: \(chatList.count)")
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        EazeRoster.sharedInstance.delegate = self
        tableView.rowHeight = 65
        let objects = EazeRoster.sharedInstance.fetchedResultsController()?.fetchedObjects
        chatList = objects!
            debugPrint("**CHATLIst :: \(chatList.count)")
    
        
       /* for object in objects! {
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
            }}
        
        
        */
        
        

        
        

    // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        EazeRoster.sharedInstance.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark: UITableView Datasources
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        print("***NUMBEROFUSERS \(EazeChats.getChatsList().count)")
        
        return EazeChats.getChatsList().count*/
        
        
        return chatList.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //let sections: NSArray? = EazeRoster.sharedInstance.fetchedResultsController()!.sections
        return 1   //sections

    }
   
    
    // Mark: UITableView Delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewPrivateChatTableViewCell", for: indexPath) as! PrivateChatTableViewCell
        let user = chatList[indexPath.row] as! XMPPUserCoreDataStorageObject
        
        /*
        let user = EazeChats.getChatsList().object(at: indexPath.row) as! XMPPUserCoreDataStorageObject */
        
        
        cell.userNameLabel.text = user.displayName
        EazeChat.sharedInstance.configurePhotoForCell(imageViewInCell: cell.avatorThumbnail, user: user)
        cell.avatorThumbnail.layer.cornerRadius = (cell.avatorThumbnail.frame.width)/2
        /*
        cell.avatorThumbnail.clipsToBounds = true
        */
        return cell

    }
    
  
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
  
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
    
    // Mark: EazeRoster Delegates
    
    func EazeRosterContentChanged(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //Will reload the tableView to reflet roster's changes
        tableView.reloadData()
    }
    
    
    // MARK: - Core Data Stack
    
    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
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
