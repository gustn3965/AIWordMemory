//
//  DatabaseSwiftData+AccountManagerProtocol.swift
//  DBImplementation
//
//  Created by 박현수 on 1/9/25.
//

import Foundation
import SwiftData
import AccountInterface
import AppEntity

// Account 계정을 일단 swiftData에 저장하는걸로. 서버연동하는게 좋을듯하나, 아직은..비용고려..
extension DataBaseSwiftData: AccountManagerProtocol {
    
    public func setupAccount() async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        await modelActor.initAccountSetting()
    }
    
    public func account() async throws -> AppEntity.AccountSetting {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        return try await modelActor.fetchAccountSetting()
    }
    
    public func updateAccount(_ account: AccountSetting) async throws {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        try await modelActor.updateAccountSetting(account)
        await MainActor.run {
            updatePulbisher.send(.updateAccount)
        }
    }
    
    public func testFetchAccountSetting() async throws -> [AppEntity.AccountSetting] {
        guard let modelActor = modelActor else { fatalError("Database not setup") }
        return try await modelActor.testFetchAccountSetting()
    }
    
}


extension DataBase {
    func initAccountSetting() {
        let existed = try? fetchAccountSetting()
        if existed == nil {
            let account = DBAccountSetting(identity: UUID().uuidString,
                                           chatGPTChances: 30,
                                           ttsChances: 20,
                                           lastUpdated: Date(), usedCoupons: [])
            modelContext.insert(account)
            try? modelContext.save()
        }
    }
    
    
    func fetchAccountSetting() throws -> AccountSetting {
        
        // cloud연동하면.. .연동되기전에 첫설치시 생성하므로.. 이미 이전에 생성해둔걸로 가져오도록함. 쿠폰은 뭐..중요하지않으니 냅두고..
        // updateAccountSetting,  useCoupon 둘다 수정
        
        let list = try modelContext.fetch(fetchDescriptorAccount())
        
        for account in list {
            print(account.createAt)
        }
        if let existingAccount = list.first {
            return existingAccount.makeAccountSEtting()
        } else {
            throw AccountError.noExistingAccount
        }
    }
    
    func updateAccountSetting(_ account: AccountSetting) async throws {
        
        let list = try modelContext.fetch(fetchDescriptorAccount())
        if let existingAccount = list.first {
            existingAccount.identity = account.identity
            existingAccount.chatGPTChances = account.chatGPTChances
            existingAccount.ttsChances = account.ttsChances
            existingAccount.lastUpdated = account.lastUpdated
            existingAccount.usedCoupons = account.usedCouponList
            try modelContext.save()
        } else {
            throw AccountError.noExistingAccount
        }
    }
   
    private func fetchDescriptorAccount() -> FetchDescriptor<DBAccountSetting> {
        let sortDescriptor = SortDescriptor<DBAccountSetting>(\.createAt, order: .forward)
        let fetchDescriptor = FetchDescriptor<DBAccountSetting>(predicate: #Predicate { _ in true }, sortBy: [sortDescriptor])
        return fetchDescriptor
    }
    

    
    func testFetchAccountSetting() throws -> [AccountSetting] {
        
        let fetchDescriptor = FetchDescriptor<DBAccountSetting>(predicate: #Predicate { _ in true })
        return try modelContext.fetch(fetchDescriptor).map { $0.makeAccountSEtting() }
    }
    
}

extension DBAccountSetting {
    func makeAccountSEtting() -> AccountSetting {
        AccountSetting(identity: identity, chatGPTChances: chatGPTChances, ttsChances: ttsChances, lastUpdated: lastUpdated, usedCouponList: usedCoupons)
    }
}
