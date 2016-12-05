//
//  TeamSelectionViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 02/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import XMPPFramework


class TeamSelectionViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, ChatDelegate, XMPPRosterMemoryStorageDelegate{
    
    @IBOutlet weak var companyListPickerViewController: UIPickerView!
    var companysArray = [Company]()
    var selectedTeamId = Int()
    var userChatId = String()
    var userChatPassword = String()
    var loginPassword = String()
    var loginUsername = String()
    var onlineBuddies = NSMutableArray()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.delegate = self
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companysArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
    
        return  "\(companysArray[row].company_name)"
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedTeamId = companysArray[row].company_id
        
    }

    @IBAction func DoneButtonTapped(_ sender: UIBarButtonItem) {
        loginCall(email: loginUsername, password: loginPassword, company_id: selectedTeamId)
        let ChatSelectionNavigationScreen = UIStoryboard.ChatSelectionScreen()
        present(ChatSelectionNavigationScreen, animated: true, completion: nil)
        
    }
    

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func loginCall(email:String, password: String, company_id: Int){
        let params: [String:Any] = ["username": email as! String,"password": password as! String, "company": company_id as! Int]
        
        LoginService().loginCall(self.view, params: params, onSuccess: {(data: JSON) in
            self.userChatId = (data["cid"].stringValue).fromBase64()
            self.userChatPassword = (data["cip"].stringValue).fromBase64()
            
            
            
            UserDefaults.standard.set(self.userChatId + "@chat.eazehub.com", forKey: "chatUserID")
            UserDefaults.standard.set(self.userChatPassword, forKey: "chatUserPassword")
            
            
            print("*** \(self.userChatId) -- \(self.userChatPassword)")
            
            
            print("***@@@ \(UserDefaults.standard.object(forKey: "chatUserID")) -- \(UserDefaults.standard.object(forKey: "chatUserPassword"))")
            
            
            if self.appDelegate.connect() {
                self.view.makeToast(message: "You are connected")
                
                Utils().delay(5.0, closure: {
                    self.appDelegate.xmppRoster.fetch()
                    debugPrint("buddies = \(self.appDelegate.xmppRoster.fetch())")
                })
                
                
                
            }
            else{
              self.view.makeToast(message: "Unable to connect")
            
            }
            debugPrint("USER id = \(UserDefaults.standard.object(forKey: "chatUserID"))")
            ActivityIndicator.shared.hideProgressView()
            
            },failed: {(errorCode: Int) in debugPrint("TeamLoginError")})
        
        }
    
    
    
        func buddyWentOnline() {
//        if !onlineBuddies.contains(name) {
//            onlineBuddies.add(name)
//        
//            }
        }
    
        func buddyWentOffline() {
//            onlineBuddies.remove(name)

        }
    
        func didDisconnect() {
            onlineBuddies.removeAllObjects()
    
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
