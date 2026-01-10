

import Foundation
import AppEntity
import AccountInterface


public enum AISearchType: Sendable {
    case meaning    // apple 이뭐야 ? -> 사과
    case translate  // 사과가 뭐야 ? -> apple
}

public protocol AIInterface: Actor {
    
    var accountManager: AccountManagerProtocol? { get }
    func setAccountManager(accountManager: AccountManagerProtocol) async

    func fetchAIExample(word: AppEntity.WordMemory,
                        sentenceType: AISentenceType) async throws -> [AppEntity.WordMemorySentence]
    
    func search(_ word: String,
                mainLanguageType: AISearchLanguageType,
                searchLanguageType: AISearchLanguageType) async throws -> AISearchResponse
    
    func sentenceInspector(_ sentence: String,
                           mainLanguageType: AISearchLanguageType) async throws -> AISentenceInspectorResponse
    
    func fetchRecommendWord(_ exclude: [String],
                            useCredit: Bool,
                            targetLanguageType: AISearchLanguageType,
                            languageLevelType: RecommendLanguageLevelType,
                            explanationLanguageType: AISearchLanguageType) async throws -> AIRecommendWordResponse
    
}

public enum AISentenceType: Sendable {
    case conversation  // 대화형
    case description   // 작문형
}

public enum AISearchLanguageType: Sendable, CaseIterable {
    case english // : return "영어"
    case french // : return "프랑스어"
    case german //: return "독일어"
    case italian // : return "이탈리아어"
    case japanese // : return "일본어"
    case korean // : return "한국어"
    case portuguese // : return "포르투갈어"
    case russian // : return "러시아어"
    case simplifiedChinese // : return "중국어 간체"
    case spanish // : return "스페인어"
    case thai // : return "태국어"
    case traditionalChinese // : return "중국어 번체"
    case vietnamese // : return "베트남어"
    
    public var name: String {
        switch self {
        case .english: return "영어"
        case .french: return "프랑스어"
        case .german: return "독일어"
        case .italian: return "이탈리아어"
        case .japanese: return "일본어"
        case .korean: return "한국어"
        case .portuguese: return "포르투갈어"
        case .russian: return "러시아어"
        case .simplifiedChinese: return "중국어 간체"
        case .spanish: return "스페인어"
        case .thai: return "태국어"
        case .traditionalChinese: return "중국어 번체"
        case .vietnamese: return "베트남어"
        }
    }
    
}

extension SearchLangagueType {
    public var aiSearchType: AISearchLanguageType {
        switch self {
        case .english:
                .english
        case .french:
                .french
        case .german:
                .german
        case .italian:
                .italian
        case .japanese:
                .japanese
        case .korean:
                .korean
        case .portuguese:
                .portuguese
        case .russian:
                .russian
        case .simplifiedChinese:
                .simplifiedChinese
        case .spanish:
                .spanish
        case .thai:
                .thai
        case .traditionalChinese:
                .traditionalChinese
        case .vietnamese:
                .vietnamese
        }
    }
}


public enum RecommendLanguageLevelType: Sendable {
    
    public enum DetailLevelType: Sendable {
        case level1
        case level2
        case level3
        case level4
        case level5
        case level6 // 높은순
    }
    
    case CEFR(DetailLevelType)   // 영어
    case TOPIK(DetailLevelType)  // 한국어
    case JLPT(DetailLevelType)   // 일본어
    
    
    public var levelName: String {
        switch self {
        case .CEFR(let level):
            switch level {
            case .level1:
                return "CEFR A1 (가장 기초적인 단어)"
            case .level2:
                return "CEFR A2 (일상생활에 필요한 단어)"
            case .level3:
                return "CEFR B1 (일반적인 대화에서 자주 쓰이는 단어)"
            case .level4:
                return "CEFR B2 (뉴스, 토론 등에서 많이 쓰이는 단어)"
            case .level5:
                return "CEFR C1 (아카데믹, 직장, 문학 등에서 활용되는 단어)"
            case .level6:
                return "CEFR C2 (거의 모든 영어 표현을 포함)"    // 높은순
            }
        case .TOPIK(let level):
            switch level {
            case .level1:
                return "TOPIK 1 (일상적인 인사, 자기소개, 간단한 지시문)"
            case .level2:
                return "TOPIK 2 (간단한 일상 대화, 공공장소 안내문)"
            case .level3:
                return "TOPIK 3 (뉴스, 드라마 일부 이해 가능)"
            case .level4:
                return "TOPIK 4 (일반적인 기사, 논설문 이해 가능)"
            case .level5:
                return "TOPIK 5 (뉴스, 시사 토론, 연구 보고서 등)"
            case .level6:
                return "TOPIK 6 (신문, 학술 논문, 법률 문서 등)"
            }
        case .JLPT(let level):
            switch level {
            case .level1:
                return "JLPT N5 (가장 기초적인 단어)"
            case .level2:
                return "JLPT N4 (기본적인 생활 회화 가능)"
            case .level3:
                return "JLPT N3 (일상 대화에서 자주 사용되는 단어)"
            case .level4:
                return "JLPT N2 (뉴스, 직장, 비즈니스 대화에서 사용)"
            case .level5:
                return "JLPT N1 (학문, 정치, 심화된 표현)"   // level5까지
            default:
                return "JLPT N1 (학문, 정치, 심화된 표현)"
            }
        }
    }
}


extension LanguageLevelType {
    
    public var aiLevelType: RecommendLanguageLevelType {
        switch self {
        case .CEFR(let detailLevelType):
            switch detailLevelType {
            case .level1:
                return .CEFR(.level1)
            case .level2:
                return .CEFR(.level2)
            case .level3:
                return .CEFR(.level3)
            case .level4:
                return .CEFR(.level4)
            case .level5:
                return .CEFR(.level5)
            case .level6:
                return .CEFR(.level6)
            }
        case .TOPIK(let detailLevelType):
            switch detailLevelType {
            case .level1:
                return .TOPIK(.level1)
            case .level2:
                return .TOPIK(.level2)
            case .level3:
                return .TOPIK(.level3)
            case .level4:
                return .TOPIK(.level4)
            case .level5:
                return .TOPIK(.level5)
            case .level6:
                return .TOPIK(.level6)
            }
        case .JLPT(let detailLevelType):
            switch detailLevelType {
            case .level1:
                return .JLPT(.level1)
            case .level2:
                return .JLPT(.level2)
            case .level3:
                return .JLPT(.level3)
            case .level4:
                return .JLPT(.level4)
            case .level5:
                return .JLPT(.level5)
            case .level6:
                return .JLPT(.level6)
            }
        case .HSK(let detailLevelType):
            switch detailLevelType {
            case .level1:
                return .TOPIK(.level1)
            case .level2:
                return .TOPIK(.level2)
            case .level3:
                return .TOPIK(.level3)
            case .level4:
                return .TOPIK(.level4)
            case .level5:
                return .TOPIK(.level5)
            case .level6:
                return .TOPIK(.level6)
            }
        }
    }
}
