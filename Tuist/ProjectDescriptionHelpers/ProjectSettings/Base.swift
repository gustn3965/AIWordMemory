import ProjectDescription



// MARK: - 프로젝트 설정, 빌드번호,swift, 인증서,

public let CURRENT_PROJECT_VERSION_VALUE = "10"
public let MARKETING_VERSION_VALUE = "2.0.0"
public let SWIFT_VERSION_VALUE = "6.2"
public let deploymentTargetiOS = "17.4"

nonisolated(unsafe) public let CODE_SIGN_ENTITLEMENTS = WMSettingValue(stringLiteral: "")
nonisolated(unsafe) public let PRODUCT_BUNDLE_IDENTIFIER = WMSettingValue(stringLiteral: "com.hyunsu.${PRODUCT_NAME:rfc1034identifier}")

public let bundlePrefix = "com.hyunsu."
nonisolated(unsafe) public let DEVELOPMENT_TEAM = WMSettingValue(stringLiteral: "WVLV77R6X7") // team
nonisolated(unsafe) public let APPLE_DEVELOPMENT = WMSettingValue(stringLiteral: "") // identifier - 개발
nonisolated(unsafe) public let APPLE_DISTRIBUTION = WMSettingValue(stringLiteral: "") // identitier - 배포

//nonisolated(unsafe) public let IOS_DEVELOPMENT = WMSettingValue(stringLiteral: "Apple Development: HyunSu Park (CGWYA7KBNS)") // identifier - 개발
nonisolated(unsafe) public let IOS_DISTRIBUTION = WMSettingValue(stringLiteral: "Apple Distribution: HyunSu Park (WVLV77R6X7)") // identitier - 배포
nonisolated(unsafe) public let IOS_DEVELOPMENT = WMSettingValue(stringLiteral: "Apple Development") // identifier - 개발
//nonisolated(unsafe) public let IOS_DISTRIBUTION = WMSettingValue(stringLiteral: "Apple Distribution") // identitier - 배포






// MARK: - Info.plist
public let defaultInfoPlist = [
    "CFBundleName": "$(PRODUCT_NAME)",
    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
    "CFBundleVersion": CURRENT_PROJECT_VERSION_VALUE,
    "CFBundleShortVersionString": MARKETING_VERSION_VALUE,
    "CFBundleDisplayName": "$(WM_APP_DISPLAY_NAME)",
    "UILaunchStoryboardName": "LaunchScreen",
    "ITSAppUsesNonExemptEncryption": "NO"   // 수출 암호화 규정 안함.
]



// MARK: - Configuration / Real, CBT, Mock
public enum WMConfiguration: CaseIterable {
    
    case realDebug
    case real
    
    case cbtDebug
    case cbt
    
    case mockDebug
    case mock
    
    var isDebug: Bool {
        switch self {
        case .real, .cbt, .mock:
            return false
        case .cbtDebug, .mockDebug, .realDebug:
            return true
        }
    }
    
    var talkName: String {
        switch self {
        case .mock:
            return "MockWordMemory"
        case .mockDebug:
            return "MockWordMemory"
        case .cbtDebug:
            return "CBTWordMemory"
        case .cbt:
            return "CBTWordMemory"
        case .real:
            return "WordMemory"
        case .realDebug:
            return "WordMemory"
        }
    }
    
    var configurationName: String {
        switch self {
        case .mock:
            return "Mock"
        case .mockDebug:
            return "Mock(Debug)"
        case .cbtDebug:
            return "CBT(Debug)"
        case .cbt:
            return "CBT"
        case .real:
            return "Real"
        case .realDebug:
            return "Real(Debug)"
        }
    }
    
    var schemeName: String {
        switch self {
        case .mock:
            return "Mock"
        case .mockDebug:
            return "Mock(Debug)"
        case .cbtDebug:
            return "CBT(Debug)"
        case .cbt:
            return "CBT"
        case .real:
            return "Real"
        case .realDebug:
            return "Real(Debug)"
        }
    }
    
    var archiveName: String {
        switch self {
        case .mock:
            return "MockWordMemory"
        case .mockDebug:
            return "MockWordMemory"
        case .cbtDebug:
            return "CBTWordMemory"
        case .cbt:
            return "CBTWordMemory"
        case .real:
            return "WordMemory"
        case .realDebug:
            return "WordMemory"
        }
    }
    
    func settingsConfiguration(settings: WMSettingsDictionary, useCocoapods: WMSettingsConfiguration.UseCocoapods) -> WMSettingsConfiguration {
        switch self {
        case .mockDebug, .cbtDebug, .realDebug:
            return .debug(configuration: self, settings: settings, useCocoapods: useCocoapods)
        case .real, .mock, .cbt:
            return .release(configuration: self, settings: settings, useCocoapods: useCocoapods)
        }
    }

    
    
    
    
}
