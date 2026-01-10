//
//  SentenceInspectorViewModel.swift
//  SentenceInspector
//
//  Created by 박현수 on 2/11/25.
//

import Foundation
import AIInterface
import DBInterface
import AppEntity

@MainActor class SentenceInspectorViewModel: ObservableObject {
    
    @Published var userLanguage: SearchLangagueType = .english
    
    @Published var searchSentence: String = ""
    @Published var wordCount: Int = 0
    @Published var aiResponse: SentenceInspectorResponseModel?
    @Published var isLoading: Bool = false
    @Published var shouldAnimateLogo = false
    
    let languageList: [SearchLangagueType] = SearchLangagueType.allCases
    let maxWordCount: Int = 100
    
    private var diContainer: SentenceInspectorDependencyInjection
    private var aiService: AIInterface
    private var dbService: DataBaseProtocol
    
    init(diContainer: SentenceInspectorDependencyInjection) {
        self.diContainer = diContainer
        self.aiService = diContainer.makeAIImplementation()
        self.dbService = diContainer.makeDBImplementation()
        
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: Locale.current.language.languageCode?.identifier ?? "en")
    }
    
    // View에서. AppStorage사용해서.
    func updateUserDefaultUserLanguageCode(code: String) {
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: code)
    }
    
    private func convertSystemLanguageToSearchLanguageType(languageCode: String) -> SearchLangagueType {
        let code = languageCode.lowercased()
        return SearchLangagueType(rawValue: code) ?? .english
    }
    
    func search() async throws {
        if searchSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        if isLoading { return }
        startLoading()
        do {
            let response = try await aiService.sentenceInspector(searchSentence,
                                                                 mainLanguageType: userLanguage.aiSearchType)
            stopLoading()
            aiResponse = SentenceInspectorResponseModel.initWithAIResponse(response)
        } catch {
            aiResponse = nil
            stopLoading()
            print(error.localizedDescription)
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

struct SentenceInspectorResponseModel: Sendable {
    
    var originSentence: String
    var explanation: String
    var correctSentence: String
    
    init(originSentence: String, explanation: String, correctSentence: String) {
        self.originSentence = originSentence
        self.explanation = explanation
        self.correctSentence = correctSentence
    }
    
    static func initWithAIResponse(_ response: AISentenceInspectorResponse) -> Self {
        .init(originSentence: response.originSentence, explanation: response.explantion, correctSentence: response.correctSentence)
    }
}
