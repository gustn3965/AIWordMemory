//
//  AccountView.swift
//  Settings
//
//  Created by 박현수 on 1/8/25.
//

import SwiftUI

import CommonUI
import AppCoordinatorService

private enum AccountNavigation: Int {
    
//    case coupon
    case purchase
//    case advertise
}
struct AccountView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any SettingsDependencyInjection
    var menu: SettingMenuList
    
    @State private var selectedMenu: AccountNavigation?
    
    @StateObject var viewModel: AccountViewModel
    
    init(diContainer: any SettingsDependencyInjection,
         menu: SettingMenuList,
         appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
        self.menu = menu
        _viewModel = StateObject(wrappedValue: AccountViewModel(accountService: diContainer.makeAccountImplementation(), dbService: diContainer.makeDBImplementation(),
                                                                isAvailableAI: diContainer.isAvailableAI(),
                                                                availableRewardAdmob: diContainer.isAvailableRewardAdmob(),
                                                                availablePurhase: diContainer.isAvailablePurchase()))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Label {
                                Text("AI 문장 횟수")
                                    .font(.body)
                            } icon: {
                                Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                            Spacer() // 버튼으로바꾸거나해야겠다.
                            
                            Text("\(viewModel.chatGPTChances)회 남음")
                                .font(.headline)
                        }
                        .padding()
                        
                        HStack {
                            Label {
                                Text("AI 스피킹 횟수")
                                    .font(.body)
                            } icon: {
                                Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                            Spacer()
                            
                            Text("\(viewModel.aiSpeakingChances)회 남음")
                                .font(.headline)
                        }
                        .padding()
                        
                        
                        Divider()
                   
                        if viewModel.showAdvertiseButton {
                            Button {
                                appCoordinator.showRewordAd = true
                            } label: {
                                HStack {
                                    Label {
                                        Text("광고로 횟수 올리기")
                                            .font(.body)
                                    } icon: {
                                        Image("icon-park-solid_adLight", bundle: CommonUIResources.bundle)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(WMPressedStyle())
                        }
                        
                        if viewModel.showPurchaseButton {
                            Button {
                                selectedMenu = .purchase
                            } label: {
                                HStack {
                                    Label {
                                        Text("구매하여 횟수 올리기")
                                            .font(.body)
                                    } icon: {
                                        Image("fluent_premium-person-24-filledLight", bundle: CommonUIResources.bundle)
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(WMPressedStyle())
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                
            }
            .padding()
            
           
        }
        .padding(30)
        .navigationTitle(LocalizedStringKey(menu.name))
        .navigationDestination(item: $selectedMenu) { (accountNavigation: AccountNavigation) in
            switch accountNavigation {
            case .purchase:
                StoreKitView(diContainer: diContainer)
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
}

private struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(LocalizedStringKey(message))
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        AccountView(diContainer: SettingsMockDIContainer(), menu: .account, appCoordinator: AppCoordinator())
    }
}
