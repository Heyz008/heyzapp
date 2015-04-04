//
//  CYUser.swift
//  Heyz
//
//  Created by Zhichao Yang on 2015-03-21.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

var connected: Bool{
    let reachabilty : Reachability = Reachability.reachabilityForInternetConnection()
    let networkStatus : NetworkStatus = reachabilty.currentReachabilityStatus()
    if networkStatus == uint(0){
        println("network issue. offline mode")
    }
    return networkStatus != uint(0)
}

//This is a utility using fo userprofile manager.
class CYUser {
    //Properties
    var user: PFUser
    //init

    init(fromPFUser user: PFUser){
        self.user = user
    }
    
    //Methods
    
    func getStringForKey(key: String) -> String{
        if let result = self.user.objectForKey(key) as? String{
            return result
        }else{
            NSException(name: "Error Value", reason: "The object for this key is not a string", userInfo: nil)
            return ""
        }
    }
    func getImgForKeyInBackground(key: String = USER_PROFILE_PHOTO, online: Bool = connected, onFinish: (img: UIImage) -> Void, onError: errorBlock = emptyErrorBlock, progressCheck: PFProgressBlock = { (progress: Int32) -> Void in
        return
        }){
        var image = UIImage()
        var imgFile = user.objectForKey(key) as PFFile?
            if imgFile == nil{
                onError(errorMsg: "no profile photo")
            }
        imgFile?.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
            if error != nil{
                onError(errorMsg: error.description)
                //println(error.description)
                return
            }
            if let img = UIImage(data: data){
                onFinish(img: img)
            }
            }, progressBlock: progressCheck)
    }
    
    private func singleSideRelationRequest(user1: PFUser, user2: PFUser) -> PFQuery{
        var query = PFQuery(className: TABLE_FRIEND)
        query.whereKey( FROM_USER, equalTo: user1.objectId)
        query.whereKey( TO_USER, equalTo: user2.objectId)
        return query
    }
    
    private func generateBlankResultBlock(onFinish: () -> Void, onError: errorBlock) -> PFArrayResultBlock{
        let block = { (finish: [AnyObject]!, error: NSError!) -> Void in
            if error != nil{
                onError(errorMsg: error.description)
            }else{
                onFinish()
            }
        }
        return block
    }
    
    func isCurrentUser() -> Bool{
        if let currentuserobjid = PFUser.currentUser().objectId{
            return user.objectId as String == currentuserobjid
        }else{
            return false
        }

    }
}
var currentUser : CYUserSelf?
var userInfoCache = NSCache()
class CYUserSelf : CYUser{
    private var userCahce = userInfoCache
    class func currentCYUser() -> CYUserSelf {
        if currentUser == nil && PFUser.currentUser() == nil{
//            NSException(name: "No user availavle", reason: "no user signed in", userInfo: nil)
//            let newuser1 = PFUser()
//            newuser1.username = "testuser1"
//            newuser1.password = "testpassword1"
//            newuser1.signUp()
//            PFUser.logInWithUsername("testuser1", password: "testpassword1")
//            PFUser.logOut()
//            let newuser2 = PFUser()
//            newuser2.username = "testuser2"
//            newuser2.password = "testpassword2"
//            newuser2.signUp()
            PFUser.logInWithUsername("testuser2", password: "testpassword2")
            return CYUserSelf(fromPFUser: PFUser.currentUser())
        }else if currentUser == nil{
            currentUser = CYUserSelf(fromPFUser: PFUser.currentUser()!)
            return currentUser!
        }else {
            return currentUser!
        }
    }
    
