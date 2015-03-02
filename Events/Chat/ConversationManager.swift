//
//  Message.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation
import CoreData
//import UIKit

class ConversationManager {
    
    var recentConversations = NSMutableArray()
    var publicConversations = NSMutableArray()
    var privateConversations = NSMutableArray()
    
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
                let conversation = Conversation(from: message.from, isPrivate: true)
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
    
    init(from: String, isPrivate: Bool){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
        self.isPrivate = isPrivate
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