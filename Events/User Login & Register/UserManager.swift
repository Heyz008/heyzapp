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
    
//    let appDefaultIdKey = "HEYZAPP.defaultID"
//    let appDefaultPwdKey = "HEYZAPP.defaultPassword"
//    var currentUser: PFUser?
//    
//    func isLoggedIn() -> Bool {
//        return currentUser != nil
//    }
//    
//    func getUserDetails(forKey: String) -> String? {
//        
//        if currentUser != nil {
//            switch (forKey) {
//            case "username":
//                return currentUser!.username
//            default:
//                return nil
//            }
//        }
//        
//        return nil
//    }
//    
//    func getContactsForUser(listener: ([String] -> ())) {
//        
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
//            
//            let predicate = NSPredicate(format: "username != '\(self.currentUser!.username)'")
//            let query = PFQuery(className: "_User", predicate: predicate)
//            let objects = query.findObjects()
//            
//            var results = [String]()
//            for object in objects {
//                results.append(object.username)
//            }
//            
//            dispatch_async(dispatch_get_main_queue()){
//                listener(results)
//            }
//        }
//        
//    }
//    
//    func loginInBackground(onSuccess: () -> (), onError: (NSError!) -> ()){
//        
//        let email = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultIdKey)
//        let password = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultPwdKey)
//        
//        PFUser.logInWithUsernameInBackground(email, password: password, block: { (user: PFUser!, error: NSError!) -> Void in
//            
//            if error == nil {
//                self.currentUser = user
//                onSuccess()
//            } else {
//                onError(error)
//            }
//        })
//        
//    }
//    
//    func logoutInBackground(){
//        
//        PFUser.logOut()
//        
//        currentUser = nil
//
//    }
//    
//    func registerUserInBackground(email: String, password: String, onSuccess: () -> (), onError: (NSError!) -> ()){
//   
//        var user = PFUser()
//        user.username = email
//        user.password = password
//        user.email = email
//        
//        user.signUpInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
//            
//            if error == nil {
//                onSuccess()
//            } else {
//                onError(error)
//            }
//        })
//
//        
//    }
//    
//    func changeEmailForUser(oldEmail: String, password: String, newEmail: String){
//        
//    }
//    
//    func changePasswordForUser(email: String, oldPassword: String, newPassword: String){
//        
//    }
//    
//    func resetPasswordForUser(email: String){
//        
//    }
//    
//    func removeUser(email: String, password: String){
//        
//    }
    
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
    
    
}
