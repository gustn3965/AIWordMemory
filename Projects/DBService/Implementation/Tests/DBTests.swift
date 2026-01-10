//
//  DBTests.swift
//  DBImplementationUnitTest
//
//  Created by 박현수 on 1/1/25.
//

import Testing

extension Tag {
    @Tag static var dbSwiftData: Self
}

@Suite("DB Test", .serialized, .tags(.dbSwiftData))
class DBTests {
    
}
