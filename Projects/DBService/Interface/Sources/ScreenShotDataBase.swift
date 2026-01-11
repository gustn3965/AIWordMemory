//
//  ScreenShotDataBase.swift
//  DBImplementation
//
//  Created by 박현수 on 2025.
//

import Foundation
import AppEntity
import Combine
import AccountInterface
import DBInterface

// MARK: - 한국어 사용자가 영어 단어를 학습하는 데이터베이스
@globalActor public actor ScreenShotKoreaDataBase: DataBaseProtocol {

    public static let shared: ScreenShotKoreaDataBase = ScreenShotKoreaDataBase()

    public init() {}

    private var cacheWords: [String: AppEntity.WordMemory] = [:]
    private var cacheTags: [String: AppEntity.WordTag] = [:]

    public func setup(includeDefaultData: Bool) {
        guard includeDefaultData else { return }

        // 태그 설정
        let tagVerb = WordTag(identity: UUID().uuidString, name: "동사")
        let tagNoun = WordTag(identity: UUID().uuidString, name: "명사")
        let tagAdjective = WordTag(identity: UUID().uuidString, name: "형용사")
        let tagTOEIC = WordTag(identity: UUID().uuidString, name: "TOEIC")
        let tagDaily = WordTag(identity: UUID().uuidString, name: "일상회화")

        let tags = [tagVerb, tagNoun, tagAdjective, tagTOEIC, tagDaily]
        tags.forEach { cacheTags[$0.identity] = $0 }

        // 예문 생성 함수
        func makeSentences(word: String, wordIdentity: String) -> [WordMemorySentence] {
            [
                WordMemorySentence(
                    identity: UUID().uuidString,
                    example: "This is an example sentence with \(word).",
                    translation: "이것은 \(word)를 사용한 예문입니다.",
                    usedWordInExample: word,
                    usedWordInTranslation: word,
                    exampleIdentity: UUID().uuidString,
                    translationIdentity: UUID().uuidString,
                    wordMemoryIdentity: wordIdentity
                )
            ]
        }

        // 한국어 사용자가 영어 단어 학습 (영어 단어 -> 한국어 뜻)
        let words: [WordMemory] = [
            WordMemory(identity: "serendipity",
                       word: "Serendipity",
                       meaning: "우연한 행운",
                       createAt: Date(),
                       correctCount: 15,
                       tags: [tagNoun],
                       sentences: makeSentences(word: "serendipity", wordIdentity: "serendipity")),

            WordMemory(identity: "ephemeral",
                       word: "Ephemeral",
                       meaning: "순간적인, 덧없는",
                       createAt: Date(),
                       correctCount: 8,
                       tags: [tagAdjective],
                       sentences: makeSentences(word: "ephemeral", wordIdentity: "ephemeral")),

            WordMemory(identity: "eloquent",
                       word: "Eloquent",
                       meaning: "유창한, 설득력 있는",
                       createAt: Date(),
                       correctCount: 12,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: makeSentences(word: "eloquent", wordIdentity: "eloquent")),

            WordMemory(identity: "ubiquitous",
                       word: "Ubiquitous",
                       meaning: "어디에나 있는",
                       createAt: Date(),
                       correctCount: 5,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: makeSentences(word: "ubiquitous", wordIdentity: "ubiquitous")),

            WordMemory(identity: "resilience",
                       word: "Resilience",
                       meaning: "회복력, 탄력성",
                       createAt: Date(),
                       correctCount: 20,
                       tags: [tagNoun, tagTOEIC],
                       sentences: makeSentences(word: "resilience", wordIdentity: "resilience")),

            WordMemory(identity: "procrastinate",
                       word: "Procrastinate",
                       meaning: "미루다, 지연하다",
                       createAt: Date(),
                       correctCount: 3,
                       tags: [tagVerb],
                       sentences: makeSentences(word: "procrastinate", wordIdentity: "procrastinate")),

            WordMemory(identity: "inevitable",
                       word: "Inevitable",
                       meaning: "피할 수 없는, 필연적인",
                       createAt: Date(),
                       correctCount: 18,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: makeSentences(word: "inevitable", wordIdentity: "inevitable")),

            WordMemory(identity: "meticulous",
                       word: "Meticulous",
                       meaning: "꼼꼼한, 세심한",
                       createAt: Date(),
                       correctCount: 7,
                       tags: [tagAdjective],
                       sentences: makeSentences(word: "meticulous", wordIdentity: "meticulous")),

            WordMemory(identity: "ambiguous",
                       word: "Ambiguous",
                       meaning: "모호한, 애매한",
                       createAt: Date(),
                       correctCount: 11,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: makeSentences(word: "ambiguous", wordIdentity: "ambiguous")),

            WordMemory(identity: "accomplish",
                       word: "Accomplish",
                       meaning: "성취하다, 달성하다",
                       createAt: Date(),
                       correctCount: 25,
                       tags: [tagVerb, tagDaily],
                       sentences: makeSentences(word: "accomplish", wordIdentity: "accomplish")),
        ]

        words.forEach { cacheWords[$0.identity] = $0 }
    }

    nonisolated(unsafe) public var updatePulbisher: PassthroughSubject<DataBaseUpdateType, Never> = PassthroughSubject()

    public func isWordEmpty() async throws -> Bool {
        cacheWords.isEmpty
    }

    public func addWord(word: AppEntity.WordMemory) async throws {
        if cacheWords[word.identity] != nil {
            throw DataBaseError.duplicated
        }
        cacheWords[word.identity] = word
        await MainActor.run { updatePulbisher.send(.add) }
    }

    public func deleteWord(identity: String) async throws {
        cacheWords.removeValue(forKey: identity)
        await MainActor.run { updatePulbisher.send(.delete(identity: identity)) }
    }

    public func editWord(word: AppEntity.WordMemory) async throws {
        cacheWords[word.identity] = word
        await MainActor.run { updatePulbisher.send(.update(identity: word.identity)) }
    }

    public func fetchWord(identity: String) async throws -> AppEntity.WordMemory? {
        cacheWords[identity]
    }

    public func fetchWordList(filter: SearchWordFilter) async throws -> [AppEntity.WordMemory] {
        Array(cacheWords.values).sorted { $0.correctCount > $1.correctCount }
    }

    public func fetchReviewList(filter: ReviewWordFilter) async throws -> [AppEntity.WordMemory] {
        Array(cacheWords.values.prefix(5))
    }

    public func addTag(tag: AppEntity.WordTag) async throws {
        cacheTags[tag.identity] = tag
        await MainActor.run { updatePulbisher.send(.add) }
    }

    public func deleteTag(identity: String) async throws {
        cacheTags.removeValue(forKey: identity)
        await MainActor.run { updatePulbisher.send(.delete(identity: identity)) }
    }

    public func editTag(tag: WordTag) async throws {
        cacheTags[tag.identity] = tag
        await MainActor.run { updatePulbisher.send(.update(identity: tag.identity)) }
    }

    public func fetchAllTags() async throws -> [AppEntity.WordTag] {
        Array(cacheTags.values)
    }

    public func fetchRecommendWords(languageType: SearchLangagueType,
                                    explanationLanguageType: SearchLangagueType,
                                    levelType: LanguageLevelType) async throws -> [WordRecommendMemory]? {
        nil
    }

    public func saveRecommendWords(words: [WordRecommendMemory]) async throws {}
}

