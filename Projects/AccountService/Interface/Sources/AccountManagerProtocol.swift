
import Foundation
import AppEntity

public protocol AccountManagerProtocol: Actor {
    func setupAccount() async throws
    func account() async throws -> AppEntity.AccountSetting
    func updateAccount(_ account: AppEntity.AccountSetting) async throws
}

public enum AccountError: Error, LocalizedError {
    case chanceExpired
    case noExistingAccount
    case alreadyUsedCoupon
    case expiredCoupon
    
    public var errorDescription: String? {
        switch self {
        case .chanceExpired:
            return "횟수를 모두 사용했습니다. 설정-계정에서 충전해보세요."
        case .noExistingAccount:
            return ""
        case .alreadyUsedCoupon:
            return "이미 사용한 쿠폰입니다."
        case .expiredCoupon:
            return "만료된 쿠폰입니다."
        }
    }
}


public actor AccountManagerMock: AccountManagerProtocol {
    
    private var account: AccountSetting
    public init(account: AccountSetting) {
        self.account = account
    }
    public func setupAccount() async throws {
        
    }
    
    public func account() async throws -> AppEntity.AccountSetting {
        return account
    }
    
    public func updateAccount(_ account: AppEntity.AccountSetting) async throws {
        self.account = account 
    }
    
    
    private var availableCoupons: [(identity: String, chatChances: Int, ttsChances: Int)] = []
    
    public func updateAvailableCoupons(_ coupons: [(identity: String, chatChances: Int, ttsChances: Int)]) async throws {
        availableCoupons = coupons
    }
  
}
