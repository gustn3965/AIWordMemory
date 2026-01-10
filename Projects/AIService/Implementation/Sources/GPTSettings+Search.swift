//
//  GPTSettings+Search.swift
//  AIImplementation
//
//  Created by 박현수 on 2/4/25.
//

import Foundation
import AppEntity
import AIInterface

extension ChatGPTRequest {
  
    static func requestSearchMeaning(searchWord: String,
                                     mainLanguageType: AISearchLanguageType,
                                     searchLanguageType: AISearchLanguageType) -> ChatGPTRequest {
        
        languageRecognizer.processString(searchWord)
//        let searchLanguage = languageRecognizer.dominantLanguage?.propertyName ?? "영어"
        let searchLanguage = searchLanguageType.name
        
        var prompt: String
        
        var questionLanguageString: String
        switch mainLanguageType {
        case .english:
            questionLanguageString = "In everyday language, what does it mainly mean?"
        case .french:
            questionLanguageString = "Dans le langage courant, que signifie-t-il principalement ?"
        case .german:
            questionLanguageString = "Was bedeutet es hauptsächlich in der Alltagssprache?"
        case .italian:
            questionLanguageString = "Nel linguaggio quotidiano, cosa significa principalmente?"
        case .japanese:
            questionLanguageString = "日常会話では主にどのような意味ですか？"
        case .korean:
            questionLanguageString = "이 단어 의미는 일상적인 표현으로 무슨뜻이야?"
        case .portuguese:
            questionLanguageString = "Na linguagem cotidiana, o que isso significa principalmente?"
        case .russian:
            questionLanguageString = "В повседневном языке, что это в основном означает?"
        case .simplifiedChinese:
            questionLanguageString = "在日常用语中，它主要是什么意思？"
        case .spanish:
            questionLanguageString = "En el lenguaje cotidiano, ¿qué significa principalmente?"
        case .thai:
            questionLanguageString = "ในภาษาทั่วไป มันหมายความว่าอะไรเป็นหลัก?"
        case .traditionalChinese:
            questionLanguageString = "這個詞的意思是日常表達是什麼意思?"
        case .vietnamese:
            questionLanguageString = "Trong ngôn ngữ hàng ngày, nó chủ yếu có nghĩa là gì?"
        }
        
        prompt =
        """
        \"['\(searchWord)'] \(questionLanguageString)\" 라고 물었을 때, [A], [B], [C], [D]는 그대로 사용하고 그외는 한글이 아닌 반드시 무조건 \(mainLanguageType.name)로 응답해.  ###응답형식: [A]: (한글이 아닌 부연설명하듯 의미를 반드시 무조건 \(mainLanguageType.name)로 작성) [B]: (\(searchLanguage)로 예문만들고) [C]: (사용예문을 \(mainLanguageType.name) 번역) [D]: (단어의 의미를 축약하여 반드시 \(mainLanguageType.name) 로 번역).     [C]: 말고는 반드시 무조건 \(mainLanguageType.name) 로 번역해 
        
        """
        
        return ChatGPTRequest.initSearch(prompt: prompt)
    }
    
    static func requestSearchTranslate(searchWord: String,
                                       mainLanguageType: AISearchLanguageType,
                                       searchLanguageType: AISearchLanguageType) -> ChatGPTRequest {
        
        languageRecognizer.processString(searchWord)
//        let searchLanguage = languageRecognizer.dominantLanguage?.propertyName ?? "영어"
        let searchLanguage = searchLanguageType.name
        let mainLanguage = mainLanguageType.name
        
        var prompt: String
        
        prompt =
        """
        \"['\(searchWord)'] 이 문장을 \(searchLanguage)로 어떻게표현해?\" 라고 물었을 때, [A], [B], [C], [D]는 그대로 사용하고 그외는 한글이 아닌 반드시 무조건 \(mainLanguage) 응답해.  ###응답형식: [A]: (\(searchLanguage)로 이 문장을 어떻게 표현하는지 포함하면서, 설명은 \(mainLanguage) 작성) [B]: (\(searchLanguage)로 예문만들고) [C]: (사용예문을 \(mainLanguage) 번역) [D]: (문장을 \(searchLanguage)로 번역).     [C]: 말고는 반드시 무조건 \(mainLanguage) 로 번역해 
        
        """
        
        return ChatGPTRequest.initSearch(prompt: prompt)
    }
    
