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
        
        nameTextLabel.text = loggedinUser.firstName.capitalized + " " + loggedinUser.lastName.capitalized
        usernameTextLabel.text = loggedinUser.email
        companyTextLabel.text = loggedinUser.company
        profilePictureView.sd_setImage(with: (NSURL(string: loggedinUser.profilePicUrl) as! URL), placeholderImage: UIImage(named: "person"))
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        let ChatFriendListPageMenuNavigationScreen = UIStoryboard.ChatFriendListPageMenuNavigationScreen()
        present(ChatFriendListPageMenuNavigationScreen, animated: true, completion: nil)
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
