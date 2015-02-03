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

@objc(Message)
class Message: NSManagedObject{
    @NSManaged var text: String!
    @NSManaged var sender: String!
    @NSManaged var receiver: String!
    @NSManaged var date: String!
    var imageURL: String?
    
//    convenience init(text: String?, sender: String?){
//        self.init(text: text, sender: sender)
//    }
//    
//    init(text: String?, sender: String?, receiver: String?, date: String?, imageURL: String?){
//        
//        self.text = text!
//        self.sender = sender!
//        self.receiver = receiver!
//        
//        if let dateString = date{
//            self.date = dateString
//        } else {
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
//            self.date = dateFormatter.stringFromDate(NSDate())
//        }
//        
//        self.imageURL = imageURL
//    }
    
    func getText() -> String! {
        return text
    }
    
    func getSender() -> String! {
        return sender
    }
    
    func getDate() -> String! {
        return date
    }
    
    func getImageURL() -> String? {
        return imageURL
    }
    
    func getReceiver() -> String! {
        return receiver
    }
    
    func setContent(text: String!, sender: String!, receiver: String!, date: String!){
        self.text = text
        self.sender = sender
        self.receiver = receiver
        self.date = date
    }
    
}