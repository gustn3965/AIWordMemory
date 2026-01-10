//
//  DependencyInjection.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation



public protocol CommonUIDependencyInjection {
    func makeUseCasse() -> CommonUIUsecase
}

public struct CommonUIMockDIContainer: CommonUIDependencyInjection {
    public init() {}
    public func makeUseCasse() -> any CommonUIUsecase {
        CommonUIMockUsecase()
    }
}