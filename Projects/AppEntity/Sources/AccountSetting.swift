//
//  AccountSetting.swift
//  AppEntity
//
//  Created by 박현수 on 1/6/25.
//

import Foundation

public struct AccountSetting: Codable, Sendable {
    
    public var identity: String // user identity 
    public var chatGPTChances: Int
    public var ttsChances: Int
//    public var isSubscriber: Int  // 구독빼고, 일회성구매로.
    public var lastUpdated: Date
    public var usedCouponList: [String]
    
    public init(identity: String, chatGPTChances: Int, ttsChances: Int, lastUpdated: Date, usedCouponList: [String]) {
        self.identity = identity
        self.chatGPTChances = chatGPTChances
        self.ttsChances = ttsChances
        self.lastUpdated = lastUpdated
        self.usedCouponList = usedCouponList
    }
}
