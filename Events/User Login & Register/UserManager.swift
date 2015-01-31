//
//  UserManager.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-27.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation
import UIKit

class UserManager {
    
    class var singleton: UserManager{
        struct Static {
            static var instance: UserManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = UserManager()
        }
        
        return Static.instance!
    }
    
    let ref = Firebase(url: "https://heyz.firebaseio.com")
    
    func loginInBackground(email: String, password: String, onComplete: ((NSError!, FAuthData!) -> Void)!){
        
        ref.authUser(email, password: password, withCompletionBlock: onComplete)
        
    }
    
    func logoutInBackground(){
        
    }
    
    func registerUserInBackground(email: String, password: String, onComplete: ((NSError!) -> Void)!){
        ref.createUser(email, password: password, withCompletionBlock: onComplete)
    }
    
    func changeEmailForUser(oldEmail: String, password: String, newEmail: String){
        
    }
    
    func changePasswordForUser(email: String, oldPassword: String, newPassword: String){
        
    }
    
    func resetPasswordForUser(email: String){
        
    }
    
    func removeUser(email: String, password: String){
        
    }
    
    
}
