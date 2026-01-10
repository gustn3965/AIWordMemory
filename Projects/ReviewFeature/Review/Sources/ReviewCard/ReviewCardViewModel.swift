//
//  ReviewCardViewModel.swift
//  Review
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import AppEntity
import AIInterface
import AVFoundation
import NaturalLanguage
import SpeechVoiceInterface
import DBInterface

@MainActor class ReviewCardViewModel: ObservableObject {
    
    @Published var showAnswer: Bool = false
    @Published var examples: [AIExample] = []
    @Published var isLoading = false
    
    var wordIdentity: String
    @Published var word: String
    @Published var answer: String
    
    var debouncer = DebounceObject()
    private let aiService: AIInterface
    private let dbService: DataBaseProtocol
    private let speechVoiceService: SpeechVoiceInterface
    private var wordMemory: WordMemory
    private let reviewType: ReviewStartFilter.ReviewType
    private let aiSentenceType: ReviewStartFilter.AISentenceType
    
    init(diContainer: ReviewDependencyInjection, wordMemory: WordMemory, reviewType: ReviewStartFilter.ReviewType, aiSentenceType: ReviewStartFilter.AISentenceType) {
        self.reviewType = reviewType
        self.aiSentenceType = aiSentenceType
        self.wordMemory = wordMemory
        switch reviewType {
        case .word:
            self.word = wordMemory.word
            self.answer = wordMemory.meaning
        case .meaning:
            self.word = wordMemory.meaning
            self.answer = wordMemory.word
        }
        self.examples = wordMemory.sentences.map { sentence in .fromWordSentence(sentence, reviewType: reviewType) }
        
        self.wordIdentity = wordMemory.identity
        self.aiService = diContainer.makeAIImplementation()
        self.dbService = diContainer.makeDBImplementation()
        self.speechVoiceService = diContainer.makeSpeechVoiceImplementation()
        
        print("cardViewModel init...\(self.word)")
        
    }
    
    var task: Task<Void, Error>?
    var actionTask: Task<Void, Error>?
    
    deinit {
        print("# \(#file) \(#function)")
        
        task?.cancel()
    }
    
    enum MemoryAction {
        case good
        case bad
    }
    
    func editMemoryAction(_ action: MemoryAction) async throws {
        wordMemory.correctCount = action == .good ? wordMemory.correctCount + 1 : wordMemory.correctCount - 1
        try await dbService.editWord(word: wordMemory)
    }
    
    
    func fetchAIExamples(force: Bool = false) async throws {
        if examples.isEmpty == false && force == false { return }
        if force {
            examples.removeAll()
        }
        
        // 1.gpt ai 생성,
        // 2.db update
        if isLoading { return }
        isLoading = true
        let sentences = try await aiService.fetchAIExample(word: wordMemory, sentenceType: aiSentenceType.aiModuleType)
        isLoading = false
        
        wordMemory.sentences = sentences
        try await dbService.editWord(word: wordMemory)
        
        examples = sentences.map { sentence in .fromWordSentence(sentence, reviewType: reviewType) }
        
        print("\(word) fetchAIExample success")
    }
    
    
    func speek(string: String, identity: String) async throws {
        if isLoading { return }
        isLoading = true
        try await speechVoiceService.speak(content: string, identity: identity)
        isLoading = false
    }
    
    
    func setShowAnswer() {
        showAnswer.toggle()
        
        examples.forEach {
            $0.showAnswer.toggle()
        }
    }
    
    
    
    class AIExample: Identifiable, ObservableObject {
        let id = UUID().uuidString
        var example: AttributedString           // 예문
        var answer: AttributedString
        @Published var translation: AttributedString
        
        var exampleIdentity: String
        var translationIdentity: String
        
        private var translationWithHidden: AttributedString      // 번역된 예문 - placeholder
        private var translationWithPlaceholder: AttributedString      // 번역된 예문 - placeholder
        
