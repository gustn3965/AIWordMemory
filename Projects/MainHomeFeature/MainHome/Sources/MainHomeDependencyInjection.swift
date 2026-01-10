//
//  DependencyInjection.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation
import DBInterface
import SpeechVoiceInterface

public protocol MainHomeDependencyInjection {

    func makeDBImplementation() -> DataBaseProtocol
    func makeSpecchAppleVoiceImplementation() -> SpeechVoiceInterface
    func makeSpeechVoiceImplementation() -> SpeechVoiceInterface

    func maxWordLength() -> Int
    func maxMeaningLength() -> Int
}


public class MainHomeMockDIContainer: MainHomeDependencyInjection {

    var dbService: DataBaseProtocol
    
    public init() {
        let database = MockInMemoryDatabase.shared
        
        Task {
            await database.setup(includeDefaultData: true)
        }
        dbService = database
        
    }
    
    public func makeSpecchAppleVoiceImplementation() -> SpeechVoiceInterface {
        SpeechVoiceMock()
    }

    public func makeSpeechVoiceImplementation() -> SpeechVoiceInterface {
        SpeechVoiceMock()
    }

    public func makeDBImplementation() -> DataBaseProtocol {
        return dbService
    }
    
    public func maxWordLength() -> Int {
        return 100
    }
    public func maxMeaningLength() -> Int {
        return 100
    }
}
