//
//  DBTagTests.swift
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

    @Suite("Tag 테스트", .serialized, .tags(.dbSwiftData))
    class DBTagTests {
        
        
        init() {
            print("init")
        }
        
        deinit {
            print("deinit")
        }
        
        
        let tag1 = WordTag(identity: generateRandomString(),
                           name: "tag1")
        let tag2 = WordTag(identity: generateRandomString(),
                           name: "tag2")
        let tag3 = WordTag(identity: generateRandomString(),
                           name: "tag3")
        let tag4 = WordTag(identity: generateRandomString(),
                           name: "tag4")
        
        
        @Test("Tag 생성할 수 있다")
        func createTag() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            
            let fetchedTag = try await database.fetchAllTags().filter { $0.identity == tag1.identity }
            #expect(fetchedTag.isEmpty == false)
        }
        
        @Test("Tag 삭제할수있다")
        func deleteTag() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            
            try await database.deleteTag(identity: tag1.identity)
            
            let fetchedTag = try await database.fetchAllTags().filter { $0.identity == tag1.identity }
            #expect(fetchedTag.isEmpty == true)
        }
        
        @Test("Tag 수정할수 있다")
        func editTag() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            var tag = tag1
            try await database.addTag(tag: tag)
            tag.name = "zxcvzxcvzxcvzcxv"
            
            
            try await database.editTag(tag: tag)
            
            let fetchedTag = try await database.fetchAllTags().filter { $0.identity == tag1.identity }
            #expect(fetchedTag.first!.name == "zxcvzxcvzxcvzcxv")
        }
        
        
        @Test("같은 tag name은 생성할 수 없다")
        func cantCreateTagWithDuplicate() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            
            do {
                try await database.addTag(tag: WordTag(identity: generateRandomString(), name: tag1.name))
                
            } catch {
                #expect(true)
            }
        }
        
        @Test("여러개 Tag 생성할 수 있다")
        func createMultipleTag() async throws {
            let database: DataBaseProtocol =  DataBaseSwiftData.shared
            await DataBaseSwiftData.shared.setup(container: .inMemory)
            try await database.addTag(tag: tag1)
            try await database.addTag(tag: tag2)
            try await database.addTag(tag: tag3)
            
            let fetchedTag = try await database.fetchAllTags()
            #expect(fetchedTag.count == 3)
        }
        
    }
}
