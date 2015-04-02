//
//  Message.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc class ConversationManager {
    
    var recentConversations = NSMutableArray()
    
    let SEC_PER_ROUND = 21600
    var requireReload = true
    
    func sendGroupMessage(message: Message, conversation: Conversation) {
        
        let outgoing = PFObject(className: "GroupMessage")
        outgoing["ChatGroup"] = PFObject(withoutDataWithClassName: "ChatGroup", objectId: conversation.from)
        outgoing["FromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser().objectId)
        switch message.type{
        case "photo":
            let data = UIImagePNGRepresentation(message.getContent() as UIImage)
            let file = PFFile(data: data)
            outgoing["MessageType"] = "photo"
            outgoing["Image"] = file
        case "voice":
            let data = message.getContent() as NSData
            let file = PFFile(data: data)
            outgoing["MessageType"] = "voice"
            outgoing["Voice"] = file
            outgoing["VoiceDuration"] = message.voiceDuration!
        default:
            outgoing["MessageType"] = "text"
            outgoing["Text"] = message.getContent() as String
        }
        
        outgoing.saveInBackgroundWithBlock(nil)
    }
    
    func updateGroupConversations(sender: ChatViewController){
        
        for conv in recentConversations {
            
            let originalQuery = PFQuery(className: "ChatGroup")
            originalQuery.includeKey("Event")
            
            originalQuery.getObjectInBackgroundWithId((conv as Conversation).from, block: { (group: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    
                    if (group["Event"] as PFObject)["ChatRound"] as Int > (conv as Conversation).round {
                        self.recentConversations.removeObject(conv)
                        
                        if sender.mDelegate != nil {
                            
                            if (sender.mDelegate! as GroupChatViewController).conversation.from == (conv as Conversation).from {
                                
                                (sender.mDelegate! as GroupChatViewController).performSegueWithIdentifier("unwindFromGroup", sender: sender)
                            }
                        }
                        
                        let predicate = NSPredicate(format: "Event = %@", group["Event"] as PFObject)
                        let query = PFQuery(className: "ChatGroup", predicate: predicate)
                        query.includeKey("Event")
                        
                        query.findObjectsInBackgroundWithBlock({ (groups: [AnyObject]!, error: NSError!) -> Void in
                            if error == nil {
                                for group in groups {
                                    if contains(group["participants"] as [String], PFUser.currentUser().objectId){
                                        
                                        let ev = ((group as PFObject)["Event"] as PFObject)
                                        let round = ev["ChatRound"] as Int
                                        let sec = round * self.SEC_PER_ROUND + Int(ev.createdAt.timeIntervalSinceNow)
                                        
                                        let conversation = Conversation(from: group.objectId, displayName: ((group["Event"] as PFObject)["title"] as String), round: round, secs: sec)
                                        self.recentConversations.insertObject(conversation, atIndex: 0)
                                        
                                        let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: (group as PFObject).objectId))
                                        let messageQuery = PFQuery(className: "GroupMessage", predicate: predicate)
                                        messageQuery.orderByAscending("createdAt")
                                        messageQuery.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                                            if error == nil {
                                                
                                                for msg in messages {
                                                    switch (msg["MessageType"] as String){
                                                    case "photo":
                                                        let userImageFile = msg["Image"] as PFFile
                                                        
                                                        let message = Message(image: UIImage(), from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                                        conversation.add(message, isIncoming: false)
                                                        
                                                        userImageFile.getDataInBackgroundWithBlock {
                                                            (imageData: NSData!, error: NSError!) -> Void in
                                                            if error == nil {
                                                                message.photo = UIImage(data: imageData)
                                                            }
                                                            
                                                            sender.tblForChat.reloadData()
                                                        }
                                                        
                                                    case "voice":
                                                        let message = Message(voiceData: nil, voiceDuration: (msg as PFObject)["VoiceDuration"] as NSTimeInterval, isRead: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                                        conversation.add(message, isIncoming: false)
                                                        
                                                        (msg["Voice"] as PFFile).getDataInBackgroundWithBlock {
                                                            (voiceData: NSData!, error: NSError!) -> Void in
                                                            if error == nil {
                                                                message.voiceData = voiceData
                                                            }
                                                        }

                                                    default:
                                                        let message = Message(text: msg["Text"] as String, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                                        conversation.add(message, isIncoming: false)
                                                        
                                                    }
                                                    
                                                }
                                                
                                                sender.tblForChat.reloadData()
                                            }
                                        })
                                        
                                        break
                                        
                                    }

                                }
                            }
                        })
                        
                    } else {
                        
                        let ev = ((group as PFObject)["Event"] as PFObject)
                        let round = ev["ChatRound"] as Int
                        
                        (conv as Conversation).secs = round * self.SEC_PER_ROUND + Int(ev.createdAt.timeIntervalSinceNow)
                        
                        let predicate = NSPredicate(format: "ChatGroup = %@ && FromUser != %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: group.objectId), PFUser.currentUser())
                        let query = PFQuery(className: "GroupMessage", predicate: predicate)
                        query.whereKey("createdAt", greaterThan: (conv as Conversation).lastRefreshedAt)
                        query.orderByAscending("createdAt")
                        
                        query.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                            if error == nil {
                                
                                if messages.count > 0 {
                                    for msg in messages {
                                        switch (msg["MessageType"] as String){
                                        case "photo":
                                            let userImageFile = msg["Image"] as PFFile
                                            
                                            let message = Message(image: UIImage(), from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                            (conv as Conversation).add(message, isIncoming: false)
                                            
                                            userImageFile.getDataInBackgroundWithBlock {
                                                (imageData: NSData!, error: NSError!) -> Void in
                                                if error == nil {
                                                    message.photo = UIImage(data: imageData)
                                                }
                                                
                                                sender.tblForChat.reloadData()
                                            }
                                        case "voice":
                                            let message = Message(voiceData: nil, voiceDuration: (msg as PFObject)["VoiceDuration"] as NSTimeInterval, isRead: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                            (conv as Conversation).add(message, isIncoming: false)
                                            
                                            (msg["Voice"] as PFFile).getDataInBackgroundWithBlock {
                                                (voiceData: NSData!, error: NSError!) -> Void in
                                                if error == nil {
                                                    message.voiceData = voiceData
                                                }
                                            }
                                        default:
                                            let message = Message(text: msg["Text"] as String, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                            (conv as Conversation).add(message, isIncoming: true)
                                            
                                        }
                                    }
                                    
                                    if sender.mDelegate == nil {
                                        sender.tblForChat.reloadData()
                                    } else {
                                        sender.mDelegate!.onAfterMsgReceived(group.objectId)
                                    }
                                    
                                    
                                }
                                
                            }
                        })
                        
                        (conv as Conversation).lastRefreshedAt = NSDate()
                        
                    }
                    
                    sender.tblForChat.reloadData()
                }
            })
            
        }
        
    }
    
    func loadGroupConversations(sender: ChatViewController) {
        
        if requireReload {
            
            requireReload = false
            
            for conv in recentConversations {
                if !(conv as Conversation).isPrivate {
                    recentConversations.removeObject(conv)
                }
            }
            
            if let user = PFUser.currentUser() {
                
                let events = user["Events"] as [String]
                for ev in events {
                    
                    let predicate = NSPredicate(format: "Event = %@", PFObject(withoutDataWithClassName: "Event", objectId: ev))
                    let query = PFQuery(className: "ChatGroup", predicate: predicate)
                    
                    query.includeKey("Event")
                    
                    query.findObjectsInBackgroundWithBlock({ (groups: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            
                            for group in groups {
                                if contains(group["participants"] as [String], user.objectId){
                                    
                                    let ev = ((group as PFObject)["Event"] as PFObject)
                                    let round = ev["ChatRound"] as Int
                                    let sec = round * self.SEC_PER_ROUND + Int(ev.createdAt.timeIntervalSinceNow)
                                    
                                    let conversation = Conversation(from: group.objectId, displayName: ((group["Event"] as PFObject)["title"] as String), round: round, secs: sec)
                                    self.recentConversations.insertObject(conversation, atIndex: 0)
                                    
                                    let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: (group as PFObject).objectId))
                                    let messageQuery = PFQuery(className: "GroupMessage", predicate: predicate)
                                    messageQuery.orderByAscending("createdAt")
                                    messageQuery.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                                        if error == nil {
                                            for msg in messages {
                                                switch (msg["MessageType"] as String){
                                                case "photo":
                                                    let userImageFile = msg["Image"] as PFFile
                                                    
                                                    let message = Message(image: UIImage(), from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                                    conversation.add(message, isIncoming: false)
                                                    
                                                    userImageFile.getDataInBackgroundWithBlock {
                                                        (imageData: NSData!, error: NSError!) -> Void in
                                                        if error == nil {
                                                            message.photo = UIImage(data: imageData)
                                                        }
                                                        
                                                        sender.tblForChat.reloadData()
                                                    }
                                                case "voice":
                                                    let message = Message(voiceData: nil, voiceDuration: (msg as PFObject)["VoiceDuration"] as NSTimeInterval, isRead: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                                                    conversation.add(message, isIncoming: false)
                                                    
                                                    (msg["Voice"] as PFFile).getDataInBackgroundWithBlock {
                                                        (voiceData: NSData!, error: NSError!) -> Void in
                                                        if error == nil {
                                                            message.voiceData = voiceData
                                                        }
                                                    }
                                                default:
                                                    let message = Message(text: msg["Text"] as String, from: group.objectId, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == user.objectId)
                                                    conversation.add(message, isIncoming: false)
                                                    
                                                }
                                                
                                            }
                                            
                                            sender.tblForChat.reloadData()
                                        }
                                    })
                                    
                                    break
                                    
                                }
                                
                            }
                        }
                        
                        
                    })
                    
                }
            }
        }
        
        
    }
    
