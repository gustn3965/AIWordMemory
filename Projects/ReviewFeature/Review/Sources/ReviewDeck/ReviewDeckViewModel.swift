//
//  ReviewDeckViewModel.swift
//  Review
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import AIInterface
import AppEntity
import SwiftUI
import DBInterface
import Combine

enum ReviewDeckError: Error, LocalizedError {
    case noReview
    
    var errorDescription: String? {
        switch self {
        case .noReview:
            return "조건에 맞는 리뷰 가능한 단어가 없습니다."
        }
    }
}
@MainActor class ReviewDeckViewModel: ObservableObject {
    
    @Published var memoryActionPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    @Published var reviewList: [WordMemory] = []
    
    @Published var currentIndex: Int = 0
    @Published var searchedIndex: Int = 0
    @Published var shouldClose: Bool = false
    
    private let dbService: DataBaseProtocol
    var reviewStartFilter: ReviewStartFilter
    var cancellables: Set<AnyCancellable> = []
    
    
    
    init(diContainer: ReviewDependencyInjection, reviewStartFilter: ReviewStartFilter) {
        self.reviewStartFilter = reviewStartFilter
        dbService = diContainer.makeDBImplementation()
        
        memoryActionPublisher
            .sink { [weak self] _ in
                self?.moveAction(.after)
            }
            .store(in: &cancellables)
    }
    
    enum DeckAction {
        case after
        case before
    }
    func moveAction(_ action: DeckAction) {
        switch action {
        case .before:
            if currentIndex > 0 {
                currentIndex -= 1
            }
        case .after:
            if currentIndex < reviewList.count - 1 {
                currentIndex += 1
                searchedIndex = max(currentIndex, searchedIndex)
            } else {
                shouldClose = true
            }
        }
    }
    
    func makeDeck() async throws {
       
        var tagFilter: SearchWordFilter.TagsFilter = .all
        var sortFilter: SearchWordFilter.SortType = .createAtDescending(true)
        if reviewStartFilter.selectedTagItem.isEmpty {
            tagFilter = .all
        } else {
            var includeNoTag: Bool = false
            if reviewStartFilter.selectedTagItem.contains(where: { tag in
                tag.isNoTag
            }) {
                includeNoTag = true
            }
            let tags = reviewStartFilter.selectedTagItem.filter { $0.isNoTag == false }.map { WordTag(identity: $0.identity, name: $0.title)}
            tagFilter = .contain(tags: tags, includeNoTag: includeNoTag)
        }
        
        switch reviewStartFilter.sortType {
        case .correctDescending:
            sortFilter = .correctCountDescending(true)
        case .correctAscending:
            sortFilter = .correctCountDescending(false)
        case .dateDescending:
            sortFilter = .createAtDescending(true)
        }
        
        let filter = SearchWordFilter(nameFilter: .all,
                         categoryFilter: tagFilter,
                         sortType: sortFilter)
        
        if reviewList.isEmpty {
            let reviewList = try await dbService.fetchWordList(filter: filter)
            self.reviewList = reviewList
            
            if reviewList.isEmpty {
                throw ReviewDeckError.noReview
            }
        }
    }
}
