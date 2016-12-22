//
//  MailHomeViewController.swift
//  Eazespot
//
//  Created by Akshay Luthra on 21/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class MailHomeViewController: UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.revealViewController().toggleAnimationDuration = 0.3
            self.revealViewController().rearViewRevealOverdraw = 0.0
        }
        
        /*
        menuButton.target = self.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().shouldUseFrontViewOverlay = true
        self.revealViewController().toggleAnimationDuration = 0.3
        self.revealViewController().rearViewRevealOverdraw = 0.0
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
