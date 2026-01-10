//
//  SpeackVoiceApple.swift
//  SpeachVoiceImplementation
//
//  Created by 박현수 on 1/2/25.
//

import SpeechVoiceInterface
import Foundation
import AVFoundation
import NaturalLanguage
import AccountInterface

@globalActor public actor SpeechVoiceAppleManager: NSObject, SpeechVoiceInterface {
    
    public static let shared: SpeechVoiceAppleManager = SpeechVoiceAppleManager()
    
    public var accountManager: AccountManagerProtocol?
    public func setAccountManager(accountManager: AccountManagerProtocol) async  {
        // apple 은 무료
    }
    
    let synthesizer: AVSpeechSynthesizer
    
    nonisolated(unsafe) private var continuation: CheckedContinuation<Void, Error>?
    
    private var task: Task<Void, Error>?
    private override init() {
        self.synthesizer = AVSpeechSynthesizer()
        super.init()
        self.synthesizer.delegate = self
        Task {
            try? await self.speak(content: "", identity: "") // 한번 실행해놓고 해야 다음부터 빠른듯 ?
        }
    }
    
    
    public func speak(content: String, identity: String) async throws {
        // 이미 합성이 진행 중이라면 중지

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        task?.cancel()
        
        task = Task {
            let text = content
            let languageRecognizer = NLLanguageRecognizer()
            languageRecognizer.processString(text)
            
            var detectedLanguage = identity
            if identity.isEmpty {
                detectedLanguage = languageRecognizer.dominantLanguage?.rawValue ?? "ko-KR"
            }
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: detectedLanguage)
            
            // 음성 합성 속성 조정 (필요시 수정)
            utterance.rate = 0.5 // 속도 (0.0 ~ 1.0)
            utterance.pitchMultiplier = 1.0 // 음조 (0.5 ~ 2.0)
            utterance.volume = 1.0 // 볼륨 (0.0 ~ 1.0)
            
            // Continuation 초기화
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.continuation = continuation
                self.synthesizer.speak(utterance)
            }
        }
        
        try await task?.value
    }
}

extension SpeechVoiceAppleManager: AVSpeechSynthesizerDelegate {
    
    nonisolated(unsafe)  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeak marker: AVSpeechSynthesisMarker, utterance: AVSpeechUtterance) {
        continuation?.resume()
        continuation = nil
    }
    nonisolated(unsafe) public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        continuation?.resume()
        continuation = nil
    }
    
    nonisolated(unsafe) public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        continuation?.resume(throwing: NSError(domain: "SpeechCancelled", code: -1, userInfo: [NSLocalizedDescriptionKey: "음성 합성이 취소되었습니다."]))
        continuation = nil
    }
    
    nonisolated(unsafe) public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFail utterance: AVSpeechUtterance, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
