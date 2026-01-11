//
//  SpeechTeests.swift
//  SpeechVoiceImplementationUnitTest
//
//  Created by 박현수 on 1/8/25.
//

import Foundation
import AppEntity
import Testing
import AccountInterface
import SpeechVoiceInterface
import SpeechVoiceImplementation

extension Tag {
    @Tag static var speechGPT: Self
}


@Suite("Speech GPT Test", .tags(.speechGPT))
struct AIGPTManagerTests {

  
    @Test("tts 횟수가 0이면 받아오지못한다")
    func cantfetchAIIfGPT() async throws {
        let mockAccountManager = AccountManagerMock(account: AccountSetting(identity: UUID().uuidString, chatGPTChances: 1, ttsChances: 0, lastUpdated: .now, usedCouponList: []))
        
        let gptManager = SpeechVoiceGPTManager.shared
        await gptManager.setAccountManager(accountManager: mockAccountManager)
        let speechInterface: SpeechVoiceInterface = gptManager
        await gptManager.setup(key: "", model: "tts-1")
        do {
            let _ = try await speechInterface.speak(content: "asdfasdf", identity: "asdfadsf")
            #expect(Bool(false))
        } catch {
            if let error = error as? AccountError {
                #expect(error == .chanceExpired)
            } else {
                #expect(Bool(false))
            }
            
        }
        
        
    }
    
    

}
