//
//  SentenceInspectorFeature.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 2/11/25.
//

import Foundation


// MARK: - sentenceInspector Feature
extension WMTarget {
    public static let sentenceInspectorFeatureProjectName: String = "SentenceInspectorFeature"
    
    public static func sentenceInspectorFeature() -> WMTarget {
        let targetName = "SentenceInspector"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.sentenceInspectorFeatureProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("SentenceInspector/Sources/**")],
                                               resources: [.path("SentenceInspector/Resources/**")],
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
    
    public static func sentenceInspectorUnitTest() -> WMTarget {
        let targetName = "SentenceInspectorUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.sentenceInspectorFeatureProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("SentenceInspector/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: .sentenceInspectorFeature())
                                 ],
                                 scripts: [])
    }
    
    public static func sentenceInspectorSampleApp() -> WMTarget {
        let targetName = "SentenceInspectorSampleApp"
        return .templateAppTarget(name: targetName,
                                  projectName: Self.sentenceInspectorFeatureProjectName,
                                  infoPlist: defaultInfoPlist,
                                  sources: [.path("SampleApp/Sources/**")],
                                  resources: [.path("SampleApp/Resources/**")],
                                  settings: ProjectDescriptionHelpers.sentenceInspectorSampleApp(targetName),
                                  dependencies: [
                                    .currentTarget(target: .sentenceInspectorFeature()),
                                    .currentTarget(target: .aiInterfaceService()),
                                    .currentTarget(target: .dbInterfaceService()),
                                    .currentTarget(target: .speechVoiceInterfaceService()),
                                    .currentTarget(target: .appCoordinatorService()),
                                  ], scripts: [])
    }
}


private func sentenceInspectorSampleApp(_ targetName: String) -> WMSettings {
    
    let configs: [WMConfiguration] = WMConfiguration.allCases
    var result: [WMSettingsConfiguration] = []
    
    configs.forEach { config in
        
        let settings = mtBaseVersioning
            .merging(mtBaseSettings)
            .merging(baseOptimizationSettings(isDebug: config.isDebug))
            .merging(basePreprocessor(by: config))
            .merging(baseAppTalkSettings())
            .merging(basesentenceInspectorProductSetting(by: config, targetName))
            .merging(appsentenceInspectorSettings(by: config, targetName))
        
        result.append(config.settingsConfiguration(settings: settings, useCocoapods: .noUse))
    }
    
    return WMSettings(configurations: result)
}

nonisolated(unsafe)private let APP_ICON_SANDBOX = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON_CBT = WMSettingValue(stringLiteral: "AppIcon")
nonisolated(unsafe)private let APP_ICON = WMSettingValue(stringLiteral: "AppIcon")

private func basesentenceInspectorProductSetting(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    [
        "PRODUCT_NAME": "\(targetName)",
        "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
        "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
        "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
    ]
}
private func appsentenceInspectorSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
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