        @Published var showTranslation: Bool = false  // placehodler -> 번역된예문
        @Published var showAnswer: Bool = false // hint -> answer 보여주기
        
        init(example: AttributedString, exampleIdentity: String, translationIdentity: String, translationWithHidden: AttributedString, translationWithAnswer: AttributedString) {
            self.example = example
            self.exampleIdentity = exampleIdentity
            self.translationIdentity = translationIdentity
            self.answer = translationWithAnswer
            
            self.translationWithHidden = translationWithHidden
            var placeHolder = translationWithHidden
            placeHolder.backgroundColor = .systemGray
            placeHolder.foregroundColor = .clear
            self.translationWithPlaceholder = placeHolder
            self.translation = placeHolder
        }
        
        
        static func fromWordSentence(_ sentence: WordMemorySentence, reviewType: ReviewStartFilter.ReviewType) -> AIExample {
            switch reviewType {
            case .word:
                ReviewCardViewModel.AIExample(example: makeUnderline(isWord: true,
                                                                     sentence: sentence.example,
                                                                     underLine: sentence.usedWordInExample,
                                                                     isHiddenUnderline: false),
                                              exampleIdentity: sentence.exampleIdentity,
                                              translationIdentity: sentence.translationIdentity,
                                              translationWithHidden: makeUnderline(isWord: false,
                                                                                   sentence: sentence.translation,
                                                                                   underLine: sentence.usedWordInTranslation,
                                                                                   isHiddenUnderline: true),
                                              translationWithAnswer: makeUnderline(isWord: false,
                                                                                   sentence: sentence.translation,
                                                                                   underLine: sentence.usedWordInTranslation,
                                                                                   isHiddenUnderline: false))
            case .meaning: // example <-> translation 바꿔서
                ReviewCardViewModel.AIExample(example: makeUnderline(isWord: true,
                                                                     sentence: sentence.translation,
                                                                     underLine: sentence.usedWordInTranslation,
                                                                     isHiddenUnderline: false),
                                              exampleIdentity: sentence.translationIdentity,    // 바꿔서 translation으로
                                              translationIdentity: sentence.exampleIdentity,
                                              translationWithHidden: makeUnderline(isWord: false,
                                                                                   sentence: sentence.example,
                                                                                   underLine: sentence.usedWordInExample,
                                                                                   isHiddenUnderline: true),
                                              translationWithAnswer: makeUnderline(isWord: false,
                                                                                   sentence: sentence.example,
                                                                                   underLine: sentence.usedWordInExample,
                                                                                   isHiddenUnderline: false))
            }
        }
        
        func setShowTranslation() {
            showTranslation.toggle()
            
            if showTranslation {
                translation = translationWithHidden
            } else {
                translation = translationWithPlaceholder
            }
            
        }
    }
}


func makeUnderline(isWord: Bool, sentence: String, underLine: String, isHiddenUnderline: Bool) -> AttributedString {
    // 전체 문장을 AttributedString으로 변환
    var modifiedSentence = sentence
    
    if isHiddenUnderline {
        // underLine 문자열을 같은 길이의 밑줄로 대체
        let underlineReplacement = String(repeating: "_", count: underLine.count)
        modifiedSentence = sentence.replacingOccurrences(of: underLine, with: underlineReplacement, options: .caseInsensitive)
    }
    
    var attributedString = AttributedString(modifiedSentence)
    attributedString.font = isWord ? .headline : .body
    attributedString.foregroundColor = .systemBlack
    
    
    
    //    if isHiddenUnderline {
    //        attributedString.backgroundColor = .systemGray
    //        attributedString.foregroundColor = .clear
    //    }
    
    //    let paragraphStyle = NSMutableParagraphStyle()
    //    paragraphStyle.lineSpacing = 5
    //    attributedString.paragraphStyle = paragraphStyle
    
    return attributedString
}


extension ReviewStartFilter.AISentenceType {
    var aiModuleType: AISentenceType {
        switch self {
        case .conversation:
            return .conversation
        case .description:
            return .description
        }
    }
}
