//
//  LanguageLevelType.swift
//  AppEntity
//
//  Created by 박현수 on 2/15/25.
//

import Foundation

public enum LanguageLevelType: Sendable, Identifiable, Hashable {
    
    public var id: String { return levelFullName }
    
    public enum DetailLevelType: Sendable {
        case level1
        case level2
        case level3
        case level4
        case level5
        case level6 // 높은순
    }
    
    case CEFR(DetailLevelType)   // 영어,
    case TOPIK(DetailLevelType)  // 한국어
    case JLPT(DetailLevelType)   // 일본어
    case HSK(DetailLevelType)   // 중국어
    
    public var levelShortName: String {
        switch self {
        case .CEFR:
            return "CEFR"
        case .TOPIK:
            return "TOPIK"
        case .JLPT:
            return "JLPT"
        case .HSK:
            return "HSK"
        }
    }
    
    public var levelFullName: String {
        switch self {
        case .CEFR(let level):
            switch level {
            case .level1:
                return "초급"
            case .level2:
                return "초중급"
            case .level3:
                return "중급"
            case .level4:
                return "상급"
            case .level5:
                return "고급"
            case .level6:
                return "최상급"    // 높은순
            }
        case .TOPIK(let level):
            switch level {
            case .level1:
                return "초급"
            case .level2:
                return "초중급"
            case .level3:
                return "중급"
            case .level4:
                return "상급"
            case .level5:
                return "고급"
            case .level6:
                return "최상급"    // 높은순
            }
        case .JLPT(let level):
            switch level {
            case .level1:
                return "초급"
            case .level2:
                return "초중급"
            case .level3:
                return "중급"
            case .level4:
                return "상급"
            case .level5:
                return "최상급"
            default:
                return "최상급"
            }
        case .HSK(let level):
            switch level {
            case .level1:
                return "초급"
            case .level2:
                return "초중급"
            case .level3:
                return "중급"
            case .level4:
                return "상급"
            case .level5:
                return "고급"
            case .level6:
                return "최상급"    // 높은순
            }
        }
    }
    
    public var levelDescription: String {
        switch self {
        case .CEFR(let level):
            switch level {
            case .level1:
                return "가장 기초적인 단어"
            case .level2:
                return "일상생활에 필요한 단어"
            case .level3:
                return "일반적인 대화에서 자주 쓰이는 단어"
            case .level4:
                return "뉴스, 토론 등에서 많이 쓰이는 단어"
            case .level5:
                return "아카데믹, 직장, 문학 등에서 활용되는 단어"
            case .level6:
                return "거의 모든 표현을 포함"    // 높은순
            }
        case .TOPIK(let level):
            switch level {
            case .level1:
                return "일상적인 인사, 자기소개, 간단한 지시문"
            case .level2:
                return "간단한 일상 대화, 공공장소 안내문"
            case .level3:
                return "뉴스, 드라마 일부 이해 가능"
            case .level4:
                return "일반적인 기사, 논설문 이해 가능"
            case .level5:
                return "뉴스, 시사 토론, 연구 보고서 등"
            case .level6:
                return "신문, 학술 논문, 법률 문서 등"
            }
        case .JLPT(let level):
            switch level {
            case .level1:
                return "가장 기초적인 단어"
            case .level2:
                return "기본적인 생활 회화 가능"
            case .level3:
                return "일상 대화에서 자주 사용되는 단어"
            case .level4:
                return "뉴스, 직장, 비즈니스 대화에서 사용"
            case .level5:
                return "학문, 정치, 심화된 표현"   // level5까지
            default:
                return "학문, 정치, 심화된 표현"
            }
        case .HSK(let level):
            switch level {
            case .level1:
                return "가장 기초적인 단어"
            case .level2:
                return "일상생활에 필요한 단어"
            case .level3:
                return "일반적인 대화에서 자주 쓰이는 단어"
            case .level4:
                return "뉴스, 토론 등에서 많이 쓰이는 단어"
            case .level5:
                return "아카데믹, 직장, 문학 등에서 활용되는 단어"
            case .level6:
                return "거의 모든 표현을 포함"    // 높은순
            }
        }
    }
    
    public var intValue: Int {
        switch self {
        case .CEFR(let level):
            switch level {
            case .level1:
                return 0
            case .level2:
                return 1
            case .level3:
                return 2
            case .level4:
                return 3
            case .level5:
                return 4
            case .level6:
                return 5
            }
        case .TOPIK(let level):
            switch level {
            case .level1:
                return 0
            case .level2:
                return 1
            case .level3:
                return 2
            case .level4:
                return 3
            case .level5:
                return 4
            case .level6:
                return 5
            }
        case .JLPT(let level):
            switch level {
            case .level1:
                return 0
            case .level2:
                return 1
            case .level3:
                return 2
            case .level4:
                return 3
            case .level5:
                return 4
            default:
                return 4
            }
        case .HSK(let level):
            switch level {
            case .level1:
                return 0
            case .level2:
                return 1
            case .level3:
                return 2
            case .level4:
                return 3
            case .level5:
                return 4
            case .level6:
                return 5
            }
        }
    }
}


extension SearchLangagueType {
    public var levelTypes: [LanguageLevelType] {
        
        switch self {
        case .english:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .korean:
            return [.TOPIK(.level1), .TOPIK(.level2), .TOPIK(.level3), .TOPIK(.level4), .TOPIK(.level5), .TOPIK(.level6)]
        case .japanese:
            return [.JLPT(.level1), .JLPT(.level2), .JLPT(.level3), .JLPT(.level4), .JLPT(.level5)]
        case .french:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .german:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .italian:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .portuguese:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .russian:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .simplifiedChinese:
            return [.HSK(.level1), .HSK(.level2), .HSK(.level3), .HSK(.level4), .HSK(.level5), .HSK(.level6)]
        case .spanish:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .thai:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        case .traditionalChinese:
            return [.HSK(.level1), .HSK(.level2), .HSK(.level3), .HSK(.level4), .HSK(.level5), .HSK(.level6)]
        case .vietnamese:
            return [.CEFR(.level1), .CEFR(.level2), .CEFR(.level3), .CEFR(.level4), .CEFR(.level5), .CEFR(.level6)]
        default:
            return []
        }
    }
}
