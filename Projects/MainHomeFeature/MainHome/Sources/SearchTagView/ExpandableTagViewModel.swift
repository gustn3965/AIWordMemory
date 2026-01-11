//
//  File.swift
//  MainHome
//
//  Created by 박현수 on 1/2/25.
//

import Foundation
import DBInterface
import Combine


struct SearchTagItem: Equatable, Identifiable {
    var id: String { identity }
    var identity: String
    var title: String
    var isNoTag: Bool
    
    init(title: String, identity: String) {
        self.identity = identity
        self.title = title
        self.isNoTag = false
    }
    
    static func noTag() -> SearchTagItem {
        var item = SearchTagItem(title: "태그 없음", identity: UUID().uuidString)
        item.isNoTag = true
        return item
    }
}

@MainActor class ExpandableTagViewModel: ObservableObject {
    @Published var items: [SearchTagItem] = []
    
    @Published var selectedItems: [SearchTagItem] = [] {
        didSet {
            selectItemUpdatePublisher.send()
        }
    }
    
    var selectItemUpdatePublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    var dbService: DataBaseProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
        
        dbService.updatePulbisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateType in
                Task {
                    do {
                        try await self?.fetch()
                        print("updated........")
                    } catch {
                        print("Error in setup: \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    func fetch() async throws {
        var newItems = try await dbService.fetchAllTags().map {
            SearchTagItem(title: $0.name, identity: $0.identity)
        }
        if newItems.isEmpty == false {
            newItems.append(.noTag())
            selectedItems = newItems
        }
        items = newItems
    }
    
    
    func isSelecteditem(item: SearchTagItem) -> Bool {
        selectedItems.contains(item)
    }
    
    func setSelectedItem(item: SearchTagItem) {
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
        if isAllSelected() {
            selectedItems = []
        } else {
            selectedItems = items
        }
    }
    
    func isAllSelected() -> Bool {
        selectedItems.count == items.count
    }
}
