//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI



public protocol SampleUsecase {}
struct SampleMockUsecase: SampleUsecase {}

class SampleViewModel: ObservableObject {
    
    @Published var useCase: SampleUsecase
    
    init(useCase: SampleUsecase) {
        self.useCase = useCase
    }
}

public struct SampleContentView: View {
    var diContainer: any SampleDependencyInjection
    @ObservedObject var viewModel: SampleViewModel
    
    public init(diContainer: any SampleDependencyInjection) {
        self.diContainer = diContainer
        self.viewModel = SampleViewModel(useCase: diContainer.makeUseCasse())
    }
    
    public var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .padding()
    }
}

struct SampleContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        SampleContentView(diContainer: SampleMockDIContainer())
    }
}
