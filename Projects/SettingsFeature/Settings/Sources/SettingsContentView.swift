//
//  SampleView.swift
//  AIManifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import AppCoordinatorService

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
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.menuList, id: \.self) { (menuList: [SettingMenuList]) in
                        SectionView(menuList: menuList, onItemTap: { menuItem in
                            selectedMenu = menuItem
                        })
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
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
            .scrollBounceBehavior(.basedOnSize)
        }
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
