//
//  SpeechGPTManager.swift
//  SpeachVoiceImplementation
//
//  Created by 박현수 on 1/2/25.
//


import Foundation
import Combine
import AVFoundation

struct TTSRequest: Codable {
    let input: String
    let model: String
    let voice: String
    
}

public struct SpeechGPTSetting: Sendable  {
    let apiKey: String
    let model: String
    
    init(apiKey: String, model: String) {
        self.apiKey = apiKey
        self.model = model
    }
}

@MainActor
class SpeechGPTManager: ObservableObject {

    private var audioPlayer: AVAudioPlayer?
    private let setting: SpeechGPTSetting
    
    
    init(setting: SpeechGPTSetting) {
        self.setting = setting
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession 설정 오류: \(error)")
        }
    }
    
    func fetchAudio(text: String) async throws -> Data {
        // API 요청 구성
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(setting.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let tTSRequest = TTSRequest(input: text, model: setting.model, voice: "nova")
            request.httpBody = try JSONEncoder().encode(tTSRequest)
        } catch {
            print("Error encoding request: \(error)")
            throw error
        }
        
        // 네트워크 요청 수행
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(response)
        
        // 응답 확인
        // HTTP 응답 상태 코드 확인
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8) ?? "알 수 없는 오류")
        }
        return data
    }
    
    
    
    func playAudio(from data: Data) async throws {
        try await MainActor.run {
            do {
                // 기존 오디오 플레이어 중지
                audioPlayer?.stop()
                
                // 새로운 오디오 플레이어 초기화
                audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error initializing AVAudioPlayer: \(error)")
                throw error
            }
        }
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


