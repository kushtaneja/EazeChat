//
//  Utils.swift
//  Eazespot
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    
    func returnWhiteSpaceCharacters() -> CharacterSet {
        return CharacterSet.whitespaces
    }
    
    
    func alertView(_ vc: UIViewController, title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.removeFromSuperview()
    }
    
    
    func checkNSUserDefault(_ key:String)->String{
        if(UserDefaults.standard.object(forKey: key) != nil){
            return (UserDefaults.standard.object(forKey: key) as! String)
        }
        return ""
    }
    
    
    // give delay in execution
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // check for TextField validations
    
    func isValidEmail(_ testStr:String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidPassword(_ testStr:String) -> Bool{
        let passwordRegEx = "^.{6,}$"
        let range = testStr.range(of: passwordRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidPhoneNumber(_ testStr:String) -> Bool{
        let phoneNumberRegEx = "^.{10,}$"
        let range = testStr.range(of: phoneNumberRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }

    func getDeviceWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func getDeviceHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
}
