//
//  WordRecommendMemory.swift
//  AppEntity
//
//  Created by 박현수 on 2/15/25.
//

import Foundation


// AI 추천 단어 모음집
// 하나의테이블에 3개의 필드를 조건으로 쿼리를 하는건 좋지않아보이지만.. 어쩔수없다 언어별로 테이블을 생성하는것도 별로인것같고.
public struct WordRecommendMemory: Sendable {
    
    public var index: Int
    public var identity: String
    public var word: String
    public var meaning: String
    public var createAt: Date
    
    public var languageType: SearchLangagueType
    public var levelType: LanguageLevelType
    public var explanationLanguageType: SearchLangagueType  // 설명해주는 언어
    
    public init(index: Int, identity: String, word: String, meaning: String, createAt: Date, languageType: SearchLangagueType, levelType: LanguageLevelType, explanationLanguageType: SearchLangagueType) {
        self.index = index
        self.identity = identity
        self.word = word
        self.meaning = meaning
        self.createAt = createAt
        self.languageType = languageType
        self.levelType = levelType
        self.explanationLanguageType = explanationLanguageType
    }
}

