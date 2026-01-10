//
//  AppTalkUnitTestSettings.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/11/24.
//

import Foundation

//nonisolated(unsafe) private let PRODUCT_NAME = WMSettingValue(stringLiteral: "MacTalkTests")


public func appTalkUnitTestSettings(_ targetName: String) -> WMSettings {
    
    let configs: [WMConfiguration] = WMConfiguration.allCases
    var result: [WMSettingsConfiguration] = []
    
    configs.forEach { config in
        let settings = mtBaseVersioning
            .merging(mtBaseSettings)
            .merging(baseOptimizationSettings(isDebug: config.isDebug))
            .merging(basePreprocessor(by: config))
            .merging(baseAppTalkUnitTestSettings())
            .merging(appTalkUnitTestSettings(by: config, targetName))
        
        result.append(config.settingsConfiguration(settings: settings, useCocoapods: .noUse))
    }
    
    return WMSettings(configurations: result)
}



private func appTalkUnitTestSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    switch config {
    case .mockDebug:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .cbtDebug:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .realDebug:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .real:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": "com.kakao.${PRODUCT_NAME:rfc1034identifier}Mac",
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .mock:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    case .cbt:
        [
//            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(config.talkName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(config.talkName)",
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_ENTITLEMENTS": "",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
            "PROVISIONING_PROFILE": "",                                 // 맥은 appstore에만 제출할거면 필요없다고함.
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "",
            "CODE_SIGN_IDENTITY": APPLE_DEVELOPMENT,
        ]
    }
}
