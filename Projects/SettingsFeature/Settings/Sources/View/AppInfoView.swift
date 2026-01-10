//
//  AppInfoView.swift
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
        List {
            // 버전 정보 섹션
            Section {
                HStack {
                    Text("현재 버전")
                        .font(.body)
                    Spacer()
                    Text(currentVersion)
                        .font(.body)
                        .foregroundStyle(Color.secondary)
                }

                HStack {
                    Text("최신 버전")
                        .font(.body)
                    Spacer()
                    HStack(spacing: 6) {
                        Text(updateVersion)
                            .font(.body)
                            .foregroundStyle(Color.secondary)
                        if isNeedUpdate {
                            Text("NEW")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                }
            } header: {
                Text("버전 정보")
            }

            // 업데이트 섹션
            if isNeedUpdate {
                Section {
                    Button {
                        handleUpdate()
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "arrow.down.app.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.blue)
                            }

                            Text("앱스토어에서 업데이트")
                                .font(.body)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("업데이트")
                } footer: {
                    Text("새로운 버전이 출시되었습니다. 업데이트하여 새로운 기능을 사용해보세요.")
                }
            }

        }
        .listStyle(.insetGrouped)
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
    NavigationStack {
        AppInfoView(diContainer: SettingsMockDIContainer(), menu: .appInfo, appCoordinator: AppCoordinator())
    }
}

extension String {
    func compareVersion(to otherVersion: String) -> ComparisonResult {
        return self.compare(otherVersion, options: .numeric)
    }
}
