//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService
import CommonUI

public protocol SettingsUsecase {}
struct SettingsMockUsecase: SettingsUsecase {}


class SettingsViewModel: ObservableObject {
    
    @Published var menuList: [[SettingMenuList]] = []
    
    init(menuList: [SettingMenuList]) {
        
        var dict: [SettingMenuList.Group: [SettingMenuList]] = [:]
        SettingMenuList.Group.allCases.forEach {
            dict[$0] = []
        }
        
        menuList.forEach { menu in
            dict[menu.group] = (dict[menu.group] ?? []) + [menu]
        }
        
        self.menuList = dict.sorted(by: { $0.key.rawValue < $1.key.rawValue})
            .map { $0.value }
            .filter { $0.isEmpty == false }
    }

}

public struct SettingsContentView: View {
    var diContainer: any SettingsDependencyInjection
    @ObservedObject var appCoordinator: AppCoordinator
    
    @StateObject var viewModel: SettingsViewModel
    @State var selectedMenu: SettingMenuList?
    
    public init(diContainer: any SettingsDependencyInjection, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinator
        _viewModel = StateObject(wrappedValue: SettingsViewModel(menuList: diContainer.makeMenuList()))
    }
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.menuList, id: \.self) { (menuList: [SettingMenuList]) in
                    Section {
                        ForEach(menuList) { item in
                            Button {
                                selectedMenu = item
                            } label: {
                                SettingsRow(item: item)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("설정")
            .navigationDestination(item: $selectedMenu, destination: { menu in
                switch menu {
                case .notice:
                    NoticeView(menu: menu)
                case .feedback:
                    FeedbackView(menu: menu)
                case .appInfo:
                    AppInfoView(diContainer: diContainer, menu: menu, appCoordinator: appCoordinator)
                case .account:
                    AccountView(diContainer: diContainer, menu: menu, appCoordinator: appCoordinator)
                case .tag:
                    TagListView(diContainer: diContainer, menu: menu)
                case .cbtResetGPTChances:
                    TESTResetGPTChancesView(diContainer: diContainer, menu: menu)
                case .cbtChagneSpeechImplementation:
                    TESTSpeechChangeView(diContainer: diContainer, menu: menu)
                case .cbtResetAppStorage:
                    TESTAppStorageView(diContainer: diContainer, menu: menu)
                }
            })
        }
    }
}

private struct SettingsRow: View {
    let item: SettingMenuList

    var body: some View {
        HStack(spacing: 12) {
            Image(item.iconName, bundle: CommonUIResources.bundle)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.accentColor)

            Text(LocalizedStringKey(item.name))
                .foregroundStyle(Color.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .contentShape(Rectangle())
    }
}

struct SettingsContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        SettingsContentView(diContainer: SettingsMockDIContainer(),
                            appCoordinator: AppCoordinator())
            .tint(Color.systemBlack)
            .environment(\.locale, .init(identifier: "en"))
    }
}
