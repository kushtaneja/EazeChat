//
//  ProfileService.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

class ProfileService {
    
    func profCall(_ view: UIView, params: [String:Any],onSuccess: @escaping (_ parsedJSON: JSON) -> Void, failed:@escaping (_ errorCode: Int) -> Void){
        ActivityIndicator.shared.showProgressView(uiView: view, text: "loading")
        
        if Reachability.isConnectedToNetwork(){
            Network().sendGetRequest(Utils().checkNSUserDefault("profileURL"), params: params, completion: {(data: JSON) in onSuccess(data) }, failed: {(errorMsg: JSON) in self.handleFailureCases(errorMsg,view: view)
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
