//
//  WordMemory.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 12/24/24.
//

import Foundation


extension WMTarget {
    
    public static let wordMemoryProjectName: String = "WordMemory"
    
    
    public static func wordMemoryApp() -> WMTarget {
        let targetName = "WordMemoryApp"
        return .templateAppTarget(name: targetName,
                                  projectName: Self.wordMemoryProjectName,
                                  infoPlist: defaultInfoPlist,
                                  sources: [.path("Sources/**")],
                                  resources: [.path("Resources/**")],
                                  settings: ProjectDescriptionHelpers.wordMemoryApp(targetName),
                                  dependencies: [
//                                    .currentTarget(target: .commonUIFeature()),
//                                    .currentTarget(target: .aiInterfaceService()),
//                                    .currentTarget(target: .dbInterfaceService()),
//                                    .currentTarget(target: .appCoordinatorService()),
//                                    .currentTarget(target: .appEntity()),
//                                    .currentTarget(target: .accountInterfaceService()),
                                    
                                    .currentTarget(target: .mainHomeFeature()),
                                    .currentTarget(target: .reviewFeature()),
                                    .currentTarget(target: .searchFeature()),
                                    .currentTarget(target: .sentenceInspectorFeature()),
                                    .currentTarget(target: .recommendFeature()),
                                    .currentTarget(target: .settingsFeature()),
                                    
                                    .currentTarget(target: .aiImplementation()),
                                    .currentTarget(target: .dbImplementation()),
                                    .currentTarget(target: .speechVoiceImplementation()),
                                    .currentTarget(target: .appCoordinatorService()),
                                    .currentTarget(target: .storeKitService()),
                                    .spm(name: "GoogleMobileAds"),
                                  ],
                                  scripts: [])
    }
    
    public static func wordMemoryUnitTest() -> WMTarget {
        let targetName = "WordMemoryUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.wordMemoryProjectName,
                                 infoPlist: [
                                    "CFBundleName": "$(PRODUCT_NAME)",
                                    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                                    "CFBundleVersion": CURRENT_PROJECT_VERSION_VALUE,
                                    "CFBundleShortVersionString": MARKETING_VERSION_VALUE,
                                    // 추가 설정들...
                                 ],
                                 sources: [.path("Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: .wordMemoryApp())
                                 ],
                                 scripts: [])
    }
    
}



private func wordMemoryApp(_ targetName: String) -> WMSettings {
    
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

nonisolated(unsafe)private let APP_ICON_MOCK = WMSettingValue(stringLiteral: "AppIcon-Mock")
nonisolated(unsafe)private let APP_ICON_CBT = WMSettingValue(stringLiteral: "AppIcon-CBT")
nonisolated(unsafe)private let APP_ICON = WMSettingValue(stringLiteral: "AppIcon")

private func baseAppTalkProductSetting(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    
    // cbt, real, mock은  distribution- 배포용. (Certificate)
    // cbtDebug, realDebug, mockDebug은 development-개발용 (Certificate)
    // cbt, cbtDebug 는 같은 bundle identifier
    
    // (identifier-AppIds) 는 - bundle identifier 별로 만들고, (총3개)
    // provisioning profile은 배포용/개발용으로  app id선택해서. 각각 만들어줌. (총6개)
    // provisioning profile은 xcode에서 한번씩 눌러주거나.. 해야함 -_ - ;
    let real: [WMConfiguration] = [.real, .realDebug]
    let cbt: [WMConfiguration] = [.cbt, .cbtDebug]
    if real.contains(config) {
        return [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_ENTITLEMENTS": "\(targetName).entitlements",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": PRODUCT_BUNDLE_IDENTIFIER,
        ]
    } else if cbt.contains(config) {
        return [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_ENTITLEMENTS": "\(targetName).entitlements",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": "com.hyunsu.${PRODUCT_NAME:rfc1034identifier}\(config.archiveName)",
        ]
    } else {
        return [
            "PRODUCT_NAME": "\(targetName)",
            "CODE_SIGN_ENTITLEMENTS": "\(targetName).entitlements",
            "DEVELOPMENT_TEAM": DEVELOPMENT_TEAM,
            "PRODUCT_BUNDLE_IDENTIFIER": "com.hyunsu.${PRODUCT_NAME:rfc1034identifier}\(config.archiveName)",
        ]
    }
    
}
private func appTalkSettings(by config: WMConfiguration, _ targetName: String) -> WMSettingsDictionary {
    switch config {
    
    case .real:
        [
            "WM_APP_DISPLAY_NAME": "AIWord",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DISTRIBUTION,
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.hyunsu.WordMemoryApp", // tuist4 부터 더이상 provisiong관리하지않음.
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON,
        ]
    case .realDebug:
        [
            "WM_APP_DISPLAY_NAME": "AIWord",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DEVELOPMENT,
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.hyunsu.WordMemoryApp", // tuist4 부터 더이상 provisiong관리하지않음.
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON,
        ]
    
    case .cbt:
        [
            "WM_APP_DISPLAY_NAME": "AIWord_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DISTRIBUTION,
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.hyunsu.WordMemoryAppCBTWordMemory", // tuist4 부터 더이상
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_CBT,
        ]
    case .cbtDebug:
        [
            "WM_APP_DISPLAY_NAME": "AIWord_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DEVELOPMENT,
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.hyunsu.WordMemoryAppCBTWordMemory", // tuist4 부터 더이상 provisiong관리하지않음.
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_CBT,
        ]
    case .mock:
        [
            "WM_APP_DISPLAY_NAME": "AIWord_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DISTRIBUTION,
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.hyunsu.WordMemoryAppMockWordMemory", // tuist4 부터 더이상
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_MOCK,
        ]
    case .mockDebug:
        [
            "WM_APP_DISPLAY_NAME": "AIWord_\(config.configurationName)",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": IOS_DEVELOPMENT,
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.hyunsu.WordMemoryAppMockWordMemory", // tuist4 부터 더이상 provisiong관리하지않음.
            "ASSETCATALOG_COMPILER_APPICON_NAME": APP_ICON_MOCK,
        ]
    }
    
}
