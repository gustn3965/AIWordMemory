//
//  DBWordAndTagTests.swift
//  DBImplementationUnitTest
//
//  Created by 박현수 on 12/31/24.
//

import Foundation

import DBImplementation
import DBInterface
import Testing
import AppEntity

extension DBTests {
    
    @Suite("Word & Tag 테스트", .serialized, .tags(.dbSwiftData))
    struct DBWordAndTagTests {
        
        let tag1 = WordTag(identity: generateRandomString(),
                           name: "tag1")
        let tag2 = WordTag(identity: generateRandomString(),
                           name: "tag2")
        let tag3 = WordTag(identity: generateRandomString(),
                           name: "tag3")
        let tag4 = WordTag(identity: generateRandomString(),
                           name: "tag4")
        
        @Test("tag와 같이 생성할 수 있다")
        func canCreateWordWithTag() async throws {
            
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [tag1, tag2])
            try await database.addWord(word: addWord)
            
            if let word = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all)).first {
                
                try #require(word.tags.count == 2)
                #expect(word.tags.contains { $0.identity == tag1.identity })
            } else {
                
                #expect(false == true)
            }
            
            
            
        }
        
        @Test("tag와 같이 생성하여 tag로 필터링할수있다.")
        func canFilterWithTag() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [tag1, tag2])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "hiasdfasdf",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zxcvzvcx",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                  categoryFilter: .contain(tags: [tag3], includeNoTag: false),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 1)
            
        }
        
        
        @Test("tag와 같이 생성하여 tag와 word.name로 필터링할수있다.")
        func canFilterWithTagAndName() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [tag1, tag2])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zzzzzzzzzzz",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zxcvzvcx",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "hi"),
                                                                                  categoryFilter: .contain(tags: [tag3], includeNoTag: false),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 0)
            
        }
        
        @Test("tag와 같이 생성하여 tag와 word.name로 필터링할수있다.2")
        func canFilterWithTagAndName2() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [tag1, tag2])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zzzzzzzzzzz",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zxcvzvcx",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "hi"),
                                                                                  categoryFilter: .contain(tags: [tag1], includeNoTag: false),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 1)
            
        }
        
        @Test("tag와 같이 생성하여 tag와 word.name로 필터링할수있다.3")
        func canFilterWithTagAndName3() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [tag1, tag2])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zzzzzzzzzzz",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zxcvzvcx",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            let addWord4 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zx33234234234",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            try await database.addWord(word: addWord4)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "zx"),
                                                                                  categoryFilter: .contain(tags: [tag3], includeNoTag: false),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 2)
            
        }
        
        
        @Test("tag와 같이 생성하여, tag없고 word.name로 필터링할수있다.")
        func canFilterWithNoTagAndName() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zzzzzzzzzzz",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "hiasdfasdfadsf",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "hi"),
                                                                                  categoryFilter: .contain(tags: [], includeNoTag: true),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 1)
            
        }
        
        @Test("tag와 같이 생성하여, tag없거나 tag가 있으며, word.name로 필터링할수있다.2")
        func canFilterWithNoTagAndTagAndName() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            try await database.addTag(tag: tag4)
            
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "zzzzzzzzzzz",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag1])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "hiasdfasdfasdf",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [tag3])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "hi"),
                                                                                  categoryFilter: .contain(tags: [tag3], includeNoTag: true),
                                                                                  sortType: .nameDescending(true)))
            //        #
            #expect(words.count == 2)
            
        }
    }
}
