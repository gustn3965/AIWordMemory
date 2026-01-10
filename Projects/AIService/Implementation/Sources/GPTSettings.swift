//
//  GPTSettings.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import AppEntity
import NaturalLanguage
import AIInterface

public struct ChatGPTSetting: Sendable {
    let apiKey: String
    let numberOfResonse: Int
    let gptModel: String
    let maxTokenResponse: Int
    
    public init(apiKey: String, numberOfResonse: Int, gptModel: String, maxTokenResponse: Int) {
        self.apiKey = apiKey
        self.numberOfResonse = numberOfResonse
        self.gptModel = gptModel
        self.maxTokenResponse = maxTokenResponse
    }
}


extension ChatGPTRequest {
    nonisolated(unsafe) static var languageRecognizer = {
        let nll = NLLanguageRecognizer()
        var hints: [NLLanguage: Double] = [:]
        NLLanguage.allCases.forEach {
            hints[$0] = 0.1
        }
        
        AISearchLanguageType.allCases.forEach {
            hints[$0.NLLanguage] = 0.9
        }
        nll.languageHints = hints
        print("????????????")
        return nll
    }()
}



extension NLLanguage {
    
    static let allCases: [NLLanguage] = [
        .undetermined, .amharic, .arabic, .armenian, .bengali, .bulgarian, .burmese,
        .catalan, .cherokee, .croatian, .czech, .danish, .dutch, .english, .finnish,
        .french, .georgian, .german, .greek, .gujarati, .hebrew, .hindi, .hungarian,
        .icelandic, .indonesian, .italian, .japanese, .kannada, .khmer, .korean,
        .lao, .malay, .malayalam, .marathi, .mongolian, .norwegian, .oriya, .persian,
        .polish, .portuguese, .punjabi, .romanian, .russian, .simplifiedChinese,
        .sinhalese, .slovak, .spanish, .swedish, .tamil, .telugu, .thai, .tibetan,
        .traditionalChinese, .turkish, .ukrainian, .urdu, .vietnamese
    ]
    
    var propertyName: String? {
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
        case .swedish: return "스웨덴어"
        case .thai: return "태국어"
        case .traditionalChinese: return "중국어 번체"
        case .vietnamese: return "베트남어"
            
        case .undetermined: return "미확인"
//        case .amharic: return "암하라어"
//        case .arabic: return "아랍어"
//        case .armenian: return "아르메니아어"
//        case .bengali: return "벵골어"
//        case .bulgarian: return "불가리아어"
//        case .burmese: return "버마어"
//        case .catalan: return "카탈로니아어"
//        case .cherokee: return "체로키어"
//        case .croatian: return "크로아티아어"
//        case .czech: return "체코어"
//        case .danish: return "덴마크어"
//        case .dutch: return "네덜란드어"
        
//        case .finnish: return "핀란드어"
//        case .georgian: return "조지아어"
        
//        case .greek: return "그리스어"
//        case .gujarati: return "구자라트어"
//        case .hebrew: return "히브리어"
//        case .hindi: return "힌디어"
//        case .hungarian: return "헝가리어"
//        case .icelandic: return "아이슬란드어"
//        case .indonesian: return "인도네시아어"
        
//        case .kannada: return "칸나다어"
//        case .khmer: return "크메르어"
        
//        case .lao: return "라오어"
//        case .malay: return "말레이어"
//        case .malayalam: return "말라얄람어"
//        case .marathi: return "마라티어"
//        case .mongolian: return "몽골어"
//        case .norwegian: return "노르웨이어"
//        case .oriya: return "오리야어"
//        case .persian: return "페르시아어"
        
//        case .punjabi: return "펀자브어"
//        case .romanian: return "루마니아어"
        
//        case .sinhalese: return "싱할라어"
//        case .slovak: return "슬로바키아어"
        
//        case .tamil: return "타밀어"
//        case .telugu: return "텔루구어"
        
//        case .tibetan: return "티베트어"
        
//        case .turkish: return "터키어"
//        case .ukrainian: return "우크라이나어"
//        case .urdu: return "우르두어"
            
            
        default:
            return nil
        }
    }
}


extension AISearchLanguageType {
    public var NLLanguage: NLLanguage {
        switch self {
        case .english: return .english
        case .french: return .french
        case .german: return .german
        case .italian: return .italian
        case .japanese: return .japanese
        case .korean: return .korean
        case .portuguese: return .portuguese
        case .russian: return .russian
        case .simplifiedChinese: return .simplifiedChinese
        case .spanish: return .spanish
        case .thai: return .thai
        case .traditionalChinese: return .traditionalChinese
        case .vietnamese: return .vietnamese
        }
    }
}