    func uploadPictureForKey(key: String = USER_PROFILE_PHOTO, online: Bool = connected, onFinish : () -> Void, onError: errorBlock = emptyErrorBlock, picture: UIImage){
        let imageData = UIImagePNGRepresentation(picture)
        let imageFile = PFFile(name: key, data:imageData)
        self.user[key] = imageFile
        self.user.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            if success{
                onFinish()
            }else{
                onError(errorMsg: error.description)
            }
        }
    }
    
    func setStringForKey(key: String, content: String){
        self.user[key] = content
        self.user.saveEventually { (success, error) -> Void in
            return
        }
    }
    //handle friends
    
    func getFriendListInBackground(onFinish: ([String]) -> Void = { (str: [String]) -> Void in
        return}, onError: errorBlock = emptyErrorBlock){
        var predicate = NSPredicate(format: "(\(FROM_USER) == %@) OR (\(TO_USER) == %@)",  self.user.objectId,  self.user.objectId)
        var query = PFQuery(className: TABLE_FRIEND, predicate: predicate)
        query.whereKey(CONFIRMED, equalTo: friendRequestStatus.accepted.rawValue)
        query.findObjectsInBackgroundWithBlock { (result : [AnyObject]!, error: NSError!) -> Void in
            if error != nil{
                onError(errorMsg: error.description)
            }else{
                var friendList = NSMutableSet()
                for relation in result{
                    let fromUser = relation.objectForKey(FROM_USER) as String
                    if fromUser != self.user.objectId{
                        friendList.addObject(fromUser)
                    }else{
                        let toUser = relation.objectForKey(TO_USER) as String
                        friendList.addObject(toUser)
                    }
                }
                self.userCahce.setObject(friendList, forKey: "friendSet")
                onFinish(friendList.allObjects as [String])
            }
        }
    }
    func checkFriendInventationSent(toUser: PFUser, onFinish: (isSent: Bool) -> Void, onError: errorBlock = emptyErrorBlock){
        checkBoolForKey(INVITED, fromUser : self.user, toUser: toUser, equalTo: true, onFinish: onFinish, onError: onError)
    }
    
    func checkBoolForKey(key: String, fromUser: PFUser = PFUser.currentUser(), toUser: PFUser, equalTo: AnyObject, onFinish: (result: Bool) -> Void, onError: errorBlock){
        var query = singleSideRelationRequest(fromUser, user2: toUser)
        query.whereKey(key, equalTo: equalTo)
        query.findObjectsInBackgroundWithBlock { (result : [AnyObject]!, error : NSError!) -> Void in
            if error != nil{
                onError(errorMsg: error.description)
            }else if result.count == 0{
                self.userCahce.setObject(false, forKey: "\(key)\(toUser.objectId)")
                onFinish(result: false)
            }else{
                self.userCahce.setObject(true, forKey: "\(key)\(toUser.objectId)")
                onFinish(result: true)
            }
        }
    }
    
    func setStateForKey( key: String, state: AnyObject, user1: PFUser, user2 : PFUser, onFinish: () -> Void, onError: errorBlock){
        let request = singleSideRelationRequest(user1, user2: user2)
        request.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil{
                onError(errorMsg: error.description)
            }else{
                if results.count == 0 {
                    var NewRelation = PFObject(className: TABLE_FRIEND)
                    NewRelation.setObject(user1, forKey: FROM_USER)
                    NewRelation.setObject(user2.objectId, forKey: TO_USER)
                    NewRelation.setObject(state, forKey: key)
                    var acl = PFACL()
                    acl.setPublicReadAccess(false)
                    acl.setPublicWriteAccess(false)
                    acl.setReadAccess(true, forUser: user1)
                    acl.setReadAccess(true, forUser: user2)
                    NewRelation.ACL = acl
                    NewRelation.saveInBackgroundWithBlock({ (finish, error) -> Void in
                        if error != nil{
                            onError(errorMsg: error.description)
                        }else{
                            if user1 == PFUser.currentUser(){
                                self.userCahce.setObject(state, forKey: "\(key)\(user2.objectId)")
                            }
                            onFinish()
                        }
                    })
                }else{
                    var relation = results.first as PFObject
                    relation.setObject(state, forKey: key)
                    relation.saveInBackgroundWithBlock({ (finish, error) -> Void in
                        if error != nil{
                            onError(errorMsg: error.description)
                        }else{
                            if user1 == PFUser.currentUser(){
                                self.userCahce.setObject(state, forKey: "\(key)\(user2.objectId)")
                            }
                            onFinish()
                        }
                    })
                }
            }
        }
    }
    
    func sendFriendInventation(toUser: PFUser,add: Bool = true, onFinish: () -> Void = {}, onError: errorBlock = emptyErrorBlock){
        setStateForKey(CONFIRMED, state: friendRequestStatus.invited.rawValue, user1: self.user, user2: toUser, onFinish: onFinish, onError: onError)
    }
    
    func acceptFriendInventation(toUser: PFUser,add: Bool = true, onFinish: () -> Void = {}, onError: errorBlock = emptyErrorBlock){
        setStateForKey(CONFIRMED, state: friendRequestStatus.accepted.rawValue, user1: toUser, user2: self.user, onFinish: onFinish, onError: onError)
        self.userCahce.removeObjectForKey("friendSet")
    }
    
    
    func rejectFriendInventation(toUser: PFUser,add: Bool = true, onFinish: () -> Void = {}, onError: errorBlock = emptyErrorBlock){
        setStateForKey(CONFIRMED, state: friendRequestStatus.rejected.rawValue, user1: toUser, user2: self.user, onFinish: onFinish, onError: onError)
        self.userCahce.removeObjectForKey("friendSet")
    }
    
    func blockUser(toUser: PFUser, block: Bool, onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        setStateForKey(BLOCK, state: block, user1: self.user, user2: toUser, onFinish: onFinish, onError: onError)
    }
    
    func favorateUser(toUser: PFUser, favorate: Bool, onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        setStateForKey(FAVORATE, state: favorate, user1: self.user, user2: toUser, onFinish: onFinish, onError: onError)
    }
}

