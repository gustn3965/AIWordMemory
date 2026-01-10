//
//  AccountViewModel.swift
//  Settings
//
//  Created by 박현수 on 1/10/25.
//

import Foundation
import AccountInterface
import DBInterface
import Combine

@MainActor class AccountViewModel: ObservableObject {
    
    var accountService: AccountManagerProtocol
    var dbService: DataBaseProtocol
    
    @Published var isSubsriber: Bool = false
    @Published var chatGPTChances: Int = 0
    @Published var aiSpeakingChances: Int = 0
    @Published var isAvailableServer: Bool = false
    
    @Published var showCouponButton: Bool = false   // 서버컨트롤
    @Published var showAdvertiseButton: Bool = false // 광고컨트롤
    @Published var showPurchaseButton: Bool = false  // 구매컨트롤  & 서버컨트롤
    
   
    var cancellable = Set<AnyCancellable>()
    
    init(accountService: AccountManagerProtocol, dbService: DataBaseProtocol, isAvailableAI: Bool, availableRewardAdmob: Bool, availablePurhase: Bool) {
        self.accountService = accountService
        self.dbService = dbService
        self.isAvailableServer = isAvailableAI
        
        if isAvailableAI == false {
            showCouponButton = false
            showAdvertiseButton = false
            showPurchaseButton = false
        } else {
//            showCouponButton = isAvailableAI // 앱리젝사유.. 앱구매없이 쿠폰제공하지말라함;
            showAdvertiseButton = availableRewardAdmob
            showPurchaseButton = availablePurhase  // 구매 주입
        }
        
        
        dbService.updatePulbisher
            .sink { [weak self] _ in
                Task {
                    await self?.fetch()
                }
            }
            .store(in: &cancellable)
        
    }
    
    func fetch() async {
        do {
            let account = try await accountService.account()
            chatGPTChances = account.chatGPTChances
            aiSpeakingChances = account.ttsChances
            
        } catch {
            
        }
        
    }

}
