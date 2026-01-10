//
//  WriteViewModel.swift
//  MainHome
//
//  Created by 박현수 on 12/27/24.
//

import Foundation
import DBInterface
import AppEntity

struct TagItem: Hashable, Identifiable {
    var id: String { identity } 
    
    var identity: String
    var name: String
}

enum WriteWordError: Error, LocalizedError {
    case emptyWord
    case emptyMeaning
    
    var errorDescription: String? {
        switch self {
        case .emptyWord:
            return "단어는 필수항목입니다."
        case .emptyMeaning:
            return "뜻은 필수항목입니다."
        }
    }
}

@MainActor class WriteViewModel: ObservableObject {
    var writeTagViewModel: WriteSelectExpandableTagViewModel
    
    
    @Published var word: String = ""
    @Published var meaning: String = ""
    @Published var wordCount: Int = 0
    @Published var meaningCount: Int = 0
    let maxWordCount: Int
    let maxWordMeaning: Int
    
    var dbService: DataBaseProtocol
    
    init(dbService: DataBaseProtocol, maxWordCount: Int, maxWordMeaning: Int) {
        self.dbService = dbService
        self.maxWordCount = maxWordCount
        self.maxWordMeaning = maxWordMeaning
        writeTagViewModel = WriteSelectExpandableTagViewModel(dbService: dbService)
    }
  
    func save() async throws {
        
        let tagItems = writeTagViewModel.selectedItems.map { WordTag(identity: $0.identity, name: $0.name)}
        try await dbService.addWord(word: WordMemory(identity: UUID().uuidString,
                                                     word: word,
                                                     meaning: meaning,
                                                     createAt: .now,
                                                     tags: tagItems))
    }
    
    
    
    func checkRequiredWord() throws {
        if word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw WriteWordError.emptyWord
        } else if meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            throw WriteWordError.emptyMeaning
        }
    }
}
