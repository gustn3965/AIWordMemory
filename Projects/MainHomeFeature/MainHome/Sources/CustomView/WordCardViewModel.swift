//
//  ScrollCardViewModel.swift
//  MainHome
//
//  Created by 박현수 on 1/2/25.
//

import Foundation
import DBInterface
import Combine

struct CardItem: Identifiable, Hashable {
    var id: String
    
    var word: String
    var meaning: String
}


enum WordCardViewType: String, Sendable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case all = "모두"
    case word = "단어"
    case meaning = "뜻"
    
}

enum WordCardSortFilter: Int, Identifiable, CaseIterable {
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

@MainActor class WordCardViewModel: ObservableObject {
    
    @Published var items: [CardItem] = []
    
    @Published var sortType: WordCardSortFilter = .dateDescending
    
    var dbService: DataBaseProtocol
    var filter: SearchWordFilter = .all()
    var cancellables = Set<AnyCancellable>()
    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
        
        dbService.updatePulbisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                Task {
                    do {
                        guard let self else { return }
                        try await self.fetchWords(filter: self.filter)
                        print("updated........")
                        
                    } catch {
                        print("Error in setup: \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchWords(filter: SearchWordFilter) async throws {
        
        var filterSortType: SearchWordFilter.SortType
        
        switch sortType {
        case .dateDescending:
            filterSortType = .createAtDescending(true)
        case .correctAscending:
            filterSortType = .correctCountDescending(false)
        case .correctDescending:
            filterSortType = .correctCountDescending(true)
        }
        
        self.filter = SearchWordFilter(nameFilter: filter.nameFilter, categoryFilter: filter.tagFilter, sortType: filterSortType)
        
        let newItems = try await dbService.fetchWordList(filter: self.filter)
        items = newItems.map {
            CardItem(id: $0.identity, word: $0.word, meaning: $0.meaning)
        }
    }
    
    
}
