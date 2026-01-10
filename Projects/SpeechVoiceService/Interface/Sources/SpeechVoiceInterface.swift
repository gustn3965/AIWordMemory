
import Foundation
import AccountInterface
import AppEntity

public protocol SpeechVoiceInterface: Actor {
    var accountManager: AccountManagerProtocol? { get }
    func setAccountManager(accountManager: AccountManagerProtocol) async

    func speak(content: String, identity: String) async throws
    
}


public actor SpeechVoiceMock: SpeechVoiceInterface {
    public var accountManager:  AccountManagerProtocol? = AccountManagerMock(account: AccountSetting(identity: UUID().uuidString,
                                                                                                     chatGPTChances: 0,
                                                                                                     ttsChances: 0,
                                                                                                     lastUpdated: .now,
                                                                                                     usedCouponList: []))
    public func setAccountManager(accountManager: AccountManagerProtocol) async  {
        self.accountManager = accountManager
    }
    
    public init() {}
    
    public func speak(content: String, identity: String) async throws {
        
    }
}
