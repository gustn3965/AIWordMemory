//
//  SearchViewModel.swift
//  Search
//
//  Created by 박현수 on 2/5/25.
//

import Foundation
import AIInterface
import DBInterface
import AppEntity

@MainActor class SearchViewModel: ObservableObject {

    @Published var userLanguage: SearchLangagueType = .english
    @Published var searchLanguage: SearchLangagueType = .english
    
    @Published var searchWord: String = ""
    @Published var wordCount: Int = 0
    @Published var aiResponse: SearchResponseModel?
    @Published var isLoading: Bool = false
    @Published var shouldAnimateLogo = false
    
    let languageList: [SearchLangagueType] = SearchLangagueType.allCases
    let maxWordCount: Int = 100
    
    private var diContainer: SearchDependencyInjection
    private var aiService: AIInterface
    private var dbService: DataBaseProtocol
    
    init(diContainer: SearchDependencyInjection) {
        self.diContainer = diContainer
        self.aiService = diContainer.makeAIImplementation()
        self.dbService = diContainer.makeDBImplementation()
        
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: Locale.current.language.languageCode?.identifier ?? "en")
    }
    
    // View에서. AppStorage사용해서.
    func updateUserDefaultUserLanguageCode(code: String) {
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: code)
    }
    func updateUserDefaultSearchLanguageCode(code: String) {
        self.searchLanguage = convertSystemLanguageToSearchLanguageType(languageCode: code)
    }
    
    private func convertSystemLanguageToSearchLanguageType(languageCode: String) -> SearchLangagueType {
        let code = languageCode.lowercased()
        return SearchLangagueType(rawValue: code) ?? .english
    }

    func search() async throws {
        if searchWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        if isLoading { return }
        startLoading()
        do {
            let response = try await aiService.search(searchWord,
                                                      mainLanguageType: userLanguage.aiSearchType,
                                                      searchLanguageType: searchLanguage.aiSearchType)
            stopLoading()
            aiResponse = SearchResponseModel.initWithAIResponse(response)
        } catch {
            aiResponse = nil
            stopLoading()
            print(error.localizedDescription)
            throw error
        }
    }
    
    func saveToWord() async throws {
        
        guard let aiResponse = aiResponse else { return }
        
        do {
            try await dbService.addWord(word: aiResponse.convertToDB())
        } catch {
            throw error
        }
    }
    
    func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.shouldAnimateLogo = true
        }
        
    }
    
    func stopLoading() {
        isLoading = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.shouldAnimateLogo = false
        }
    }
}

struct SearchResponseModel: Sendable {
    enum SearchType {
        case meaning
        case translate
        
        static func convert(aiSearchType: AISearchType) -> Self {
            switch aiSearchType {
            case .meaning:
                return .meaning
            case .translate:
                return .translate
            }
        }
    }
    var word: String
    var explanation: String
    var sentence: String
    var sentenceTranslation: String
    var meaning: String
    var searchType: SearchType
    
    init(word: String, explanation: String, sentence: String, sentenceTranslation: String, meaning: String, searchType: SearchType) {
        self.word = word
        self.explanation = explanation
        self.sentence = sentence
        self.sentenceTranslation = sentenceTranslation
        self.meaning = meaning
        self.searchType = searchType
    }
    
    static func initWithAIResponse(_ response: AISearchResponse) -> SearchResponseModel {
        SearchResponseModel(word: response.word,
                            explanation: response.explanation,
                            sentence: response.sentence,
                            sentenceTranslation: response.sentenceTranslation,
                            meaning: response.meaning,
                            searchType: SearchType.convert(aiSearchType: response.searchType))
    }
    
    func convertToDB() -> WordMemory {
        
        switch searchType {
        case .meaning:
            WordMemory(identity: UUID().uuidString,
                       word: word,
                       meaning: meaning,
                       createAt: .now)
        case .translate:
            WordMemory(identity: UUID().uuidString,
                       word: meaning,
                       meaning: word,
                       createAt: .now)
        }
        
    }
}
