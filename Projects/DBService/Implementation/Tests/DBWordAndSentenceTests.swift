//
//  DBWordAndSentenceTests.swift
//  DBImplementation
//
//  Created by 박현수 on 1/3/25.
//

import Foundation
import DBImplementation
import DBInterface
import Testing
import AppEntity



extension DBTests {
    @Suite("Sentence 테스트", .serialized, .tags(.dbSwiftData))
    class DBSentenceTests {
        
        
        @Test("sentence 추가하고 가져올수있따.")
        func addSentence() async throws {
            
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let wordIdentity: String = "asdf"
            
            let sentence = WordMemorySentence(identity: UUID().uuidString,
                                             example: "hi is hello",
                                             translation: "안녕은 안녕",
                                             usedWordInExample: "hi",
                                             usedWordInTranslation: "안녕",
                                              exampleIdentity: "안녕은 안녕",
                                              translationIdentity: "안녕",
                                             wordMemoryIdentity: wordIdentity)
            var addWord = AppEntity.WordMemory(identity: wordIdentity,
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [],
                                               sentences: [sentence])
            
            try await database.addWord(word: addWord)
            
            guard let word = try await database.fetchWord(identity: wordIdentity) else {
                #expect(false == true)
                return
            }
            
            
            #expect(word.sentences.count == 1)
        
            
        }
        
        @Test("update에 sentence 추가하고 가져올수있따.")
        func updateAddSentence() async throws {
            
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let wordIdentity: String = "asdf"
            
            let sentence = WordMemorySentence(identity: UUID().uuidString,
                                             example: "hi is hello",
                                             translation: "안녕은 안녕",
                                             usedWordInExample: "hi",
                                             usedWordInTranslation: "안녕",
                                              exampleIdentity: "안녕은 안녕",
                                              translationIdentity: "안녕",
                                             wordMemoryIdentity: wordIdentity)
            var addWord = AppEntity.WordMemory(identity: wordIdentity,
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [],
                                               sentences: [])
            
            try await database.addWord(word: addWord)
            addWord.sentences = [sentence]
            try await database.editWord(word: addWord)
            
            guard let word = try await database.fetchWord(identity: wordIdentity) else {
                #expect(false == true)
                return
            }
            
            
            #expect(word.sentences.count == 1)
        
            
        }
        
        @Test("update에 sentence 추가하고 가져올수있따2.")
        func updateAddSentence2() async throws {
            
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let wordIdentity: String = "asdf"
            
            let sentence = WordMemorySentence(identity: UUID().uuidString,
                                             example: "hi is hello",
                                             translation: "안녕은 안녕",
                                             usedWordInExample: "hi",
                                             usedWordInTranslation: "안녕",
                                              exampleIdentity: "안녕은 안녕",
                                              translationIdentity: "안녕",
                                             wordMemoryIdentity: wordIdentity)
            let sentence2 = WordMemorySentence(identity: UUID().uuidString,
                                             example: "hi is hellozxcvzxcv",
                                             translation: "안녕은 안녕asdfsdf",
                                             usedWordInExample: "hiadsf",
                                             usedWordInTranslation: "안녕asdfasdf",
                                               exampleIdentity: "hi is hellozxcvzxcv",
                                               translationIdentity: "안녕은 안녕asdfsdf",
                                             wordMemoryIdentity: wordIdentity)
            var addWord = AppEntity.WordMemory(identity: wordIdentity,
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [],
                                               sentences: [])
            
            try await database.addWord(word: addWord)
            addWord.sentences = [sentence, sentence2]
            try await database.editWord(word: addWord)
            
            guard let word = try await database.fetchWord(identity: wordIdentity) else {
                #expect(false == true)
                return
            }
            
            
            #expect(word.sentences.count == 2)
        
            
        }
        
    }
}
