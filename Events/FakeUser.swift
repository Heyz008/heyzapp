//
//  FakeUser.swift
//  Heyz
//
//  Created by Zhichao Yang on 2015-03-29.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import UIKit

class FakeUser {
    var info: [String: String]
    var profileImage: UIImage
    init(info: [String: String], image: UIImage){
        self.info = info
        self.profileImage = image
    }
    class func getFakeUser(num: Int) -> FakeUser {
        switch num{
        case 0:
            let data0 : [String: String] =
            [   "status" : "single",
                "name" : "Yang",
                "location" : "Toronto",
                "sex": "Male",
                "sign": "Coding...",
                "age" : "20",
                "favorate": "false"]
            let image = UIImage(named: "profile-pic3")
            return FakeUser(info: data0, image: image!)
        default:
            let data1 : [String: String] =
            [   "status" : "in relation",
                "name" : "Jay",
                "location" : "Toronto",
                "sex": "Male",
                "sign": "Also Coding...",
                "age" : "22",
                "favorate": "true"]
            let image = UIImage(named: "555.jpg")
            return FakeUser(info: data1, image: image!)
            
        }
    }
}