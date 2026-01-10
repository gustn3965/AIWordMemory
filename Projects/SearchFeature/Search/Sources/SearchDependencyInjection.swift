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


public protocol SearchDependencyInjection {
    func makeAIImplementation() -> AIInterface
    func makeDBImplementation() -> DataBaseProtocol
    func makeSpeechVoiceImplementation() -> SpeechVoiceInterface
}

public struct SearchMockDIContainer: SearchDependencyInjection {
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
