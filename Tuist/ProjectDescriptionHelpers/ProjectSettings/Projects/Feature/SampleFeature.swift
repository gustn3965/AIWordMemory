//
//  SampleFeature.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/11/25.
//

import Foundation

extension WMTarget {
    
    public static let sampleFeatureProjectName: String = "SampleFeature"
    
    private static let featureFolderName: String = "Sample"
    private static let sampleAppFolderName: String = "SampleApp"
    
    public static func sampleFeature() -> WMTarget {
        let targetName = "Sample"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.sampleFeatureProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("\(Self.featureFolderName)/Sources/**")],
                                               resources: [.path("\(Self.featureFolderName)/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
//                                                .currentTarget(target: .commonUIFeature()),
//                                                .currentTarget(target: .aiInterfaceService()),
//                                                .currentTarget(target: .dbInterfaceService()),
//                                                .currentTarget(target: .appCoordinatorService()),
//                                                .spm(name: "GoogleMobileAds"),
                                               ],
                                               scripts: [])
    }
    
    public static func sampleUnitTest() -> WMTarget {
        let targetName = "SampleUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.sampleFeatureProjectName,
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
                                    .currentTarget(target: .sampleFeature())
                                 ],
                                 scripts: [])
    }
    
    public static func sampleSampleApp() -> WMTarget {
        let targetName = "SampleSampleApp"
        return .templateAppTarget(name: targetName,
                                  projectName: Self.sampleFeatureProjectName,
                                  infoPlist: defaultInfoPlist,
                                  sources: [.path("\(Self.sampleAppFolderName)/Sources/**")],
                                  resources: [.path("\(Self.sampleAppFolderName)/Resources/**")],
                                  settings: ProjectDescriptionHelpers.mainHomeSampleApp(targetName),
                                  dependencies: [
                                    .currentTarget(target: .sampleFeature()),
//                                    .currentTarget(target: .aiInterfaceService()),
//                                    .currentTarget(target: .dbInterfaceService()),
//                                    .currentTarget(target: .appCoordinatorService()),
//                                    .spm(name: "GoogleMobileAds"),
                                  ], scripts: [])
    }
}



private func mainHomeSampleApp(_ targetName: String) -> WMSettings {
    
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
