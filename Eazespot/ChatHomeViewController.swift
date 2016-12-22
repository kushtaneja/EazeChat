//
//  ChatHomeViewController.swift
//  Eazespot
//
//  Created by Akshay Luthra on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ChatHomeViewController: UIViewController {

    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.revealViewController().toggleAnimationDuration = 0.3
            self.revealViewController().rearViewRevealOverdraw = 0.0
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.value(forKey: "logout") !=  nil) {
            if (UserDefaults.standard.value(forKey: "logout") as! Bool) {
                
            } else {
                EazeChat.sharedInstance.connect()
                Utils().delay(2.0, closure: {
                    if (!(EazeChat.sharedInstance.isConnected())) {
                        Utils().alertViewforXmppStreamConnection(self, title: "Unable to connect to our Chat Server", message: "Chat not Connected")
                    }
                })
            }
        }
    }
    
    
    @IBAction func selectNewChatUserButtonTapped(_ sender: Any) {
        let newChatNavigationScreen = UIStoryboard.newChatNavigationScreen()
        present(newChatNavigationScreen, animated: true, completion: nil)
    }
    
    
    
    
    
    /*
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "JWT_key")
        defaults.removeObject(forKey: kXMPP.myJID)
        defaults.removeObject(forKey: kXMPP.myPassword)
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
        
        //let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //appDelegate?.saveContext()
        
        UserDefaults.standard.set(true, forKey: "logout")
        
        let loginScreen = UIStoryboard.loginScreen()
        
        present(loginScreen, animated: true, completion: nil)
        
    }
    
    */
    
}
