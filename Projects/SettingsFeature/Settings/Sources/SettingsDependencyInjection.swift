//
//  DependencyInjection.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation
import DBInterface
import AccountInterface
import StoreKitService
public protocol SettingsDependencyInjection {
    
    func isAvailablePurchase() -> Bool
    
    func isAvailableRewardAdmob() -> Bool
    
    func isAvailableAI() -> Bool
    
    func makeMenuList() -> [SettingMenuList]
    
    func makeDBImplementation() -> DataBaseProtocol
    
    func makeAccountImplementation() -> AccountManagerProtocol
    
    func changeSpeechImplementation() -> String
    
    func storeKitServiceImplementation() -> StoreKitManager
    
    func getAppVersion() -> (currentVersion: String, updateVersion: String)
}

public enum SettingMenuList: Int, Identifiable, Hashable  {
    
    enum Group: Int, CaseIterable, Identifiable, Hashable {
        var id: Int { self.rawValue }
        
        case announce
        case account
        case test  // cbt, mock 용
    }
    
    case notice
    case feedback
    case appInfo
    case account
    case tag
    
    case cbtChagneSpeechImplementation
    case cbtResetGPTChances
    case cbtResetAppStorage
    
    public var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .notice:
            "공지사항"
        case .feedback:
            "건의사항"
        case .appInfo:
            "앱 정보"
        case .account:
            "계정"
        case .tag:
            "태그 관리"
            
            
        case .cbtChagneSpeechImplementation:
            "Speech 변경"
        case .cbtResetGPTChances:
            "gpt 횟수 초기화"
        case .cbtResetAppStorage:
            "UserDefault 초기화, gpt횟수증가"
        }
    }
    
    var iconName: String {
        switch self {
        case .notice:
            "mingcute_announcement-fill-light"
        case .feedback:
            "ic_round-feedback-light"
        case .appInfo:
            "si_info-fill-light"
        case .account:
            "mdi_account-circle-light"
        case .tag:
            "gridicons_tag-light"
            
            
        case .cbtChagneSpeechImplementation, .cbtResetGPTChances, .cbtResetAppStorage:
            "fluent-mdl2_test-auto-solid-light"
        }
    }
    
    var group: Group {
        switch self {
        case .notice:
            return .announce
        case .feedback:
            return .announce
        case .appInfo:
            return .announce
        case .account:
            return .account
        case .tag:
            return .account
            
            
        case .cbtChagneSpeechImplementation, .cbtResetGPTChances, .cbtResetAppStorage:
            return .test
        }
    }
    
}
public class SettingsMockDIContainer: SettingsDependencyInjection {
    
    private var dbService: DataBaseProtocol
    private var accountService: AccountManagerProtocol
    
    public init() {
        let database = MockInMemoryDatabase.shared
        
        Task {
            await database.setup(includeDefaultData: false)
        }
        dbService = database
        accountService = AccountManagerMock(account: .init(identity: UUID().uuidString,
                                                           chatGPTChances: 0,
                                                           ttsChances: 0,
                                                           lastUpdated: .now,
                                                           usedCouponList: []))
    }
    
    public func makeMenuList() -> [SettingMenuList] {
        
        return [.notice, .feedback, .appInfo, .account, .tag, .cbtChagneSpeechImplementation, .cbtResetGPTChances]
    }
    
    public func changeSpeechImplementation() -> String {
        return "mock...."
    }
    
    public func makeDBImplementation() -> DataBaseProtocol {
        dbService
        
    }
    
    public func makeAccountImplementation() -> any AccountManagerProtocol {
        return accountService
    }
    
    public func isAvailableAI() -> Bool {
        return true
    }
    
    public func isAvailableRewardAdmob() -> Bool {
        return true
    }
    
    public func isAvailablePurchase() -> Bool {
        return true
    }
    
    public func purchaseFirst() async throws {
        
    }
    
    public func storeKitServiceImplementation() -> StoreKitManager {
        StoreKitManager(purcahaseChatGPTChances: 200,
                        purchaseTTSChances: 100)
    }
    
    public func getAppVersion() -> (currentVersion: String, updateVersion: String) {
        return ("1.1.5", "1.2.0")
    }
}
