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
    
    func countUnread() -> Int{
        
        var count = 0
        for conv in recentConversations {
            let conversation = conv as Conversation
            if conversation.from != "Fake" {
                count = count + conversation.unread
            }
        }
        
        return count
    }
    
    func sendGroupMessage(message: Message, conversation: Conversation) {
        
        let outgoing = PFObject(className: "GroupMessage")
        outgoing["ChatGroup"] = PFObject(withoutDataWithClassName: "ChatGroup", objectId: conversation.from)
        outgoing["FromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser().objectId)
        switch message.type {
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
        
        outgoing.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
            if succeeded {
                let query = PFQuery(className: "ChatGroup")
                query.getObjectInBackgroundWithId(conversation.from, block: { (group: PFObject!, error: NSError!) -> Void in
                    
                    if error == nil {
                        let participants = group["participants"] as [String]
                        var pArray = [PFUser]()
                        for p in participants {
                            if p != PFUser.currentUser().objectId {
                                pArray.append(PFUser(withoutDataWithObjectId: p))
                            }
                        }
                        
                        let pushQuery = PFInstallation.query()
                        pushQuery.whereKey("User", containedIn: pArray)
                        
                        let push = PFPush()
                        push.setQuery(pushQuery)
                        switch message.type {
                        case "photo":
                            push.setData([
                                "alert" : ("\(conversation.displayName)发来一张图片"),
                                "badge" : "Increment"
                                ])
                        case "voice":
                            push.setData([
                                "alert" : ("\(conversation.displayName)发来一段语音"),
                                "badge" : "Increment"
                                ])
                        default:
                            push.setData([
                                "alert" : ("\(conversation.displayName): \(message.getContent() as String)"),
                                "badge" : "Increment"
                                ])
                        }
                        push.sendPushInBackgroundWithBlock(nil)
                        
                    }
                })
            }
        })
    }
    
    func updateGroupConversations(onBeforeGroupCreated: (String) -> (), onAfterGroupCreated: () -> (), onAfterMsgFetched: (String) -> ()){
        
        for conv in recentConversations {
            if (conv as Conversation).from == "Fake" {
                continue
            }
            
            let originalQuery = PFQuery(className: "ChatGroup")
            originalQuery.includeKey("Event")
            
            originalQuery.getObjectInBackgroundWithId((conv as Conversation).from, block: { (group: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    
                    if (group["Event"] as PFObject)["ChatRound"] as Int > (conv as Conversation).round {
                        
                        self.recentConversations.removeObject(conv)
                        
                        onBeforeGroupCreated((conv as Conversation).from)
                        
                        self.loadConversationWithID((group["Event"] as PFObject).objectId, onAfterConvLoaded: onAfterGroupCreated)
                    } else {
                        
                        let ev = ((group as PFObject)["Event"] as PFObject)
                        let round = ev["ChatRound"] as Int
                        
                        (conv as Conversation).secs = round * self.SEC_PER_ROUND + Int(ev.createdAt.timeIntervalSinceNow)
                        
                        let predicate = NSPredicate(format: "ChatGroup = %@ && FromUser != %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: group.objectId), PFUser.currentUser())
                        let query = PFQuery(className: "GroupMessage", predicate: predicate)
                        query.whereKey("createdAt", greaterThan: (conv as Conversation).lastRefreshedAt)
                        query.orderByAscending("createdAt")
                        self._fetchMessageWithQuery(query, conversation: (conv as Conversation), incoming: true, onAfterFetched: {
                            onAfterMsgFetched((conv as Conversation).from)
                        })
                        
                        (conv as Conversation).lastRefreshedAt = NSDate()
                        
                    }

                }
            })
            
        }
        
    }
    
    func _fetchMessageWithQuery(query: PFQuery, conversation: Conversation, incoming: Bool, onAfterFetched: () -> ()){
        
        query.findObjectsInBackgroundWithBlock({ (messages: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                if messages.count > 0 {
                    for msg in messages {
                        switch (msg["MessageType"] as String){
                        case "photo":
                            let userImageFile = msg["Image"] as PFFile
                            
                            let message = Message(image: UIImage(), from: conversation.from, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                            conversation.add(message, isIncoming: incoming)
                            
                            userImageFile.getDataInBackgroundWithBlock {
                                (imageData: NSData!, error: NSError!) -> Void in
                                if error == nil {
                                    message.photo = UIImage(data: imageData)
                                    onAfterFetched()
                                }
                            }
                        case "voice":
                            let message = Message(voiceData: nil, voiceDuration: (msg as PFObject)["VoiceDuration"] as NSTimeInterval, isRead: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId, from: conversation.from, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                            conversation.add(message, isIncoming: incoming)
                            
                            (msg["Voice"] as PFFile).getDataInBackgroundWithBlock {
                                (voiceData: NSData!, error: NSError!) -> Void in
                                if error == nil {
                                    message.voiceData = voiceData
                                }
                            }
                        default:
                            let message = Message(text: msg["Text"] as String, from: conversation.from, isDelay: false, isSentByMe: (msg as PFObject)["FromUser"].objectId == PFUser.currentUser().objectId)
                            conversation.add(message, isIncoming: incoming)
                            
                        }
                        
                    }
                    self.topConversation(conversation)
                    onAfterFetched()
                }
                
            }
        })
    }
    
    func loadConversationWithID(id: String, onAfterConvLoaded: () -> ()){
        
        
        let user = PFUser.currentUser().objectId
        
        let predicate = NSPredicate(format: "Event = %@", PFObject(withoutDataWithClassName: "Event", objectId: id))
        let query = PFQuery(className: "ChatGroup", predicate: predicate)
        
        query.includeKey("Event")
        
        query.findObjectsInBackgroundWithBlock({ (groups: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                for group in groups {
                    if contains(group["participants"] as [String], user){
                        
                        let ev = ((group as PFObject)["Event"] as PFObject)
                        let round = ev["ChatRound"] as Int
                        let sec = round * self.SEC_PER_ROUND + Int(ev.createdAt.timeIntervalSinceNow)
                        
                        let conversation = Conversation(from: group.objectId, displayName: ((group["Event"] as PFObject)["title"] as String), round: round, secs: sec)
                        self.recentConversations.insertObject(conversation, atIndex: 0)
                        
                        let predicate = NSPredicate(format: "ChatGroup = %@", PFObject(withoutDataWithClassName: "ChatGroup", objectId: (group as PFObject).objectId))
                        let messageQuery = PFQuery(className: "GroupMessage", predicate: predicate)
                        messageQuery.orderByAscending("createdAt")
                        self._fetchMessageWithQuery(messageQuery, conversation: conversation, incoming: false, onAfterFetched: onAfterConvLoaded)
                        
                        break
                        
                    }
                    
                }
            }
            
        })
    }
    
    func loadAllGroupConversations(onAfterConvLoaded: () -> ()) {
        
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
                    
                    loadConversationWithID(ev, onAfterConvLoaded: {
                        
                        if self.recentConversations.count == 3 {
                            self.addFakeData()
                        }
                        onAfterConvLoaded()
                        println(self.recentConversations.count)
                        
                    })
                    
                }
            }
            
        }
        
        
    }
    
    func addFakeData() {
        
        let conv1 = Conversation(from: "Fake", displayName: "Momo Guan")
        let m1 = Message(text: "好的，明天见", from: "Momo Guan", isDelay: false, isSentByMe: false)
        conv1.add(m1, isIncoming: true)
        
        recentConversations.insertObject(conv1, atIndex: 0)
        
        let conv2 = Conversation(from: "Fake", displayName: "Daniel Dai")
        let m2 = Message(text: "sounds good!", from: "Daniel Dai", isDelay: false, isSentByMe: false)
        conv2.add(m2, isIncoming: false)
        
        recentConversations.addObject(conv2)
        
        
    }
    
    
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