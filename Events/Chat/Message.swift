//
//  Message.swift
//  Heyz
//
//  Created by Jay Yu on 2015-01-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation

class Message: NSObject{
    var text: String
    var sender: String
    var date: String
    var imageURL: String?
    
    convenience init(text: String?, sender: String?){
        self.init(text: text, sender: sender)
    }
    
    init(text: String?, sender: String?, imageURL: String?){
        self.text = text!
        self.sender = sender!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
        self.date = dateFormatter.stringFromDate(NSDate())
        self.imageURL = imageURL
    }
    
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
    
    
}