//import SwiftUI
//
//public struct ContentView: View {
//    public init() {}
//
//    public var body: some View {
//        Text("{{name}}")
//            .padding()
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//

import SpeechVoiceInterface
import AVFoundation
import AccountInterface
import ClockImplementation

@globalActor public actor SpeechVoiceGPTManager: SpeechVoiceInterface {
    public var accountManager: AccountManagerProtocol?
    public func setAccountManager(accountManager: AccountManagerProtocol) async  {
        self.accountManager =  accountManager
    }
    
    public static let shared: SpeechVoiceGPTManager = SpeechVoiceGPTManager()
    
    var gpt: SpeechGPTManager?
    var cacheManager: SpeechCacheManager = SpeechCacheManager()
    
    private var task: Task<Void, Error>?
    
    private init() {}
    
    public func setup(key: String, model: String) async {
        
        // model - https://platform.openai.com/docs/models#tts
        let gptSetting = SpeechGPTSetting(apiKey: key, model: model)
        gpt = await SpeechGPTManager(setting: gptSetting)
        
    }
    
    public func speak(content: String, identity: String) async throws {
        guard let gpt = gpt else {
            throw NetworkError.missingGPT
        }
        
        
        let cachedAudioData = cacheManager.loadData(forKey: identity)
        if let cachedAudioData = cachedAudioData {
            try await gpt.playAudio(from: cachedAudioData)
        } else {
            task?.cancel()
            task = Task {
                
                guard let account = try await accountManager?.account() else {
                    throw AccountError.noExistingAccount
                }
                if account.ttsChances <= 0 {
                    throw AccountError.chanceExpired
                }
                
                let data = try await gpt.fetchAudio(text: content)
                
                guard var account = try await accountManager?.account() else {
                    throw AccountError.noExistingAccount
                }
                if account.ttsChances <= 0 {
                    throw AccountError.chanceExpired
                } else {
                    account.ttsChances -= 1
                    account.lastUpdated = await ClockManager.shared.fetchClock()
                    try await accountManager?.updateAccount(account)
                }
                
                try await gpt.playAudio(from: data)
                
                cacheManager.saveData(data, forKey: identity)
            }
            try await task?.value
        }
    }
}
