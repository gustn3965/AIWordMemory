//
//  DBWord.swift
//  DBImplementation
//
//  Created by 박현수 on 12/29/24.
//

import Foundation

import SwiftData

@Model
final class DBWord {
    //    #Unique<DBWordTag>([\.identity])  // iOS18부터
    //    #Index<DBWord>([\.word])          // iOS18부터
    @Attribute() var identity: String = UUID().uuidString //Attributed(.unique)는 cloudkit에서 못쓴다함.
    var word: String = ""
    var meaning: String = ""
    var createAt: Date = Date()
    var correctCount: Int = 0
    
    @Relationship var tags: [DBWordTag]? = []
    @Relationship var sentences: [DBWordSentence]? = []
    
    init(word: String, meaning: String, tags: [DBWordTag], sentences: [DBWordSentence] = [], identity: String = UUID().uuidString) {
        self.word = word
        self.meaning = meaning
        self.tags = tags
        self.sentences = sentences
        self.identity = identity
    }
}



