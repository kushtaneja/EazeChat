//
//  LoggedinUserProfile.swift
//  Eazespot
//
//  Created by Kush Taneja on 08/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
class LoggedinUserProfile{
//    "id": 93,
//    "first_name": "Kush",
//    "last_name": "Taneja",
//    "username": "kush.taneja@tagbin.in",
//    "email": "kush.taneja@tagbin.in",
//    "last_login": "2016-12-08T13:09:58.614879Z",
//    "is_superuser": false,
//    "is_staff": false,
//    "is_active": true,
//    "date_joined": "2016-12-02T13:47:08.940625Z",
//    "password": "pbkdf2_sha256$24000$mZESORolfmmY$71rdwvY++nuBQlZzhgry3zUdxTR14axZT57dn5390W0="
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var profilePicUrl = ""
    var company = ""
    
    init(userFirstName: String,userLastName: String,userEmail: String,userPicUrl: String,companyName: String)
    {   self.firstName = userFirstName
        self.lastName = userLastName
        self.email = userEmail
        self.profilePicUrl = userPicUrl
        self.company = companyName
    }
    init(){
    
    
    
    }
    
    








}
