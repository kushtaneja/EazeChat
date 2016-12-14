//
//  PrivateChatTableViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 10/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework

class PrivateChatTableViewController: UITableViewController, EazeRosterDelegate {
        
        var chatList = NSArray()
        
        // MARK: Life Cycle
        override func viewDidLoad() {
        super.viewDidLoad()
        EazeRoster.sharedInstance.delegate = self
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = 65
        tableView.reloadData()

        
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            EazeRoster.sharedInstance.delegate = self
            if (!EazeChat.sharedInstance.isConnected()){
                EazeChat.sharedInstance.connect()
            }
            tableView.reloadData()
            
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            EazeRoster.sharedInstance.delegate = nil
        }
        
        // MARK: EazeRoster Delegates
        
        func EazeRosterContentChanged() {
            //Will reload the tableView to reflet roster's changes
            tableView.reloadData()
        }
        
        // MARK: UITableView Datasources
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("**CHATLIST::\(EazeChats.getChatsList().count)")
            return EazeChats.getChatsList().count
        }
    
        override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
            
        }
    
        
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateChatTableViewCell", for: indexPath) as! PrivateChatTableViewCell
        let user = EazeChats.getChatsList()[indexPath.row] 
        cell.userNameLabel.text = user.displayName
        cell.lastMessageLabel.isHidden = true
        EazeChat.sharedInstance.configurePhotoForCell(imageViewInCell: cell.avatorThumbnail, user: user)
        
        cell.avatorThumbnail.layer.cornerRadius = (cell.avatorThumbnail.frame.width)/2
        cell.avatorThumbnail.clipsToBounds = true
        cell.lastMessageTimeLabel.isHidden = true
        
        return cell
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomNavigationScreen = UIStoryboard.ChatRoomNavigationScreen()
        
        if let controller = chatRoomNavigationScreen.topViewController as? ChatRoomViewController{
            let user = EazeChats.getChatsList()[indexPath.row]
            
            controller.recipient = user
            chatRoomNavigationScreen.pushViewController(controller, animated: true)
        }
        
        
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
            if editingStyle == UITableViewCellEditingStyle.delete {
                let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to clear the entire message history? \n This cannot be undEaze.", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                refreshAlert.addAction(UIAlertAction(title: "Clear message history", style: .destructive, handler: { (action: UIAlertAction!) in
                    EazeChats.removeUserAtIndexPath(indexPath: indexPath as NSIndexPath)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                present(refreshAlert, animated: true, completion: nil)
            }
        }
        
                 // MARK: Memory Management
        
        override func didReceiveMemoryWarning() {
            
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
