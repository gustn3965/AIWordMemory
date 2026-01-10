//
//  StoreKitView.swift
//  Settings
//
//  Created by 박현수 on 1/14/25.
//

import SwiftUI
import CommonUI


struct StoreKitView: View {
    
    @StateObject var viewModel: StoreKitViewModel
    var diContainer: any SettingsDependencyInjection
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State var successPurchaseAlert: Bool = false
    @State var failedPurchaseAlert: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    init(diContainer: any SettingsDependencyInjection) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: StoreKitViewModel(accountService: diContainer.makeAccountImplementation(),
                                                                 storeKitService: diContainer.storeKitServiceImplementation()))
    }
    
    var body: some View {
        
        ZStack {
            
            
//            BackgroundView()
            ZStack {
                LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [Color.systemBlack, Color.systemWhite]) : Gradient(colors: [Color.systemWhite, Color.systemBlack]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(10)
                .northWestShadow(radius: 3, offset: 3)
                
                LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [Color.systemBlack, Color(red: 0, green: 0, blue: 0, opacity: 0.8)]) : Gradient(colors: [Color.systemWhite, Color(red: 0.236, green: 0.236, blue: 0.236, opacity: 0.5)]),
                               startPoint: .top,
                               endPoint: .bottom)
                
                    .edgesIgnoringSafeArea(.all)
                    .cornerRadius(10)
                    .northWestShadow(radius: 3, offset: 3)
                    .padding(1)
                    
            }
            
            VStack {
                Text("AI 학습 구매권")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                    .shadow(color: Color.systemWhite, radius: 2, x: 2, y: 2)
                
                VStack {
                    HStack {
                        Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("AI 문장 생성 기능")
                        
                    }
                    Text("200회 추가 제공!")
                        .font(.title3)
                        .bold()
                }
                .padding(.bottom, 20)
                
                VStack {
                    HStack {
                        Image("ri_voice-ai-light", bundle: CommonUIResources.bundle)
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("AI 스피킹 기능")
                        
                    }
                    Text("100회 추가 제공!")
                        .font(.title3)
                        .bold()
                }
                .padding(.bottom, 20)
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.purchaseFirst()
                            successPurchaseAlert = true
                            
                        } catch {
                            failedPurchaseAlert = true
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                } label: {
                    HStack {
                        Text("구매")
                        Text("₩1,100")
                            
                    }
                    .font(.title3)
                    .bold()
                    .padding([.leading, .trailing], 20)
                    .padding(10)
                    
                }
                
                .buttonStyle(PurchaseButtonStyle())
                
                .fixedSize()
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.5)
                
            }
        }
        .padding(40)
        .navigationTitle("구매")
        
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $failedPurchaseAlert,
               presenting: errorMessage) { errorMessage in
        } message: { errorMessage in
//            Text(errorMessage)
        }
        
    }
}

#Preview {
    NavigationStack {
        StoreKitView(diContainer: SettingsMockDIContainer())
    }
}


public struct PurchaseButtonStyle: ButtonStyle {
    
//    let width: CGFloat
//    let height: CGFloat
//
//    public init(width: CGFloat, height: CGFloat) {
//        self.width = width
//        self.height = height
//    }
    
    var backgroundColor: Color
    
    public init(backgroundColor: Color = .element) {
        self.backgroundColor = backgroundColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            ZStack {
                Group {
                    
                    if configuration.isPressed {
                        Capsule()
                            .fill(Color.systemBlack.opacity(0.7))
                            .southEastShadow(radius: 1, offset: 2)
                    } else {
                        Capsule()
                            .fill(backgroundColor)
                            .northWestShadow(radius: 1, offset: 2)
                        Capsule()
                            .inset(by: 4)
                            .fill(backgroundColor)
                            
                            .northWestShadow(radius: 1, offset: 2)
                    }
                }
            }
            
            configuration.label
                .font(.headline)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            //            .frame(width: width, height: height)
                .opacity(configuration.isPressed ? 0.2 : 1)
                
        }
    }
}
