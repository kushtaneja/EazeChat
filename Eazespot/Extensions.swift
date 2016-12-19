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
    
    class func loginScreen() -> UIViewController {
        return eazeSpotMainStoryboard().instantiateViewController(withIdentifier: "LoginViewController")
    }
    
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
extension Date {
    
    
    init?(jsonDate: String) {
        let scanner = Scanner(string: jsonDate)
        
        
        // Read milliseconds part:
        var milliseconds : Int64 = 0
        guard scanner.scanInt64(&milliseconds) else { return nil }
        // Milliseconds to seconds:
        var timeStamp = TimeInterval(milliseconds)/1000.0
        
        // Read optional timezone part:
        var timeZoneOffset : Int = 0
        if scanner.scanInt(&timeZoneOffset) {
            let hours = timeZoneOffset / 100
            let minutes = timeZoneOffset % 100
            // Adjust timestamp according to timezone:
            timeStamp += TimeInterval(3600 * hours + 60 * minutes)
        }
        
        
        // Success! Create NSDate and return.
        self.init(timeIntervalSince1970: timeStamp)
    }

    
    
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            
            formatter.calendar = Calendar(identifier: .iso8601)
           formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "local")
        //   formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            return formatter
        }()
    }
    var iso8601: String {
        
        return Formatter.iso8601.string(from: self)
    }
    
    struct Formatters {
        
        static let custom: DateFormatter = {
            let formatter = DateFormatter()
            return formatter
        }()
        static let date:DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        static let time:DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
        static let weekday: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "cccc"
            return formatter
        }()
        static let month: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL"
            return formatter
        }()
    }
    var date: String {
        return Formatters.date.string(from: self)
    }
    var time: String {
        return Formatters.time.string(from: self)
    }
    var weekdayName: String {
        return Formatters.weekday.string(from: self)
    }
    var monthName: String {
        return Formatters.month.string(from: self)
    }
    func formatted(with dateFormat: String) -> String {
        Formatters.custom.dateFormat = dateFormat
        return Formatters.custom.string(from: self)
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
    var dateFromISO8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
    
    
    func toDateFormatted(with dateFormat:String)-> Date? {
        Date.Formatters.custom.dateFormat = dateFormat
        return Date.Formatters.custom.date(from: self)
    }
}
