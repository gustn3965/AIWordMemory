//
//  FilterType.swift
//  DBImplementation
//
//  Created by 박현수 on 12/31/24.
//

import Foundation
import AppEntity

public struct SearchWordFilter: Sendable {
    public enum NameFilter: Sendable {
        case contain(name: String)
        case all
    }
    
    public enum SortType: Sendable {
        case nameDescending(Bool)
        case createAtDescending(Bool)
        case correctCountDescending(Bool)
    }
    
    public enum TagsFilter: Sendable, Equatable {
        case contain(tags: [AppEntity.WordTag], includeNoTag: Bool)
        case all
    }
    
    public let nameFilter: NameFilter
    public let tagFilter: TagsFilter
    public let sortType: SortType
    
    public static func all() -> SearchWordFilter {
        SearchWordFilter(nameFilter: .all, categoryFilter: .all, sortType: .createAtDescending(true))
    }
    
    public init(nameFilter: NameFilter = .all,
                categoryFilter: TagsFilter = .all,
                sortType: SortType = .createAtDescending(true)) {
        self.nameFilter = nameFilter
        self.tagFilter = categoryFilter
        self.sortType = sortType
    }
}

public struct ReviewWordFilter: Sendable {
    
    public enum ReviewType: Sendable {
        case word
        case meaning
    }
    
    public enum SortType: Sendable {
        case correctCountDescending(Bool)
        case createAtDescending(Bool)
    }
    
    public let reviewType: ReviewType
    
    public let sortType: SortType
    
    public init(reviewType: ReviewType = .word,
                sortType: SortType = .correctCountDescending(false)) {
        self.reviewType = reviewType
        self.sortType = sortType
    }
    
}
