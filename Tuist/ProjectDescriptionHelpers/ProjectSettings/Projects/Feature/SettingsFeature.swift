//
//  SettingsFeature.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 12/28/24.
//

import Foundation

extension WMTarget {
    
    public static let settingsFeatureProjectName: String = "SettingsFeature"
    private static let featureFolderName: String = "Settings"
    private static let sampleAppFolderName: String = "SampleApp"
    
    public static func settingsFeature() -> WMTarget {
        let targetName = "Settings"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.settingsFeatureProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("\(Self.featureFolderName)/Sources/**")],
                                               resources: [.path("\(Self.featureFolderName)/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
                                                .currentTarget(target: .commonUIFeature()),
                                                .currentTarget(target: .dbInterfaceService()),
                                                .currentTarget(target: .appCoordinatorService()),
                                                .currentTarget(target: .storeKitService()),
//                                                .spm(name: "GoogleMobileAds"),
                                               ],
                                               scripts: [])
    }
    
    public static func settingsUnitTest() -> WMTarget {
        let targetName = "SettingsUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.settingsFeatureProjectName,
                                 infoPlist: [
                                    "CFBundleName": "$(PRODUCT_NAME)",
                                    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                                    "CFBundleVersion": CURRENT_PROJECT_VERSION_VALUE,
                                    "CFBundleShortVersionString": MARKETING_VERSION_VALUE,
                                    // 추가 설정들...
                                 ],
                                 sources: [.path("\(Self.featureFolderName)/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: .settingsFeature())
                                 ],
                                 scripts: [])
    }
    
    public static func settingsSampleApp() -> WMTarget {
        let targetName = "SettingsSampleApp"
        return .templateAppTarget(name: targetName,
                                  projectName: Self.settingsFeatureProjectName,
                                  infoPlist: defaultInfoPlist,
                                  sources: [.path("\(Self.sampleAppFolderName)/Sources/**")],
                                  resources: [.path("\(Self.sampleAppFolderName)/Resources/**")],
                                  settings: ProjectDescriptionHelpers.settingsSampleApp(targetName),
                                  dependencies: [
                                    .currentTarget(target: .settingsFeature()),
                                    .currentTarget(target: .dbInterfaceService()),
                                    .currentTarget(target: .appCoordinatorService()),
                                    .currentTarget(target: .storeKitService()),
//                                    .spm(name: "GoogleMobileAds"),
                                  ], scripts: [])
    }
}



private func settingsSampleApp(_ targetName: String) -> WMSettings {
    
    let configs: [WMConfiguration] = WMConfiguration.allCases
    var result: [WMSettingsConfiguration] = []
    
    configs.forEach { config in
        
        let settings = mtBaseVersioning
            .merging(mtBaseSettings)
            .merging(baseOptimizationSettings(isDebug: config.isDebug))
            .merging(basePreprocessor(by: config))
            .merging(baseAppTalkSettings())
            .merging(baseAppTalkProductSetting(by: config, targetName))
            .merging(appTalkSettings(by: config, targetName))
        
        result.append(config.settingsConfiguration(settings: settings, useCocoapods: .noUse))
    }
    
    return WMSettings(configurations: result)
}

nonisolated(unsafe)private let APP_ICON_SANDBOX = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON_CBT = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON = WMSettingValue(stringLiteral: "AppIcon")

private func baseAppTalkProductSetting(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    [
        "PRODUCT_NAME": "\(targetName)",
        "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
        "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
        "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
    ]
}
private func appTalkSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    switch config {
    case .mockDebug:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    case .cbtDebug:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    case .realDebug:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    case .real:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    case .mock:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    case .cbt:
        [
            "WM_APP_DISPLAY_NAME": "\(targetName)_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
        ]
    }
}
