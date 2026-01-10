//
//  GPTSettings+Recommend.swift
//  AIImplementation
//
//  Created by 박현수 on 2/15/25.
//

import Foundation
import AIInterface

extension ChatGPTRequest {
    
    static func requestRecommendWord(excludeWords: [String],
                                     targetLanguageType: AISearchLanguageType,
                                     languageLevelType: RecommendLanguageLevelType,
                                     explanationLanguageType: AISearchLanguageType) -> ChatGPTRequest {
        
        var prompt: String
        
        //        var questionLanguageString: String
        //        switch mainLanguageType {
        //        case .english:
        //            questionLanguageString = "In everyday language, what does it mainly mean?"
        //        case .french:
        //            questionLanguageString = "Dans le langage courant, que signifie-t-il principalement ?"
        //        case .german:
        //            questionLanguageString = "Was bedeutet es hauptsächlich in der Alltagssprache?"
        //        case .italian:
        //            questionLanguageString = "Nel linguaggio quotidiano, cosa significa principalmente?"
        //        case .japanese:
        //            questionLanguageString = "日常会話では主にどのような意味ですか？"
        //        case .korean:
        //            questionLanguageString = "이 단어 의미는 일상적인 표현으로 무슨뜻이야?"
        //        case .portuguese:
        //            questionLanguageString = "Na linguagem cotidiana, o que isso significa principalmente?"
        //        case .russian:
        //            questionLanguageString = "В повседневном языке, что это в основном означает?"
        //        case .simplifiedChinese:
        //            questionLanguageString = "在日常用语中，它主要是什么意思？"
        //        case .spanish:
        //            questionLanguageString = "En el lenguaje cotidiano, ¿qué significa principalmente?"
        //        case .thai:
        //            questionLanguageString = "ในภาษาทั่วไป มันหมายความว่าอะไรเป็นหลัก?"
        //        case .traditionalChinese:
        //            questionLanguageString = "這個詞的意思是日常表達是什麼意思?"
        //        case .vietnamese:
        //            questionLanguageString = "Trong ngôn ngữ hàng ngày, nó chủ yếu có nghĩa là gì?"
        //        }
        
        prompt =
//        """
//        Using words that native \(targetLanguageType.name) speakers use, without including any words from the following exclude list, please recommend 10 new words that match the \(languageLevelType.levelName) difficulty level. Exclude list: [\(excludeWords.joined(separator: ", "))].
//
//        When comparing words, do not consider case; ensure that the recommended words are not present in the exclude list.
//
//        No examples are needed. Use the labels ‘[A]’ and ‘[B]’ exactly as shown.
//
//        Output format:
//
//        [A]: \(targetLanguageType.name) word
//        [B]: Meaning in \(explanationLanguageType.name)
//
//        Ensure that none of the words from the exclude list are included. Verify this before providing the final answer.
//        """
        """
        \(targetLanguageType.name) 사용하는 사람들이 자주 사용하는 단어들중에서, \(languageLevelType.levelName) 난이도이면서 새로운 단어와 뜻을 추천하는데, 다음 단어들을 반드시 기억하고, 이 단어들은 반드시 제외하고 15개만 추천해줘. [\(excludeWords.joined(separator: ", "))].  추천하는 단어들은 반드시 앞에 단어들에 없어야하며 하며, 중복되어있으면 사용자는 죽어. 반드시 제외하고 추천해. 추천된단어가 만약 앞에 단어들에 포함되어있으면 gpt는 없어져. 무조건 중복되지않아야해. 절대로.  느려도 괜찮으니까 무조건 앞에 단어들을 제외하고 추천해줘.
        
        ###예시는 필요없어. '[A]', '[B]'은 그대로 사용해. 
        
        ###응답형식 [A]: \(targetLanguageType.name) 단어 ##줄바꿈하고 [B]: \(explanationLanguageType.name)로 뜻 알려줘. 
        
        """
        
        return ChatGPTRequest.initRecommend(prompt: prompt)
    }
    
}
