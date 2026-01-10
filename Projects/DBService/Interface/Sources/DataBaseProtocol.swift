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

import Foundation
import AppEntity
import Combine


public protocol DataBaseProtocol: Sendable {
    
//    static let shared: Self
   
    var updatePulbisher: PassthroughSubject<DataBaseUpdateType, Never> { get }
    
    func isWordEmpty() async throws -> Bool
    
    func addWord(word: WordMemory) async throws
    
    func deleteWord(identity: String) async throws
    
    func editWord(word: WordMemory) async throws
    
    func fetchWord(identity: String) async throws -> AppEntity.WordMemory?
    
    func fetchWordList(filter: SearchWordFilter) async throws -> [AppEntity.WordMemory]
    
    func fetchReviewList(filter: ReviewWordFilter) async throws -> [AppEntity.WordMemory]
    
    
    
    func addTag(tag: WordTag) async throws
    
    func deleteTag(identity: String) async throws
    
    func editTag(tag: WordTag) async throws 
    
    func fetchAllTags() async throws -> [AppEntity.WordTag]
    
    
    func fetchRecommendWords(languageType: SearchLangagueType,
                             explanationLanguageType: SearchLangagueType,
                             levelType: LanguageLevelType) async throws -> [WordRecommendMemory]?
    
    func saveRecommendWords(words: [WordRecommendMemory]) async throws
    
}

public enum DataBaseError: Error, LocalizedError {
    case duplicated
    case unknown
    case requiredNotFound
    
    public var errorDescription: String? {
        switch self {
        case .duplicated:
            return "중복된 항목입니다. 다른 값을 입력해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 나중에 다시 시도해주세요."
        case .requiredNotFound:
            return "필수 항목이 없습니다."
        }
    }
}

public enum DataBaseUpdateType: Sendable {
    case update(identity: String)
    case delete(identity: String)
    case add
    case updateAccount // 서버로 옮기면 없앨것 
}



