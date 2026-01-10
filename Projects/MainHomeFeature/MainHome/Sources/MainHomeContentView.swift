//
//  MainHomeContentView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import CommonUI
import AppCoordinatorService

public struct MainHomeContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any MainHomeDependencyInjection
    
    public init(diContainer: any MainHomeDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
    }
    
    public var body: some View {
        MainHomeView(diContainer: diContainer, appCoordinates: appCoordinator)
            .environmentObject(AppCoordinator())
    }
}


struct MainHomeContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        MainHomeContentView(diContainer: MainHomeMockDIContainer(), appCoordinator: AppCoordinator())
    }
}
