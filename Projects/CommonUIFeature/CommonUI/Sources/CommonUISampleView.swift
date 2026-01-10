//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI



public protocol CommonUIUsecase {}
struct CommonUIMockUsecase: CommonUIUsecase {}

class CommonUIViewModel: ObservableObject {
    
    @Published var useCase: CommonUIUsecase
    
    init(useCase: CommonUIUsecase) {
        self.useCase = useCase
    }
}

public struct CommonUIContentView: View {
    var diContainer: any CommonUIDependencyInjection
    @ObservedObject var viewModel: CommonUIViewModel
    
    public init(diContainer: any CommonUIDependencyInjection) {
        self.diContainer = diContainer
        self.viewModel = CommonUIViewModel(useCase: diContainer.makeUseCasse())
    }
    
    public var body: some View {
        Text("hihihih?????i")
            .frame(width: 200, height: 200)
            .background(
                ZStack {
                    Capsule()
                        .fill(Color.greenColor)
                        .northWestShadow(radius: 3, offset: 1)
                    Capsule()
                        .inset(by: 3)
                        .fill(Color.greenColor)
                        .southEastShadow(radius: 1, offset: 1)
                }
            )
    }
}


struct CommonUIContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color.element
            CommonUIContentView(diContainer: CommonUIMockDIContainer())
            
        }
        .frame(width: 300, height: 100)
        .previewLayout(.sizeThatFits)
    }
}
