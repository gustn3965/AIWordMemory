import Foundation
import Testing
import AIImplementation


extension Tag {
    @Tag static var chatGPT: Self
}

@Suite("ChatGPT Test", .tags(.chatGPT))
struct GPTTest {
    
    let setting: ChatGPTSetting = ChatGPTSetting(apiKey: "",
                                                 numberOfResonse: 1,
                                                 gptModel: "gpt-4o",
                                                 maxTokenResponse: 300)
    @Test("영어->한국어 테스트")
    func test() async throws {
        
        let response = try await ChatGPTManager(chatGPTSetting: setting).fetchChatGPTResponse(request: ChatGPTRequest.initFetchSentence(prompt:
"""
A 단어: 기대하다
뜻: expect

단어(A) 이용한 문장을 3개만 만들어줘. 
문장에 사용된 단어(A) 알려주는데 대신 사용된 단어(A)가 미래형이든 과거형이든 변형됐으면 변형된 단어로 알려줘

[예시]: 
[해석]: 
[사용된 단어(A)]:

이런형식으로 답변해줘
"""
                                                                                                   ))
        if let choice = response.choices.first {
            let responseText = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            print(responseText)
            
            
        } else {
            let errorMessage = "GPT로부터 응답이 없습니다."
        }
    }
    
    @Test("한국어->영어 테스트")
    func testToEnglish() async throws {
        let response = try await ChatGPTManager(chatGPTSetting: setting).fetchChatGPTResponse(request: ChatGPTRequest.initFetchSentence(prompt: """
A 단어: expect
뜻: 기대하다

단어(A) 이용한 문장을 3개만 만들어줘. 
문장에 사용된 단어(A) 알려주는데 대신 사용된 단어(A)가 미래형이든 과거형이든 변형됐으면 변형된 단어로 알려줘

[예시]: 
[해석]: 
[사용된 단어(A)]:

이런형식으로 답변해줘
"""
                                                                                                   ))
        
        print(response.choices.count)
        
        if let choice = response.choices.first {
            let responseText = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            print(responseText)
                                                               
        } else {
            let errorMessage = "GPT로부터 응답이 없습니다."
        }
    }
    
    
    @Test("GPT 응답 -> AIInterface응답 변환 테스트 ")
    func testParser() async throws {
        let response = try await ChatGPTManager(chatGPTSetting: setting).fetchChatGPTResponse(request: ChatGPTRequest.initFetchSentence(prompt: """
A 단어: 기대하다
뜻: expect

단어(A) 이용한 문장을 3개만 만들어줘. 
문장에 사용된 단어(A) 알려주는데 대신 사용된 단어(A)가 미래형이든 과거형이든 변형됐으면 변형된 단어로 알려줘

[예시]: 
[해석]: 
[사용된 단어(A)]:

이런형식으로 답변해줘
"""
                                                                                                   ))
        // 예시 응답을 추출하는 과정
//        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        
        let parsedResponse = ResponseParser.parse(response: response)
        if let parsedResponse = parsedResponse {
            print(parsedResponse)
            print(parsedResponse.examples.count)
        } else {
            print("응답을 파싱하는 데 실패했습니다.")
        }
    }
    
}
