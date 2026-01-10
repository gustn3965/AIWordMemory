//
//  WordTag.swift
//  AppEntity
//
//  Created by 박현수 on 1/3/25.
//

import Foundation


public struct WordTag: Sendable, Hashable {
    
    public var identity: String
    public var name: String
    
    public init(identity: String, name: String) {
        self.identity = identity
        self.name = name
    }
}

