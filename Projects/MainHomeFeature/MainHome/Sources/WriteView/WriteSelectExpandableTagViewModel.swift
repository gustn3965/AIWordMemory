//
//  WriteSelectExpandableTagViewModel.swift
//  MainHomeSampleApp
//
//  Created by 박현수 on 1/2/25.
//

import Foundation
import DBInterface
import AppEntity

@MainActor class WriteSelectExpandableTagViewModel: ObservableObject {
    
    
    
    @Published var items: [TagItem] = []
    
    @Published var selectedItems: [TagItem] = []
    
    @Published var needExpanding: Bool = false
    @Published var showAlertNewAddTag: Bool = false
    @Published var titleForNewTag: String = ""
    
    @Published var showErrorAlertTag: Bool = false
    @Published var errorMessage: String = ""
    var dbService: DataBaseProtocol
    
    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
    }
    
    
    func fetch() async throws {
        items = try await dbService.fetchAllTags().map {
            TagItem(identity: $0.identity, name: $0.name)
        }
    }
    
    
    func isSelecteditem(item: TagItem) -> Bool {
        selectedItems.contains(item)
    }
    
    func setSelectedItem(item: TagItem) {
        if isSelecteditem(item: item) {
            if let index = selectedItems.firstIndex(of: item) {
                selectedItems.remove(at: index)
            }
        } else {
            selectedItems.append(item)
        }
    }
    
    func addNewTag() async throws {
        if titleForNewTag.isEmpty || titleForNewTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "필수 항목이 없습니다."
            showErrorAlertTag = true
        } else {
            let newTag = TagItem(identity: UUID().uuidString, name: titleForNewTag)
            try await dbService.addTag(tag: WordTag(identity: newTag.identity, name: newTag.name))
            items.append(newTag)
            titleForNewTag = ""
            
        }
    }
}
