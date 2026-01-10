//
//  GPTSettings+FetchSentence.swift
//  AIImplementation
//
//  Created by 박현수 on 2/4/25.
//

import Foundation
import AppEntity
import AIInterface

extension ChatGPTRequest {

    static func requestFetchSentence(word: AppEntity.WordMemory, sentenceType: AISentenceType) -> ChatGPTRequest {
        
        languageRecognizer.processString(word.word)
        let wordLanugage = languageRecognizer.dominantLanguage?.propertyName ?? "[단어(W)]: ()에 사용된 언어"
        languageRecognizer.processString(word.meaning)
        let meaningLanugage = languageRecognizer.dominantLanguage?.propertyName ?? "[뜻(M)]: ()에 사용된 언어"
        
        var prompt: String
        
        switch sentenceType {
        case .conversation:
            prompt =
            """
            [단어(W)]: (\(word.word))
            [뜻(M)]: (\(word.meaning))
            
            [단어(W)]: 단어를 이용하여  두 화자 A와 B의 대화 형식으로 총 2개 만들어줘.
            
            무조건 아래형식(줄바꿈없이)으로 답변해줘
            
            [예시]: (반드시 무조건 \(wordLanugage)로 대화를 작성)
            [해석]: (반드시 무조건 대화를 \(meaningLanugage)로 번역함)
            [사용된 예시 단어]:  (대화에 사용된 \(wordLanugage) 단어를 작성합니다)
            [사용된 해석 뜻]:
            
            
            아래 참고해서 만들어줘.
            
            
            프롬프트:
            [단어(W)]: be used to  # 영어로 감지됌.
            [뜻(M)]: -에 익숙하다    # 한국어로 감지됌.
            
            
            생성예시:
            [예시]: A: Are you used to waking up early for work?  B: Not yet, but I’m slowly getting used to it. What about you?
            [해석]: A: 일찍 일어나서 출근하는 거에 익숙해졌어?  B: 아직은 아니야, 하지만 천천히 익숙해지고 있어. 너는 어때?
            [사용된 예시 단어]: used to, getting used to
            [사용된 해석 뜻]: 익숙해졌어, 익숙해지고 있어
            
            프롬프트 뜻은 '-에 익숙하다지만', 파싱이 가능하도록 '익숙했다'로 바꿔준걸 유념해.
            미래형이든 과거형이든 상관없어. [예시]는 [단어(A)] 언어로 만들고, [해석]은 [뜻(B)]의 언어로 해석해줘.
            
            """
        case .description:
            prompt =
            """
            [단어(W)]: \(word.word)
            [뜻(M)]: \(word.meaning)
            
            단어(A) 이용한 문장을 3개만 만들어줘.
            
            무조건 아래형식으로 답변해줘
            
            [예시]: (반드시 무조건 \(wordLanugage)로 대화를 작성)
            [해석]: (반드시 무조건 대화를 \(meaningLanugage)로 번역함)
            [사용된 예시 단어]:  (대화에 사용된 \(wordLanugage) 단어를 작성합니다)
            [사용된 해석 뜻]:
            
            아래 참고해서 만들어줘.
            
            프롬프트: 
            [단어(W)]: be used to 
            [뜻(M)]: -에 익숙하다
            
            생성예시: 
            [예시]: He was used to the cold weather when he lived in Canada.  
            [해석]: 그는 캐나다에 살 때 추운 날씨에 익숙했다.
            [사용된 예시 단어]: was used to
            [사용된 해석 뜻]: 익숙했다.
            
            프롬프트 뜻은 '-에 익숙하다지만', 파싱이 가능하도록 '익숙했다'로 바꿔준걸 유념해.
            미래형이든 과거형이든 상관없어. [예시]는 [단어(W)] 언어로 만들고, [해석]은 [뜻(M)]의 언어로 해석해줘.
            
            """
        }
        
        
        
        return ChatGPTRequest.initFetchSentence(prompt: prompt)
    }
}
