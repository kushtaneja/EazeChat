//
//  UserProfileDisplayViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import SDWebImage

class UserProfileDisplayViewController: UIViewController {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var companyTextLabel: UILabel!
    
    var loggedinUser = LoggedinUserProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(loggedinUser.firstName + " " + loggedinUser.lastName
            , forKey: "Name")
        nameTextLabel.text = loggedinUser.firstName.uppercased() + " " + loggedinUser.lastName.uppercased()
        usernameTextLabel.text = loggedinUser.email
        companyTextLabel.text = loggedinUser.company
        profilePictureView.sd_setImage(with: (NSURL(string: loggedinUser.profilePicUrl) as! URL), placeholderImage: UIImage(named: "person"))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        let ChatFriendListPageMenuNavigationScreen = UIStoryboard.ChatFriendListPageMenuNavigationScreen()
       
        present(ChatFriendListPageMenuNavigationScreen, animated: true, completion: nil)
    }
    
}
