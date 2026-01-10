//
//  AppInfiView.swift
//  Settings
//
//  Created by 박현수 on 1/23/25.
//

import SwiftUI
import CommonUI
import AppCoordinatorService

struct AppInfoView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    var diContainer: any SettingsDependencyInjection
    
    var menu: SettingMenuList
    var currentVersion: String
    var updateVersion: String
    
    init(diContainer: any SettingsDependencyInjection,
         menu: SettingMenuList,
         appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        let (currentVersion, updateVersion) = diContainer.getAppVersion()
        self.currentVersion = currentVersion
        self.updateVersion = updateVersion
        self.appCoordinator = appCoordinator
        self.menu = menu
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("현재 버전")
                                .font(.body)
                            Spacer()
                            Text(currentVersion)
                                .font(.headline)
                        }
                        .padding()
                        
                        HStack {
                            Text("최신 버전")
                                .font(.body)
                            Spacer()
                            Text(updateVersion)
                                .font(.headline)
                        }
                        .padding()
                        
                        if isNeedUpdate {
                            ZStack {
                                Color.systemWhite
                                Button(action: handleUpdate) {
                                    Text("앱스토어 바로가기")
                                }
                                .buttonStyle(WMButtonStyle())
                                .frame(height: 50)
                                .padding(.bottom, 30)
                                .fixedSize()
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                
            }
            .padding()
            
           
        }
        .padding(30)
        .navigationTitle(LocalizedStringKey(menu.name))
    }
    
    func handleUpdate() {
        AppCoordinator.showAppStore()
    }
    
    var isNeedUpdate: Bool {
        updateVersion.compareVersion(to: currentVersion) == .orderedDescending
    }
}

#Preview {
    AppInfoView(diContainer: SettingsMockDIContainer(), menu: .account, appCoordinator: AppCoordinator())
}

extension String {
    func compareVersion(to otherVersion: String) -> ComparisonResult {
        return self.compare(otherVersion, options: .numeric)
    }
}
