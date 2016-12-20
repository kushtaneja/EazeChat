//
//  ResetPasswordViewController.swift
//  Eazespot
//
//  Created by Akshay Luthra on 20/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldErrorMessage: UILabel!
    
    let whitespaceSet = Utils().returnWhiteSpaceCharacters()
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        emailTextFieldErrorMessage.text = ""
        emailTextField.layer.borderWidth = CGFloat(integerLiteral: 1)
        emailTextField.tintColor = ColorCode().appThemeColor
        emailTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        startNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopNotification()
    }
    
    func startNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func stopNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillBeHidden(_ aNotification: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        
        emailTextFieldErrorMessage.text = ""
        emailTextField.layer.borderColor = ColorCode().appThemeColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func keyboardWillShow(_ aNotification: Notification) {
        if(activeField != nil) {
            var info: [AnyHashable: Any] = aNotification.userInfo!
            let kbSize: CGSize = ((info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size)
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
    
    func resetPasswordCall(_ email:String){
        let params: Dictionary<String,AnyObject> = ["email":email as AnyObject]
        
        print("@@@ \(params)")
        
        ForgotPasswordService().forgotPassword(self.view, params: params as Dictionary<String, AnyObject>, onSuccess:{(data: JSON) in
                DispatchQueue.main.async {
                    ActivityIndicator.shared.hideProgressView()
                    self.dismiss(animated: true, completion: nil)
                    self.view.makeToast(message: "A password reset link has been sent to your email")
                }
        }, failed:{(errorCode: Int) in print("failure")})
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        
        if ((emailTextField.text?.trimmingCharacters(in: whitespaceSet as CharacterSet))! == ""){
            emailTextField.layer.borderColor = ColorCode().redColor.cgColor
            self.emailTextFieldErrorMessage.text = "Invalid Username"
            self.view.makeToast(message: "Invalid Email")
            return
        }
        
        resetPasswordCall(emailTextField.text!.trimmingCharacters(in: whitespaceSet as CharacterSet))
    }

}
