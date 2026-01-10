//
//  DBWordTests.swift
//  DBImplementation
//
//  Created by 박현수 on 12/31/24.
//

import Foundation

import DBImplementation
import DBInterface
import Testing
import AppEntity



extension DBTests {
    @Suite("Word 테스트", .serialized, .tags(.dbSwiftData))
    class DBDataTests {
        
        
        init() {
            print("init")
        }
        
        deinit {
            print("deinit")
        }
        
        @Test("생성할 수 있다")
        func create가능() async throws {
            
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            try await database.addWord(word: addWord)
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                  categoryFilter: .all,
                                                                                  sortType: .createAtDescending(true)))
            
            // Then
            try #require(words.count == 1)
            
            let word = words.first!
            #expect(word.word == addWord.word)
            #expect(true)
        }
        
        
        @Test("아무것도 생성안하면 empty다")
        func isEmpty() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
           
            let result = try await database.isWordEmpty()
            
            #expect(result)
        }
        
        @Test("생성했으면 empty가 아니다")
        func isNotEmpty() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            try await database.addWord(word: addWord)
            let result = try await database.isWordEmpty()
            #expect(result == false)
        }
        
        @Test("동일한 id가 이미 있는경우 생성할수없다.")
        func cantCreateDuplicate() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            var addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            try await database.addWord(word: addWord)
            
            do {
                addWord.meaning = "something else"
                try await database.addWord(word: addWord)
                throw DataBaseError.duplicated
            } catch {
                #expect(true)
            }
            
        }
        
        @Test("word 삭제 가능하다 ")
        func delete가능() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            try await database.addWord(word: addWord)
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                  categoryFilter: .all,
                                                                                  sortType: .createAtDescending(true)))
            
            // Then
            try #require(words.count == 1)
            
            
            try await database.deleteWord(identity: addWord.identity)
            
            let wordsAfterDelete = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                             categoryFilter: .all,
                                                                                             sortType: .createAtDescending(true)))
            #expect(wordsAfterDelete.isEmpty)
        }
        
        @Test("수정할 수 있다.")
        func canEdit() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            var addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            try await database.addWord(word: addWord)
            addWord.word = "edit"
            try await database.editWord(word: addWord)
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                  categoryFilter: .all,
                                                                                  sortType: .createAtDescending(true)))
            
            // Then
            try #require(words.count == 1)
            
            let word = words.first!
            #expect(word.word == "edit")
            #expect(true)
        }
        
        @Test("id로 dbword 가져올수있다.")
        func canFetchByWordIdentity() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: "asdf",
                                               word: "hi",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            try await database.addWord(word: addWord)
            
            let word = try await database.fetchWord(identity: addWord.identity)
            try #require(word != nil)
            #expect(word!.identity == addWord.identity)
        }
        
        @Test("이름필터링 적용하여 가져올수있다")
        func canFilterAndFetch() async throws {
            
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "가",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "나",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "다",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .contain(name: "나"),
                                                                                  categoryFilter: .all,
                                                                                  sortType: .createAtDescending(true)))
            
            
            
            // Then
            try #require(words.count == 1)
            
            let word = words.first!
            #expect(word.word == addWord2.word)
            #expect(true)
        }
        
        @Test("필터링 적용하여 가져올수있다")
        func canFilterAndFetch2() async throws {
            // Given
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            let addWord = AppEntity.WordMemory(identity: generateRandomString(),
                                               word: "가",
                                               meaning: "meaning",
                                               createAt: Date(),
                                               tags: [])
            
            let addWord2 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "나",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [])
            let addWord3 = AppEntity.WordMemory(identity: generateRandomString(),
                                                word: "다",
                                                meaning: "meaning",
                                                createAt: Date(),
                                                tags: [])
            
            try await database.addWord(word: addWord)
            try await database.addWord(word: addWord2)
            try await database.addWord(word: addWord3)
            
            let words = try await database.fetchWordList(filter: SearchWordFilter(nameFilter: .all,
                                                                                  categoryFilter: .all,
                                                                                  sortType: .createAtDescending(true)))
            
            
            
            // Then
            #expect(words.count == 3)
            
            
        }
    }
}
