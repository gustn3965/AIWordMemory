//
//  DependencyInjection.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation
import AIInterface
import DBInterface
import SpeechVoiceInterface



public protocol SentenceInspectorDependencyInjection {
    func makeAIImplementation() -> AIInterface
    func makeDBImplementation() -> DataBaseProtocol
    func makeSpeechVoiceImplementation() -> SpeechVoiceInterface
}

public struct SentenceInspectorMockDIContainer: SentenceInspectorDependencyInjection {
    var dbService: DataBaseProtocol
    
    public init() {
        let database = MockInMemoryDatabase.shared
        
        Task {
            await database.setup(includeDefaultData: true)
        }
        dbService = database
        
    }
    
    public func makeAIImplementation() -> any AIInterface {
        AIMockImplementation()
    }
    
    public func makeDBImplementation() -> DataBaseProtocol {
        dbService
    }
    
    public func makeSpeechVoiceImplementation() -> SpeechVoiceInterface {
        SpeechVoiceMock()
    }

    
}
