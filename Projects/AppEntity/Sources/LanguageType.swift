//
//  LanguageType.swift
//  AppEntity
//
//  Created by 박현수 on 2/11/25.
//

import Foundation


public enum SearchLangagueType: String, Sendable, CaseIterable, Identifiable {
    public var id: String { return String(self.rawValue) }
    
    case english = "en" // : return "영어"
    case korean = "ko" // : return "한국어"
    case japanese = "ja" // : return "일본어"
    case french = "fr" // : return "프랑스어"
    case german = "de"//: return "독일어"
    case italian = "it"// : return "이탈리아어"
    case portuguese = "pt" // : return "포르투갈어"
    case russian = "ru" // : return "러시아어"
    case spanish = "es" // : return "스페인어"
    case thai = "th" // : return "태국어"
    case simplifiedChinese = "zh" // : return "중국어 간체"
    case traditionalChinese = "zh-TW" // : return "중국어 번체"
    case vietnamese = "vi" // : return "베트남어"
    
    public var name: String {
        switch self {
        case .english: return "영어"
        case .korean: return "한국어"
        case .japanese: return "일본어"
        case .spanish: return "스페인어"
        case .french: return "프랑스어"
        case .german: return "독일어"
        case .italian: return "이탈리아어"
        
        case .portuguese: return "포르투갈어"
        case .russian: return "러시아어"
        case .simplifiedChinese: return "중국어 간체"
        case .traditionalChinese: return "중국어 번체"
        
        case .thai: return "태국어"
        case .vietnamese: return "베트남어"
        }
    }
   
    public var intValue: Int {
        switch self {
        case .english: return 0
        case .korean: return 1
        case .japanese: return 2
            
        case .spanish: return 3
        case .french: return 4
        case .german: return 5
        case .italian: return 6
        case .portuguese: return 7
        case .russian: return 8
        case .simplifiedChinese: return 9
        case .traditionalChinese: return 10
        case .thai: return 11
        case .vietnamese: return 12
        }
    }
}
