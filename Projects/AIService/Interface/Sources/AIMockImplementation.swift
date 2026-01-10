//
//  AIMockImplementation.swift
//  AIInterface
//
//  Created by 박현수 on 2/11/25.
//

import Foundation
import AppEntity
import AccountInterface



public actor AIMockImplementation: AIInterface {
    
    public init() { }
    
    public var accountManager:  AccountManagerProtocol? = AccountManagerMock(account: AccountSetting(identity: UUID().uuidString,
                                                                                                     chatGPTChances: 10,
                                                                                                     ttsChances: 10,
                                                                                                     lastUpdated: .now,
                                                                                                     usedCouponList: []))
    public func setAccountManager(accountManager: AccountManagerProtocol) async  {
        self.accountManager = accountManager
    }
    
    public func fetchAIExample(word: AppEntity.WordMemory, sentenceType: AISentenceType) async throws -> [AppEntity.WordMemorySentence] {
        
        let account = try await accountManager?.account()
        if let account = account, account.chatGPTChances <= 0 {
            throw AccountError.chanceExpired
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        if word.word == "used to" {
            return AIFetchSentenceResponse(examples: [
                AIFetchSentenceResponse.AIExample(example: "She used to play the piano every evening.",
                          translation: "그녀는 매일 저녁 피아노를 연주하곤 했었다.",
                          usedWordInExample: "used to",
                          usedWordInTranslation: "기대했다"),
                AIFetchSentenceResponse.AIExample(example: "They didn't use to go to the gym regularly.",
                          translation: "그들은 정기적으로 체육관에 가곤 하지 않았다.",
                          usedWordInExample: "use to",
                          usedWordInTranslation: "하곤 하지 않았다"),
                AIFetchSentenceResponse.AIExample(example: "Did you use to live in New York?",
                          translation: "당신은 뉴욕에 살곤 했었나요?",
                          usedWordInExample: "use to",
                          usedWordInTranslation: "하곤 했었나요")
            ]).examples.map { $0.makeWordMeorySentence(wordMemoryIdentity: word.identity)}
        } else if word.word == "be used to "{
            return AIFetchSentenceResponse(examples: [
                AIFetchSentenceResponse.AIExample(example: "She is used to waking up early every day.",
                          translation: "그녀는 매일 아침 일찍 일어나는 것에 익숙하다.",
                          usedWordInExample: "is used to",
                          usedWordInTranslation: "기대했다"),
                AIFetchSentenceResponse.AIExample(example: "I wasn't used to the cold weather when I first moved here.",
                          translation: "나는 처음 여기에 이사 왔을 때 추운 날씨에 익숙하지 않았다.",
                          usedWordInExample: "wasn't used to",
                          usedWordInTranslation: "에 익숙하지 않았다"),
                AIFetchSentenceResponse.AIExample(example: "They will be used to the new software soon.",
                          translation: "그들은 곧 새로운 소프트웨어에 익숙해질 것이다.",
                          usedWordInExample: "will be used to",
                          usedWordInTranslation: "익숙해질 것이다")
            ]).examples.map { $0.makeWordMeorySentence(wordMemoryIdentity: word.identity)}
        }
        return AIFetchSentenceResponse(examples: [
            AIFetchSentenceResponse.AIExample(example: "She expected to receive a promotion by the end of the year.",
                      translation: "그녀는 올해 말까지 승진을 받을 것이라고 기대했다.",
                      usedWordInExample: "expected",
                      usedWordInTranslation: "기대했다"),
            AIFetchSentenceResponse.AIExample(example: "We are expecting a large crowd at the concert tonight.",
                      translation: "우리는 오늘 밤 콘서트에 많은 사람들이 올 것으로 기대하고 있다.",
                      usedWordInExample: "expecting",
                      usedWordInTranslation: "기대하고 있다"),
            AIFetchSentenceResponse.AIExample(example: "They expect the weather to improve by the weekend.",
                      translation: "그들은 주말까지 날씨가 좋아질 것이라고 기대하고 있다.",
                      usedWordInExample: "expect",
                      usedWordInTranslation: "기대하고 있다")
        ]).examples.map { $0.makeWordMeorySentence(wordMemoryIdentity: word.identity)}
    }
    
    public func search(_ word: String,
                       mainLanguageType: AISearchLanguageType,
                       searchLanguageType: AISearchLanguageType) async throws -> AISearchResponse {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
//        throw AIMockError.missingGPT
        return AISearchResponse(word: "as - as I expected", explanation: "期待通り、予想通りの結果や状況であることを表現します。", sentence: "She was as beautiful as I expected.", sentenceTranslation: "彼女は、私が期待していた通りに美しかった。", meaning: "予想通り、期待通り", searchType: .translate)
    }
    
    public func sentenceInspector(_ sentence: String,
                                  mainLanguageType: AISearchLanguageType) async throws -> AISentenceInspectorResponse {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        return AISentenceInspectorResponse(originSentence: "이 칭찬감옥은 뭐에요?",
                                           explantion: "The sentence \"이 칭찬감옥은 뭐에요?\" is an informal and somewhat playful expression in Korean. It translates to \"What is this praise prison?\" The phrase \"칭찬감옥\" (praise prison) is not a common or standard expression, which may cause confusion. However, it doesn't come off as rude or inappropriate. It might be perceived as humorous or sarcastic depending on the context.",
                                           correctSentence: "이 칭찬감옥은 뭐예요?\" (The only correction is to change \"뭐에요?\" to \"뭐예요?\" for correct spelling and formality.)")
    }
    
    
    public func fetchRecommendWord(_ exclude: [String],
                                   useCredit: Bool,
                                   targetLanguageType: AISearchLanguageType,
                                   languageLevelType: RecommendLanguageLevelType,
                                   explanationLanguageType: AISearchLanguageType) async throws -> AIRecommendWordResponse {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        switch targetLanguageType {
        case .english:
            return AIRecommendWordResponse(words: [.init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다"),
                                                   .init(word: "love", meaning: "사랑하다")])
        case .japanese:
            return AIRecommendWordResponse(words: [.init(word: "あなた", meaning: "나")])
        case .korean:
            return AIRecommendWordResponse(words: [.init(word: "사랑합니다", meaning: "love")])
        default:
            throw AIMockError.unknown
        }
        
    }

}


enum AIMockError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, message: String)
    case decodingError
    case parserErrorToAIInterface
    case unknown
    case missingGPT
    
    var errorDescription: String? {
        switch self {
        
        case .missingGPT:
            return "gpt 모델 초기화하지못했습니다."
        default:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}


extension AIFetchSentenceResponse.AIExample {
    public func makeWordMeorySentence(wordMemoryIdentity: String) -> AppEntity.WordMemorySentence {
        WordMemorySentence(identity: UUID().uuidString,
                           example: example,
                           translation: translation,
                           usedWordInExample: usedWordInExample,
                           usedWordInTranslation: usedWordInTranslation,
                           exampleIdentity: exampleIdentity,
                           translationIdentity: translationIdentity,
                           wordMemoryIdentity: wordMemoryIdentity)
            
    }
}
