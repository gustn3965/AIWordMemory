//
//  ReviewStartFilter.swift
//  Review
//
//  Created by 박현수 on 1/3/25.
//

import Foundation

struct ReviewStartFilter {
    enum SortType: Int, Identifiable, CaseIterable {
        case dateDescending = 0 // 최근날짜순 ->
        case correctAscending = 1 // 덜맞춘순서 ->
        case correctDescending = 2 // 많이맞춘순서 ->
        
        var id: Int { self.rawValue }
        
        var name: String {
            switch self {
            case .correctDescending:
                "맞힌 순서"
            case .correctAscending:
                "틀린 순서"
            case .dateDescending:
                "최근 생성순"
            }
        }
    }
    
    enum ReviewType: Int, Identifiable, CaseIterable {
        case word
        case meaning
        
        var id: Int { self.rawValue }
        
        var name: String {
            switch self {
            case .word:
                return "단어"
            case .meaning:
                return "뜻"
            }
        }
    }
    
    enum AISentenceType: Int, Identifiable, CaseIterable {
        case description
        case conversation
        
        var id: Int { self.rawValue }
        
        var name: String {
            switch self {
            case .conversation:
                return "대화형"
            case .description:
                return "작문형"
            }
        }
    }
    
    var sortType: SortType
    var reviewType: ReviewType
    var aiSentenceType: AISentenceType
    var selectedTagItem: [FilterTagItem]
    
}
