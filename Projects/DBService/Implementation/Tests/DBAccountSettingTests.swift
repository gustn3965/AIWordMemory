//
//  DBAccountSetting.swift
//  DBImplementation
//
//  Created by 박현수 on 1/7/25.
//

import Foundation
import DBImplementation
import DBInterface
import Testing
import AppEntity
import AccountInterface

extension DBTests {
    @Suite(" AccountSetting 테스트", .serialized, .tags(.dbSwiftData))
    class DBAccountSettingTests {
        
        
        init() {
            print("init")
        }
        
        deinit {
            print("deinit")
        }
        
        @Test("한번만 생성할 수 있다")
        func 한번만생성가능() async throws {
            
            let database =  DataBaseSwiftData.shared
            await database.setup(container: .inMemory)
            
            
            try await database.setupAccount()
            try await database.setupAccount()
            try await database.setupAccount()
            
            let count = try await database.testFetchAccountSetting().count
            #expect(count == 1)
        }
        
        @Test("수정간으하다")
        func canEdit() async throws {
            
            let database = DataBaseSwiftData.shared
            await database.setup(container: .inMemory)
            
            
            try await database.setupAccount()
            
            var account = try await database.account()
            account.chatGPTChances = 10000
            
            try await database.updateAccount(account)
            
            let updated = try await database.account()
            #expect(updated.chatGPTChances == 10000)
        }
        
//        @Test("유효쿠폰목록이 있고 사용한적 없다면 사용가능하다")
//        func canUseCoupon() async throws {
//            
//            let database = DataBaseSwiftData.shared
//            await database.setup(container: .inMemory)
//            
//            
//            try await database.setupAccount()
//            try await database.updateAvailableCoupons([(identity: "ABCD", chatChances: 50, ttsChances: 10)])
//            
//            do {
//                try await database.useCoupon("ABCD")
//                #expect(true)
//            } catch {
//                #expect(Bool(false))
//            }
//        }
//        
//        @Test("유효쿠폰목록이 있고 사용한적 없다면 사용가능하고 횟수증가한다.")
//        func canUseCoupon2() async throws {
//            
//            let database = DataBaseSwiftData.shared
//            await database.setup(container: .inMemory)
//            
//            
//            try await database.setupAccount()
//            var account = try await database.account()
//            account.chatGPTChances = 0
//            account.ttsChances = 0
//            try await database.updateAccount(account)
//            
//            try await database.updateAvailableCoupons([(identity: "ABCD", chatChances: 50, ttsChances: 10)])
//            
//            do {
//                try await database.useCoupon("ABCD")
//                
//                let newAccount = try await database.account()
//                #expect(newAccount.chatGPTChances == 50 && newAccount.ttsChances == 10)
//            } catch {
//                #expect(Bool(false))
//            }
//        }
//        
//        @Test("유효쿠폰목록이 있고 사용한적 있다면 사용할수없다.")
//        func cantUseCoupon() async throws {
//            
//            let database = DataBaseSwiftData.shared
//            await database.setup(container: .inMemory)
//            
//            
//            try await database.setupAccount()
//            try await database.updateAvailableCoupons([(identity: "ABCD", chatChances: 50, ttsChances: 10)])
//            var account = try await database.account()
//            account.usedCouponList = ["ABCD"]
//            try await database.updateAccount(account)
//            
//            do {
//                try await database.useCoupon("ABCD")
//                #expect(Bool(false))
//            } catch {
//                if let error = error as? AccountError {
//                    #expect(error == .alreadyUsedCoupon)
//                } else {
//                    #expect(Bool(false))
//                }
//                
//            }
//        }
//        
//        @Test("유효쿠폰목록이 없다면 쿠폰 사용할수없다.")
//        func expiredCoupon() async throws {
//            
//            let database = DataBaseSwiftData.shared
//            await database.setup(container: .inMemory)
//            
//            
//            try await database.setupAccount()
//            try await database.updateAvailableCoupons([])
//            
//            do {
//                try await database.useCoupon("ABCD")
//                #expect(Bool(false))
//            } catch {
//                if let error = error as? AccountError {
//                    #expect(error == .expiredCoupon)
//                } else {
//                    #expect(Bool(false))
//                }
//                
//            }
//        }
    }
}