extension ScreenShotKoreaDataBase: AccountManagerProtocol {
    public func setupAccount() async throws {}

    public func account() async throws -> AppEntity.AccountSetting {
        AccountSetting(identity: UUID().uuidString, chatGPTChances: 50, ttsChances: 30, lastUpdated: .now, usedCouponList: [])
    }

    public func updateAccount(_ account: AppEntity.AccountSetting) async throws {}
    public func useCoupon(_ coupon: String) async throws {}
}


// MARK: - 영어 사용자가 한국어 단어를 학습하는 데이터베이스
@globalActor public actor ScreenShotEnglishDataBase: DataBaseProtocol {

    public static let shared: ScreenShotEnglishDataBase = ScreenShotEnglishDataBase()

    public init() {}

    private var cacheWords: [String: AppEntity.WordMemory] = [:]
    private var cacheTags: [String: AppEntity.WordTag] = [:]

    public func setup(includeDefaultData: Bool) {
        guard includeDefaultData else { return }

        // 태그 설정 (영어)
        let tagVerb = WordTag(identity: UUID().uuidString, name: "Verb")
        let tagNoun = WordTag(identity: UUID().uuidString, name: "Noun")
        let tagAdjective = WordTag(identity: UUID().uuidString, name: "Adjective")
        let tagTOPIK = WordTag(identity: UUID().uuidString, name: "TOPIK")
        let tagDaily = WordTag(identity: UUID().uuidString, name: "Daily")

        let tags = [tagVerb, tagNoun, tagAdjective, tagTOPIK, tagDaily]
        tags.forEach { cacheTags[$0.identity] = $0 }

        // 예문 생성 함수
        func makeSentences(word: String, wordIdentity: String) -> [WordMemorySentence] {
            [
                WordMemorySentence(
                    identity: UUID().uuidString,
                    example: "\(word)를 사용한 예문입니다.",
                    translation: "This is an example sentence using \(word).",
                    usedWordInExample: word,
                    usedWordInTranslation: word,
                    exampleIdentity: UUID().uuidString,
                    translationIdentity: UUID().uuidString,
                    wordMemoryIdentity: wordIdentity
                )
            ]
        }

        // 영어 사용자가 한국어 단어 학습 (한국어 단어 -> 영어 뜻)
        let words: [WordMemory] = [
            WordMemory(identity: "사랑",
                       word: "사랑",
                       meaning: "Love",
                       createAt: Date(),
                       correctCount: 20,
                       tags: [tagNoun, tagDaily],
                       sentences: makeSentences(word: "사랑", wordIdentity: "사랑")),

            WordMemory(identity: "행복",
                       word: "행복",
                       meaning: "Happiness",
                       createAt: Date(),
                       correctCount: 18,
                       tags: [tagNoun, tagDaily],
                       sentences: makeSentences(word: "행복", wordIdentity: "행복")),

            WordMemory(identity: "감사합니다",
                       word: "감사합니다",
                       meaning: "Thank you",
                       createAt: Date(),
                       correctCount: 25,
                       tags: [tagDaily],
                       sentences: makeSentences(word: "감사합니다", wordIdentity: "감사합니다")),

            WordMemory(identity: "미안합니다",
                       word: "미안합니다",
                       meaning: "I'm sorry",
                       createAt: Date(),
                       correctCount: 15,
                       tags: [tagDaily],
                       sentences: makeSentences(word: "미안합니다", wordIdentity: "미안합니다")),

            WordMemory(identity: "아름답다",
                       word: "아름답다",
                       meaning: "Beautiful",
                       createAt: Date(),
                       correctCount: 12,
                       tags: [tagAdjective, tagTOPIK],
                       sentences: makeSentences(word: "아름답다", wordIdentity: "아름답다")),

            WordMemory(identity: "기억하다",
                       word: "기억하다",
                       meaning: "To remember",
                       createAt: Date(),
                       correctCount: 8,
                       tags: [tagVerb, tagTOPIK],
                       sentences: makeSentences(word: "기억하다", wordIdentity: "기억하다")),

            WordMemory(identity: "꿈",
                       word: "꿈",
                       meaning: "Dream",
                       createAt: Date(),
                       correctCount: 10,
                       tags: [tagNoun],
                       sentences: makeSentences(word: "꿈", wordIdentity: "꿈")),

            WordMemory(identity: "희망",
                       word: "희망",
                       meaning: "Hope",
                       createAt: Date(),
                       correctCount: 14,
                       tags: [tagNoun, tagTOPIK],
                       sentences: makeSentences(word: "희망", wordIdentity: "희망")),

            WordMemory(identity: "노력하다",
                       word: "노력하다",
                       meaning: "To make an effort",
                       createAt: Date(),
                       correctCount: 7,
                       tags: [tagVerb, tagTOPIK],
                       sentences: makeSentences(word: "노력하다", wordIdentity: "노력하다")),

            WordMemory(identity: "설레다",
                       word: "설레다",
                       meaning: "To feel excited, flutter",
                       createAt: Date(),
                       correctCount: 5,
                       tags: [tagVerb],
                       sentences: makeSentences(word: "설레다", wordIdentity: "설레다")),
        ]

        words.forEach { cacheWords[$0.identity] = $0 }
    }

    nonisolated(unsafe) public var updatePulbisher: PassthroughSubject<DataBaseUpdateType, Never> = PassthroughSubject()

    public func isWordEmpty() async throws -> Bool {
        cacheWords.isEmpty
    }

    public func addWord(word: AppEntity.WordMemory) async throws {
        if cacheWords[word.identity] != nil {
            throw DataBaseError.duplicated
        }
        cacheWords[word.identity] = word
        await MainActor.run { updatePulbisher.send(.add) }
    }

    public func deleteWord(identity: String) async throws {
        cacheWords.removeValue(forKey: identity)
        await MainActor.run { updatePulbisher.send(.delete(identity: identity)) }
    }

    public func editWord(word: AppEntity.WordMemory) async throws {
        cacheWords[word.identity] = word
        await MainActor.run { updatePulbisher.send(.update(identity: word.identity)) }
    }

    public func fetchWord(identity: String) async throws -> AppEntity.WordMemory? {
        cacheWords[identity]
    }

    public func fetchWordList(filter: SearchWordFilter) async throws -> [AppEntity.WordMemory] {
        Array(cacheWords.values).sorted { $0.correctCount > $1.correctCount }
    }

    public func fetchReviewList(filter: ReviewWordFilter) async throws -> [AppEntity.WordMemory] {
        Array(cacheWords.values.prefix(5))
    }

    public func addTag(tag: AppEntity.WordTag) async throws {
        cacheTags[tag.identity] = tag
        await MainActor.run { updatePulbisher.send(.add) }
    }

    public func deleteTag(identity: String) async throws {
        cacheTags.removeValue(forKey: identity)
        await MainActor.run { updatePulbisher.send(.delete(identity: identity)) }
    }

    public func editTag(tag: WordTag) async throws {
        cacheTags[tag.identity] = tag
        await MainActor.run { updatePulbisher.send(.update(identity: tag.identity)) }
    }

    public func fetchAllTags() async throws -> [AppEntity.WordTag] {
        Array(cacheTags.values)
    }

    public func fetchRecommendWords(languageType: SearchLangagueType,
                                    explanationLanguageType: SearchLangagueType,
                                    levelType: LanguageLevelType) async throws -> [WordRecommendMemory]? {
        nil
    }

    public func saveRecommendWords(words: [WordRecommendMemory]) async throws {}
}

extension ScreenShotEnglishDataBase: AccountManagerProtocol {
    public func setupAccount() async throws {}

    public func account() async throws -> AppEntity.AccountSetting {
        AccountSetting(identity: UUID().uuidString, chatGPTChances: 50, ttsChances: 30, lastUpdated: .now, usedCouponList: [])
    }

    public func updateAccount(_ account: AppEntity.AccountSetting) async throws {}
    public func useCoupon(_ coupon: String) async throws {}
}
