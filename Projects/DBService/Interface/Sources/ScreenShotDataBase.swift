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

        // 한국어 사용자가 영어 단어 학습 (영어 단어 -> 한국어 뜻)
        let words: [WordMemory] = [
            WordMemory(identity: "serendipity",
                       word: "Serendipity",
                       meaning: "우연한 행운",
                       createAt: Date(),
                       correctCount: 15,
                       tags: [tagNoun],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Finding that rare book was pure serendipity.",
                                              translation: "그 희귀한 책을 발견한 것은 순전히 우연한 행운이었다.",
                                              usedWordInExample: "serendipity", usedWordInTranslation: "우연한 행운",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "serendipity"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Their meeting was a moment of serendipity.",
                                              translation: "그들의 만남은 우연한 행운의 순간이었다.",
                                              usedWordInExample: "serendipity", usedWordInTranslation: "우연한 행운",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "serendipity")
                       ]),

            WordMemory(identity: "ephemeral",
                       word: "Ephemeral",
                       meaning: "순간적인, 덧없는",
                       createAt: Date(),
                       correctCount: 8,
                       tags: [tagAdjective],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Fame can be ephemeral in the entertainment industry.",
                                              translation: "연예계에서 명성은 덧없을 수 있다.",
                                              usedWordInExample: "ephemeral", usedWordInTranslation: "덧없는",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ephemeral"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Cherry blossoms are beautiful but ephemeral.",
                                              translation: "벚꽃은 아름답지만 순간적이다.",
                                              usedWordInExample: "ephemeral", usedWordInTranslation: "순간적인",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ephemeral")
                       ]),

            WordMemory(identity: "eloquent",
                       word: "Eloquent",
                       meaning: "유창한, 설득력 있는",
                       createAt: Date(),
                       correctCount: 12,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "She gave an eloquent speech at the conference.",
                                              translation: "그녀는 회의에서 유창한 연설을 했다.",
                                              usedWordInExample: "eloquent", usedWordInTranslation: "유창한",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "eloquent"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "His eloquent argument convinced everyone.",
                                              translation: "그의 설득력 있는 주장이 모두를 납득시켰다.",
                                              usedWordInExample: "eloquent", usedWordInTranslation: "설득력 있는",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "eloquent")
                       ]),

            WordMemory(identity: "ubiquitous",
                       word: "Ubiquitous",
                       meaning: "어디에나 있는",
                       createAt: Date(),
                       correctCount: 5,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Smartphones have become ubiquitous in modern society.",
                                              translation: "스마트폰은 현대 사회에서 어디에나 있게 되었다.",
                                              usedWordInExample: "ubiquitous", usedWordInTranslation: "어디에나 있는",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ubiquitous"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Coffee shops are ubiquitous in this city.",
                                              translation: "이 도시에는 커피숍이 어디에나 있다.",
                                              usedWordInExample: "ubiquitous", usedWordInTranslation: "어디에나 있는",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ubiquitous")
                       ]),

            WordMemory(identity: "resilience",
                       word: "Resilience",
                       meaning: "회복력, 탄력성",
                       createAt: Date(),
                       correctCount: 20,
                       tags: [tagNoun, tagTOEIC],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Her resilience helped her overcome many challenges.",
                                              translation: "그녀의 회복력이 많은 어려움을 극복하는 데 도움이 되었다.",
                                              usedWordInExample: "resilience", usedWordInTranslation: "회복력",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "resilience"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "The team showed great resilience after the defeat.",
                                              translation: "팀은 패배 후 큰 회복력을 보여주었다.",
                                              usedWordInExample: "resilience", usedWordInTranslation: "회복력",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "resilience")
                       ]),

            WordMemory(identity: "procrastinate",
                       word: "Procrastinate",
                       meaning: "미루다, 지연하다",
                       createAt: Date(),
                       correctCount: 3,
                       tags: [tagVerb],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Don't procrastinate on your homework.",
                                              translation: "숙제를 미루지 마라.",
                                              usedWordInExample: "procrastinate", usedWordInTranslation: "미루다",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "procrastinate"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "I tend to procrastinate when I'm stressed.",
                                              translation: "나는 스트레스를 받으면 일을 미루는 경향이 있다.",
                                              usedWordInExample: "procrastinate", usedWordInTranslation: "미루다",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "procrastinate")
                       ]),

            WordMemory(identity: "inevitable",
                       word: "Inevitable",
                       meaning: "피할 수 없는, 필연적인",
                       createAt: Date(),
                       correctCount: 18,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "Change is inevitable in life.",
                                              translation: "인생에서 변화는 피할 수 없다.",
                                              usedWordInExample: "inevitable", usedWordInTranslation: "피할 수 없는",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "inevitable"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "The outcome was inevitable from the start.",
                                              translation: "그 결과는 처음부터 필연적이었다.",
                                              usedWordInExample: "inevitable", usedWordInTranslation: "필연적인",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "inevitable")
                       ]),

            WordMemory(identity: "meticulous",
                       word: "Meticulous",
                       meaning: "꼼꼼한, 세심한",
                       createAt: Date(),
                       correctCount: 7,
                       tags: [tagAdjective],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "She is meticulous about her work.",
                                              translation: "그녀는 일에 대해 꼼꼼하다.",
                                              usedWordInExample: "meticulous", usedWordInTranslation: "꼼꼼한",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "meticulous"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "The detective made a meticulous investigation.",
                                              translation: "형사는 세심한 조사를 했다.",
                                              usedWordInExample: "meticulous", usedWordInTranslation: "세심한",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "meticulous")
                       ]),

            WordMemory(identity: "ambiguous",
                       word: "Ambiguous",
                       meaning: "모호한, 애매한",
                       createAt: Date(),
                       correctCount: 11,
                       tags: [tagAdjective, tagTOEIC],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "His answer was ambiguous and confusing.",
                                              translation: "그의 대답은 모호하고 혼란스러웠다.",
                                              usedWordInExample: "ambiguous", usedWordInTranslation: "모호한",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ambiguous"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "The contract had some ambiguous terms.",
                                              translation: "계약서에는 몇 가지 애매한 조항이 있었다.",
                                              usedWordInExample: "ambiguous", usedWordInTranslation: "애매한",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "ambiguous")
                       ]),

            WordMemory(identity: "accomplish",
                       word: "Accomplish",
                       meaning: "성취하다, 달성하다",
                       createAt: Date(),
                       correctCount: 25,
                       tags: [tagVerb, tagDaily],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "She accomplished her goal of running a marathon.",
                                              translation: "그녀는 마라톤을 완주하는 목표를 달성했다.",
                                              usedWordInExample: "accomplished", usedWordInTranslation: "달성했다",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "accomplish"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "What do you want to accomplish this year?",
                                              translation: "올해 무엇을 성취하고 싶으세요?",
                                              usedWordInExample: "accomplish", usedWordInTranslation: "성취하다",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "accomplish")
                       ]),
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

        // 영어 사용자가 한국어 단어 학습 (한국어 단어 -> 영어 뜻)
        let words: [WordMemory] = [
            WordMemory(identity: "사랑",
                       word: "사랑",
                       meaning: "Love",
                       createAt: Date(),
                       correctCount: 20,
                       tags: [tagNoun, tagDaily],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "나는 너를 사랑해.",
                                              translation: "I love you.",
                                              usedWordInExample: "사랑", usedWordInTranslation: "love",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "사랑"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "사랑은 아름다운 감정이에요.",
                                              translation: "Love is a beautiful emotion.",
                                              usedWordInExample: "사랑", usedWordInTranslation: "Love",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "사랑")
                       ]),

            WordMemory(identity: "행복",
                       word: "행복",
                       meaning: "Happiness",
                       createAt: Date(),
                       correctCount: 18,
                       tags: [tagNoun, tagDaily],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "행복은 마음에서 옵니다.",
                                              translation: "Happiness comes from the heart.",
                                              usedWordInExample: "행복", usedWordInTranslation: "Happiness",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "행복"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "저는 지금 너무 행복해요.",
                                              translation: "I am so happy right now.",
                                              usedWordInExample: "행복", usedWordInTranslation: "happy",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "행복")
                       ]),

            WordMemory(identity: "감사합니다",
                       word: "감사합니다",
                       meaning: "Thank you",
                       createAt: Date(),
                       correctCount: 25,
                       tags: [tagDaily],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "도와주셔서 감사합니다.",
                                              translation: "Thank you for helping me.",
                                              usedWordInExample: "감사합니다", usedWordInTranslation: "Thank you",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "감사합니다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "선물 감사합니다!",
                                              translation: "Thank you for the gift!",
                                              usedWordInExample: "감사합니다", usedWordInTranslation: "Thank you",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "감사합니다")
                       ]),

            WordMemory(identity: "미안합니다",
                       word: "미안합니다",
                       meaning: "I'm sorry",
                       createAt: Date(),
                       correctCount: 15,
                       tags: [tagDaily],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "늦어서 미안합니다.",
                                              translation: "I'm sorry for being late.",
                                              usedWordInExample: "미안합니다", usedWordInTranslation: "sorry",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "미안합니다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "정말 미안합니다, 제 실수예요.",
                                              translation: "I'm really sorry, it's my mistake.",
                                              usedWordInExample: "미안합니다", usedWordInTranslation: "sorry",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "미안합니다")
                       ]),

            WordMemory(identity: "아름답다",
                       word: "아름답다",
                       meaning: "Beautiful",
                       createAt: Date(),
                       correctCount: 12,
                       tags: [tagAdjective, tagTOPIK],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "오늘 노을이 정말 아름답다.",
                                              translation: "The sunset is really beautiful today.",
                                              usedWordInExample: "아름답다", usedWordInTranslation: "beautiful",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "아름답다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "한국의 자연은 아름답습니다.",
                                              translation: "Korea's nature is beautiful.",
                                              usedWordInExample: "아름답다", usedWordInTranslation: "beautiful",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "아름답다")
                       ]),

            WordMemory(identity: "기억하다",
                       word: "기억하다",
                       meaning: "To remember",
                       createAt: Date(),
                       correctCount: 8,
                       tags: [tagVerb, tagTOPIK],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "저는 그 날을 항상 기억해요.",
                                              translation: "I always remember that day.",
                                              usedWordInExample: "기억하다", usedWordInTranslation: "remember",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "기억하다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "이 단어를 기억하세요.",
                                              translation: "Please remember this word.",
                                              usedWordInExample: "기억하다", usedWordInTranslation: "remember",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "기억하다")
                       ]),

            WordMemory(identity: "꿈",
                       word: "꿈",
                       meaning: "Dream",
                       createAt: Date(),
                       correctCount: 10,
                       tags: [tagNoun],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "제 꿈은 의사가 되는 거예요.",
                                              translation: "My dream is to become a doctor.",
                                              usedWordInExample: "꿈", usedWordInTranslation: "dream",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "꿈"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "어젯밤에 이상한 꿈을 꿨어요.",
                                              translation: "I had a strange dream last night.",
                                              usedWordInExample: "꿈", usedWordInTranslation: "dream",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "꿈")
                       ]),

            WordMemory(identity: "희망",
                       word: "희망",
                       meaning: "Hope",
                       createAt: Date(),
                       correctCount: 14,
                       tags: [tagNoun, tagTOPIK],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "희망을 잃지 마세요.",
                                              translation: "Don't lose hope.",
                                              usedWordInExample: "희망", usedWordInTranslation: "hope",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "희망"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "그는 우리에게 희망을 주었어요.",
                                              translation: "He gave us hope.",
                                              usedWordInExample: "희망", usedWordInTranslation: "hope",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "희망")
                       ]),

            WordMemory(identity: "노력하다",
                       word: "노력하다",
                       meaning: "To make an effort",
                       createAt: Date(),
                       correctCount: 7,
                       tags: [tagVerb, tagTOPIK],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "저는 매일 한국어를 공부하려고 노력해요.",
                                              translation: "I try to study Korean every day.",
                                              usedWordInExample: "노력하다", usedWordInTranslation: "try",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "노력하다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "성공하려면 노력해야 합니다.",
                                              translation: "You have to make an effort to succeed.",
                                              usedWordInExample: "노력하다", usedWordInTranslation: "make an effort",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "노력하다")
                       ]),

            WordMemory(identity: "설레다",
                       word: "설레다",
                       meaning: "To feel excited, flutter",
                       createAt: Date(),
                       correctCount: 5,
                       tags: [tagVerb],
                       sentences: [
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "첫 데이트라서 설레요.",
                                              translation: "I'm excited because it's my first date.",
                                              usedWordInExample: "설레다", usedWordInTranslation: "excited",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "설레다"),
                           WordMemorySentence(identity: UUID().uuidString,
                                              example: "새로운 시작에 마음이 설렙니다.",
                                              translation: "My heart flutters at this new beginning.",
                                              usedWordInExample: "설레다", usedWordInTranslation: "flutters",
                                              exampleIdentity: UUID().uuidString, translationIdentity: UUID().uuidString,
                                              wordMemoryIdentity: "설레다")
                       ]),
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
