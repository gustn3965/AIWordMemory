//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService


public struct SearchContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any SearchDependencyInjection
    
    public init(diContainer: any SearchDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
    }
    
    public var body: some View {
        SearchView(diContainer: diContainer)
    }
}

struct SearchContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        SearchContentView(diContainer: SearchMockDIContainer(), appCoordinator: AppCoordinator())
    }
}
