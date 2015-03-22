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

class ConversationManager {
    
    var recentConversations = NSMutableArray()
    var publicConversations = NSMutableArray()
    var privateConversations = NSMutableArray()
    
    let SEC_PER_ROUND = 600
    
    func sendGroupMessage(message: Message, conversation: Conversation) {
        
        let outgoing = PFObject(className: "GroupMessage")
        outgoing["ChatGroup"] = PFObject(withoutDataWithClassName: "ChatGroup", objectId: conversation.from)
        outgoing["FromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser().objectId)
        switch message.type{
        default:
            outgoing["MessageType"] = "text"
            outgoing["Text"] = message.getContent() as String
        }
        
        outgoing.saveInBackgroundWithBlock(nil)
    }
    
    func updateGroupConversations(sender: ChatViewController){
        
        for conv in publicConversations {
            
            let query = PFQuery(className: "ChatGroup")
            query.includeKey("Event")
            
            query.getObjectInBackgroundWithId((conv as Conversation).from, block: { (group: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    
                    if (group["Event"] as PFObject)["ChatRound"] as Int > (conv as Conversation).round {
                        self.publicConversations.removeObject(conv)
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
                                        
                                        let conversation = Conversation(from: group.objectId, round: round, secs: sec)
                                        self.publicConversations.insertObject(conversation, atIndex: 0)
                                        self.recentConversations.insertObject(conversation, atIndex: 0)
                                        
                                        let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: (group as PFObject).objectId))
                                        let messageQuery = PFQuery(className: "GroupMessage", predicate: predicate)
                                        messageQuery.orderByAscending("createdAt")
                                        messageQuery.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                                            if error == nil {
                                                
                                                for msg in messages {
                                                    switch (msg["MessageType"] as String){
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
                        
                        (conv as Conversation).secs = (conv as Conversation).secs - Int(sender.refreshRate)
                        
                        let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: group.objectId))
                        let query = PFQuery(className: "GroupMessage", predicate: predicate)
                        query.skip = (conv as Conversation).history.count
                        query.orderByAscending("createdBy")
                        
                        query.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                            if error == nil {
                                
                                if messages.count > 0 {
                                    for msg in messages {
                                        switch (msg["MessageType"] as String){
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
                        
                    }
                    
                    sender.tblForChat.reloadData()
                }
            })
            
        }
        
    }
    
    func loadGroupConversations(sender: ChatViewController) {
        
        publicConversations.removeAllObjects()
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
                                
                                let conversation = Conversation(from: group.objectId, round: round, secs: sec)
                                self.publicConversations.insertObject(conversation, atIndex: 0)
                                self.recentConversations.insertObject(conversation, atIndex: 0)
                                
                                let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: (group as PFObject).objectId))
                                let messageQuery = PFQuery(className: "GroupMessage", predicate: predicate)
                                messageQuery.orderByAscending("createdAt")
                                messageQuery.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
                                    if error == nil {
                                        for msg in messages {
                                            switch (msg["MessageType"] as String){
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
    
    func addIncoming(message: Message, isPrivate: Bool) {
        
        if isPrivate {
            var found = false
            for i in 0 ..<  privateConversations.count {
                if let conversation = privateConversations.objectAtIndex(i) as? Conversation{
                    if conversation.from == message.from {
                        topConversation(conversation)
                        conversation.add(message, isIncoming: true)
                        found = true
                        break
                    }
                }
            }
            
            if !found {
                let conversation = Conversation(from: message.from)
                conversation.add(message, isIncoming: true)
                privateConversations.insertObject(conversation, atIndex: 0)
                recentConversations.insertObject(conversation, atIndex: 0)
            }
        }
        
    }
    
    func getConversationAtIndex(index: Int, type: Int) -> Conversation! {
        switch type{
        case 0:
            return recentConversations.objectAtIndex(index) as Conversation
        case 1:
            return publicConversations.objectAtIndex(index) as Conversation
        default:
            return privateConversations.objectAtIndex(index) as Conversation
        }

    }
    
    func topConversation(conversation: Conversation) {
        if conversation.isPrivate {
            privateConversations.removeObject(conversation)
            privateConversations.insertObject(conversation, atIndex: 0)
        } else {
            publicConversations.removeObject(conversation)
            publicConversations.insertObject(conversation, atIndex: 0)
        }
        
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
    
    init(from: String){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
        self.isPrivate = true
        self.round = 0
        self.secs = 0
    }
    
    init(from: String, round: Int, secs: Int){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
        self.isPrivate = false
        self.round = round
        self.secs = secs
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
    
    var voicePath: NSString?
    var voiceDuration: NSString?
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
    
    init(voicePath: NSString, voiceDuration: NSString, isRead: Bool, from: NSString, isDelay: Bool, isSentByMe: Bool) {
        
        self.voicePath = voicePath
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
            return voicePath!
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