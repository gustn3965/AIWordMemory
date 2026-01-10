//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import Settings
import AppCoordinatorService


@main
struct SettingsSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            //                .environment(\.locale, .init(identifier: "en"))
        }
    }
}

struct ContentView: View {
    @StateObject var diContainer = SettingsMockDIContainer()
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            SettingsContentView(diContainer: diContainer,
                                appCoordinator: AppCoordinator())
            .tint(Color.systemBlack)
        }
    }
}



struct ContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .tint(Color.systemBlack)
            .environment(\.locale, .init(identifier: "en"))
    }
}
