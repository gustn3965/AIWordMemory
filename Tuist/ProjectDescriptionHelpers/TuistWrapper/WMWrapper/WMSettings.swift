//
//  WMSettings.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation


public typealias WMSettingsDictionary = [String : WMSettingValue]

public struct WMSettings {
    
    var configurations: [WMSettingsConfiguration]

    
    
    public static func talkBaseProject() -> WMSettings {
        let configs: [WMConfiguration] = WMConfiguration.allCases
        var result: [WMSettingsConfiguration] = []
        configs.forEach { config in
            result.append(config.settingsConfiguration(settings: [:], useCocoapods: .noUse))
        }
        return WMSettings(configurations: result)
    }
    
    public static func appTalkUnitTestTarget(_ targetName: String) -> WMSettings {
        appTalkUnitTestSettings(targetName)
    }
    
    public static func appTalkDynamicFramework(_ targetName: String) -> WMSettings {
        appTalkDynamicFrameworkSettings(targetName)
    }
}

extension Dictionary where Key == String, Value == WMSettingValue  {
    public func merging(_ other: WMSettingsDictionary) -> WMSettingsDictionary {
        self.merging(other) { _, new in
            return new
        }
    }
}



public struct WMSettingsConfiguration {
    
    var configuration: WMConfiguration
    var dictionary: WMSettingsDictionary
    var isDebug: Bool
    var xcconfigPath: WMPath?
    
    
    public static func debug(configuration: WMConfiguration,
                             settings: WMSettingsDictionary,
                             useCocoapods: UseCocoapods) -> WMSettingsConfiguration {
        return WMSettingsConfiguration(configuration: configuration,
                                         dictionary: settings,
                                         isDebug: true,
                                         xcconfigPath: useCocoapods.xcconfigPath(configName: configuration.configurationName))
    }
    
    public static func release(configuration: WMConfiguration,
                               settings: WMSettingsDictionary,
                               useCocoapods: UseCocoapods) -> WMSettingsConfiguration {
        return WMSettingsConfiguration(configuration: configuration,
                                         dictionary: settings,
                                         isDebug: false,
                                         xcconfigPath: useCocoapods.xcconfigPath(configName: configuration.configurationName))
    }
    
    
    public enum UseCocoapods {
        case use(WMTarget)
        case noUse
        
        func xcconfigPath(configName: String) -> WMPath? {
            switch self {
            case .use(let talkTarget):
                return .relativeToRoot("PodsXcconfig/\(talkTarget.name).\(configName.lowercased()).xcconfig")
            case .noUse:
                return nil
            }
        }
    }
}


public enum WMSettingValue: ExpressibleByStringInterpolation, ExpressibleByArrayLiteral {
    case string(String)
    case array([String])
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }

    /// Creates an instance initialized with the given elements.
    public init(arrayLiteral elements: String...) {
        self = .array(elements)
    }
}

