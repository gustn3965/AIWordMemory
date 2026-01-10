//
//  AIGPTManagerTests.swift
//  AIImplementationUnitTest
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import Testing
import AIImplementation
import AppEntity
import AIInterface
import AccountInterface

@Suite("ChatGPTManager Test", .tags(.chatGPT))
struct AIGPTManagerTests {

    
    @Test("chatGPT 횟수가 0이면 받아오지못한다")
    func cantfetchAIIfGPT() async throws {
        let mockAccountManager = AccountManagerMock(account: AccountSetting(identity: UUID().uuidString, chatGPTChances: 0, ttsChances: 1, lastUpdated: .now, usedCouponList: []))
        
        let gptManager = AIGPTManager.shared
        await gptManager.setAccountManager(accountManager: mockAccountManager)
        let aiInterface: AIInterface = gptManager
        await gptManager.setup(setting: ChatGPTSetting(apiKey: "",
                                                       numberOfResonse: 1,
                                                       gptModel: "gpt-4o",
                                                       maxTokenResponse: 300))
        do {
            let response = try await aiInterface.fetchAIExample(word: WordMemory(identity: "zcvzxczxcvzxvc",
                                                                                word: "expect",
                                                                                 meaning: "기대하다", createAt: Date()), sentenceType: .description)
            #expect(Bool(false))
        } catch {
            if let error = error as? AccountError {
                #expect(error == .chanceExpired)
            } else {
                #expect(Bool(false))
            }
            
        }
        
        
    }
//    @Test("ai 요청하여 응답받아올수있다.")
//    func canFetchAI() async throws {
//        
//        let gptManager = AIGPTManager.shared
//        let aiInterface: AIInterface = gptManager
//        await gptManager.setup(setting: ChatGPTSetting(apiKey: "",
//                                                       numberOfResonse: 1,
//                                                       gptModel: "gpt-4o",
//                                                       maxTokenResponse: 300))
//        
//        let response = try await aiInterface.fetchAIExample(word: WordMemory(identity: "zcvzxczxcvzxvc",
//                                                                            word: "expect",
//                                                                            meaning: "기대하다", createAt: Date()))
//        
//        
//        #expect(response.count == 3)
//        print(response)
//        
//        /*
//         [예시]: She expected to receive a promotion by the end of the year.
//         [해석]: 그녀는 연말까지 승진할 것을 기대했다.
//         [사용된 예시 단어(A)]: expected
//         [사용된 해석 뜻(B)]: 기대했다
//
//         [예시]: We expect that the weather will be nice tomorrow.
//         [해석]: 우리는 내일 날씨가 좋을 것으로 기대한다.
//         [사용된 예시 단어(A)]: expect
//         [사용된 해석 뜻(B)]: 기대한다
//
//         [예시]: They will expect the project to be completed by next week.
//         [해석]: 그들은 다음 주까지 프로젝트가 완료될 것을 기대할 것이다.
//         [사용된 예시 단어(A)]: will expect
//         [사용된 해석 뜻(B)]: 기대할 것이다
//         */
//    }
//    
  
    

}
