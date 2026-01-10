//
//  EditSelectExpandableTagViewModel.swift
//  MainHome
//
//  Created by 박현수 on 1/3/25.
//

import Foundation

import Foundation
import DBInterface
import AppEntity

@MainActor class EditSelectExpandableTagViewModel: ObservableObject {
    
    
    
    @Published var items: [EditTagItem] = []
    
    @Published var selectedItems: [EditTagItem] = []
    
    @Published var needExpanding: Bool = false
    @Published var showAlertNewAddTag: Bool = false
    @Published var titleForNewTag: String = ""
    
    @Published var showErrorAlertTag: Bool = false
    @Published var errorMessage: String = ""
    
    var dbService: DataBaseProtocol
    var wordIdentity: String
    
    init(dbService: DataBaseProtocol, wordIdentity: String) {
        self.dbService = dbService
        self.wordIdentity = wordIdentity
    }
    
    
    func fetch() async throws {

        guard let wordMemory = try await dbService.fetchWord(identity: wordIdentity) else { return }
        items = try await dbService.fetchAllTags().map {
            EditTagItem(identity: $0.identity, name: $0.name)
        }
        selectedItems = wordMemory.tags.map { EditTagItem(identity: $0.identity, name: $0.name)}
    }
    
    
    func isSelecteditem(item: EditTagItem) -> Bool {
        selectedItems.contains(item)
    }
    
    func setSelectedItem(item: EditTagItem) {
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
            let newTag = EditTagItem(identity: UUID().uuidString, name: titleForNewTag)
            try await dbService.addTag(tag: WordTag(identity: newTag.identity, name: newTag.name))
            items.append(newTag)
            titleForNewTag = ""
            
        }
    }
}
