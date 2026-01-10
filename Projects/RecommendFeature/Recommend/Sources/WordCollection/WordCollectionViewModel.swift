//
//  WordCollectionViewModel.swift
//  Recommend
//
//  Created by 박현수 on 2/14/25.
//

import Foundation
import AIInterface
import DBInterface
import AppEntity

@MainActor class WordCollectionViewModel: ObservableObject {
    
    @Published var userLanguage: SearchLangagueType = .english
    @Published var selectLanguageTab: SearchLangagueType = .english
    @Published var selectLanguageLevelType: LanguageLevelType? = nil

    let languageList: [SearchLangagueType] = SearchLangagueType.allCases
    let languageTabList: [SearchLangagueType] = SearchLangagueType.allCases
    
    private var diContainer: RecommendDependencyInjection
    private var aiService: AIInterface
    private var dbService: DataBaseProtocol
    
    init(diContainer: RecommendDependencyInjection) {
        self.diContainer = diContainer
        self.aiService = diContainer.makeAIImplementation()
        self.dbService = diContainer.makeDBImplementation()
        
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: Locale.current.language.languageCode?.identifier ?? "en")
    }
    
    
    // View에서. AppStorage사용해서.
    func updateUserDefaultUserLanguageCode(code: String) {
        self.userLanguage = convertSystemLanguageToSearchLanguageType(languageCode: code)
    }
    
    func makeRecommendListViewModel() -> RecommendListViewModel? {
        guard let selectLanguageLevelType = selectLanguageLevelType else { return nil }
        
        return RecommendListViewModel(diContainer: diContainer,
                               targetLanguageType: selectLanguageTab,
                               explanationLanguageType: userLanguage,
                               levelType: selectLanguageLevelType)
    }
    
    private func convertSystemLanguageToSearchLanguageType(languageCode: String) -> SearchLangagueType {
        let code = languageCode.lowercased()
        return SearchLangagueType(rawValue: code) ?? .english
    }
    
    
}
