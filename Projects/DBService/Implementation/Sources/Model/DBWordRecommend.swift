//
//  DBWordRecommend.swift
//  DBImplementation
//
//  Created by 박현수 on 2/15/25.
//

import Foundation
import SwiftData

@Model
final class DBWordRecommend {
    @Attribute() var identity: String = UUID().uuidString
    var index: Int = 0
    var word: String = ""
    var meaning: String = ""
    var createAt: Date = Date()
    
    var languageType: Int = 0             // 찾고자하는 언어
    var explanationLanguageType: Int = 0  // 설명해주는 언어
    var levelType: Int = 0                // 언어 난이도
    
    init(word: String, meaning: String, createAt: Date, languageType: Int, explanationLanguageType: Int, levelType: Int, index: Int, identity: String = UUID().uuidString) {
        self.identity = identity
        self.word = word
        self.meaning = meaning
        self.createAt = createAt
        self.languageType = languageType
        self.explanationLanguageType = explanationLanguageType
        self.levelType = levelType
        self.index = index 
    }
}


