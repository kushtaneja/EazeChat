//
//  LoginViewController.swift
//  Eazespot
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit
import Alamofire
import XMPPFramework

class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate{
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    var companyArray = [Company]()
    let whitespaceSet =  Utils().returnWhiteSpaceCharacters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        EazeChat.start(delegate: nil)
        EazeChat.setupArchiving(archiving: true)
        
        passwordErrorLabel.text = ""
        usernameErrorLabel.text = ""
        passwordTextField.layer.borderWidth = CGFloat(integerLiteral: 1)
        passwordTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
        passwordTextField.tintColor = ColorCode().appThemeColor
        emailTextField.layer.borderWidth = CGFloat(integerLiteral: 1)
        emailTextField.tintColor = ColorCode().appThemeColor
        emailTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        /*
        if (UserDefaults.standard.value(forKey: "logout") !=  nil)
        {
            if (UserDefaults.standard.value(forKey: "logout") as! Bool) {
               
                EazeChat.start(delegate: nil)
                EazeChat.setupArchiving(archiving: true)
                
                debugPrint("STREAM STARTED AFTER LOGOUT")
                debugPrint("**LOGout == TRUE")
                
            }
            else if (!(UserDefaults.standard.value(forKey: "logout") as! Bool))
            {
                debugPrint("**LOGout == FALSE")
                
            }
        } else {
            
            EazeChat.start(delegate: nil)
            EazeChat.setupArchiving(archiving: true)
            
        }
        */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        passwordErrorLabel.text = ""
        usernameErrorLabel.text = ""
        passwordTextField.layer.borderWidth = CGFloat(integerLiteral: 1)
        passwordTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
        passwordTextField.tintColor = ColorCode().appThemeColor
        emailTextField.layer.borderWidth = CGFloat(integerLiteral: 1)
        emailTextField.tintColor = ColorCode().appThemeColor
        emailTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
        startNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopNotification()
    }
    
    func startNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func stopNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ aNotification: Notification) {
        if (activeField != nil){
            var info: [AnyHashable: Any] = aNotification.userInfo!
            let kbSize: CGSize = (((info[UIKeyboardFrameEndUserInfoKey])! as AnyObject).cgRectValue.size)
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            var aRect: CGRect = self.view.frame
            aRect.size.height -= kbSize.height
            if !aRect.contains(activeField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ aNotification: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        disableTextFieldEditing()
        
        if (!wrongPasswordField() && !wrongUsernameField()) {
            self.usernameErrorLabel.text = ""
            self.passwordErrorLabel.text = ""
            loginCall(email: emailTextField.text!.trimmingCharacters(in: whitespaceSet as CharacterSet), password: passwordTextField.text!)
        } else {
            switch wrongUsernameField() {
            case true:
                showErrorMessage(emailTextField.placeholder!)
            case false:
                removeErrorMessage(emailTextField.placeholder!)
            default:
                break
            }
            
            switch wrongPasswordField() {
            case true:
                showErrorMessage(passwordTextField.placeholder!)
            case false:
                removeErrorMessage(passwordTextField.placeholder!)
            default:
                break
            }
        }
        
    }
    
    func loginCall(email:String, password: String){
        let params: [String:Any] = ["username": email ,"password": password ]
        LoginService().loginCall(self.view, params: params, onSuccess: {(data: JSON) in
            if (data["login"] == false) {
                self.companyArray = []
                for company in data["company"].arrayValue {
                    let companyName = company["company_name"].stringValue
                    let companyId = company["company"].intValue
                    let currentCompany = Company(company_Name:companyName,company_Id: companyId)
                    self.companyArray.append(currentCompany)
                }
                
                let teamSelectionNavigationScreen = UIStoryboard.teamSelectionScreen()
                let teamSelectionScreen = teamSelectionNavigationScreen.topViewController as! TeamSelectionViewController
                teamSelectionScreen.companysArray = self.companyArray
                teamSelectionScreen.loginUsername = self.emailTextField.text!
                teamSelectionScreen.loginPassword = self.passwordTextField.text!
                UIApplication.topViewController()?.present(teamSelectionNavigationScreen, animated: true, completion: nil)
                
            } else if (data["login"] == true) {
                
                let user_id = data["user_id"].stringValue
                if (UserDefaults.standard.value(forKey: "user_id") !=  nil)
                {
                    if ((UserDefaults.standard.value(forKey: "user_id") as! String) == user_id ) {
                        
                    } else {
                        EazeChat.sharedInstance.disconnect()
//                      EazeMessage.sharedInstance.deleteMessages()
                        EazeRoster.removeUsers()
                        
                        self.setValue(value: user_id, forKey: "user_id")
                    }
                } else {
                    self.setValue(value: user_id, forKey: "user_id")
                }
                
                let userChatId = (data["cid"].stringValue).fromBase64()
                let userChatPassword = (data["cip"].stringValue).fromBase64()
                self.setValue(value: userChatId + "@chat.eazespot.com", forKey: kXMPP.myJID)
                self.setValue(value: userChatPassword, forKey: kXMPP.myPassword)
                
                let company_id = data["company_id"].intValue
                let company_name = data["company_name"].stringValue
                let jwt_token = data["key"].stringValue
                           
                self.setValue(value: jwt_token, forKey: "JWT_key")
                
                EazeChat.sharedInstance.connect()
               
                let params = ["company_id": company_id, "user_id": user_id] as [String : Any]
                
                ProfileService().profileCall(self.view, params: params, onSuccess: {(profdata: JSON) in
                    let firstname = profdata["user"]["first_name"].stringValue
                    let lastname = profdata["user"]["last_name"].stringValue
                    let email = profdata["user"]["email"].stringValue
                    let profilePicUrl =  profdata["profile_pic"]["L"].stringValue
                    let user = LoggedinUserProfile(userFirstName: firstname, userLastName: lastname, userEmail: email,userPicUrl: profilePicUrl,companyName: company_name)
                    let ProfDisplayNavigationScreen = UIStoryboard.ProfDisplayNavigationScreen()
                    let ProfDisplayScreen = ProfDisplayNavigationScreen.topViewController as!UserProfileDisplayViewController
                    ProfDisplayScreen.loggedinUser = user
                    
                    self.view.makeToast(message: "Successfully Logged in with Single Team")
                    ActivityIndicator.shared.hideProgressView()
                    UserDefaults.standard.setValue(false, forKey: "logout")
                    UIApplication.topViewController()?.present(ProfDisplayNavigationScreen, animated: true, completion: nil)
                    
                }, failed: {(errorCode: Int) in debugPrint("loginError")})
                
            }
        }, failed: {(errorCode: Int) in debugPrint("loginError")})
        
    }
    
    
    func wrongUsernameField()->Bool{
        var errorExists = true
        if emailTextField.text!.trimmingCharacters(in: whitespaceSet as CharacterSet) == "" {
            errorExists = true
        }
        else {
            errorExists = false
        }
        return errorExists
    }
    
    func wrongPasswordField()->Bool{
        var errorExists = true
        if passwordTextField.text!.isEmpty {
            
            showErrorMessage(passwordTextField.placeholder!)
            
            errorExists = true
        }
            //        else if Utils().isValidPassword(passwordTextField.text!) {
        else {
            
            removeErrorMessage(passwordTextField.placeholder!)
            
            errorExists = false
        }
        return errorExists
    }
    
    func showErrorMessage(_ placeholder: String){
        switch placeholder {
        case "Email or Username":
            emailTextField.layer.borderColor = ColorCode().redColor.cgColor
            self.usernameErrorLabel.text = "Invalid Username"
            self.view.makeToast(message: "Invalid Username or Email")
        case "Password":
            passwordTextField.layer.borderColor = ColorCode().redColor.cgColor
            self.passwordErrorLabel.text = "Invalid Password"
            self.view.makeToast(message: "Invalid Password")
        default:
            break
            
        }
    }
    
    func removeErrorMessage(_ placeholder: String) {
        switch placeholder {
        case "Email or Username" :
            self.usernameErrorLabel.text = ""
            emailTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
        case "Password" :
            self.passwordErrorLabel.text = ""
            passwordTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
        default:
            break
        }
    }
    
    func disableTextFieldEditing() {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        removeErrorMessage(textField.placeholder!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    private func setValue(value: String, forKey key: String) {
        if value.characters.count > 0 {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    
    @IBAction func forgotPasswordTapped(_ sender: AnyObject) {
        let resetPasswordScreen:ResetPasswordViewController = UIStoryboard.resetPasswordScreen()!
        UIApplication.topViewController()?.present(resetPasswordScreen, animated: true, completion: nil)
    }
    
    
}
