//
//  MockDataBase.swift
//  DBInterface
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import AppEntity
import Combine
import AccountInterface



@globalActor public actor MockInMemoryDatabase: DataBaseProtocol {
    
    public static let shared: MockInMemoryDatabase = MockInMemoryDatabase()
    
    public init() {}
    
    private var cacheWords: [String: AppEntity.WordMemory] = [:]
    private var cacheTags: [String: AppEntity.WordTag] = [:]
    
    public func setup(includeDefaultData: Bool) {
        
        if includeDefaultData == false {
            return
        }
        let tag1: WordTag = .init(identity: UUID().uuidString, name: "verb")
        let tag2: WordTag = .init(identity: UUID().uuidString, name: "noun")
        let tag3: WordTag = .init(identity: UUID().uuidString, name: "형용사")
        let tag4: WordTag = .init(identity: UUID().uuidString, name: "동사")
        let tag5: WordTag = .init(identity: UUID().uuidString, name: "일상생활영어")
        
        let sentences: [WordMemorySentence] = [
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            WordMemorySentence(identity: UUID().uuidString,
                               example: "he is used to walk", translation: "그는 걷는데 익숙하다", usedWordInExample: "is used to", usedWordInTranslation: "익숙하다", exampleIdentity: "he is used to walk", translationIdentity: "그는 걷는데 익숙하다", wordMemoryIdentity: "be used to"),
            
        ]
        
        let tags: [WordTag] = [tag1, tag2, tag3, tag4, tag5]
        tags.forEach { cacheTags[$0.identity] = $0 }
        var words = [
            WordMemory(identity: "과일",
                       word: "과일",
                       meaning: "fruit",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            WordMemory(identity: "가을",
                       word: "가을",
                       meaning: "autumn",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            WordMemory(identity: "날씨",
                       word: "날씨",
                       meaning: "weather",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            WordMemory(identity: "월요일",
                       word: "월요일",
                       meaning: "Monday",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            WordMemory(identity: "화요일",
                       word: "화요일",
                       meaning: "Tuesday",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            
            
            
            WordMemory(identity: "기대하다",
                       word: "기대하다",
                       meaning: "be looking for",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            WordMemory(identity: "친구",
                       word: "친구",
                       meaning: "friend",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag1],
                       sentences: sentences),
            WordMemory(identity: "가족",
                       word: "가족",
                       meaning: "family",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag1],
                       sentences: sentences),
            WordMemory(identity: "사랑",
                       word: "사랑",
                       meaning: "love",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag1],
                       sentences: sentences),
            WordMemory(identity: "보고싶다",
                       word: "보고싶다",
                       meaning: "mise you",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag2],
                       sentences: sentences),
            
            
            
            WordMemory(identity: "be used to",
                       word: "be used to",
                       meaning: "-에 익숙하다",
                       createAt: .now,
                       correctCount: 20,
                       tags: [tag1, tag2, tag3, tag4, tag5],
                       sentences: sentences),
            
            WordMemory(identity: "헌법재판소",
                       word: "헌법재판소",
                       meaning: "constitutional court",
                       createAt: .now,
                       correctCount: 324234,
                       tags: [tag1]),
            WordMemory(identity: "apparently",
                       word: "apparently",
                       meaning: "듣기로는..",
                       createAt: .now,
                       correctCount: 3),
            WordMemory(identity: randomeText(),
                       word: "used to",
                       meaning: "-에 하곤했었다",
                       createAt: .now,
                       correctCount: 5),
            
            
            WordMemory(identity: randomeText(),
                       word: "こんにちは ",
                       meaning: "안녕하세요.",
                       createAt: .now,
                       tags: [tag3]),
            
            WordMemory(identity: randomeText(),
                       word: "いぬ",
                       meaning: "dog",
                       createAt: .now,
                       tags: [tag1, tag2, tag3]),
            
            
            WordMemory(identity: randomeText(),
                       word: "be looking forward to",
                       meaning: "-를 기대한다",
                       createAt: .now,
                       tags: [tag1]),
            
            WordMemory(identity: randomeText(),
                       word: "appearently",
                       meaning: "듣기로는..",
                       createAt: .now,
                       tags: [tag2, tag3]),
        ]
//        for _ in 0..<10000 {
//            let word = WordMemory(identity: UUID().uuidString, word: randomeText(), meaning: randomeText(), createAt: .now)
//            words.append(word)
//        }
        
//        words = words.map { WordMemory(identity: $0.identity, word: $0.meaning, meaning: $0.word, createAt: $0.createAt)}
        
        words.forEach { cacheWords[$0.identity] = $0 }
    }
    
    
    nonisolated(unsafe) public var updatePulbisher: PassthroughSubject<DataBaseUpdateType, Never> = PassthroughSubject()
    
    public func isWordEmpty() async throws -> Bool {
        cacheWords.isEmpty
    }
    
    public func addWord(word: AppEntity.WordMemory) async throws {
        throw DataBaseError.duplicated
        if cacheWords[word.identity] != nil {
            throw DataBaseError.duplicated
        } else {
            for value in cacheWords.values {
                if value.word.lowercased() == word.word.lowercased() {
                    throw DataBaseError.duplicated
                }
            }
            cacheWords[word.identity] = word
            await MainActor.run {
                updatePulbisher.send(.add)
            }
        }
        
        
    }
    
    public func deleteWord(identity: String) async throws {
        
        cacheWords.removeValue(forKey: identity)
        
        await MainActor.run {
            updatePulbisher.send(.delete(identity: identity))
        }
    }
    
    public func editWord(word: AppEntity.WordMemory) async throws {
        if let existed = cacheWords[word.identity] {
            if existed.word != word.word {
                for value in cacheWords.values {
                    if value.word == word.word {
                        throw DataBaseError.duplicated
                    }
                }
            }
        }
        
        cacheWords[word.identity] = word
        
        await MainActor.run {
            updatePulbisher.send(.update(identity: word.identity))
        }
    }
    
    public func fetchWord(identity: String) async throws -> AppEntity.WordMemory? {
        return cacheWords[identity]
    }
    
    public func fetchWordList(filter: SearchWordFilter) async throws -> [AppEntity.WordMemory] {
        
        var nameFilter: String? = nil
        var tagFilters: [String] = []
        var andIncludeNoTag: Bool = false
        switch filter.nameFilter {
        case .contain(let name):
            nameFilter = name
        case .all:
            nameFilter = nil
        }
        
        switch filter.tagFilter {
        case .contain(let tags, let includeNoTag):
            tagFilters = tags.map(\.identity)
            andIncludeNoTag = includeNoTag
        case .all:
            print("all")
//            tagFilters = cacheTags.values.map(\.identity)
            // 밑에서
        }
        
        let words = cacheWords.values.filter { word in
            var nameBool: Bool
            var tagBool: Bool
            
            if let nameFilter = nameFilter {
                nameBool = word.word.lowercased().contains(nameFilter.lowercased()) || word.meaning.lowercased().contains(nameFilter.lowercased())
            } else {
                nameBool = true
            }
            
            let tagFilterBool = word.tags.map(\.identity).contains { tagId in
                tagFilters.contains(tagId)
            }
            
            if filter.tagFilter == .all {
                tagBool = true
            } else {
                if andIncludeNoTag {
                    tagBool = tagFilterBool || word.tags.isEmpty
                } else {
                    tagBool = tagFilterBool
                }
            }
            
            return nameBool && tagBool
        }
        
        return words.sorted { w1, w2 in
            switch filter.sortType {
            case .nameDescending(let descending):
                if descending {
                    return w1.word > w2.word
                } else {
                    return w1.word < w2.word
                }
                
            case .createAtDescending(let descending):
                if descending {
                    return w1.createAt > w2.createAt
                } else {
                    return w1.createAt < w2.createAt
                }
            case .correctCountDescending(let descending):
                if descending {
                    return w1.correctCount > w2.correctCount
                } else {
                    return w1.correctCount < w2.correctCount
                }
            }
        }
        
    }
    
    public func fetchReviewList(filter: ReviewWordFilter) async throws -> [AppEntity.WordMemory] {
        [
            //            WordMemory(identity: randomeText(),
            //                    word: "expect",
            //                    meaning: "기대하다",
            //                    createAt: .now),
            //            WordMemory(identity: randomeText(),
            //                    word: "appearently",
            //                    meaning: "듣기로는",
            //                    createAt: .now),
            WordMemory(identity: randomeText(),
                       word: "be used to ",
                       meaning: "-에 익숙하다",
                       createAt: .now),
            
            WordMemory(identity: randomeText(),
                       word: "헌법재판소",
                       meaning: "constitutional court",
                       createAt: .now),
            
            WordMemory(identity: randomeText(),
                       word: "こんにちは ",
                       meaning: "안녕하세요.",
                       createAt: .now),
            
            WordMemory(identity: randomeText(),
                       word: "いぬ",
                       meaning: "dog",
                       createAt: .now),
            
            WordMemory(identity: randomeText(),
                       word: "used to",
                       meaning: "-에 하곤했었다",
                       createAt: .now),
            WordMemory(identity: randomeText(),
                       word: "be looking forward to",
                       meaning: "-를 기대한다",
                       createAt: .now),
            WordMemory(identity: randomeText(),
                       word: "apparently",
                       meaning: "듣기로는..",
                       createAt: .now),
            WordMemory(identity: randomeText(),
                       word: "appearently",
                       meaning: "듣기로는..",
                       createAt: .now),
            
        ]
    }
    
    public func addTag(tag: AppEntity.WordTag) async throws {
        if cacheTags[tag.identity] != nil {
            throw DataBaseError.duplicated
        } else {
            cacheTags[tag.identity] = tag
            await MainActor.run {
                updatePulbisher.send(.add)
            }
        }
    }
    
    public func deleteTag(identity: String) async throws {
        cacheTags.removeValue(forKey: identity)
        await MainActor.run {
            updatePulbisher.send(.delete(identity: identity))
        }
    }
    
    public func editTag(tag: WordTag) async throws {
        if var cachedTag = cacheTags[tag.identity] {
            cachedTag.name = tag.name
            cacheTags[tag.identity] = cachedTag
            await MainActor.run {
                updatePulbisher.send(.update(identity: tag.identity))
            }
        }
    }
    
    public func fetchAllTags() async throws -> [AppEntity.WordTag] {
        return cacheTags.map { $0.value }
    }
    
    
    public func fetchRecommendWords(languageType: SearchLangagueType,
                             explanationLanguageType: SearchLangagueType,
                                    levelType: LanguageLevelType) async throws -> [WordRecommendMemory]? {
        
        
        [.init(index: 0, identity: UUID().uuidString,
               word: "love", meaning: "사랑해", createAt: .now, languageType: languageType, levelType: levelType, explanationLanguageType: explanationLanguageType)]
    }
    
    public func saveRecommendWords(words: [WordRecommendMemory]) async throws {
        
    }
}


public func randomeText(minLength: Int = 5, maxLength: Int? = 10, characterSet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {
    // 최소 길이가 1 이상인지 확인
    let min = max(minLength, 1)
    
    // 최대 길이가 최소 길이보다 큰지 확인
    let max: Int
    if let maxLength = maxLength, maxLength >= min {
        max = maxLength
    } else {
        max = min
    }
    
    // 문자열의 최종 길이 결정
    let length = max == min ? min : Int.random(in: min...max)
    
    // 랜덤 문자열 생성
    let randomString = String((0..<length).compactMap { _ in characterSet.randomElement() })
    
    return randomString
}


extension MockInMemoryDatabase: AccountManagerProtocol {
    public func setupAccount() async throws {
        
    }
    
    public func account() async throws -> AppEntity.AccountSetting {
        return AccountSetting(identity: UUID().uuidString, chatGPTChances: 100, ttsChances: 10, lastUpdated: .now, usedCouponList: [])
    }
    
    public func updateAccount(_ account: AppEntity.AccountSetting) async throws {
        
    }
    
    public func useCoupon(_ coupon: String) async throws {
        
    }
    
    
}
