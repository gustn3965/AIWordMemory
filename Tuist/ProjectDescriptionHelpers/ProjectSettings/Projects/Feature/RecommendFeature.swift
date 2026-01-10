//
//  RecommendFeature.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 2/13/25.
//

import Foundation

// MARK: - RecommendFeature Feature
extension WMTarget {
    public static let recommendFeatureProjectName: String = "RecommendFeature"
    
    public static func recommendFeature() -> WMTarget {
        let targetName = "Recommend"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.recommendFeatureProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("Recommend/Sources/**")],
                                               resources: [.path("Recommend/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
                                                .currentTarget(target: .commonUIFeature()),
                                                .currentTarget(target: .aiInterfaceService()),
                                                .currentTarget(target: .dbInterfaceService()),
                                                .currentTarget(target: .speechVoiceInterfaceService()),
                                                .currentTarget(target: .appCoordinatorService()),
                                               ],
                                               scripts: [])
    }
    
    public static func recommendUnitTest() -> WMTarget {
        let targetName = "RecommendUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.recommendFeatureProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("Recommend/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: .recommendFeature())
                                 ],
                                 scripts: [])
    }
    
    public static func recommendSampleApp() -> WMTarget {
        let targetName = "RecommendSampleApp"
        return .templateAppTarget(name: targetName,
                                  projectName: Self.recommendFeatureProjectName,
                                  infoPlist: defaultInfoPlist,
                                  sources: [.path("SampleApp/Sources/**")],
                                  resources: [.path("SampleApp/Resources/**")],
                                  settings: ProjectDescriptionHelpers.recommendSampleApp(targetName),
                                  dependencies: [
                                    .currentTarget(target: .recommendFeature()),
                                    .currentTarget(target: .aiInterfaceService()),
                                    .currentTarget(target: .dbInterfaceService()),
                                    .currentTarget(target: .speechVoiceInterfaceService()),
                                    .currentTarget(target: .appCoordinatorService()),
                                  ], scripts: [])
    }
}


private func recommendSampleApp(_ targetName: String) -> WMSettings {
    
    let configs: [WMConfiguration] = WMConfiguration.allCases
    var result: [WMSettingsConfiguration] = []
    
    configs.forEach { config in
        
        let settings = mtBaseVersioning
            .merging(mtBaseSettings)
            .merging(baseOptimizationSettings(isDebug: config.isDebug))
            .merging(basePreprocessor(by: config))
            .merging(baseAppTalkSettings())
            .merging(baseRecommendProductSetting(by: config, targetName))
            .merging(appRecommendSettings(by: config, targetName))
        
        result.append(config.settingsConfiguration(settings: settings, useCocoapods: .noUse))
    }
    
    return WMSettings(configurations: result)
}

nonisolated(unsafe)private let APP_ICON_SANDBOX = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON_CBT = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON = WMSettingValue(stringLiteral: "AppIcon")

private func baseRecommendProductSetting(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    [
        "PRODUCT_NAME": "\(targetName)",
        "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
        "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
        "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
    ]
}
private func appRecommendSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
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
