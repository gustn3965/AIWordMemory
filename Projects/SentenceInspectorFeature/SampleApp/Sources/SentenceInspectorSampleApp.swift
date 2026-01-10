//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import SentenceInspector
import AppCoordinatorService
@main
struct SentenceInspectorSampleApp: App {
    var body: some Scene {
        WindowGroup {
            SentenceInspectorContentView(diContainer: SentenceInspectorMockDIContainer(), appCoordinator: AppCoordinator())
        }
    }
}
