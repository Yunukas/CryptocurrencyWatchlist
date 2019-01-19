//
//  Crypto.swift
//  TwoScreenApp
//
//  Created by Yunus Yurttagul on 13.01.2019.
//  Copyright © 2019 YJ. All rights reserved.
//

import Foundation

class Crypto {
    var name : String = ""
    var price : String = ""
    var dailyChangePercentage : String = ""
    
    init(name : String, price : String, dailyChangePercentage: String)
    {
        self.name = name
        self.price = price
        self.dailyChangePercentage = dailyChangePercentage
    }
}
