//
//  DBWordSentence.swift
//  DBImplementation
//
//  Created by 박현수 on 1/3/25.
//

import Foundation
import SwiftData

@Model
final class DBWordSentence {
    @Attribute() var identity: String = UUID().uuidString
    var example: String = ""
    var translation: String = ""
    var usedWordInExample: String = ""
    var usedWordInTranslation: String = ""
    var exampleIdentity: String = ""
    var translationIdentity: String = ""
    
    var wordMemoryIdentity: String = ""
    @Relationship(inverse: \DBWord.sentences) var words: [DBWord]? = []
    
    init(identity: String, example: String, translation: String, usedWordInExample: String, usedWordInTranslation: String, exampleIdentity: String, translationIdentity: String, wordMemoryIdentity: String) {
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



