import UIKit
import Foundation
import Alamofire

class Network {

    func postCall(_ url: String, params: [String:Any],completion: @escaping(_ parsedJSON: JSON)-> Void, failed: @escaping(_ ErrorMsg:JSON)-> Void){
        var AlamofireManager: Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // after 20 seconds it stops
        configuration.timeoutIntervalForResource = 10
        AlamofireManager = Alamofire.SessionManager(configuration: configuration)
        Alamofire.request(url, method: .post, parameters: params, encoding : JSONEncoding.default).validate().responseJSON { response in
          
            switch response.result {
            case .success:
                let parsedJSON = JSON(response.result.value!)
                completion(parsedJSON)
            case .failure(let error):
                do {
                    let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                    guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                        return
                    }
                    
                    let parsedJson = JSON(JSONDictionary)
                    failed(parsedJson)
                }
                catch let JSONError as NSError {
                    print("Error while sending Request")
                    print(response.result.error?._code)
                    print("\(JSONError)")
                    let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                    let error = ["message":errorMessage]
                    let json = JSON(error)
                    failed(json)
                    debugPrint("*postCall Faliure*\(url) ** \(json)")
                }
                }
            }
}

    func sendGetRequest(_ url: String, params: [String:Any],completion: @escaping(_ parsedJSON: JSON)-> Void, failed: @escaping(_ ErrorMsg:JSON)-> Void) {
        
        debugPrint("url in sendGetRequest call: \(url)")
        
        let headers: Dictionary<String,String> = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        let parsedJson = JSON(response.result.value!)
                        completion(parsedJson)
                    case .failure(let error):
                        do {
                            let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                            guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                                return
                            }
                            let parsedJson = JSON(JSONDictionary)
                            failed(parsedJson)
                        }
                        catch let JSONError as NSError {
                            let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                            let error = ["message":errorMessage]
                            let json = JSON(error)
                            failed(json)
                            debugPrint("*getRequest Faliure*\(url) ** \(json)")
                        }
            }
        }
    }
    
    func handlingFailureCases(_ statusCode: Int) -> String{
        print(statusCode)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "errorWhileSendingRequest"), object: nil)
        var errorMsg: String!
        switch statusCode{
        case 401:
            errorMsg = "Your login session has expired due to multiple logins! Please try logging in again"
        case 402 ... 499:
            errorMsg = "An error Occured"
        case 500 ... 510:
            errorMsg = "The server failed to fulfill an apparently valid request."
        case 900 :
            errorMsg = "An error Occured"
        case -1020 ... -1001:
            errorMsg = "Server couldn't be reached. Please try again later"
        default:
            errorMsg = "Server failed to fulfill request"
        }
        return errorMsg
    }

    func sendGetRequest(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void) {
        
        debugPrint("url in sendGetRequest call: \(url)")
        
        let headers: Dictionary<String,String> = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        
        //print("GET HEADER : \(headers)")
        
        
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers)
            //.validate(contentType: ["application/json"])
            .responseJSON { response in
                
                //print("%%% GET with header \((response.response?.statusCode)!)")
                
                if (response.response?.statusCode == 403) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
                    Utils().delay(1.0, closure: {
                        UIApplication.topViewController()!.view.makeToast(message: "Current Session Expired")
                    })
                } else {
                    switch response.result {
                    case .success:
                        let parsedJson = JSON(response.result.value!)
                        debugPrint("**sendGetRequest success** \(url) ** \(parsedJson)")
                        completion(parsedJson, (response.response?.statusCode)!)
                    case .failure(let error):
                        debugPrint("**sendGetRequest failure** \(url) ** \(response.result.error!._code)")
                        //                    if response.response?.statusCode != nil{
                        //                        failed(errorMsg: self.handlingFailureCases((response.response?.statusCode)!))
                        //                    }
                        do {
                            let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                            guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                                return
                            }
                            let parsedJson = JSON(JSONDictionary)
                            failed(parsedJson)
                        }
                        catch let JSONError as NSError {
                            let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                            let error = ["message":errorMessage]
                            let json = JSON(error)
                            failed(json)
                        }
                        
                    }
                }
        }
    }

    
   


}
