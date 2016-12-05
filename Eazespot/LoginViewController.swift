//
//  LoginViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController{

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?
    var companyArray = [Company]()
    let whitespaceSet =  Utils().returnWhiteSpaceCharacters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   var errorExists = false
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
         disableTextFieldEditing()
        errorExists = false
        if emailTextField.text!.trimmingCharacters(in: whitespaceSet as CharacterSet) == "" {
            showErrorMessage(emailTextField.placeholder!)
            errorExists = true
        }
        else {
            removeErrorMessage(passwordTextField.text!)
            errorExists = false
        
        }
        if passwordTextField.text!.isEmpty {
            showErrorMessage(passwordTextField.placeholder!)
            errorExists = true
        }
        else if Utils().isValidPassword(passwordTextField.text!) {
        removeErrorMessage(passwordTextField.text!)
         errorExists = false
        }
        if !errorExists {
            loginCall(email: emailTextField.text!.trimmingCharacters(in: whitespaceSet as CharacterSet), password: passwordTextField.text!)
        
        }

    }
    
    func loginCall(email:String, password: String){
        let params: [String:Any] = ["username": email as! String,"password": password as! String]
        LoginService().loginCall(self.view, params: params, onSuccess: {(data: JSON) in
            if (data["login"] == false) {
                self.companyArray = []
                for company in data["company"].arrayValue {
                    let companyName = company["company_name"].stringValue
                    var companyId = company["company"].intValue
                    var currentCompany = Company(company_Name:companyName,company_Id: companyId)
                    
                    self.companyArray.append(currentCompany)
                }
                
                let teamSelectionNavigationScreen = UIStoryboard.teamSelectionScreen()
                let teamSelectionScreen = teamSelectionNavigationScreen.topViewController as! TeamSelectionViewController
                teamSelectionScreen.companysArray = self.companyArray
                teamSelectionScreen.loginUsername = self.emailTextField.text!
                teamSelectionScreen.loginPassword = self.passwordTextField.text!
                
                
                
                UIApplication.topViewController()?.present(teamSelectionNavigationScreen, animated: true, completion: nil)
                
            } else if (data["login"] == true) {
              self.view.makeToast(message: "Successfully Logged in with Single Team")
            }
            
            
            
            
            ActivityIndicator.shared.hideProgressView()
            }, failed: {(errorCode: Int) in debugPrint("loginError")})
    }
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.resignFirstResponder()
    }
    func disableTextFieldEditing() {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showErrorMessage(_ placeholder: String){
        switch placeholder {
            case "Email or Username":
            emailTextField.layer.borderColor = UIColor.red.cgColor
            self.view.makeToast(message: "Invalid Username or Email")
            case "Password":
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            self.view.makeToast(message: "Invalid Password")
        default:
            break
        
        }
        
            }
    func removeErrorMessage(_ placeholder: String) {
        switch placeholder {
        case "Email or Username" :
            emailTextField.text = ""
            emailTextField.layer.borderColor = UIColor.white as! CGColor
        case "Password" :
            passwordTextField.text = ""
            passwordTextField.layer.borderColor = UIColor.white as! CGColor
        default:
            break
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        removeErrorMessage(textField.placeholder!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    

}

