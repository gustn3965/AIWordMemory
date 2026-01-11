//
//  MainHomeViewModel.swift
//  MainHome
//
//  Created by 박현수 on 12/25/24.
//

import Foundation
import DBInterface
import Combine
import AppEntity

@MainActor class MainHomeViewModel: ObservableObject {
    
    var tagViewModel: ExpandableTagViewModel
    var wordCardviewModel: WordCardViewModel
    
    var dbService: DataBaseProtocol
    
    
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    
    
    // need view
    @Published var needTopExpandableTagView: Bool = false
    @Published var needEmptyAddView: Bool = true
    
    
    // sheet
    @Published var showAddViewSheet: Bool = false
    @Published var addWordSheet: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dbService: DataBaseProtocol) {
        tagViewModel = ExpandableTagViewModel(dbService: dbService)
        wordCardviewModel = WordCardViewModel(dbService: dbService)
        
        self.dbService = dbService
        
        tagViewModel.selectItemUpdatePublisher
            .sink { [weak self] _ in
                Task {
                    try await self?.fetch()
                }
            }
            .store(in: &cancellables)
        
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
    
    func setup() async throws {
        needTopExpandableTagView = try await dbService.fetchAllTags().isEmpty == false
        
        needEmptyAddView = try await dbService.fetchWordList(filter: SearchWordFilter()).isEmpty
        
        print(needTopExpandableTagView)
        print(needEmptyAddView)
        
        
        
    }
 
    func fetch() async throws {
    
        var nameFilter: SearchWordFilter.NameFilter = .all
        var tagFilter: SearchWordFilter.TagsFilter = .all
        
        if searchText.isEmpty || searchText.components(separatedBy: .whitespacesAndNewlines).isEmpty {
            nameFilter = .all
        } else {
            nameFilter = .contain(name: searchText)
        }
        
        if tagViewModel.selectedItems.isEmpty {
            if tagViewModel.items.isEmpty {
                tagFilter = .all
            } else {
                tagFilter = .contain(tags: [], includeNoTag: false)
            }
        } else {
            var includeNoTag: Bool = false
            if tagViewModel.selectedItems.contains(where: { tag in
                tag.isNoTag
            }) {
                includeNoTag = true
            }
            let tags = tagViewModel.selectedItems.filter { $0.isNoTag == false }.map { WordTag(identity: $0.identity, name: $0.title)}
            tagFilter = .contain(tags: tags, includeNoTag: includeNoTag)
        
        }
        
        let searchFilter = SearchWordFilter(nameFilter: nameFilter,
                                            categoryFilter: tagFilter,
                                            sortType: .createAtDescending(true))
        
        
        try await wordCardviewModel.fetchWords(filter: searchFilter)
    }
}