    static func requestSentenceInspector(sentence: String,
                                         mainLanguageType: AISearchLanguageType) -> ChatGPTRequest {
        languageRecognizer.processString(sentence)
        let searchLanguage = languageRecognizer.dominantLanguage?.propertyName ?? "영어"
        
//        let searchLanguage = searchLanguageType.name
        let mainLanguage = mainLanguageType.name
        
        var prompt: String
        
        
        switch mainLanguageType {
        case .english:
            prompt = """
            "['\(sentence)'] Please check this sentence in \(searchLanguage)" was asked. Use [올바른설명] and [올바른문장] exactly as they are, and for everything else, respond exclusively in \(mainLanguage) (do not use Korean). ###Response format: [올바른설명]: (Explain in \(mainLanguage) whether this sentence is a naturally common expression in \(searchLanguage), if there are any shortcomings, or if it is impolite or awkward) [올바른문장]: (If there are errors, correct them in \(searchLanguage); if not, give praise in \(mainLanguage)).
            """
        case .french:
            prompt = """
            "['\(sentence)'] Veuillez vérifier cette phrase en \(searchLanguage)" a été demandé. Utilisez [올바른설명] et [올바른문장] exactement tels quels, et pour tout le reste, répondez exclusivement en \(mainLanguage) (n'utilisez pas le coréen). ###Format de réponse: [올바른설명]: (Expliquez en \(mainLanguage) si cette phrase est une expression naturelle en \(searchLanguage), s'il y a des lacunes, ou si elle est impolie ou maladroite) [올바른문장]: (S'il y a des erreurs, corrigez-les en \(searchLanguage); sinon, félicitez en \(mainLanguage)).
            """
        case .german:
            prompt = """
            "['\(sentence)'] Bitte überprüfe diesen Satz auf \(searchLanguage)" wurde gefragt. Verwende [올바른설명] und [올바른문장] genau so, wie sie sind, und antworte für alle anderen Teile ausschließlich auf \(mainLanguage) (verwende kein Koreanisch). ###Antwortformat: [올바른설명]: (Erkläre auf \(mainLanguage), ob dieser Satz in \(searchLanguage) im alltäglichen Gebrauch natürlich klingt, ob es Mängel gibt oder ob er unhöflich bzw. ungeschickt ist) [올바른문장]: (Falls Fehler vorhanden sind, korrigiere sie in \(searchLanguage); falls nicht, lobe in \(mainLanguage)).
            """
        case .italian:
            prompt = """
            "['\(sentence)'] Per favore, controlla questa frase in \(searchLanguage)" è stato chiesto. Usa [올바른설명] e [올바른문장] esattamente come sono, e per tutto il resto rispondi esclusivamente in \(mainLanguage) (non in coreano). ###Formato di risposta: [올바른설명]: (Spiega in \(mainLanguage) se questa frase è un'espressione naturale in \(searchLanguage), se presenta carenze, o se è scortese o innaturale) [올바른문장]: (Se ci sono errori, correggili in \(searchLanguage); altrimenti, complimentati in \(mainLanguage)).
            """
        case .japanese:
            prompt = """
            "['\(sentence)'] この文を \(searchLanguage) でチェックしてください" と尋ねられた場合、[올바른설명] と [올바른문장] はそのまま使用し、その他は必ず \(mainLanguage) で回答してください (韓国語ではなく)。 ###回答フォーマット: [올바른설명]: (\(mainLanguage) で、この文が \(searchLanguage) で日常的に自然な表現であるか、欠点があるか、失礼または不自然でないかを説明してください) [올바른문장]: (誤りがある場合は \(searchLanguage) で修正し、なければ \(mainLanguage) で賞賛してください)
            """
        case .korean:
            prompt = """
            "['\(sentence)'] 이 문장을 \(searchLanguage)로 검사해줘 " 라고 물었을 때, [올바른설명], [올바른문장]는 그대로 사용하고 그외는 반드시 \(mainLanguage)로 응답해.  ###응답형식: [올바른설명]: (해당 문장이 \(searchLanguage)로 일상적으로 자연스러운 표현인지, 부족한 점이 없는지, 무례하거나 어색하지 않은지를 \(mainLanguage)로 설명해) [올바른문장]: (틀린 부분이 있다면 \(searchLanguage)로 바꿔주고, 없으면 \(mainLanguage)로 칭찬해줘)
            """
        case .portuguese:
            prompt = """
            "['\(sentence)'] Por favor, verifique esta frase em \(searchLanguage)" foi perguntado. Use [올바른설명] e [올바른문장] exatamente como estão, e para todo o resto responda estritamente em \(mainLanguage) (não use coreano). ###Formato de resposta: [올바른설명]: (Explique em \(mainLanguage) se esta frase é uma expressão natural do dia a dia em \(searchLanguage), se há alguma deficiência, ou se é indelicada ou estranha) [올바른문장]: (Se houver erros, corrija-os em \(searchLanguage); caso contrário, elogie em \(mainLanguage)).
            """
        case .russian:
            prompt = """
            "['\(sentence)'] Пожалуйста, проверьте это предложение на \(searchLanguage)" был задан вопрос. Используйте [올바른설명] и [올바른문장] точно так, как они есть, а для всего остального отвечайте исключительно на \(mainLanguage) (не используйте корейский). ###Формат ответа: [올바른설명]: (Объясните на \(mainLanguage), является ли это предложение естественным в повседневном употреблении на \(searchLanguage), есть ли недостатки или оно не является невежливым/неуклюжим) [올바른문장]: (Если есть ошибки, исправьте их на \(searchLanguage); если нет, похвалите на \(mainLanguage)).
            """
        case .simplifiedChinese:
            prompt = """
            "['\(sentence)'] 请用 \(searchLanguage) 检查这句话" 是这样问的。请保持 [올바른설명] 和 [올바른문장] 不变，其余部分必须全部使用 \(mainLanguage) 回答（不得使用韩文）。 ###回答格式: [올바른설명]: (请用 \(mainLanguage) 解释这句话在 \(searchLanguage) 中是否为日常自然的表达，是否存在不足，是否不礼貌或不自然) [올바른문장]: (如果有错误，请用 \(searchLanguage) 更正；如果没有，请用 \(mainLanguage) 赞扬)
            """
        case .spanish:
            prompt = """
            "['\(sentence)'] Por favor, revisa esta frase en \(searchLanguage)" fue lo que se preguntó. Usa [올바른설명] y [올바른문장] exactamente como están, y para todo lo demás responde exclusivamente en \(mainLanguage) (no en coreano). ###Formato de respuesta: [올바른설명]: (Explica en \(mainLanguage) si esta frase es una expresión natural en \(searchLanguage), si presenta deficiencias, o si resulta descortés o poco natural) [올바른문장]: (Si hay errores, corrígelos en \(searchLanguage); si no, elógiala en \(mainLanguage)).
            """
        case .thai:
            prompt = """
            "['\(sentence)'] กรุณาตรวจสอบประโยคนี้เป็นภาษา \(searchLanguage)" ถูกถามมา ให้ใช้ [올바른설명] และ [올바른문장] เหมือนเดิม และส่วนอื่นๆ ต้องตอบเป็น \(mainLanguage) เท่านั้น (ไม่ใช่ภาษาเกาหลี) ###รูปแบบการตอบ: [올바른설명]: (อธิบายเป็น \(mainLanguage) ว่าประโยคนี้เป็นการใช้ภาษาที่เป็นธรรมชาติใน \(searchLanguage) หรือไม่ มีจุดด้อยหรือไม่ และไม่หยาบคายหรือไม่) [올바른문장]: (หากมีข้อผิดพลาด ให้แก้ไขเป็น \(searchLanguage); หากไม่มี ให้ชมใน \(mainLanguage))
            """
        case .traditionalChinese:
            prompt = """
            "['\(sentence)'] 請用 \(searchLanguage) 檢查這句話" 是這樣詢問的。請保持 [올바른설명] 與 [올바른문장] 不變，其餘部分必須全部以 \(mainLanguage) 回答（請勿使用韓文）。 ###回覆格式: [올바른설명]: (請以 \(mainLanguage) 解釋此句話在 \(searchLanguage) 中是否為日常自然的表達，是否有不足，或是否不禮貌或不自然) [올바른문장]: (如有錯誤，請用 \(searchLanguage) 更正；如無，請以 \(mainLanguage) 稱讚)
            """
        case .vietnamese:
            prompt = """
            "['\(sentence)'] Vui lòng kiểm tra câu này bằng \(searchLanguage)" đã được yêu cầu. Hãy sử dụng [올바른설명] và [올바른문장] chính xác như chúng vốn có, và với những phần khác hãy trả lời hoàn toàn bằng \(mainLanguage) (không dùng tiếng Hàn). ###Định dạng phản hồi: [올바른설명]: (Giải thích bằng \(mainLanguage) xem câu này có phải là cách diễn đạt tự nhiên trong đời sống hàng ngày bằng \(searchLanguage) hay không, có thiếu sót gì, hoặc có vẻ thô lỗ hay lạ lẫm) [올바른문장]: (Nếu có lỗi, hãy sửa bằng \(searchLanguage); nếu không, hãy khen ngợi bằng \(mainLanguage)).
            """
        }
        
        
//        prompt =
//        """
//         \"['\(sentence)'] 이 문장을 \(searchLanguage)로 검사해줘 \" 라고 물었을 때, [올바른설명], [올바른문장]는 그대로 사용하고 그외는 한글이 아닌 반드시 무조건 \(mainLanguage)로 응답해.  ###응답형식: [올바른설명]: (해당 문장이 \(searchLanguage)로 일상적으로 자연스러운 표현인인지, 부족한점은 없는지, 무례하지는 않는지, 어색하지는 않는지를 설명하는데, \(mainLanguage)로 설명해) [올바른문장]: (틀린부분이 있다면 \(searchLanguage)로 바꿔줘, 없으면 \(mainLanguage)로 칭찬해줘)
//        
//        """
        return ChatGPTRequest.initSearch(prompt: prompt)
    }
}
