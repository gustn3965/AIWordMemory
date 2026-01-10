//
//  DBWordTag.swift
//  DBImplementation
//
//  Created by 박현수 on 12/29/24.
//

//import Foundation
import SwiftData
import SwiftUI

@Model
public final class DBWordTag {
    //    #Unique<DBWordTag>([\.identity])  // iOS18부터
    @Attribute() var identity: String = UUID().uuidString
    var name: String = ""
    
    @Relationship(inverse: \DBWord.tags) var words: [DBWord]? = []
    
    public init(name: String, identity: String = UUID().uuidString) {
        self.name = name
        self.identity = identity
    }
}
