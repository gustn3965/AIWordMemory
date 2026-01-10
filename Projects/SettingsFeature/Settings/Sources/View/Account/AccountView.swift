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
    case purchase
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
        _viewModel = StateObject(wrappedValue: AccountViewModel(
            accountService: diContainer.makeAccountImplementation(),
            dbService: diContainer.makeDBImplementation(),
            isAvailableAI: diContainer.isAvailableAI(),
            availableRewardAdmob: diContainer.isAvailableRewardAdmob(),
            availablePurhase: diContainer.isAvailablePurchase()
        ))
    }

    var body: some View {
        List {
            // AI 사용량 섹션
            Section {
                // AI 문장 횟수
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.systemBlack.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }

                    Text("AI 문장 횟수")
                        .font(.body)

                    Spacer()

                    Text("\(viewModel.chatGPTChances)회")
                        .font(.headline)
                        .foregroundStyle(Color.systemBlack)
                }
                .padding(.vertical, 4)

                // AI 스피킹 횟수
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.systemBlack.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: "waveform")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.systemBlack)
                    }

                    Text("AI 스피킹 횟수")
                        .font(.body)

                    Spacer()

                    Text("\(viewModel.aiSpeakingChances)회")
                        .font(.headline)
                        .foregroundStyle(Color.systemBlack)
                }
                .padding(.vertical, 4)
            } header: {
                Text("사용량")
            }

            // 충전 섹션
            Section {
                if viewModel.showAdvertiseButton {
                    Button {
                        appCoordinator.showRewordAd = true
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "play.rectangle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.orange)
                            }

                            Text("광고로 횟수 올리기")
                                .font(.body)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 4)
                    }
                }

                if viewModel.showPurchaseButton {
                    Button {
                        selectedMenu = .purchase
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "crown.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.blue)
                            }

                            Text("구매하여 횟수 올리기")
                                .font(.body)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("충전")
            }
        }
        .listStyle(.insetGrouped)
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

#Preview {
    NavigationStack {
        AccountView(diContainer: SettingsMockDIContainer(), menu: .account, appCoordinator: AppCoordinator())
    }
}
