//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import MainHome
import AppCoordinatorService


@main
struct MainHomeSampleApp: App {
    @StateObject var coordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            MainHomeView(diContainer: MainHomeMockDIContainer(), appCoordinates: coordinator)
        }
    }
}


struct MainHomeContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        MainHomeContentView(diContainer: MainHomeMockDIContainer(), appCoordinator: AppCoordinator())
    }
}
