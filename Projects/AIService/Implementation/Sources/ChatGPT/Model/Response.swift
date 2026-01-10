//
//  Response.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation

public struct ChatGPTResponse: Codable, Sendable {
    let id: String
    let object: String
    let created: Int
    let model: String
    public let choices: [Choice]           // request의 n에 따라 여러개일수있음.
    public let usage: Usage
    
    public struct Choice: Codable, Sendable {
        public let index: Int
        public let message: Message
        public let finish_reason: String
    }
    
    public struct Message: Codable, Sendable {
        public let role: String
        public let content: String
    }
    
    public struct Usage: Codable, Sendable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}
