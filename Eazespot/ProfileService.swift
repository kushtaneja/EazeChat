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
    
    func profileCall(_ view: UIView, params: [String:Any],onSuccess: @escaping (_ parsedJSON: JSON) -> Void, failed:@escaping (_ errorCode: Int) -> Void){
        
        let company_id = params["company_id"] as! String
        let user_id = params["user_id"] as! String
        
        ActivityIndicator.shared.showProgressView(uiView: view, text: "loading")
        
        if Reachability.isConnectedToNetwork(){
            Network().sendGetRequest(Urls().getProfile(company_id: company_id, user_id: user_id), params: params, completion: {(data: JSON) in onSuccess(data) }, failed: {(errorMsg: JSON) in self.handleFailureCases(errorMsg,view: view)
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
