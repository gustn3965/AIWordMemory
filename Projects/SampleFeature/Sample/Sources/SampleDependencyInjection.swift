//
//  DependencyInjection.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation



public protocol SampleDependencyInjection {
    func makeUseCasse() -> SampleUsecase
}

public struct SampleMockDIContainer: SampleDependencyInjection {
    public init() {}
    public func makeUseCasse() -> any SampleUsecase {
        SampleMockUsecase()
    }
}