//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService


public struct ReviewContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    var diContainer: any ReviewDependencyInjection
    
    public init(diContainer: any ReviewDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
    }
    
    public var body: some View {
        ReviewStartView(diContainer: diContainer, appCoordinator: appCoordinator)
    }
}


struct ReviewContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        ReviewContentView(diContainer: ReviewMockDIContainer(), appCoordinator: AppCoordinator())
    }
}

