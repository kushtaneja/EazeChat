//
//  SideMenuViewController.swift
//  Eazespot
//
//  Created by Akshay Luthra on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    
    @IBOutlet weak var projectsDropDownView: UIView!
    @IBOutlet weak var projectsDropDownLabel: UILabel!
    
    var projectsDropDownLabelText = "Veg"
  //  let projectsDropDown = DropDown()
    var projectsOptions = ["Eazespot", "Mito", "Top Gear"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width/2
        
        //nameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("fullName") as? String
        //emailLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        switch(indexPath.row){
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "mailsCell")!
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell")!
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "chatCell")!
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell")!
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell")!
        default:break
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 4:
            logoutConfirmationAlert()
        default:
            debugPrint("default")
        }
    }
    
    
    func logoutConfirmationAlert(){
        let jssAlertView = JSSAlertView().show(
            self,
            title: "Logout",
            text: "Are you sure you want to logout?",
            buttonText: "Yes",
            cancelButtonText : "No",
            color: UIColorFromHex(0xE8E8E8, alpha: 1))
        jssAlertView.addAction(logoutUser)
        jssAlertView.addCancelAction({})
    }
    
    func logoutUser(){
        /*
        LogoutService().logoutUser(self.view, params: [:], onSuccess:{(data: JSON) in
            if(data["error"] ==  true){
                ActivityIndicator.shared.hideProgressView()
                self.view.makeToast(message: data["message"].stringValue)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "signedInStatus")
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "appDescriptionStatus")
                    NSNotificationCenter.defaultCenter().postNotificationName("logoutUser", object: nil)
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "checkNeverShowMessageAgain")
                    self.performSegueWithIdentifier("openAppDescriptionViewControllerFromSideMenuSegue", sender: self)
                }
            }
        }, failed:{(errorCode: Int) in print("failure")})
        */
    }
    
}
