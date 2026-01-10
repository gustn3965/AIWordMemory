//
//  WordSentence.swift
//  AppEntity
//
//  Created by 박현수 on 1/3/25.
//

import Foundation

public struct WordMemorySentence: Sendable, Hashable {
    public let identity: String
    
    public let example: String
    public let translation: String
    public let usedWordInExample: String
    public let usedWordInTranslation: String
    
    public let exampleIdentity: String
    public let translationIdentity: String
    
    public let wordMemoryIdentity: String
    
    public init(identity: String, example: String, translation: String, usedWordInExample: String, usedWordInTranslation: String, exampleIdentity: String, translationIdentity: String, wordMemoryIdentity: String) {
        self.identity = identity
        self.example = example
        self.translation = translation
        self.usedWordInExample = usedWordInExample
        self.usedWordInTranslation = usedWordInTranslation
        self.exampleIdentity = exampleIdentity
        self.translationIdentity = translationIdentity
        self.wordMemoryIdentity = wordMemoryIdentity
    }
}