class CYUserOther: CYUser {
    func getIsFavorate(result: (Bool) -> Void){
        currentUser?.checkBoolForKey(FAVORATE, toUser: self.user, equalTo: true, onFinish: result, onError: emptyErrorBlock)
    }
    
    func setFavorate(favorate: Bool, onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        currentUser?.favorateUser(self.user, favorate: favorate, onFinish: onFinish, onError: onError)
    }
    func getIsBlocked(result: (Bool) -> Void){
        currentUser?.checkBoolForKey(FAVORATE, toUser: self.user, equalTo: true, onFinish: result, onError: emptyErrorBlock)
    }
    func setBlock(toUser: PFUser, block: Bool, onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        currentUser?.blockUser(self.user, block: block, onFinish: onFinish, onError: onError)
    }
    func sendFriendRequest(onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        currentUser?.sendFriendInventation(self.user, add: true, onFinish: onFinish, onError: onError)
    }
    func cancelFriendRequest(onFinish: ()-> Void = {}, onError: errorBlock = emptyErrorBlock){
        currentUser?.sendFriendInventation(self.user, add: false, onFinish: onFinish, onError: onError)
    }
    func getIsFriend(result: (Bool) -> Void){
        currentUser?.getFriendListInBackground( { (list) -> Void in
            result(contains(list, self.user.objectId))
        }, onError: emptyErrorBlock)
    }
    
    func getIsInviting(result: (Bool) -> Void){
        currentUser?.checkBoolForKey(CONFIRMED,  toUser: self.user, equalTo: friendRequestStatus.invited.rawValue, onFinish: result, onError: emptyErrorBlock)
    }
    
    func getIsInvited(result: (Bool) -> Void){
        currentUser?.checkBoolForKey(CONFIRMED,  fromUser: self.user, toUser: PFUser.currentUser(), equalTo: friendRequestStatus.invited.rawValue, onFinish: result, onError: emptyErrorBlock)
    }
}

typealias errorBlock = (errorMsg: String) -> Void
let emptyErrorBlock = {(errorMsg: String) -> Void in
    println(errorMsg)
    return
}
enum friendRequestStatus : Int{
    case null = 1
    case invited
    case accepted
    case rejected
}

let USER_PROFILE_PHOTO = "profilePhoto"
let TABLE_FRIEND = "friendConnecton"
let FROM_USER = "fromUser"
let TO_USER = "toUser"
let INVITED = "invited"
let CONFIRMED = "confirmed"
let BLOCK = "block"
let FAVORATE = "favorate"