//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService

public struct SentenceInspectorContentView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any SentenceInspectorDependencyInjection
    
    
    public init(diContainer: any SentenceInspectorDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
    }
    
    public var body: some View {
        SentenceInspectorView(diContainer: diContainer)
    }
}

struct SentenceInspectorContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        SentenceInspectorContentView(diContainer: SentenceInspectorMockDIContainer(), appCoordinator: AppCoordinator())
    }
}
