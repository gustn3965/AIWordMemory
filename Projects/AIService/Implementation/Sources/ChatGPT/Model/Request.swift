//
//  Request.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
public struct ChatGPTRequest: Codable {
    let messages: [Message]
    let temperature: Double
    let stop: [String]?
    
    struct Message: Codable {
        let role: String // "system", "user", "assistant"
        let content: String
    }
    
    private init(prompt: String,
                 system: String,
                temperature: Double = 0.7,
                stop: [String]? = nil) {
        self.messages = [
            Message(role: "system", content: system),
            Message(role: "user", content: prompt)
        ]
        self.temperature = temperature
        self.stop = stop
    }
    
    public static func initFetchSentence(prompt: String) -> ChatGPTRequest {
        ChatGPTRequest(prompt: prompt, system: "당신은 도움이 되는 AI 비서입니다.")
    }
    
    public static func initSearch(prompt: String) -> ChatGPTRequest {
        ChatGPTRequest(prompt: prompt, system: "당신은 언어 전문가이자 친절한 튜터입니다. 새로운 언어를 배우는 사람들이 단어의 의미, 발음, 예문 등을 이해할 수 있도록 돕습니다. 반딋 무조건 다양한언어로 응답해야합니다.")
    }
    
    public static func initRecommend(prompt: String) -> ChatGPTRequest {
        ChatGPTRequest(prompt: prompt, system: "당신은 언어 전문가이자 친절한 튜터입니다. Exclude에 없는 단어들로만 반드시 추천해야합니다.")
    }
}

public struct ChatGPTBaseRequest: Codable {
    let model: String
    let messages: [ChatGPTRequest.Message]
    let max_tokens: Int
    let temperature: Double
    let n: Int
    let stop: [String]?
    
    public init(request: ChatGPTRequest, model: String, numberOfResponse: Int, max_tokens: Int) {
        self.model = model
        self.messages = request.messages
        self.max_tokens = max_tokens
        self.temperature = request.temperature
        self.n = numberOfResponse
        self.stop = request.stop
    }
}






