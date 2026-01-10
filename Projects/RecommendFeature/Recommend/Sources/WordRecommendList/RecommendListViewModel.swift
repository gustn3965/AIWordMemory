//
//  RecommendListViewModel.swift
//  Recommend
//
//  Created by 박현수 on 2/15/25.
//

import Foundation
import AIInterface
import DBInterface
import AppEntity
import SpeechVoiceInterface

@MainActor class RecommendListViewModel: ObservableObject {
    
    @Published var items: [RecommendWordModel] = []
    @Published var isLoading: Bool = false
    @Published var shouldAnimateLogo = false
    
    private var targetLanguageType: SearchLangagueType
    private var explanationLanguageType: SearchLangagueType
    private var levelType: LanguageLevelType
    
    private var diContainer: RecommendDependencyInjection
    private var aiService: AIInterface
    private var dbService: DataBaseProtocol
    private var appleSpeechService: SpeechVoiceInterface
    
    init(diContainer: RecommendDependencyInjection,
         targetLanguageType: SearchLangagueType,
         explanationLanguageType: SearchLangagueType,
         levelType: LanguageLevelType) {
        self.targetLanguageType = targetLanguageType
        self.explanationLanguageType = explanationLanguageType
        self.levelType = levelType
        
        self.diContainer = diContainer
        self.aiService = diContainer.makeAIImplementation()
        self.dbService = diContainer.makeDBImplementation()
        self.appleSpeechService = diContainer.makeSpecchAppleVoiceImplementation()
        
    }
 
    func firstLoadDB() async throws {
        if items.isEmpty {
            startLoading()
            let dbItems = try await fetchDB()
            if dbItems.isEmpty == false {
                items = dbItems
            }
            stopLoading()
        }
    }
    enum AILeakWord: Error, LocalizedError {
        case leakWord
        public var errorDescription: String? {
            switch self {
            case .leakWord:
                return "더이상 AI가 추천할 수 있는 단어가 없습니다.😭"
            }
        }
    }
    func fetchRecommend() async throws {
        
        startLoading()
        do {
            var filtered = try await fetchAI(useCredit: true)
            if filtered.isEmpty {
                filtered = try await fetchAI(useCredit: false) // 두번째는 무료로....
            }
            
            if filtered.isEmpty {
                stopLoading()
                throw AILeakWord.leakWord
            }
            items.insert(contentsOf: filtered, at: 0)
            
            try await saveNewRecommendToDB(newModels: filtered)
            
            stopLoading()
        } catch {
            stopLoading()
            throw error
        }
        
        
        // save
        // languageType: Int
        // explanationLanguageType: Int
        // levelType: Int
    }
    
    // 내 DBWord에 저장
    func saveToWordDB(item: RecommendWordModel) async throws {
        
        try await dbService.addWord(word: WordMemory(identity: UUID().uuidString,
                                           word: item.word, meaning: item.meaning, createAt: .now))
    }
    
    func speechAppleTTS(content: String) async throws {
        try await self.appleSpeechService.speak(content: content, identity: targetLanguageType.rawValue)
    }
    
    // MARK: - Private
    private func fetchAI(useCredit: Bool) async throws -> [RecommendWordModel] {
        let exclude = alreadyExistWords()
        let response = try await self.aiService.fetchRecommendWord(exclude,
                                                                   useCredit: useCredit,
                                                                   targetLanguageType: targetLanguageType.aiSearchType,
                                                                   languageLevelType: levelType.aiLevelType,
                                                                   explanationLanguageType: explanationLanguageType.aiSearchType)
        
        
        let newModels = response.words.map { RecommendWordModel.initWithAIResponse($0, levelType: levelType)}
        
        let filtered = filterExistWords(newModels: newModels)
        return filtered
    }
    
    private func fetchDB() async throws -> [RecommendWordModel] {
        let fetchedItems = try await dbService.fetchRecommendWords(languageType: targetLanguageType,
                                                explanationLanguageType: explanationLanguageType,
                                                levelType: levelType)
        guard let fetchedItems = fetchedItems else { return  []}
        let newItems = fetchedItems.map { RecommendWordModel.initWithAppEntity($0)}
        return newItems
    }
    
    // 내 DBWordRecommend에 저장
    private func saveNewRecommendToDB(newModels: [RecommendWordModel]) async throws {

        if newModels.isEmpty { return }
        
        var index = items.count + newModels.count // 앞의것부터 앞에나올수있도록 index크게잡아줌.
        let newIndexedModels = newModels.map {
            index -= 1
            var new = $0
            new.index = index
            return new
        }
        try await dbService.saveRecommendWords(words: newIndexedModels.map { $0.appEntity(languageType: targetLanguageType, explanationLanguageType: explanationLanguageType)})
    }
    
    
    
    private func alreadyExistWords() -> [String] {
        
        return items.map {
            $0.word
        }
    }
    
    private func filterExistWords(newModels: [RecommendWordModel]) -> [RecommendWordModel] {
        if items.isEmpty {
            return newModels
        }
        return newModels.filter { new in
            (items.contains { item in item.word == new.word }) == false
        }
    }
    
    private func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.shouldAnimateLogo = true
        }
        
    }
    
    private func stopLoading() {
        isLoading = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.shouldAnimateLogo = false
        }
    }
}

struct RecommendWordModel: Identifiable, Sendable, Hashable {
    
    static func == (lhs: RecommendWordModel, rhs: RecommendWordModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    var id: String = UUID().uuidString
    var word: String
    var meaning: String
    var levelType: LanguageLevelType
    var index: Int
    
    init(word: String, meaning: String, levelType: LanguageLevelType, index: Int = 0) {
        self.word = word
        self.meaning = meaning
        self.levelType = levelType
        self.index = index
    }
    
    static func initWithAIResponse(_ response: AIRecommendWordResponse.Word, levelType: LanguageLevelType) -> Self {
        .init(word: response.word, meaning: response.meaning, levelType: levelType)
    }
    
    static func initWithAppEntity(_ appEntity: WordRecommendMemory) -> Self {
        .init(word: appEntity.word, meaning: appEntity.meaning, levelType: appEntity.levelType, index: appEntity.index)
    }
    
    func appEntity(languageType: SearchLangagueType, explanationLanguageType: SearchLangagueType) -> WordRecommendMemory {
        WordRecommendMemory(index: index, identity: id, word: word, meaning: meaning, createAt: .now, languageType: languageType, levelType: levelType, explanationLanguageType: explanationLanguageType)
    }
}


extension RecommendListViewModel {
    
    static func makeMock() -> RecommendListViewModel {
        return RecommendListViewModel(diContainer: RecommendMockDIContainer(),
                                      targetLanguageType: .english,
                                      explanationLanguageType: .korean,
                                      levelType: .CEFR(.level1))
    }
}
