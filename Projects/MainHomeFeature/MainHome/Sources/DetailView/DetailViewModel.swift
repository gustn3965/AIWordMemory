//
//  DetailViewModel.swift
//  MainHome
//
//  Created by 박현수 on 1/2/25.
//

import Foundation
import DBInterface
import AppEntity
import Combine
import SpeechVoiceInterface

@MainActor class DetailViewModel: ObservableObject {

    var dbService: DataBaseProtocol
    var appleSpeechService: SpeechVoiceInterface
    var speechVoiceService: SpeechVoiceInterface
    var wordIdentity: String

    @Published var word: String = "expect"
    @Published var meaning: String = "예상하다"

    @Published var correctCount: Int = 0

    @Published var editSheet: Bool = false
    @Published var deleteAlert: Bool = false

    @Published var tags: [String] = []
    @Published var sentences: [Sentence] = []

    var cancellables: Set<AnyCancellable> = []

    init(dbService: DataBaseProtocol, wordIdentity: String, appleSpeechService: SpeechVoiceInterface, speechVoiceService: SpeechVoiceInterface) {
        self.dbService = dbService
        self.appleSpeechService = appleSpeechService
        self.speechVoiceService = speechVoiceService
        self.wordIdentity = wordIdentity
        
        dbService.updatePulbisher
            .sink { [weak self] _ in
                Task {
                    try await self?.fetch()
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteWord() async throws {
        try await dbService.deleteWord(identity: wordIdentity)
    }
    
    func fetch() async throws {
        guard let fetchedWord = try await dbService.fetchWord(identity: wordIdentity) else {
            throw DataBaseError.unknown
        }
        
        word = fetchedWord.word
        meaning = fetchedWord.meaning
        correctCount = fetchedWord.correctCount
        tags = fetchedWord.tags.map { $0.name }
        sentences = fetchedWord.sentences.map { Sentence(example: $0.example, translation: $0.translation, exampleIdentity: $0.exampleIdentity) }
    }

    func speechAppleTTS(content: String) async throws {
        try await self.appleSpeechService.speak(content: content, identity: "")
    }

    func speechTTS(content: String, identity: String) async throws {
        try await self.speechVoiceService.speak(content: content, identity: identity)
    }


    struct Sentence: Identifiable {
        var example: String
        var translation: String
        var exampleIdentity: String
        let id = UUID().uuidString
    }
}
