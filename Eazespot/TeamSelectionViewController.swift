//
//  TeamSelectionViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 02/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit


class TeamSelectionViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var companyListPickerViewController: UIPickerView!
    var companysArray = [Company]()
    var selectedTeamId = Int()
    var userChatId = String()
    var userChatPassword = String()
    var loginPassword = String()
    var loginUsername = String()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

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
        
        print("hhhh: \(selectedTeamId)")
        
    }

    @IBAction func DoneButtonTapped(_ sender: UIBarButtonItem) {
        loginCall(email: loginUsername, password: loginPassword, company_id: selectedTeamId)
        
    }
    

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func loginCall(email:String, password: String, company_id: Int){
        let params: [String:Any] = ["username": email as! String,"password": password as! String, "company": company_id as! Int]
        
        LoginService().loginCall(self.view, params: params, onSuccess: {(data: JSON) in
            self.userChatId = (data["cid"].stringValue).fromBase64()
            self.userChatPassword = (data["cip"].stringValue).fromBase64()
            debugPrint("\(self.userChatId)and\(self.userChatPassword)")
            
            
            
            
            ActivityIndicator.shared.hideProgressView()
        },failed: {(errorCode: Int) in debugPrint("TeamLoginError")})
        
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
