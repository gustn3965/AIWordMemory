//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService

public struct RecommendContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any RecommendDependencyInjection
    
    
    public init(diContainer: any RecommendDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
    }
   
    public var body: some View {
        VStack {
            WordCollectionView(diContainer: diContainer)
        }
    }
}

struct RecommendContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        RecommendContentView(diContainer: RecommendMockDIContainer(), appCoordinator: AppCoordinator())
    }
}
