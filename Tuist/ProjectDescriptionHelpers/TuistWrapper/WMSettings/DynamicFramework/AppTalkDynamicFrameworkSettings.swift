//
//  AppTalkDynamicFrameworkSettings.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 12/23/24.
//

import Foundation

//nonisolated(unsafe) private let PRODUCT_NAME = WMSettingValue(stringLiteral: "MacTalkTests")

public func appTalkDynamicFrameworkSettings(_ targetName: String) -> WMSettings {
    
    let configs: [WMConfiguration] = WMConfiguration.allCases
    var result: [WMSettingsConfiguration] = []
    
    configs.forEach { config in
        
        let settings = mtBaseVersioning
            .merging(mtBaseSettings)
            .merging(baseOptimizationSettings(isDebug: config.isDebug))
            .merging(basePreprocessor(by: config))
            .merging(baseAppDynamicSettings())
            .merging(appTalkDynamicFrameworkSettings(by: config, targetName))
        
        result.append(config.settingsConfiguration(settings: settings, useCocoapods: .noUse))
    }
    
    return WMSettings(configurations: result)
}



private func appTalkDynamicFrameworkSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    switch config {
    case .mockDebug:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
//            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .cbtDebug:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
//            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_CBT,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .realDebug:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
//            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_CBT,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .real:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .mock:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
//            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_SANDBOX,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .cbt:
        [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": CODE_SIGN_ENTITLEMENTS,
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
//            "INFOPLIST_FILE": INFOPLIST_FILE,
//            "GENERATE_INFOPLIST_FILE": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
//            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_CBT,
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    }
}
