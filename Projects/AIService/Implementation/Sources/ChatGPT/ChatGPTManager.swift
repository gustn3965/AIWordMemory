//
//  GPTNetwork.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation



import Foundation



public actor ChatGPTManager {
    
    public init(chatGPTSetting: ChatGPTSetting) {
        self.setting = chatGPTSetting
    }
    
    private let setting: ChatGPTSetting
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    public func fetchChatGPTResponse(request: ChatGPTRequest) async throws -> ChatGPTResponse {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        
        let baseRequest = ChatGPTBaseRequest(request: request,
                                             model: setting.gptModel,
                                             numberOfResponse: setting.numberOfResonse,
                                             max_tokens: setting.maxTokenResponse)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(setting.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(baseRequest)
        
        
        print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
        print("---------------------reequest...........\(request)")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("---------------------get...........")
        // HTTP 응답 상태 코드 확인
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print(String(data: data, encoding: .utf8))
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8) ?? "알 수 없는 오류")
        }
        
        // 응답 디코딩
        let decoder = JSONDecoder()
        if let dataString = String(data: data, encoding: .utf8) {
            print("Response data as string: \(dataString)")
        } else {
            print("Unable to convert data to string")
        }
        let chatGPTResponse = try decoder.decode(ChatGPTResponse.self, from: data)
        
        return chatGPTResponse
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, message: String)
    case decodingError
    case parserErrorToAIInterface
    case unknown
    case missingGPT
    
    var errorDescription: String? {
        switch self {
        
        case .missingGPT:
            return "gpt 모델 초기화하지못했습니다."
        default:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}


