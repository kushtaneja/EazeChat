//
//  ChatFriendListPageMenuViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 05/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import SDWebImage


class ChatFriendListPageMenuViewController: UIViewController,CAPSPageMenuDelegate{
    
        var pageMenu : CAPSPageMenu?
        let storyBoard: UIStoryboard =  UIStoryboard(name: "Main", bundle: nil)
        var controllerArray : [UIViewController] = []
        var pageMenuCurrentIndex = 0
        override func viewDidLoad() {
            super.viewDidLoad()
            UserDefaults.standard.set(false, forKey: "logout")
            if (UserDefaults.standard.value(forKey: "Name") != nil){
                self.navigationItem.title = UserDefaults.standard.value(forKey: "Name") as! String?
            }
            else{
             
            self.navigationItem.title = "Chats"
            
            }
            if (UserDefaults.standard.value(forKey: "login") !=  nil)
            {
                if (UserDefaults.standard.value(forKey: "login") as! Bool) {
                    
                    EazeChat.sharedInstance.connect()
                    
                    debugPrint("**LOGIN == TRUE")
                    
                }
                else if (!(UserDefaults.standard.value(forKey: "login") as! Bool))
                {
                    debugPrint("**LOGIN == FALSE")
                    
                }
            }

          
            
                      

        // Making Page View Controllers
            var controller : UIViewController = UIViewController()
        
        
        
            controller = storyBoard.instantiateViewController(withIdentifier: "PrivateChatTableViewController")
            controller.title = "Private"
            controllerArray.append(controller)
        //controller = storyBoard.instantiateViewControllerWithIdentifier("LookUpViewController")
            controller = storyBoard.instantiateViewController(withIdentifier: "GroupChatTableViewController")
            controller.title = "Group"
            controllerArray.append(controller)
        
            //    EazeMessage.sharedInstance.getMessagesFromServer()
        
        
            let parameters: [CAPSPageMenuOption] = [
            //.MenuHeight(40.0),
                .menuItemSeparatorWidth(0.0),
                .useMenuLikeSegmentedControl(true),
                .menuItemSeparatorPercentageHeight(0.1),
                .scrollMenuBackgroundColor(UIColor.clear),
                .selectionIndicatorColor(ColorCode().navBarBlueTextColor),
                .unselectedMenuItemLabelColor(ColorCode().navBarBlueTextColor),
                .selectedMenuItemLabelColor(ColorCode().navBarBlueTextColor),
                .selectedItemBackgroundColor(UIColor.clear),
                .unSelectedMenuItemBackgroundColor(UIColor.clear),
                .canChangePageOnHorizontalScroll(false),
                .addBottomMenuHairline(true),
                .bottomMenuHairlineColor(UIColor(rgb: 0xeeeeee))
            
            ]
            pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame:  CGRect(x: 0.0, y: 64.0, width: self.view.frame.width, height: self.view.frame.height - 64.0), pageMenuOptions: parameters)
        
        //pageMenu?.menuItemFont = UIFont(name: "Roboto-Regular", size: 15)!
            pageMenu?.view.backgroundColor = UIColor.clear
            pageMenu?.delegate = self
            self.view.addSubview(pageMenu!.view)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
        pageMenuCurrentIndex = index
        
        switch pageMenuCurrentIndex{
        case 0:
            print("@@@@@@@@ EXPLORE")
           
        case 1:
            print("@@@@@@@@ LOOK UP")
            
        default:
            break
        }
        
    }
    
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        pageMenuCurrentIndex = index
        
        switch pageMenuCurrentIndex{
        case 0:
            print("@@@@@@@@ WILL EXPLORE")
        case 1:
            print("@@@@@@@@ WILL LOOK UP")
        default:
            break
        }
    }

    @IBAction func newChatButtonTapped(_ sender: Any) {
        let newChatNavigationScreen = UIStoryboard.NewChatNavigationScreen()
        
        present(newChatNavigationScreen, animated: true, completion: nil)
        
        
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "JWT_key")
        defaults.removeObject(forKey: "profileURL")
        defaults.removeObject(forKey: kXMPP.myJID)
        defaults.removeObject(forKey: kXMPP.myPassword)

//UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
        EazeChat.stop()
        UserDefaults.standard.set(false, forKey: "login")
        UserDefaults.standard.set(true, forKey: "logout")
        let loginScreen = UIStoryboard.loginScreen()
        
        present(loginScreen, animated: true, completion: nil)
        
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
