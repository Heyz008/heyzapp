//
//  MessageDelegate.swift
//  Heyz
//
//  Created by Jay Yu on 2015-02-04.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation

//消息代理协议 
protocol MessageDelegate {
    
    func onAfterMsgReceived(from: String)
    
}