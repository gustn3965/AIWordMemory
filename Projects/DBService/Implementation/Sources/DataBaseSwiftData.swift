//import SwiftUI
//
//public struct ContentView: View {
//    public init() {}
//
//    public var body: some View {
//        Text("{{name}}")
//            .padding()
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
import Foundation
import DBInterface
import AppEntity

import SwiftData
import Combine
import CoreData


@globalActor public actor DataBaseSwiftData: DataBaseProtocol {
    
    public enum Container {
        case real
        case inMemory
    }
    
    public func setup(container: Container) {
        
        var config: ModelConfiguration
        switch container {
        case .real:
            let url = URL.documentsDirectory.appendingPathComponent("WordDatabase")
            config = ModelConfiguration(url: url)
            //            config = ModelConfiguration(url: url, cloudKitDatabase: .private(<#T##privateDBName: String##String#>))
            //            config = ModelConfiguration()
            //            config.cloudKitContainerIdentifier = "iCloud.aiWordMemory"
            //            config.cloudKitDatabase = .
            print("⭐️⭐️⭐️⭐️⭐️Database url:\n\(url)\n⭐️⭐️⭐️⭐️⭐️")
        case .inMemory:
            config = ModelConfiguration(isStoredInMemoryOnly: true)
        }
        
        do {
            let container = try ModelContainer(
                for: Schema(versionedSchema: WordSchemaV1.self),
                migrationPlan: WordMigrationPlan.self,
                configurations: config
            )
            
            self.modelActor = DataBase(modelContainer: container)
            
            NotificationCenter.default.addObserver(forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: nil) { notification in
                guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                    return
                }
                
                
                if event.type == .import, event.endDate != nil {
                    // 가져오기가 완료되었습니다. 여기서 필요한 작업을 수행하세요.
                    print("✅✅✅✅ Update Pushed!!!")
                    Task {
                        await MainActor.run {
                            self.updatePulbisher.send(.add)
                        }
                    }
                }
            }
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    public nonisolated(unsafe) var updatePulbisher: PassthroughSubject<DBInterface.DataBaseUpdateType, Never> = PassthroughSubject()
    private var continuation: AsyncStream<DBInterface.DataBaseUpdateType>.Continuation?
    
    public static let shared: DataBaseSwiftData = DataBaseSwiftData()
    
    var modelActor: DataBase?
    
    private init() { }
    
    public func isWordEmpty() async throws -> Bool {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        return try await modelActor.isWordEmpty()
    }
    
    public func addWord(word: AppEntity.WordMemory) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.insert(word: word)
        print("# \(#file) \(#function)")
        await MainActor.run {
            updatePulbisher.send(.add)
        }
        
    }
    
    public func deleteWord(identity: String) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.delete(identity: identity)
        print("# \(#file) \(#function)")
        await MainActor.run {
            updatePulbisher.send(.delete(identity: identity))
        }
    }
    
    public func editWord(word: AppEntity.WordMemory) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.update(word: word)
        print("# \(#file) \(#function)")
        await MainActor.run {
            updatePulbisher.send(.update(identity: word.identity))
        }
    }
    
    public func fetchWord(identity: String) async throws -> WordMemory? {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        print("# \(#file) \(#function)")
        return try await modelActor.fetchWord(identity: identity)
    }
    
    public func fetchWordList(filter: DBInterface.SearchWordFilter) async throws -> [AppEntity.WordMemory] {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        let words = try await modelActor.fetchWords(filter: filter)
        print("# \(#file) \(#function)")
        return words
    }
    
    public func fetchReviewList(filter: DBInterface.ReviewWordFilter) async throws -> [AppEntity.WordMemory] {
        //        guard let modelActor = modelActor else { fatalError("Database not setup") }
        
        return []
    }
    
    
    public func addTag(tag: WordTag) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.insert(tag: tag)
        await MainActor.run {
            updatePulbisher.send(.add)
        }
        
    }
    
    public func deleteTag(identity: String) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.deleteTag(identity: identity)
        await MainActor.run {
            updatePulbisher.send(.delete(identity: identity))
        }
        
    }
    
    public func editTag(tag: WordTag) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.editTag(tag: tag)
        await MainActor.run {
            updatePulbisher.send(.update(identity: tag.identity))
        }
        
    }
    
    
    public func fetchAllTags() async throws -> [AppEntity.WordTag]
    {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        let tags = try await modelActor.fetchAllTags()
        return tags
    }
    
    public func fetchRecommendWords(languageType: SearchLangagueType,
                                    explanationLanguageType: SearchLangagueType,
                                    levelType: LanguageLevelType) async throws -> [WordRecommendMemory]? {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        print("# \(#file) \(#function)")
        return try await modelActor.fetchRecommendWords(languageType: languageType, explanationLanguageType: explanationLanguageType, levelType: levelType)
    }
    
    public func saveRecommendWords(words: [WordRecommendMemory]) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.insertRecommendWords(words: words)
