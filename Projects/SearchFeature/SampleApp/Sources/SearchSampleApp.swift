//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import Search

@main
struct SearchSampleApp: App {
    var body: some Scene {
        WindowGroup {
            SearchContentView(diContainer: SearchMockDIContainer())
        }
    }
}
