//
//  UserManager.swift
//  Heyz
//
//  Created by Jay Yu on 2015-03-09.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation

@objc class UserManager {
    
    var requests: [PFObject]?
    
    func acceptFriendRequest(fromUser: String, sender: FriendsTableViewController){
        
        if requests != nil {
            for req in requests! {
                
                if req["fromUser"] as NSString == fromUser {
                    
                    req["status"] = "accepted"
                    req.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            
                            if let user = PFUser.currentUser() {
                                println(user.objectId)
                                println(fromUser)
                                let predicate = NSPredicate(format: "user = %@", user.objectId)
                                let query = PFQuery(className: "FriendRelation", predicate: predicate)
                                
                                query.findObjectsInBackgroundWithBlock({( objects: [AnyObject]!, error: NSError!) -> Void in
                                    if error == nil {
                                        if let obj = objects.first as? PFObject {
                                            println(obj)
                                            let relations = obj["relations"] as NSMutableArray
                                            relations.addObject(fromUser)
                                            obj.saveInBackgroundWithBlock(nil)
                                            
                                        }
                                    }
                                })
                                
                                let predicate2 = NSPredicate(format: "user = %@", fromUser)
                                let query2 = PFQuery(className: "FriendRelation", predicate: predicate2)
                                
                                query2.findObjectsInBackgroundWithBlock({( objects: [AnyObject]!, error: NSError!) -> Void in
                                    if error == nil {
                                        if let obj = objects.first as? PFObject {
                                            println(obj)
                                            let relations = obj["relations"] as NSMutableArray
                                            relations.addObject(user.objectId)
                                            obj.saveInBackgroundWithBlock(nil)
                                            
                                        }
                                    }
                                })
                            }
                            self.showSimpleAlert("Request Accepted", message: "You have accepted the friend request.", sender: sender)
                            
                            sender.onAfterRequestAction(fromUser, accepted: true)
                        } else {
                            self.showSimpleAlert("Failed to accept request.", message: "Error: \(error.localizedDescription)", sender: sender)
                        }
                    })
                    
                    break
                }

            }
        }

    }
    
    func denyFriendRequest(fromUser: String, sender: FriendsTableViewController){
        
        if requests != nil {
            for req in requests! {
                
                if req["fromUser"] as NSString == fromUser {
                    
                    req["status"] = "denied"
                    req.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            self.showSimpleAlert("Request Denied", message: "You have denied the friend request.", sender: sender)
                            
                            sender.onAfterRequestAction(fromUser, accepted: false)
                        } else {
                            self.showSimpleAlert("Failed to deny request.", message: "Error: \(error.localizedDescription)", sender: sender)
                        }
                    })
                    
                    break
                }
            }
        }
        
    }
    
    func updatePendingRequests(sender: FriendsTableViewController) {
        let predicate = NSPredicate(format: "toUser = %@ AND status = %@", PFUser.currentUser().objectId, "pending")
        var query = PFQuery(className: "FriendRequest", predicate: predicate)
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                
                self.requests = (objects as [PFObject])
                
                sender.requests.removeAll(keepCapacity: false)
                for obj in objects {
                    sender.requests.append(obj["fromUser"] as String)
                }
                sender.friendsTableView.reloadData()
            }
            
        })
        
    }
    
    func updateFriends(sender: FriendsTableViewController){
        
        if let user = PFUser.currentUser() {
            
            let predicate = NSPredicate(format: "user = %@", user.objectId)
            let query = PFQuery(className: "FriendRelation", predicate: predicate)
            
            query.findObjectsInBackgroundWithBlock({( objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    if let obj = objects.first as? PFObject {
                        sender.friends = obj["relations"] as [String]
                        sender.friendsTableView.reloadData()
                    }
                }
            })
        }

    }
    
    func sendFriendRequest(email: String, sender: UIViewController) {
        
        if let user = PFUser.currentUser() {
            
            let predicate = NSPredicate(format: "email = %@", email)
            var query = PFQuery(className: "_User", predicate: predicate)
            
            query.findObjectsInBackgroundWithBlock({( objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    
                    if let toUser = objects.first as? PFUser {
                        
                        let fromUser = user.username
                        
                        var request = PFObject(className: "FriendRequest")
                        request["fromUser"] = user.objectId
                        request["toUser"] = toUser.objectId
                        request["status"] = "pending"
                        
                        request.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                            if succeeded {
                                self.showSimpleAlert("Request Sent", message: "Your request has been sent.", sender: sender)
                            } else {
                                self.showSimpleAlert("Failed to send request.", message: "Error: \(error.localizedDescription)", sender: sender)
                            }
                        })
                        
                    }
                }
            })
            
        }
    }
    
    func showSimpleAlert(title: String, message: String, sender: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        sender.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func resetPassword(email: String, sender: UIViewController){
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (succeeded: Bool, error: NSError!) -> Void in
        
            if error == nil {
                self.showSimpleAlert("Password Reset", message: "Follow the instruction in email to reset password.", sender: sender)
            } else {
                self.showSimpleAlert("Reset failed", message: "Error: \(error.localizedDescription)", sender: sender)
                
            }
        })
    }
    
    func loginViaTwitter(sender: UIViewController){
        
        PFTwitterUtils.logInWithBlock({
            (user: PFUser!, error: NSError!) -> Void in
            if let user = user {
                
                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                
                if user.isNew {
                    println("User signed up and logged in through Twitter!")
                    
//                    delegate.isRegistering = true
//                    delegate.isFromFacebook = true
                    
                    NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: appDefaultIdKey)
                    NSUserDefaults.standardUserDefaults().setObject(user.password, forKey: appDefaultPwdKey)
                    
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                    
//                    delegate.connect()
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    println("User logged in through Twitter!")
                    
                    NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: appDefaultIdKey)
                    NSUserDefaults.standardUserDefaults().setObject(user.password, forKey: appDefaultPwdKey)
                    
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                    
//                    delegate.connect()
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                println("Uh oh. The user cancelled the Twitter login.")
            }
        })
    }
    
    func loginViaFacebook(sender: UIViewController){
        
        PFFacebookUtils.logInWithPermissions([], {
            (user: PFUser!, error: NSError!) -> Void in
            if let user = user {
                
                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
                
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                    
//                    delegate.isRegistering = true
//                    delegate.isFromFacebook = true
                    
                    NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: appDefaultIdKey)
                    NSUserDefaults.standardUserDefaults().setObject(user.password, forKey: appDefaultPwdKey)
                    
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
                    
//                    delegate.connect()
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    println("User logged in through Facebook!")
                    
                    NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: appDefaultIdKey)
                    NSUserDefaults.standardUserDefaults().setObject(user.password, forKey: appDefaultPwdKey)
                    
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                    NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                    
//                    delegate.connect()
                    
                    sender.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        })
    }
    
    func login(sender: UIViewController) {
        
        let username = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultIdKey)
        let password = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultPwdKey)
        
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser!, error: NSError!) -> Void in
            if error != nil {
                
                self.showSimpleAlert("Log in failed", message: "Error: \(error.localizedDescription)", sender: sender)
                
            } else {
                
//                NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                
//                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
//                delegate.connect()
                
                sender.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
    }
    
    func loginInBackground(sender: UIViewController){
        
        if(PFUser.currentUser() == nil){
            let username = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultIdKey)
            let password = NSUserDefaults.standardUserDefaults().stringForKey(appDefaultPwdKey)
            
            println(username)
            
            if (username == nil || password == nil){
                let storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as SigninViewController
                sender.presentViewController(vc, animated: true, completion: nil)
            } else {
                
                PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser!, error: NSError!) -> Void in
                    if error != nil {
                        
                        let storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
                        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as SigninViewController
                        sender.presentViewController(vc, animated: true, completion: nil)
                        
                    }
//                    else {
//                        
//                        NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                        NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
//                        delegate.connect()
//                    }
                })
            }
        }
//        else if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate{
//
//            delegate.connect()
//        }
        
        
    }
    
    func logoutInBackground(){
        
        PFUser.logOut()
    }
    
    func signupInBackground(name: String, password: String, email: String, sender: UIViewController) {
        
        let user = PFUser()
        user.username = name
        user.password = password
        user.email = email
        
        user.signUpInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                
                let friendsList = PFObject(className: "FriendRelation")
                friendsList["user"] = user.objectId
                friendsList["relations"] = [String]()
                
                friendsList.saveInBackgroundWithBlock(nil)
                
//                let delegate = UIApplication.sharedApplication().delegate as AppDelegate
//                delegate.isRegistering = true
//                
//                NSUserDefaults.standardUserDefaults().setObject(user.objectId + xmppDomain, forKey: xmppDefaultIdKey)
//                NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: xmppDefaultPwdKey)
//                
//                delegate.connect()
                
                sender.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                
                self.showSimpleAlert("Registration failed", message: "Error: \(error.localizedDescription)", sender: sender)
                
            }
        })
    }
    
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