//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import Recommend
import AppCoordinatorService

@main
struct RecommendSampleApp: App {
    var body: some Scene {
        WindowGroup {
            RecommendContentView(diContainer: RecommendMockDIContainer(), appCoordinator: AppCoordinator())
        }
    }
}
