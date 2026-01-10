//
//  WordMemoryDIContainer.swift
//  WordMemoryApp
//
//  Created by 박현수 on 1/2/25.
//

import Foundation

import Review
import MainHome
import Search
import SentenceInspector
import Recommend
import Settings


import AIImplementation
import AIInterface

import DBInterface
import DBImplementation

import SpeechVoiceInterface
import SpeechVoiceImplementation
import AccountInterface
import StoreKitService



public class ServerStatus: ObservableObject, @unchecked Sendable {
    @Published var admobBannerId: String = ""
    @Published var admobRewardID: String = ""
    @Published var needUpdateApp: String = ""
    @Published var updateVersion: String = ""
    
    var availablePurchase: Bool = false  // false 설정>계정>구매 제거
    var availableRewardAdmob: Bool = false // false 메인하단광고 제거, 설정>계정>광고 제거
    nonisolated(unsafe) var availableAI: Bool = false        // false 쿠폰,구매,광고 제거
    
    func changeAdmobBannerId(_ banner: String) {
#if MOCK
        self.admobBannerId = "ca-app-pub-3940256099942544/2435281174"    // test
#elseif CBT
        self.admobBannerId = "ca-app-pub-3940256099942544/2435281174"
#else
        self.admobBannerId = banner
#endif
    }
    func changeAdmobRewardID(_ banner: String) {
#if MOCK
        self.admobRewardID = "ca-app-pub-3940256099942544/1712485313"         // test
#elseif CBT
        self.admobRewardID = "ca-app-pub-3940256099942544/1712485313"         // test
#else
        self.admobRewardID = banner
#endif
        
    }
    
    func changeAvailablePurchase(_ availablePurchase: Bool) {
        self.availablePurchase = availablePurchase
    }
    
    func changeAvailableRewardAdmob(_ availableAdvertise: Bool) {
        self.availableRewardAdmob = availableAdvertise
    }
    
    func changeAvailableAI(_ availableAI: Bool) {
        self.availableAI = availableAI
    }
}