//    func addIncoming(message: Message, isPrivate: Bool) {
    
//        if isPrivate {
//            var found = false
//            for i in 0 ..<  recentConversations.count {
//                if let conversation = recentConversations.objectAtIndex(i) as? Conversation{
//                    if conversation.from == message.from {
//                        topConversation(conversation)
//                        conversation.add(message, isIncoming: true)
//                        found = true
//                        break
//                    }
//                }
//            }
//            
//            if !found {
//                let conversation = Conversation(from: message.from)
//                conversation.add(message, isIncoming: true)
//                recentConversations.insertObject(conversation, atIndex: 0)
//            }
//        }
        
//    }
    
    func getConversationAtIndex(index: Int) -> Conversation! {
        return recentConversations.objectAtIndex(index) as Conversation

    }
    
    func topConversation(conversation: Conversation) {
        
        recentConversations.removeObject(conversation)
        recentConversations.insertObject(conversation, atIndex: 0)
    }

    
    class var singleton: ConversationManager{
        
        struct Static {
            static var instance: ConversationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = ConversationManager()
        }
        
        return Static.instance!
    }
}

class Conversation {
    
    var history: NSMutableArray
    var from: String
    var unread: Int
    var isPrivate: Bool
    var round: Int
    var secs: Int
    var displayName: String
    var lastRefreshedAt: NSDate
    
