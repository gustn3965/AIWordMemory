//
//  StoreKitViewModel.swift
//  Settings
//
//  Created by 박현수 on 1/14/25.
//

import Foundation
import StoreKitService
import AccountInterface

@MainActor class StoreKitViewModel: ObservableObject {
    var accountService: AccountManagerProtocol
    var storeKitService: StoreKitManager
    
    init(accountService: AccountManagerProtocol, storeKitService: StoreKitManager) {
        self.accountService = accountService
        self.storeKitService = storeKitService
    }
    
    func purchaseFirst() async throws {
//        try? await Task.sleep(nanoseconds: 2_000_000_000)
        try await storeKitService.purchaseFirst()
        
//        var account = try await accountService.account()
//        account.chatGPTChances += await storeKitService.purchaseChatGPTChances
//        account.ttsChances += await storeKitService.purchaseTTSChances
//        try await accountService.updateAccount(account)
        
    }
}
