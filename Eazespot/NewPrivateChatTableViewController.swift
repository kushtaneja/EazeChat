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

extension NewPrivateChatTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController){
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
}

class NewPrivateChatTableViewController: UITableViewController,EazeRosterDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var delegate:ContactPickerDelegate?
    var xmppUserCoreDataStorageObject = XMPPRosterCoreDataStorage()
    var filteredUsers = [XMPPUserCoreDataStorageObject]()
    var filderedBuddyList : NSFetchedResultsController<NSFetchRequestResult>?
    class var sharedInstance : NewPrivateChatTableViewController {
        struct NewPrivateChatSingleton {
            static let instance = NewPrivateChatTableViewController()
        }
        return NewPrivateChatSingleton.instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EazeRoster.sharedInstance.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        presentRecipients()
        
        
        if (searchController.isActive && searchController.searchBar.text != "")
        {
            self.navigationController?.navigationBar.isHidden = false
            searchController.searchBar.isHidden = false
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

       
       
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EazeRoster.sharedInstance.delegate = self
        ActivityIndicator.shared.showProgressView(uiView: self.view)
        presentRecipients()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// Mark: UITableView Datasources
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       if (searchController.isActive && searchController.searchBar.text != "") {
            return (filderedBuddyList!.sections?.count)!
        } else {
            return (EazeRoster.buddyList.sections?.count)!
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sections: Array<Any>?
        if (searchController.isActive && searchController.searchBar.text != "") {
           sections = filderedBuddyList?.sections
        }
       else {
        sections =  EazeRoster.buddyList.sections
        }
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section] as AnyObject
            
            return (sectionInfo as AnyObject).numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sections: Array<Any>?
        if (searchController.isActive && searchController.searchBar.text != "") {
           sections = filderedBuddyList?.sections
        }
        else {
         sections =  EazeRoster.buddyList.sections
        
        }
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section] as AnyObject
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
        
        if (searchController.isActive && searchController.searchBar.text != "")
        {
           // let user = filteredUsers[indexPath.row]
            let user = filderedBuddyList?.object(at: indexPath) as! XMPPUserCoreDataStorageObject
            cell.titleLabel?.text = user.displayName
        }
        else {
         
          let User = EazeRoster.buddyList.object(at: indexPath) as! XMPPUserCoreDataStorageObject
            
            cell.titleLabel?.text = User.displayName
        }
        
        
        /*
         
        if user.unreadMessages.intValue > 0 {
            cell.backgroundColor = ColorCode().appThemeColor
        } else {
            cell.backgroundColor = UIColor.white
        } 
         
         */
        
        
        cell.statusView?.layer.borderWidth = CGFloat(integerLiteral: 2)
        
        let sections: Array? =  EazeRoster.buddyList.sections
        
        let sectionInfo: AnyObject = sections![indexPath.section]
        let tmpSection: Int = Int(sectionInfo.name)!
        
        if (tmpSection == 0) {
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
    
    func EazeRosterContentChanged() {
        //Will reload the tableView to reflet roster's changes
        EazeRoster.sharedInstance.delegate = self

        ActivityIndicator.shared.showProgressView(uiView: self.view)
        tableView.reloadData()
    }
    
    //MARK: presentRecipients
    func presentRecipients(){
        
        Utils().delay(1.0, closure: {
    
                if EazeChat.sharedInstance.isConnected() {
                    self.tableView.reloadData()
                    self.navigationItem.title = "Select a recipient"
                    ActivityIndicator.shared.hideProgressView()
            }
            
        })
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        //filteredUsers = filter(EazeRoster.buddyList.fetchedObjects as! [XMPPUserCoreDataStorageObject],searchText: searchText)
        filderedBuddyList = filter(EazeRoster.buddyList, searchText: searchText)
        
        self.tableView.reloadData()
    }
   
    func filter(_ controller: NSFetchedResultsController<NSFetchRequestResult>, searchText: String)->NSFetchedResultsController<NSFetchRequestResult>{
        
        return EazeRoster.sharedInstance.filteredUsersFetchedResultsController(frorName: searchText.lowercased())!
    }

    
    
    
    // MARK: - Core Data Stack
    
    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
      
}
