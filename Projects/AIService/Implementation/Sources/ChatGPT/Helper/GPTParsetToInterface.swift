//
//  GPTParsetToInterface.swift
//  AIImplementation
//
//  Created by 박현수 on 1/1/25.
//

import Foundation
import AIInterface

public struct ResponseParser {
    public static func parse(response: ChatGPTResponse) -> AIFetchSentenceResponse? {
        // 각 예시는 빈 줄로 구분되어 있다고 가정합니다.
        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        print(responseText)
        let blocks = responseText.components(separatedBy: "\n\n")
        var examples: [AIFetchSentenceResponse.AIExample] = []
        
        for block in blocks {
            // 각 블록을 라인 단위로 분리
            let lines = block.components(separatedBy: .newlines)

            var sentences: [String] = []
            for line in lines {
                if line.starts(with: "[예시]:") {
//                    example = line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    sentences.append(line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.starts(with: "[해석]:") {
                    sentences.append(line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    translation = line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[사용된 예시 단어]:") {
                    sentences.append(line.replacingOccurrences(of: "[사용된 예시 단어]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedWord = line.replacingOccurrences(of: "[사용된 예시 단어]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[사용된 해석 뜻]:") {
                    sentences.append(line.replacingOccurrences(of: "[사용된 해석 뜻]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedTranslationWord = line.replacingOccurrences(of: "[사용된 해석 뜻]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    if var beforeSentence = sentences.last {
                        beforeSentence.append("\n" + line.trimmingCharacters(in: .whitespacesAndNewlines))
                        sentences.removeLast()
                        sentences.append(beforeSentence)
                    }
                }
            }
            
            if sentences.count == 4 {
                let aiExample = AIFetchSentenceResponse.AIExample(example: sentences[0], translation: sentences[1], usedWordInExample: sentences[2], usedWordInTranslation: sentences[3])
                examples.append(aiExample)
            }
//            // 모든 필드가 채워졌는지 확인
//            if !example.isEmpty && !translation.isEmpty && !usedWord.isEmpty && !usedTranslationWord.isEmpty {
//                let aiExample = AIResponse.AIExample(example: example, translation: translation, usedWordInExample: usedWord, usedWordInTranslation: usedTranslationWord)
//                examples.append(aiExample)
//            }
        }
        
        
        return AIFetchSentenceResponse(examples: examples)
    }
    
    
    public static func parseMeaning(searchWord: String, response: ChatGPTResponse) -> AISearchResponse? {
        // 각 예시는 빈 줄로 구분되어 있다고 가정합니다.
        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        print(responseText)
        let blocks = responseText.components(separatedBy: "\n\n")
        var example: AISearchResponse?
        
        var sentences: [String] = []
        
        for block in blocks {
            // 각 블록을 라인 단위로 분리
            let lines = block.components(separatedBy: .newlines)

            
            for line in lines {
                if line.starts(with: "[A]:") {
//                    example = line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    sentences.append(line.replacingOccurrences(of: "[A]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.starts(with: "[B]:") {
                    sentences.append(line.replacingOccurrences(of: "[B]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    translation = line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[C]:") {
                    sentences.append(line.replacingOccurrences(of: "[C]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedWord = line.replacingOccurrences(of: "[사용된 예시 단어]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[D]:") {
                    sentences.append(line.replacingOccurrences(of: "[D]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedTranslationWord = line.replacingOccurrences(of: "[사용된 해석 뜻]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    if var beforeSentence = sentences.last {
                        beforeSentence.append("\n" + line.trimmingCharacters(in: .whitespacesAndNewlines))
                        sentences.removeLast()
                        sentences.append(beforeSentence)
                    }
                }
            }
            
            
            if sentences.count == 4 {
                example = AISearchResponse(word: searchWord,
                                           explanation: sentences[0],
                                           sentence: sentences[1],
                                           sentenceTranslation: sentences[2],
                                           meaning: sentences[3],
                                           searchType: .meaning)
                break
            }
        }
        
        return example
    }
    
    
    public static func parseTranslate(searchWord: String, response: ChatGPTResponse) -> AISearchResponse? {
        // 각 예시는 빈 줄로 구분되어 있다고 가정합니다.
        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        print(responseText)
        let blocks = responseText.components(separatedBy: "\n\n")
        var example: AISearchResponse?
        
        var sentences: [String] = []
        
        for block in blocks {
            // 각 블록을 라인 단위로 분리
            let lines = block.components(separatedBy: .newlines)

            
            for line in lines {
                if line.starts(with: "[A]:") {
//                    example = line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    sentences.append(line.replacingOccurrences(of: "[A]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.starts(with: "[B]:") {
                    sentences.append(line.replacingOccurrences(of: "[B]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    translation = line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[C]:") {
                    sentences.append(line.replacingOccurrences(of: "[C]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedWord = line.replacingOccurrences(of: "[사용된 예시 단어]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.starts(with: "[D]:") {
                    sentences.append(line.replacingOccurrences(of: "[D]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    usedTranslationWord = line.replacingOccurrences(of: "[사용된 해석 뜻]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    if var beforeSentence = sentences.last {
                        beforeSentence.append("\n" + line.trimmingCharacters(in: .whitespacesAndNewlines))
                        sentences.removeLast()
                        sentences.append(beforeSentence)
                    }
                }
            }
            
            
            if sentences.count == 4 {
                example = AISearchResponse(word: searchWord,
                                           explanation: sentences[0],
                                           sentence: sentences[1],
                                           sentenceTranslation: sentences[2],
                                           meaning: sentences[3],
                                           searchType: .translate)
                break
            }
        }
        
        return example
    }
    
    
    public static func parseSentenceInsepctor(originSentence: String, response: ChatGPTResponse) -> AISentenceInspectorResponse? {
        // 각 예시는 빈 줄로 구분되어 있다고 가정합니다.
        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        print(responseText)
        let blocks = responseText.components(separatedBy: "\n\n")
        var example: AISentenceInspectorResponse?
        
        var sentences: [String] = []
        
        for block in blocks {
            // 각 블록을 라인 단위로 분리
            let lines = block.components(separatedBy: .newlines)

            
            for line in lines {
                if line.starts(with: "[올바른설명]:") {
//                    example = line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    sentences.append(line.replacingOccurrences(of: "[올바른설명]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.starts(with: "[올바른문장]:") {
                    sentences.append(line.replacingOccurrences(of: "[올바른문장]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    translation = line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    if var beforeSentence = sentences.last {
                        beforeSentence.append("\n" + line.trimmingCharacters(in: .whitespacesAndNewlines))
                        sentences.removeLast()
                        sentences.append(beforeSentence)
                    }
                }
            }
            
            
            if sentences.count == 2 {
                example = AISentenceInspectorResponse(originSentence: originSentence,
                                                      explantion: sentences[0],
                                                      correctSentence: sentences[1])
                break
            }
        }
        
        return example
    }
    
    
    public static func parseRecommendWord(response: ChatGPTResponse) -> AIRecommendWordResponse? {
        // 각 예시는 빈 줄로 구분되어 있다고 가정합니다.
        let responseText = response.choices.compactMap { $0.message.content }.joined(separator: "\n\n")
        print(responseText)
        let blocks = responseText.components(separatedBy: "\n\n")
        
        var words: [AIRecommendWordResponse.Word] = []
        
        for block in blocks {
            // 각 블록을 라인 단위로 분리
            let lines = block.components(separatedBy: .newlines)
            
            var sentences: [String] = []
            
            for line in lines {
                if line.starts(with: "[A]:") {
//                    example = line.replacingOccurrences(of: "[예시]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    sentences.append(line.replacingOccurrences(of: "[A]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                } else if line.starts(with: "[B]:") {
                    sentences.append(line.replacingOccurrences(of: "[B]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
//                    translation = line.replacingOccurrences(of: "[해석]:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            
            if sentences.count == 2 {
                words.append(AIRecommendWordResponse.Word(word: sentences[0], meaning: sentences[1]))
            }
        }
        
        return AIRecommendWordResponse(words: words)
    }
}
