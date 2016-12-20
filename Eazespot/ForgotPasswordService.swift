//
//  ForgotPasswordService.swift
//  Eazespot
//
//  Created by Akshay Luthra on 20/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordService {
    func forgotPassword(_ view: UIView, params: Dictionary<String,AnyObject>,onSuccess: @escaping (_ parsedJSON: JSON) -> Void, failed: (_ errorCode: Int) -> Void){
        ActivityIndicator.shared.showProgressView(uiView: view, text: "Please wait...")
        if Reachability.isConnectedToNetwork() {
            Network().postCall(Urls().forgotPassword(), params: params, completion: {(data: JSON) in
                onSuccess(data)
            }, failed: {(errorMsg: JSON) in
                self.handleFailureCases(errorMsg,view: view)
            })
        } else {
            ActivityIndicator.shared.hideProgressView()
            view.makeToast(message: "No Internet Connection")
        }
    }
    
    func handleFailureCases(_ errorMsg:JSON,view:UIView){
        ActivityIndicator.shared.hideProgressView()
        view.makeToast(message: errorMsg["message"].stringValue)
    }
}
