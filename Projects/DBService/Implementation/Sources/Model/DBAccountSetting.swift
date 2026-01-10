//
//  DBAccountSetting.swift
//  DBImplementation
//
//  Created by 박현수 on 1/6/25.
//

import Foundation
import SwiftData

@Model
final class DBAccountSetting {
    
    @Attribute() public var identity: String = UUID().uuidString // user identity  //Attributed(.unique)는 cloudkit에서 못쓴다함.
    var chatGPTChances: Int = 0
    var ttsChances: Int = 0
//    var isSubscriber: Int = 0     // 구독빼고 1회성구매로
    var lastUpdated: Date = Date()
    var createAt: Date = Date()
    
    var usedCoupons: [String] = []
    
    
    init(identity: String, chatGPTChances: Int, ttsChances: Int, lastUpdated: Date, usedCoupons: [String]) {
        self.chatGPTChances = chatGPTChances
        self.ttsChances = ttsChances
//        self.isSubscriber = isSubscriber
        self.lastUpdated = lastUpdated
        self.identity = identity
        self.usedCoupons = usedCoupons
    }
}