public class WordMemoryDIContainer: ReviewDependencyInjection,
                                    MainHomeDependencyInjection,
                                    SearchDependencyInjection,
                                    SentenceInspectorDependencyInjection,
                                    RecommendDependencyInjection,
                                    SettingsDependencyInjection,
                                    ObservableObject {
    
    @Published var dbService: DataBaseProtocol
    @Published var aiService: AIInterface
    @Published var speechVoiceService: SpeechVoiceInterface
    @Published var appleSpeechVoiceService: SpeechVoiceInterface
    @Published var accountService: AccountManagerProtocol
    @Published var serverStatus: ServerStatus
    @Published var storeKit: StoreKitManager
    
    // 비동기 초기화를 위한 private init
    private init(dbService: DataBaseProtocol, aiService: AIInterface, speechVoiceService: SpeechVoiceInterface, appleSpeechVoiceService: SpeechVoiceInterface, accountService: AccountManagerProtocol, serverStatus: ServerStatus,
                 storeKit: StoreKitManager) {
        self.dbService = dbService
        self.aiService = aiService
        self.speechVoiceService = speechVoiceService
        self.appleSpeechVoiceService = appleSpeechVoiceService
        self.accountService = accountService
        self.serverStatus = serverStatus
        self.storeKit = storeKit
    }
    
    public static func create() -> WordMemoryDIContainer {
        let dbService: DataBaseProtocol
        let aiService: AIInterface
        let speechVoiceService: SpeechVoiceInterface
        let appleSppechVoiceService: SpeechVoiceInterface
        let accountService: AccountManagerProtocol
        let serverStatus: ServerStatus
        let storeKit = StoreKitManager(purcahaseChatGPTChances: Self.purchaseChatGPTChances(),
                                       purchaseTTSChances: Self.purchaseTTSChances())
        
#if MOCK
        let database = MockInMemoryDatabase.shared
        dbService = database
        aiService = AIMockImplementation()
        speechVoiceService = SpeechVoiceAppleManager.shared
        appleSppechVoiceService = SpeechVoiceAppleManager.shared
        accountService = AccountManagerMock(account: .init(identity: UUID().uuidString,
                                                           chatGPTChances: 0, ttsChances: 0, lastUpdated: .now, usedCouponList: []))
        serverStatus = ServerStatus()
        serverStatus.changeAvailableAI(true)
        serverStatus.changeAvailablePurchase(true)
        serverStatus.changeAvailableRewardAdmob(true)
        Task {
            await database.setup(includeDefaultData: true)
        }
#else
        
        
        let database = DataBaseSwiftData.shared
        let gptManager = AIGPTManager.shared
        let speechGPT = SpeechVoiceGPTManager.shared
        let lazyServerStatus = ServerStatus()
        
        dbService = database
        aiService = gptManager
        speechVoiceService = speechGPT
        appleSppechVoiceService = SpeechVoiceAppleManager.shared
        accountService = database
        serverStatus = lazyServerStatus
        
        Task {
            await database.setup(container: .real)
            do {
                try await accountService.setupAccount()
                await aiService.setAccountManager(accountManager: database)
                await speechVoiceService.setAccountManager(accountManager: database)
            } catch {
                
            }
            
            
            let cloudkit = CloudKitManager()
           
            do {
                let response = try await cloudkit.fetchAPIKey()
                let (needUpdate, updateVersion) = await cloudkit.isNeedUpdateApp()
                await MainActor.run {
                    serverStatus.changeAdmobBannerId(response.admobBannerID)
                    lazyServerStatus.changeAdmobRewardID(response.admobRewardID)
                    lazyServerStatus.changeAvailableRewardAdmob(response.admobRewardAvailable == 1 ? true : false)
                    lazyServerStatus.changeAvailableAI(response.availableServer == 1 ? true : false)
                    serverStatus.needUpdateApp = needUpdate ? Self.isKorean() ? response.updateAppDescriptionKR : response.updateAppDescriptionEN : ""
                    serverStatus.updateVersion = updateVersion
                }
                
                await gptManager.setup(setting: ChatGPTSetting(apiKey: response.openAIKey,
                                                               numberOfResonse: 1,
                                                               gptModel: response.chatGPTModel,
                                                               maxTokenResponse: response.maxResponseToken))
                await speechGPT.setup(key: response.openAIKey, model: response.ttsModel)
            } catch {
                print(error)
            }
       
            
            do {
                await storeKit.setup()
                lazyServerStatus.changeAvailablePurchase(storeKit.availableProducts.isEmpty == false)
            }
            
        }
#endif
        
        return WordMemoryDIContainer(dbService: database,
                                     aiService: aiService,
                                     speechVoiceService: speechVoiceService,
                                     appleSpeechVoiceService: appleSppechVoiceService,
                                     accountService: accountService,
                                     serverStatus: serverStatus,
                                     storeKit: storeKit)
    }
    
    public func makeAccountImplementation() -> any AccountManagerProtocol {
        return accountService
    }
    
    public func makeSpeechVoiceImplementation() -> any SpeechVoiceInterface {
        return speechVoiceService
    }
    
    public func makeSpecchAppleVoiceImplementation() -> any SpeechVoiceInterface {
        return appleSpeechVoiceService
    }
    
    
    public func makeAIImplementation() -> any AIInterface {
        return aiService
    }
    
    public func makeDBImplementation() -> any DBInterface.DataBaseProtocol {
        return dbService
    }
    
    public func changeSpeechVoiceImplementation() {
        if let _ = speechVoiceService as? SpeechVoiceGPTManager {
            speechVoiceService = SpeechVoiceAppleManager.shared
        } else {
            speechVoiceService = SpeechVoiceGPTManager.shared
        }
    }
    
    public func makeMenuList() -> [SettingMenuList] {
#if MOCK
        return [.notice, .feedback, .appInfo, .account, .tag, .cbtChagneSpeechImplementation, .cbtResetGPTChances, .cbtResetAppStorage]
#elseif CBT
        return [.notice, .feedback, .appInfo, .account, .tag, .cbtChagneSpeechImplementation, .cbtResetGPTChances, .cbtResetAppStorage]
#else
        return [.notice, .feedback, .appInfo, .account, .tag,]
#endif
    }
    
    public func changeSpeechImplementation() -> String {
        print("# \(#file) \(#function)")
        if let _ = speechVoiceService as? SpeechVoiceGPTManager {
            speechVoiceService = SpeechVoiceAppleManager.shared
            return "Default Apple Speech"
        } else {
            speechVoiceService = SpeechVoiceGPTManager.shared
            return "openAI GPT Speech"
        }
    }
    
    
    
    public func isAvailableAI() -> Bool {
        return self.serverStatus.availableAI
    }
    
    public func isAvailableRewardAdmob() -> Bool {
        return self.serverStatus.availableRewardAdmob
    }
    
    public func isAvailablePurchase() -> Bool {
        return self.serverStatus.availablePurchase
    }
    
    
    public func storeKitServiceImplementation() -> StoreKitManager {
        self.storeKit
    }
    
    public func getAppVersion() -> (currentVersion: String, updateVersion: String) {
        return (Bundle.main.releaseVersionNumber ?? "", serverStatus.updateVersion)
    }
}



extension WordMemoryDIContainer {
    public func maxWordLength() -> Int {
        return 100
    }
    public func maxMeaningLength() -> Int {
        return 100
    }
    
    // 보상형 광고 admob
    public func rewardChatGPTChances() -> Int {
        return 20
    }
    
    public func rewardTTSChances() -> Int {
        return 5
    }
    
    
    // 구매시
    public static func purchaseChatGPTChances() -> Int {
        return 200
    }
    
    public static func purchaseTTSChances() -> Int {
        return 100
    }
    
    private static func isKorean() -> Bool {
        let languageCode = Locale.current.language.languageCode?.identifier
        return languageCode == "ko"
    }
}