    init(from: String, displayName: String){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
        self.isPrivate = true
        self.round = 0
        self.secs = 0
        self.displayName = displayName
        self.lastRefreshedAt = NSDate()
    }
    
    init(from: String, displayName: String, round: Int, secs: Int){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
        self.isPrivate = false
        self.round = round
        self.secs = secs
        self.displayName = displayName
        self.lastRefreshedAt = NSDate()
    }
    
    func resetUnread() {
        self.unread = 0
    }
    
    func incrementUnread() {
        self.unread++;
    }
    
    func add(message: Message, isIncoming: Bool){
        self.history.addObject(message)
        if isIncoming {
            incrementUnread()
        }
    }

}

class Message {
    
    var text: NSString?
    
    var photo: UIImage?
//    var thumbnailUrl: NSString?
//    var originalUrl: NSString?
    
    var voiceData: NSData?
    var voiceDuration: NSTimeInterval?
    var isRead: Bool?
    
    var from: NSString
    var timestamp: NSString
    var isDelay: Bool
    var isSentByMe: Bool
    var type: String
    
    init(text: NSString, from: NSString, isDelay: Bool, isSentByMe: Bool){
        self.text = text
        self.from = from
        self.isDelay = isDelay
        self.isSentByMe = isSentByMe
        self.type = "text"
        
        if(self.isDelay){
            self.timestamp = "Delayed message"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd '@' h:mm a"
            self.timestamp = dateFormatter.stringFromDate(NSDate())
        }
    }
    
    init(image: UIImage, from: NSString, isDelay: Bool, isSentByMe: Bool){
        self.photo = image
        self.from = from
        self.isDelay = isDelay
        self.isSentByMe = isSentByMe
        self.type = "photo"
        
        if(self.isDelay){
            self.timestamp = "Delayed message"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd '@' h:mm a"
            self.timestamp = dateFormatter.stringFromDate(NSDate())
        }
    }
    
    init(voiceData: NSData?, voiceDuration: NSTimeInterval, isRead: Bool, from: NSString, isDelay: Bool, isSentByMe: Bool) {
        
        self.voiceData = voiceData
        self.voiceDuration = voiceDuration
        self.isRead = isRead
        self.from = from
        self.isDelay = isDelay
        self.isSentByMe = isSentByMe
        self.type = "voice"
        
        if(self.isDelay){
            self.timestamp = "Delayed message"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd '@' h:mm a"
            self.timestamp = dateFormatter.stringFromDate(NSDate())
        }
    }
    
    func getContent() -> AnyObject {
        
        switch (type) {
        case "text":
            return text!
        case "voice":
            return voiceData!
        default:
            return photo!
        }
    }
    
    func getSender() -> String {
        return from
    }
    
    func getTimestamp() -> String {
        return timestamp
    }
}