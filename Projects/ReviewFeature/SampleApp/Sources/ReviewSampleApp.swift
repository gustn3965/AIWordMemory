//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import Review
import AppCoordinatorService

@main
struct ReviewSampleApp: App {
    @StateObject var coordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            ReviewContentView(diContainer: ReviewMockDIContainer(), appCoordinator: coordinator)
                .environmentObject(coordinator)
        }
    }
}
