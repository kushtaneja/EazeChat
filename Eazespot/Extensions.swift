//
//  Extensions.swift
//  Eazespot
//
//  Created by Kush Taneja on 02/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    class func eazeSpotMainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    
    class func teamSelectionScreen() -> UINavigationController {
        return (eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "TeamSelectionNavigationController") as? UINavigationController)!
    }
    
    class func ProfDisplayNavigationScreen() -> UINavigationController {
        return (eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "ProfDisplayNavigationController") as? UINavigationController)!
    }
    
    class func ChatFriendListPageMenuNavigationScreen() -> UINavigationController {
        return (eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "ChatFriendListPageMenuNavigationController") as? UINavigationController)!
    }
    class func ChatRoomNavigationScreen() -> UINavigationController {
        return (eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "ChatRoomNavigationController") as? UINavigationController)!
    }
    
    class func NewChatNavigationScreen() -> UINavigationController {
        return (eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "NewChatNavigationViewController") as? UINavigationController)!
    }


}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            
            return self[(startIndex..<endIndex)]
        }
    }
    
    func fromBase64() -> String {
        let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
