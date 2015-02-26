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
                        privateConversations.removeObject(conversation)
                        privateConversations.insertObject(conversation, atIndex: 0)
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
    
    init(from: String){
        self.history = NSMutableArray()
        self.from = from
        self.unread = 0
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
    
    var body: String
    var from: String
    var isDelay: Bool
    var isSentByMe: Bool = false
    var timestamp: String
    
    init(body: String, from: String, isDelay: Bool, isSentByMe: Bool){
        self.body = body
        self.from = from
        self.isDelay = isDelay
        self.isSentByMe = isSentByMe
        
        if(self.isDelay){
            self.timestamp = "Delayed message"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd '@' h:mm a"
            self.timestamp = dateFormatter.stringFromDate(NSDate())
        }
    }
    
    func getBody() -> String {
        return body
    }
    
    func getSender() -> String {
        return from
    }
    
    func getTimestamp() -> String {
        return timestamp
    }
}