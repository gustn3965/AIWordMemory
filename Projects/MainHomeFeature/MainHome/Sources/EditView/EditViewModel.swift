//
//  EditViewModel.swift
//  MainHome
//
//  Created by 박현수 on 1/3/25.
//

import Foundation
import Foundation
import DBInterface
import AppEntity

struct EditTagItem: Hashable, Identifiable {
    var id: String { identity }
    
    var identity: String
    var name: String
}


@MainActor class EditViewModel: ObservableObject {
    var editTagViewModel: EditSelectExpandableTagViewModel
    
    
    @Published var word: String = ""
    @Published var meaning: String = ""
    @Published var wordCount: Int = 0
    @Published var meaningCount: Int = 0
    let maxWordCount: Int
    let maxWordMeaning: Int
    
    var dbService: DataBaseProtocol
    var wordIdentity: String
    
    init(dbService: DataBaseProtocol, wordIdentity: String, maxWordCount: Int, maxWordMeaning: Int) {
        self.wordIdentity = wordIdentity
        self.dbService = dbService
        self.maxWordCount = maxWordCount
        self.maxWordMeaning = maxWordMeaning
        editTagViewModel = EditSelectExpandableTagViewModel(dbService: dbService, wordIdentity: wordIdentity)
    }
    
    deinit {
        print("# \(#file) \(#function)")
    }
  
    func save() async throws {
        let wordMemory = try await dbService.fetchWord(identity: wordIdentity)
        let tagItems = editTagViewModel.selectedItems.map { WordTag(identity: $0.identity, name: $0.name)}
        try await dbService.editWord(word: WordMemory(identity: wordIdentity,
                                                      word: word,
                                                      meaning: meaning,
                                                      createAt: .now,
                                                      tags: tagItems,
                                                      sentences: wordMemory?.sentences ?? []
                                                     ))
        
    }
    
    func fetchWord() async throws {
        let wordMemory = try await dbService.fetchWord(identity: wordIdentity)
        
        guard let wordMemory = wordMemory else { return }
        word = wordMemory.word
        meaning = wordMemory.meaning
        wordCount = word.count
        meaningCount = meaning.count
        
    }
    
    func checkRequiredWord() throws {
        if word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw WriteWordError.emptyWord
        } else if meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw WriteWordError.emptyMeaning
        }
    }
    
  
}
