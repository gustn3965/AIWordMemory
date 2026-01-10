//
//  ReviewStartViewModel.swift
//  Review
//
//  Created by 박현수 on 12/27/24.
//

import Foundation
import DBInterface
import Combine


@MainActor class ReviewStartViewModel: ObservableObject {
    
    var filterTagViewModel: FilterTagViewModel
    
    @Published var sortType: ReviewStartFilter.SortType = .dateDescending
    @Published var reviewType: ReviewStartFilter.ReviewType = .word
    @Published var aiSentenceType: ReviewStartFilter.AISentenceType = .description
    @Published var startReview: Bool = false
    @Published var needFilterTagView: Bool = false
    
    let sortDescription: String = "리뷰 순서"
    let reviewDescription: String = "리뷰 타입"
    let aiSentenceDescription: String = "AI 생성 문장 타입"
    let reviewStartButtonName: String = "리뷰 시작"
    
    var dbService: DataBaseProtocol
    var debouncer = DebounceObject()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
        filterTagViewModel = FilterTagViewModel(dbService: dbService)
        
        dbService.updatePulbisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                Task {
                    do {
                        try await self?.setup()
                        print("updated........")
                        
                    } catch {
                        print("Error in setup: \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func checkEmptyDB() async throws -> Bool {
        return try await dbService.isWordEmpty()
    }
    
    func makeReviewStartFilter() -> ReviewStartFilter {
        ReviewStartFilter(sortType: sortType,
                          reviewType: reviewType,
                          aiSentenceType: aiSentenceType,
                          selectedTagItem: filterTagViewModel.selectedItems
                          )
    }
    
    func setup() async throws {
        needFilterTagView = try await dbService.fetchAllTags().isEmpty == false
    }
}
