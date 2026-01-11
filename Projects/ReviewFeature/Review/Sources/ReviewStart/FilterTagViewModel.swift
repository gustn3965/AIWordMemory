//
//  FilterTagViewModel.swift
//  Review
//
//  Created by 박현수 on 1/3/25.
//

import Foundation
import DBInterface
import Combine

struct FilterTagItem: Equatable, Identifiable {
    var id: String { identity }
    var identity: String
    var title: String
    var isNoTag: Bool
    
    init(title: String, identity: String) {
        self.identity = identity
        self.title = title
        self.isNoTag = false
    }
    
    static func noTag() -> FilterTagItem {
        var item = FilterTagItem(title: String(localized: "태그 없음"), identity: UUID().uuidString)
        item.isNoTag = true
        return item
    }
}

@MainActor class FilterTagViewModel: ObservableObject {
    @Published var items: [FilterTagItem] = []
    
    @Published var selectedItems: [FilterTagItem] = []
    
    var dbService: DataBaseProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
        
        dbService.updatePulbisher
            .sink { [weak self] updateValue in
                Task {
                    try await self?.fetch()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetch() async throws {
        var newItems = try await dbService.fetchAllTags().map {
            FilterTagItem(title: $0.name, identity: $0.identity)
        }
        if newItems.isEmpty == false {
            newItems.append(.noTag())
            selectedItems = newItems
        }
        items = newItems
    }
    
    
    
    func isSelecteditem(item: FilterTagItem) -> Bool {
        selectedItems.contains(item)
    }
    
    func setSelectedItem(item: FilterTagItem) {
        if isSelecteditem(item: item) {
            if let index = selectedItems.firstIndex(of: item) {
                if selectedItems.count > 1 {
                    selectedItems.remove(at: index)
                }
            }
        } else {
            selectedItems.append(item)
        }
    }
    
    func selectAllItem() {
        selectedItems = items
    }
    
    func isAllSelected() -> Bool {
        selectedItems.count == items.count
    }
}
