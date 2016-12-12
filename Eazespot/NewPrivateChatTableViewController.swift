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

protocol ContactPickerDelegate{
    func didSelectContact(recipient: XMPPUserCoreDataStorageObject)
}

class NewPrivateChatTableViewController: UITableViewController,EazeRosterDelegate {
    
    var delegate:ContactPickerDelegate?
    var xmppUserCoreDataStorageObject = XMPPRosterCoreDataStorage()
    
    class var sharedInstance : NewPrivateChatTableViewController {
        struct NewPrivateChatSingleton {
            static let instance = NewPrivateChatTableViewController()
        }
        return NewPrivateChatSingleton.instance
    }
    
        override func viewDidLoad() {
        super.viewDidLoad()
        EazeRoster.sharedInstance.delegate = self
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if EazeChat.sharedInstance.isConnected() {
            navigationItem.title = "Select a recipient"
        }
        
        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (EazeRoster.buddyList.sections?.count)!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sections: Array? =  EazeRoster.buddyList.sections
        
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section]
            
            return (sectionInfo as AnyObject).numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections: Array? =  EazeRoster.buddyList.sections
        
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section]
            let tmpSection: Int = Int(sectionInfo.name)!
            
            switch (tmpSection) {
            case 0 :
                return "Available"
                
            case 1 :
                return "Away"
                
            default :
                return "Offline"
                
            }
        }
        
        return ""
    }

   
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewPrivateChatTableViewCell", for: indexPath) as! ContactTableViewCell
        let user = EazeRoster.buddyList.object(at: indexPath) as! XMPPUserCoreDataStorageObject


        /*
         
        if user.unreadMessages.intValue > 0 {
            cell.backgroundColor = ColorCode().appThemeColor
        } else {
            cell.backgroundColor = UIColor.white
        } 
         
         */
        cell.titleLabel?.text = user.displayName
        
        cell.statusView?.layer.borderWidth = CGFloat(integerLiteral: 2)
        
        if (indexPath.section == 0) {
            cell.statusView?.layer.backgroundColor = ColorCode().statusOnlineGreenColor.cgColor
            cell.statusView?.layer.borderColor = UIColor.white.cgColor
        }
        else {
            cell.statusView?.layer.backgroundColor = UIColor.white.cgColor
            cell.statusView?.layer.borderColor = ColorCode().statusOfflineBorderColor.cgColor
        
        
        }
        /*
        EazeChat.sharedInstance.configurePhotoForCell(imageViewInCell: cell.avatorThumbnail, user: user)
        cell.avatorThumbnail.layer.cornerRadius = (cell.avatorThumbnail.frame.width)/2
        cell.avatorThumbnail.clipsToBounds = true
         */

        return cell

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomNavigationScreen = UIStoryboard.ChatRoomNavigationScreen()
        if let controller = chatRoomNavigationScreen.topViewController as? ChatRoomViewController{
                let user = EazeRoster.userFromRosterAtIndexPath(indexPath: indexPath)
                controller.recipient = user
            let ChatFriendListNavigationScreen = UIStoryboard.ChatFriendListPageMenuNavigationScreen()
            present(ChatFriendListNavigationScreen, animated: true, completion:{
            ChatFriendListNavigationScreen.pushViewController(controller, animated: false)
            })
        }
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
    
    // MARK: EazeRoster Delegates
    
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