//        await MainActor.run {
//            updatePulbisher.send(.update(identity: tag.identity))
//        }
    }
}

@ModelActor actor DataBase {
    
    func isWordEmpty() async throws -> Bool {
        var fetchDescriptor = FetchDescriptor<DBWord>()
        fetchDescriptor.fetchLimit = 1
        
        let result = try modelContext.fetch(fetchDescriptor)
        return result.isEmpty
    }
    
    func insert(word: AppEntity.WordMemory) throws {
        
        let searchWord = word.word
        let sameResult: ComparisonResult = .orderedSame
        let fetchDescriptor = FetchDescriptor<DBWord>(
            predicate: #Predicate<DBWord> { dbword in dbword.word.caseInsensitiveCompare(searchWord) == sameResult }, sortBy: []
        )
        
        let existingWord = try modelContext.fetch(fetchDescriptor).first
        
        if existingWord != nil {
            // word 로 유니크체크
            throw DataBaseError.duplicated
        } else {
            
            let allTags = try fetchAllDBTags()
            let dbTags = allTags.filter { dbTag in
                word.tags.contains { tag in
                    tag.identity == dbTag.identity
                }}
            //            let tags = dbTags.map { AppEntity.WordTag(identity: $0.identity, name: $0.name)}
            
            let sentences = word.sentences.map { $0.makeDBInstnace(wordIdentity: word.identity) }
            
            let newWord = DBWord(word: word.word, meaning: word.meaning, tags: [], sentences: sentences, identity: word.identity)
            modelContext.insert(newWord)
            newWord.tags = dbTags
            
            try modelContext.save()
        }
    }
    
    func insert(tag: AppEntity.WordTag) throws {
        let searchWord = tag.name
        let result: ComparisonResult = .orderedSame
        let fetchDescriptor = FetchDescriptor<DBWordTag>(
            predicate: #Predicate<DBWordTag> { dbword in dbword.name.caseInsensitiveCompare(searchWord) == result }, sortBy: []
        )
        
        let existingWord = try modelContext.fetch(fetchDescriptor).first
        
        if existingWord != nil {
            // word 로 유니크체크
            throw DataBaseError.duplicated
        } else {
            let newTag = DBWordTag(name: tag.name, identity: tag.identity)
            modelContext.insert(newTag)
            try modelContext.save()
        }
    }
    
    func editTag(tag: AppEntity.WordTag) throws {
        if tag.name.isEmpty || tag.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { throw DataBaseError.requiredNotFound}
        let searchWord = tag.identity
        let result: ComparisonResult = .orderedSame
        let fetchDescriptor = FetchDescriptor<DBWordTag>(
            predicate: #Predicate<DBWordTag> { dbword in dbword.identity.caseInsensitiveCompare(searchWord) == result }, sortBy: []
        )
        let existingTag = try modelContext.fetch(fetchDescriptor).first
        if let existingTag = existingTag {
            
            let duplicated = tag.name
            let fetchDescriptor = FetchDescriptor<DBWordTag>(
                predicate: #Predicate<DBWordTag> { dbword in dbword.name.caseInsensitiveCompare(duplicated) == result }, sortBy: []
            )
            let duplicatedTag = try modelContext.fetch(fetchDescriptor).first
            if duplicatedTag != nil {
                throw DataBaseError.duplicated
            }
            
            existingTag.name = tag.name
            try modelContext.save()
        }
    }
    
    
    func update(word: AppEntity.WordMemory) throws {
        let searchWordIdentity = word.identity
        let fetchDescriptor = FetchDescriptor<DBWord>(
            predicate: #Predicate { dbword in dbword.identity == searchWordIdentity })
        
        let existingWord = try modelContext.fetch(fetchDescriptor).first
        
        if let existingWord = existingWord {
            if existingWord.word.lowercased() != word.word.lowercased() {
                let result: ComparisonResult = .orderedSame
                let wordName = word.word
                let fetchDescriptor = FetchDescriptor<DBWord>(
                    predicate: #Predicate { dbword in dbword.word.caseInsensitiveCompare(wordName) == result })
                if try modelContext.fetch(fetchDescriptor).first != nil {
                    throw DataBaseError.duplicated
                }
                
            }
            existingWord.meaning = word.meaning
            existingWord.word = word.word
            existingWord.correctCount = word.correctCount
            
            let allTags = try fetchAllDBTags()
            let dbTags = allTags.filter { dbTag in
                word.tags.contains { tag in
                    tag.identity == dbTag.identity
                }}
            existingWord.tags = dbTags
            
            
            (existingWord.sentences ?? []).forEach { modelContext.delete($0) }
            existingWord.sentences?.removeAll()
            
            // Add new sentences
            word.sentences.forEach { sentence in
                let newSentence = sentence.makeDBInstnace(wordIdentity: word.identity)
                modelContext.insert(newSentence)
                existingWord.sentences?.append(newSentence)
            }
            
            try modelContext.save()
        }
    }
    
    public func fetchWord(identity: String) async throws -> AppEntity.WordMemory? {
        let result: ComparisonResult = .orderedSame
        let identityPredicate = #Predicate<DBWord> { dbWord in
            dbWord.identity.caseInsensitiveCompare(identity) == result
            
        }
        let fetchDescriptor = FetchDescriptor<DBWord>(predicate: identityPredicate)
        
        let words = try modelContext.fetch(fetchDescriptor)
        
        if let word = words.first {
            return WordMemory(identity: word.identity,
                              word: word.word,
                              meaning: word.meaning,
                              createAt: word.createAt,
                              correctCount: word.correctCount,
                              tags: (word.tags ?? []).map { tag in WordTag(identity: tag.identity, name: tag.name )},
                              sentences: (word.sentences ?? []).map { sentence in sentence.makeAppEntity(wordIdentity: word.identity)})
            
        } else {
            return nil
        }
    }

    
    @available(iOS 18, *)
    func fetchWordsIOS18(filter: DBInterface.SearchWordFilter) throws -> [AppEntity.WordMemory] {
        var namePredicate: Predicate<DBWord>
        var tagPredicate: Predicate<DBWord>
        var sortDescriptor: SortDescriptor<DBWord>
        
        switch filter.nameFilter {
        case .contain(let name):
            namePredicate = #Predicate<DBWord> { word in
                word.word.localizedStandardContains(name) || word.meaning.localizedStandardContains(name)
            }
        case .all:
            namePredicate = #Predicate<DBWord> { _ in true }
        }
        
        switch filter.tagFilter {
        case .contain(let tags, let includeNoTag):
            let tagIdentitys = tags.map { $0.identity }
            
            let includeTagPredicate = #Predicate<DBWord> { word in
                word.tags?.contains { dbTag in
                    tagIdentitys.contains(dbTag.identity)
                } ?? false
            }
            
            if includeNoTag {
                let noTagPredicate = #Predicate<DBWord> { word in
                    word.tags?.count == 0
                }
                tagPredicate = #Predicate<DBWord> { word in
                    includeTagPredicate.evaluate(word) || noTagPredicate.evaluate(word)
                }
            } else {
                tagPredicate = includeTagPredicate
            }
        case .all:
            tagPredicate = #Predicate<DBWord> { _ in true }
        }
        
        switch filter.sortType {
        case .nameDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.word, order: bool ? .reverse: .forward) // forward가 ascending
        case .createAtDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.createAt, order: bool ? .reverse: .forward)
        case .correctCountDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.correctCount, order: bool ? .reverse: .forward)
        }
        
        
        let combinedPredicate = #Predicate<DBWord> { word in
            namePredicate.evaluate(word) && tagPredicate.evaluate(word)
        }
        let fetchDescriptor = FetchDescriptor<DBWord>(predicate: combinedPredicate,
                                                      sortBy: [sortDescriptor])
        
        let words = try modelContext.fetch(fetchDescriptor)
        
        return words.map { word in
            AppEntity.WordMemory(identity: word.identity,
                                 word: word.word,
                                 meaning: word.meaning,
                                 createAt: word.createAt,
                                 correctCount: word.correctCount,
                                 tags: (word.tags ?? []).map { tag in WordTag(identity: tag.identity, name: tag.name )},
                                 sentences: (word.sentences ?? []).map { sentence in sentence.makeAppEntity(wordIdentity: word.identity)})
        }
    }
    
    func fetchWordsLegacy(filter: DBInterface.SearchWordFilter) throws -> [AppEntity.WordMemory] {
        // iOS 18 미만 버전에서 실행될 코드
        var namePredicate: Predicate<DBWord>
        var sortDescriptor: SortDescriptor<DBWord>
        
        switch filter.nameFilter {
        case .contain(let name):
            namePredicate = #Predicate<DBWord> { word in
                word.word.localizedStandardContains(name) || word.meaning.localizedStandardContains(name)
            }
        case .all:
            namePredicate = #Predicate<DBWord> { _ in true }
        }
        
        switch filter.sortType {
        case .nameDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.word, order: bool ? .reverse: .forward)
        case .createAtDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.createAt, order: bool ? .reverse: .forward)
        case .correctCountDescending(let bool):
            sortDescriptor = SortDescriptor<DBWord>(\.correctCount, order: bool ? .reverse: .forward)
        }
        
        let fetchDescriptor = FetchDescriptor<DBWord>(predicate: namePredicate, sortBy: [sortDescriptor])
        
        let nameFilteredWords = try modelContext.fetch(fetchDescriptor)
        
        
        // Tag 필터링을 메모리에서 수행
        let finalFilteredWords: [DBWord] = nameFilteredWords.filter { (word: DBWord) in
            switch filter.tagFilter {
            case .contain(let tags, let includeNoTag):
                let tagIdentitys = tags.map { (tag: WordTag) in tag.identity }
                
                if includeNoTag {
                    let tagFilter = word.tags?.contains { (tag: DBWordTag) in
                        return tagIdentitys.contains(tag.identity)
                    } ?? false
                    return (tagFilter || (word.tags?.isEmpty ?? true))
                } else {
                    let tagFilter = word.tags?.contains { (tag: DBWordTag) in
                        return tagIdentitys.contains(tag.identity)
                    } ?? false
                    return tagFilter
                }
            case .all:
                return true
            }
        }
        
        return finalFilteredWords.map { word in
            AppEntity.WordMemory(identity: word.identity,
                                 word: word.word,
                                 meaning: word.meaning,
                                 createAt: word.createAt,
                                 correctCount: word.correctCount,
                                 tags: (word.tags ?? []).map { tag in WordTag(identity: tag.identity, name: tag.name )},
                                 sentences: (word.sentences ?? []).map { sentence in sentence.makeAppEntity(wordIdentity: word.identity)})
        }
    }
    
    func fetchWords(filter: DBInterface.SearchWordFilter) async throws -> [AppEntity.WordMemory] {
        if #available(iOS 18, *) {
            return try fetchWordsIOS18(filter: filter)
        } else {
            return try fetchWordsLegacy(filter: filter)
        }
        
    }
    
    
    func delete(identity: String) throws {
        let identity = identity
        let fetchDescriptor = FetchDescriptor<DBWord>(predicate: #Predicate { dbword in dbword.identity == identity })
        let existingWord = try modelContext.fetch(fetchDescriptor).first
        
        if let existingWord = existingWord {
            modelContext.delete(existingWord)
            
            try modelContext.save()
        }
    }
    
    func deleteTag(identity: String) throws {
        let identity = identity
        let fetchDescriptor = FetchDescriptor<DBWordTag>(predicate: #Predicate { dbword in dbword.identity == identity })
        let existingWord = try modelContext.fetch(fetchDescriptor).first
        
        if let existingWord = existingWord {
            modelContext.delete(existingWord)
            
            try modelContext.save()
        }
    }
    
    
    
    func fetchAllTags() throws -> [AppEntity.WordTag] {
        let tags = try fetchAllDBTags()
        return tags.map { AppEntity.WordTag(identity: $0.identity, name: $0.name )}
    }
    
    private func fetchAllDBTags() throws -> [DBWordTag] {
        let fetchDescriptor = FetchDescriptor<DBWordTag>(sortBy: [])
        let existingWord = try modelContext.fetch(fetchDescriptor)
        return existingWord
    }
    
    
    
    func fetchRecommendWords(languageType: SearchLangagueType,
                             explanationLanguageType: SearchLangagueType,
                                    levelType: LanguageLevelType) throws -> [AppEntity.WordRecommendMemory]? {
        
        let result: ComparisonResult = .orderedSame
        
        let levelInt = levelType.intValue
        let explanationLanguageInt = explanationLanguageType.intValue
        let languageTypeInt = languageType.intValue
        let identityPredicate = #Predicate<DBWordRecommend> { dbWord in
            dbWord.levelType == levelInt &&
            dbWord.explanationLanguageType == explanationLanguageInt &&
            dbWord.languageType == languageTypeInt
        }
        
        let sortDescriptor: SortDescriptor<DBWordRecommend>
        sortDescriptor = SortDescriptor<DBWordRecommend>(\.index, order: .reverse)
        
        let fetchDescriptor = FetchDescriptor<DBWordRecommend>(predicate: identityPredicate, sortBy: [sortDescriptor])
        
        let words = try modelContext.fetch(fetchDescriptor)
        
        if let word = words.first {
            
            return words.map {
                WordRecommendMemory(index: $0.index, identity: $0.identity, word: $0.word, meaning: $0.meaning, createAt: $0.createAt, languageType: languageType, levelType: levelType, explanationLanguageType: explanationLanguageType)
            }
        } else {
            return nil
        }
    }
    
    func insertRecommendWords(words: [AppEntity.WordRecommendMemory]) throws {
        
        for word in words {
            let newWord = DBWordRecommend(word: word.word, meaning: word.meaning, createAt: word.createAt, languageType: word.languageType.intValue, explanationLanguageType: word.explanationLanguageType.intValue, levelType: word.levelType.intValue, index: word.index)
            modelContext.insert(newWord)
        }
        try modelContext.save()
    }
}




extension DBWordSentence {
    
    func makeAppEntity(wordIdentity: String) -> AppEntity.WordMemorySentence {
        WordMemorySentence(identity: identity,
                           example: example,
                           translation: translation,
                           usedWordInExample: usedWordInExample,
                           usedWordInTranslation: usedWordInTranslation,
                           exampleIdentity: exampleIdentity,
                           translationIdentity: translationIdentity,
                           wordMemoryIdentity: wordIdentity)
    }
}


extension WordMemorySentence {
    func makeDBInstnace(wordIdentity: String) -> DBWordSentence {
        DBWordSentence(identity: identity,
                       example: example,
                       translation: translation,
                       usedWordInExample: usedWordInExample,
                       usedWordInTranslation: usedWordInTranslation,
                       exampleIdentity: exampleIdentity,
                       translationIdentity: translationIdentity,
                       wordMemoryIdentity: wordIdentity)
    }
}
