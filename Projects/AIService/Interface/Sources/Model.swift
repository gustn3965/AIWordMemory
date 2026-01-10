//
//  Model.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation


public struct AIFetchSentenceResponse: Sendable {
    
    public struct AIExample: Sendable {
        
        public let example: String
        public let translation: String
        public let usedWordInExample: String
        public let usedWordInTranslation: String
        
        public let exampleIdentity: String = UUID().uuidString
        public let translationIdentity: String = UUID().uuidString
        
        public init(example: String, translation: String, usedWordInExample: String, usedWordInTranslation: String) {
            self.example = example
            self.translation = translation
            self.usedWordInExample = usedWordInExample
            self.usedWordInTranslation = usedWordInTranslation
        }
    }

    
    public let examples: [AIExample]
    
    public init(examples: [AIExample]) {
        self.examples = examples
    }
    
}



public struct AISearchResponse: Sendable {
    public var word: String
    public var explanation: String
    public var sentence: String
    public var sentenceTranslation: String
    public var meaning: String
    
    public var searchType: AISearchType
    
    public init(word: String, explanation: String, sentence: String, sentenceTranslation: String, meaning: String, searchType: AISearchType) {
        self.word = word
        self.explanation = explanation
        self.sentence = sentence
        self.sentenceTranslation = sentenceTranslation
        self.meaning = meaning
        self.searchType = searchType
    }
}

public struct AISentenceInspectorResponse: Sendable {
    public var originSentence: String
    public var explantion: String
    public var correctSentence: String
    
    public init(originSentence: String, explantion: String, correctSentence: String) {
        self.originSentence = originSentence
        self.explantion = explantion
        self.correctSentence = correctSentence
    }
}


public struct AIRecommendWordResponse: Sendable {
    
    public struct Word: Sendable {
        public var word: String
        public var meaning: String
        public init(word: String, meaning: String) {
            self.word = word
            self.meaning = meaning
        }
    }
    
    public var words: [Word]
    
    public init(words: [Word]) {
        self.words = words
    }
}

