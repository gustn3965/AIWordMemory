import Foundation


// 기본 사용자 단어 db
public struct WordMemory: Sendable, Hashable {
    public var identity: String
    public var word: String
    public var meaning: String
    public var createAt: Date
    public var correctCount: Int = 0
    
    public var tags: [WordTag] // tag를 여러개가질 수 있다. 없으면 빈어레이.
    public var sentences: [WordMemorySentence]
    
    public init(identity: String, word: String, meaning: String, createAt: Date, correctCount: Int = 0, tags: [WordTag] = [], sentences: [WordMemorySentence] = []) {
        self.identity = identity
        self.word = word
        self.meaning = meaning
        self.createAt = createAt
        self.correctCount = correctCount
        self.tags = tags
        self.sentences = sentences
    }
}
