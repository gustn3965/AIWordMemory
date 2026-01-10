
import AIInterface
import AppEntity
import AccountInterface
import ClockImplementation

@globalActor public actor AIGPTManager: AIInterface {
    
    public var accountManager: AccountManagerProtocol?
    public func setAccountManager(accountManager: AccountManagerProtocol) async  {
        self.accountManager = accountManager
    }
    
    public static let shared: AIGPTManager = AIGPTManager()
    
    var gpt: ChatGPTManager?
    
    public func fetchAIExample(word: AppEntity.WordMemory, sentenceType: AISentenceType) async throws -> [AppEntity.WordMemorySentence] {
        
        guard let gpt = gpt else { throw NetworkError.missingGPT }
        
        try await checkBeforeAccount()
        
        let gptResponse = try await gpt.fetchChatGPTResponse(request: .requestFetchSentence(word: word, sentenceType: sentenceType))
        
        try await checkAfterAccount()
        
        if let response = ResponseParser.parse(response: gptResponse) {
            return response.examples.map { $0.makeWordMeorySentence(wordMemoryIdentity: word.identity)}
        }
        throw NetworkError.parserErrorToAIInterface
    }
    
    public func search(_ word: String,
                       mainLanguageType: AISearchLanguageType,
                       searchLanguageType: AISearchLanguageType) async throws -> AISearchResponse {
        
        guard let gpt = gpt else { throw NetworkError.missingGPT }
        
        try await checkBeforeAccount()
        
        let searchType = getSearchType(word, mainLanguageType: mainLanguageType, searchLanguageType: searchLanguageType)
        
        var response: AISearchResponse?
        switch searchType {
        case .meaning:
            response = try await requestSearchMeaning(gpt: gpt, word: word, mainLanguageType: mainLanguageType, searchLanguageType: searchLanguageType)
        case .translate:
            response = try await requestSearchTranslate(gpt: gpt, word: word, mainLanguageType: mainLanguageType, searchLanguageType: searchLanguageType)
        }
        
        try await checkAfterAccount()
        
        if let response = response {
            return response
        }
        throw NetworkError.parserErrorToAIInterface
    }
    
    public func sentenceInspector(_ sentence: String,
                                  mainLanguageType: AISearchLanguageType) async throws -> AISentenceInspectorResponse {
        guard let gpt = gpt else { throw NetworkError.missingGPT }
        
        try await checkBeforeAccount()
        
        let gptResponse = try await gpt.fetchChatGPTResponse(request: .requestSentenceInspector(sentence: sentence,
                                                                                                mainLanguageType: mainLanguageType))
        
        try await checkAfterAccount()
        
        if let response = ResponseParser.parseSentenceInsepctor(originSentence: sentence, response: gptResponse) {
            return response
        }
        throw NetworkError.parserErrorToAIInterface
    }
    
    public func fetchRecommendWord(_ exclude: [String],
                                   useCredit: Bool,
                                   targetLanguageType: AISearchLanguageType,
                                   languageLevelType: RecommendLanguageLevelType,
                                   explanationLanguageType: AISearchLanguageType) async throws -> AIRecommendWordResponse {
        guard let gpt = gpt else { throw NetworkError.missingGPT }
        
        if useCredit {
            try await checkBeforeAccount()
        }
        
        let gptResponse = try await gpt.fetchChatGPTResponse(request: .requestRecommendWord(excludeWords: exclude, targetLanguageType: targetLanguageType, languageLevelType: languageLevelType, explanationLanguageType: explanationLanguageType))
        
        if useCredit {
            try await checkAfterAccount()
        }
        
        if let response = ResponseParser.parseRecommendWord(response: gptResponse) {
            return response
        }
        throw NetworkError.parserErrorToAIInterface
    }
    
    
    // MARK: - Private
    
    private func checkBeforeAccount() async throws {
        guard let account = try await accountManager?.account() else {
            throw AccountError.noExistingAccount
        }
        if account.chatGPTChances <= 0 {
            throw AccountError.chanceExpired
        }
    }
    
    private func checkAfterAccount() async throws {
        guard var account = try await accountManager?.account() else {
            throw AccountError.noExistingAccount
        }
        if account.chatGPTChances <= 0 {
            throw AccountError.chanceExpired
        } else {
            account.chatGPTChances -= 1
            account.lastUpdated = await ClockManager.shared.fetchClock()
            try await accountManager?.updateAccount(account)
        }
    }
    
    private func requestSearchMeaning(gpt: ChatGPTManager,
                                      word: String,
                                      mainLanguageType: AISearchLanguageType,
                                      searchLanguageType: AISearchLanguageType) async throws -> AISearchResponse? {
        let gptResponse = try await gpt.fetchChatGPTResponse(request: .requestSearchMeaning(searchWord: word,
                                                                                            mainLanguageType: mainLanguageType,
                                                                                            searchLanguageType: searchLanguageType))
        let response = ResponseParser.parseMeaning(searchWord: word, response: gptResponse)
        return response
    }
    
    private func requestSearchTranslate(gpt: ChatGPTManager,
                                        word: String,
                                        mainLanguageType: AISearchLanguageType,
                                        searchLanguageType: AISearchLanguageType) async throws -> AISearchResponse? {
        let gptResponse = try await gpt.fetchChatGPTResponse(request: .requestSearchTranslate(searchWord: word,
                                                                                              mainLanguageType: mainLanguageType,
                                                                                              searchLanguageType: searchLanguageType))
        let response = ResponseParser.parseTranslate(searchWord: word, response: gptResponse)
        return response
        
    }
    
    private func getSearchType(_ word: String, mainLanguageType: AISearchLanguageType, searchLanguageType: AISearchLanguageType) -> AISearchType {
        
        ChatGPTRequest.languageRecognizer.processString(word)
        let searchLanugage = ChatGPTRequest.languageRecognizer.dominantLanguage?.propertyName ?? "영어"
        
        if searchLanugage == searchLanguageType.name {
            return .meaning // apple 이 뭐에요 ? -> 사과
        } else {
            return .translate // 사과 뭐에요 ? -> apple
        }
        
    }
    
    public func setup(setting: ChatGPTSetting) {
        gpt = ChatGPTManager(chatGPTSetting: setting)
    }
}


