//
//  LoginService.swift
//  Eazespot
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

class LoginService {
    func loginCall(_ view: UIView, params: [String:Any],onSuccess: @escaping (_ parsedJSON: JSON) -> Void, failed:@escaping (_ errorCode: Int) -> Void){
        ActivityIndicator.shared.showProgressView(uiView: view, text: "loading")
        
        if Reachability.isConnectedToNetwork(){
            Network().postCall(Urls().login(), params: params, completion: {(data: JSON) in onSuccess(data) }, failed: {(errorMsg: JSON) in self.handleFailureCases(errorMsg,view: view)
            })
        }
        else {
        ActivityIndicator.shared.hideProgressView()
            view.makeToast(message: "No Internet Connection")
        }
    }
    
    func handleFailureCases(_ errorMsg:JSON,view:UIView){
        ActivityIndicator.shared.hideProgressView()
        view.makeToast(message: errorMsg["err"].stringValue)
    }



}
